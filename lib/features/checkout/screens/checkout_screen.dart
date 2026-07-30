import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/phone_display.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../addresses/models/address_model.dart';
import '../../addresses/screens/addresses_screen.dart';
import '../../addresses/services/address_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../notifications/services/push_messaging_service.dart';
import '../../orders/controllers/order_controller.dart';
import '../services/hesab_pay_status_poller.dart';
import 'hesabpay_webview_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';

/// Checkout: address, payment method, order summary. API: /checkout.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

enum _PaymentMethod { cod, hesabPay }

class _CheckoutScreenState extends State<CheckoutScreen> {
  _PaymentMethod _paymentMethod = _PaymentMethod.cod;
  bool _isSubmitting = false;
  bool _isLoadingAddresses = true;
  final AddressService _addressService = AddressService();
  List<AddressModel> _addresses = const [];
  AddressModel? _selectedAddress;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _loadAddresses();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int? _savedAddressId() {
    return _prefs?.getInt(AppConstants.checkoutSelectedAddressIdKey);
  }

  Future<void> _saveAddressId(int id) async {
    await _prefs?.setInt(AppConstants.checkoutSelectedAddressIdKey, id);
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final list = await _addressService.getAddresses();
      if (!mounted) return;
      final savedId = _savedAddressId();
      AddressModel? selectedBySaved;
      if (savedId != null) {
        for (final address in list) {
          if (address.id == savedId) {
            selectedBySaved = address;
            break;
          }
        }
      }
      final selected = list.cast<AddressModel?>().firstWhere(
            (a) => selectedBySaved != null && a?.id == selectedBySaved.id,
            orElse: () => list.cast<AddressModel?>().firstWhere(
            (a) => a?.isDefault == true,
            orElse: () => list.isNotEmpty ? list.first : null,
          ),
          );
      setState(() {
        _addresses = list;
        _selectedAddress = selected;
      });
      if (selected != null) {
        await _saveAddressId(selected.id);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _addresses = const [];
        _selectedAddress = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
      }
    }
  }

  Future<void> _openAddressPicker() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingAddresses) return;

    if (_addresses.isEmpty) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddressesScreen()),
      );
      await _loadAddresses();
      return;
    }

    final picked = await showModalBottomSheet<AddressModel>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                l10n.deliveryAddress,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._addresses.map(
                (a) => ListTile(
                  onTap: () => Navigator.of(ctx).pop(a),
                  leading: Icon(
                    _selectedAddress?.id == a.id
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  title: Text(
                    a.formattedLabel.isNotEmpty ? a.formattedLabel : a.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.fullName.trim().isNotEmpty) Text(a.fullName.trim()),
                      if (a.phone.trim().isNotEmpty)
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(displayAfghanLocalPhone(a.phone)),
                          ),
                        ),
                      if (a.displayAddress.trim().isNotEmpty)
                        Text(a.displayAddress.trim()),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  );
                  await _loadAddresses();
                },
                child: Text(l10n.addAddress),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedAddress = picked);
      await _saveAddressId(picked.id);
    }
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final cart = Get.find<CartController>();
    final auth = Get.find<AuthController>();
    final restaurantId = cart.restaurantId;
    if (restaurantId == null || cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cartEmpty)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_selectedAddress == null) {
        throw Exception('Please select a delivery address');
      }
      await cart.recalculate();
      if (!mounted) return;

      final calcFresh = cart.calculation.value;
      if (calcFresh == null) {
        throw Exception(
          'Could not confirm cart totals. Please check your connection and try again.',
        );
      }

      final items = cart.itemRequests.map((e) => e.toJson()).toList();

      final deliveryPhone = _selectedAddress?.phone.isNotEmpty == true
          ? _selectedAddress!.phone
          : (auth.currentUser?.phone ?? '');
      if (deliveryPhone.isEmpty) {
        throw Exception('Please add phone number in your profile or address');
      }

      final deliveryName = _selectedAddress?.fullName.isNotEmpty == true
          ? _selectedAddress!.fullName
          : (auth.currentUser?.name ?? 'Customer');
      final deliveryAddress = _selectedAddress?.displayAddress ?? '';
      if (deliveryAddress.isEmpty) {
        throw Exception('Please select a valid delivery address');
      }

      final payload = <String, dynamic>{
        'restaurant_id': restaurantId,
        'items': items,
        'address_id': _selectedAddress!.id,
        'delivery_name': deliveryName,
        'delivery_phone': deliveryPhone,
        'delivery_address': deliveryAddress,
        'payment_method': _paymentMethod == _PaymentMethod.hesabPay ? 'hesabpay' : 'cod',
        'subtotal': calcFresh.subtotal,
        'delivery_fee': calcFresh.deliveryFee,
        'tax': calcFresh.tax,
        'total': calcFresh.total,
      };

      dynamic data;
      if (_paymentMethod == _PaymentMethod.hesabPay) {
        final res = await ApiClient.dio.post(
          ApiConstants.payAbsoluteUrl,
          data: payload,
        );
        data = res.data;
      } else {
        final codPayload = Map<String, dynamic>.from(payload)
          ..['payment_method'] = 'cash';
        final res = await ApiClient.dio.post(
          ApiConstants.checkout,
          data: codPayload,
        );
        data = res.data;
      }

      final map = _asStringKeyMap(data);
      final paymentUrl = map['payment_url']?.toString();
      final orderId = _extractOrderId(map);

      if (!_isCheckoutSuccessful(map)) {
        throw Exception(_checkoutErrorMessage(map));
      }

      if (_paymentMethod == _PaymentMethod.hesabPay && paymentUrl != null && paymentUrl.isNotEmpty) {
        if (orderId == null) {
          throw Exception('Order ID missing from server');
        }
        await _prefs?.setInt(AppConstants.pendingHesabPayOrderIdKey, orderId);
        await _prefs?.setBool(AppConstants.hesabPayInAppFlowKey, true);
        bool? webViewSuccess;
        try {
          webViewSuccess = await navigator.push<bool>(
            MaterialPageRoute(
              builder: (_) => HesabPayWebViewScreen(initialUrl: paymentUrl),
            ),
          );
        } finally {
          await _prefs?.setBool(AppConstants.hesabPayInAppFlowKey, false);
        }
        if (!mounted) return;
        await _completeHesabPayAfterWebView(
          orderId,
          cart,
          webViewReportedSuccess: webViewSuccess,
        );
      } else {
        if (!mounted) return;
        await _refreshOrdersAfterCheckout();
        if (!mounted) return;
        final placedOrderId = orderId;
        cart.clear();
        Navigator.of(context).popUntil((route) => route.isFirst);
        showAppOrderPlacedNoticeAfterCheckout(
          message: l10n.orderPlacedSnackbar,
          orderId: placedOrderId,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_checkoutErrorMessageFromException(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, dynamic> _asStringKeyMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  bool _isCheckoutSuccessful(Map<String, dynamic> map) {
    if (map['status'] == true || map['success'] == true) return true;
    final paymentUrl = map['payment_url']?.toString();
    if (paymentUrl != null && paymentUrl.isNotEmpty) return true;
    if (map['order_id'] != null || map['order'] != null) return true;
    final nested = map['data'];
    if (nested is Map) {
      if (nested['order'] != null || nested['order_id'] != null) return true;
    }
    return false;
  }

  String _checkoutErrorMessage(Map<String, dynamic> map) {
    final message = map['message']?.toString();
    if (message != null && message.isNotEmpty) return message;
    final errors = map['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
      return first.toString();
    }
    return 'Checkout failed';
  }

  String _checkoutErrorMessageFromException(Object error) {
    if (error is DioException) return parseDioError(error);
    if (error is Exception) {
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      if (message.isNotEmpty) return message;
    }
    return userFriendlyErrorMessage(error);
  }

  int? _extractOrderId(Map<String, dynamic> map) {
    final direct = map['order_id'];
    if (direct is int) return direct;
    if (direct is String) return int.tryParse(direct);
    final order = map['order'];
    if (order is Map) {
      final id = order['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    final nested = map['data'];
    if (nested is Map) {
      final nestedOrderId = nested['order_id'];
      if (nestedOrderId is int) return nestedOrderId;
      if (nestedOrderId is String) return int.tryParse(nestedOrderId);
      final nestedOrder = nested['order'];
      if (nestedOrder is Map) {
        final id = nestedOrder['id'];
        if (id is int) return id;
        if (id is String) return int.tryParse(id);
      }
    }
    return null;
  }

  Future<void> _completeHesabPayAfterWebView(
    int orderId,
    CartController cart, {
    bool? webViewReportedSuccess,
  }) async {
    HesabPayPaymentOutcome outcome;
    if (webViewReportedSuccess == true) {
      outcome = await HesabPayStatusPoller.confirmAfterGatewaySuccess(
        orderId: orderId,
      );
    } else {
      outcome = await HesabPayStatusPoller.poll(orderId: orderId);
    }

    if (outcome == HesabPayPaymentOutcome.pending) {
      outcome = await HesabPayStatusPoller.poll(
        orderId: orderId,
        maxAttempts: 10,
        delayBetweenAttempts: const Duration(milliseconds: 1500),
      );
    }

    await _prefs?.remove(AppConstants.pendingHesabPayOrderIdKey);
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;

    Future<void> showSuccess() async {
      await _refreshOrdersAfterCheckout();
      if (!mounted) return;
      cart.clear();
      Navigator.of(context).popUntil((route) => route.isFirst);
      showAppOrderPlacedNoticeAfterCheckout(
        message: loc.paymentSuccessfulConfirmed,
        orderId: orderId,
      );
    }

    switch (outcome) {
      case HesabPayPaymentOutcome.paid:
        await showSuccess();
      case HesabPayPaymentOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.paymentFailedOrCancelled)),
        );
      case HesabPayPaymentOutcome.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.paymentNotCompleted)),
        );
    }
  }

  Future<void> _refreshOrdersAfterCheckout() async {
    await PushMessagingService.refreshTokenCache();
    await PushMessagingService.syncTokenToBackend();
    if (!Get.isRegistered<OrderController>()) return;
    try {
      await Get.find<OrderController>().loadOrders();
    } catch (_) {
      // Non-blocking: checkout should still finish even if list refresh fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = Get.find<CartController>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkout)),
      body: MaxWidthBody(
        child: ListView(
          padding: EdgeInsets.all(context.pageHorizontalPadding),
          children: [
          Text(l10n.deliveryAddress, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _CheckoutAddressCard(
            isLoading: _isLoadingAddresses,
            address: _selectedAddress,
            emptyLabel: l10n.selectOrAddAddress,
            loadingLabel: l10n.checkoutLoadingAddresses,
            onTap: _openAddressPicker,
          ),
          const SizedBox(height: 24),
          Text(l10n.paymentMethod, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: _paymentMethodLeadingIcon(
                    child: Icon(
                      Icons.home_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  title: Text(l10n.cashOnDelivery),
                  trailing: _paymentMethod == _PaymentMethod.cod
                      ? Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => setState(() => _paymentMethod = _PaymentMethod.cod),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/hesabpay.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(l10n.hesabPayTitle),
                  subtitle: Text(l10n.payOnlineSecurely),
                  trailing: _paymentMethod == _PaymentMethod.hesabPay
                      ? Icon(Icons.check_rounded, color: AppColors.primary)
                      : null,
                  onTap: () => setState(() => _paymentMethod = _PaymentMethod.hesabPay),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.orderSummary, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.subtotal), Text(AppCurrency.format(cart.subtotal, decimalDigits: 2))]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.delivery), Text(AppCurrency.format(cart.deliveryFee, decimalDigits: 2))]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.total, style: Theme.of(context).textTheme.titleMedium), Text(AppCurrency.format(cart.total, decimalDigits: 2), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _isSubmitting ? 'Please wait...' : l10n.placeOrder,
            onPressed: _isSubmitting ? null : _placeOrder,
          ),
        ],
        ),
      ),
    );
  }

  Widget _paymentMethodLeadingIcon({required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _CheckoutAddressCard extends StatelessWidget {
  const _CheckoutAddressCard({
    required this.isLoading,
    required this.address,
    required this.emptyLabel,
    required this.loadingLabel,
    required this.onTap,
  });

  final bool isLoading;
  final AddressModel? address;
  final String emptyLabel;
  final String loadingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          loadingLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : address == null
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              emptyLabel,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : _AddressDetails(address: address!),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressDetails extends StatelessWidget {
  const _AddressDetails({required this.address});

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = address.fullName.trim();
    final phone = displayAfghanLocalPhone(address.phone).trim();
    final line = address.displayAddress.trim();
    final label = address.formattedLabel.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (name.isNotEmpty) ...[
          Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
        ],
        if (phone.isNotEmpty) ...[
          _AddressMetaRow(
            icon: Icons.phone_rounded,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (line.isNotEmpty)
          _AddressMetaRow(
            icon: Icons.home_rounded,
            crossAxisAlignment: CrossAxisAlignment.start,
            child: Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressMetaRow extends StatelessWidget {
  const _AddressMetaRow({
    required this.icon,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final IconData icon;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: crossAxisAlignment == CrossAxisAlignment.start ? 2 : 0,
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}
