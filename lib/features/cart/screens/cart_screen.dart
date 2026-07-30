import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_currency.dart';
import '../../../core/widgets/app_network_image.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_model.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';

/// Cart screen: item cards with image/name/price/qty,
/// order summary, and proceed-to-checkout CTA. Matches modern food-delivery UX.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CartController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.cart,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        
      ),
      body: MaxWidthBody(
        child: Obx(() {
          if (ctrl.items.isEmpty) {
            return _CartEmptyState(l10n: l10n);
          }
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        context.pageHorizontalPadding,
                        8,
                        context.pageHorizontalPadding,
                        16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = ctrl.items[index];
                            return _CartItemCard(
                              item: item,
                              restaurantName: ctrl.restaurantName,
                              l10n: l10n,
                              onIncrement: () => ctrl.updateQuantity(
                                item.foodId,
                                item.quantity + 1,
                                variantId: item.variantId,
                              ),
                              onDecrement: () {
                                if (item.quantity <= 1) {
                                  ctrl.removeItem(
                                    item.foodId,
                                    variantId: item.variantId,
                                  );
                                } else {
                                  ctrl.updateQuantity(
                                    item.foodId,
                                    item.quantity - 1,
                                    variantId: item.variantId,
                                  );
                                }
                              },
                              onRemove: () => ctrl.removeItem(
                                item.foodId,
                                variantId: item.variantId,
                              ),
                            );
                          },
                          childCount: ctrl.items.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _OrderSummarySection(
                        subtotal: ctrl.subtotal,
                        deliveryFee: ctrl.deliveryFee,
                        total: ctrl.total,
                        l10n: l10n,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    8,
                    context.pageHorizontalPadding,
                    16,
                  ),
                  child: _ProceedToCheckoutButton(
                    total: ctrl.total,
                    l10n: l10n,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CartEmptyState extends StatelessWidget {
  const _CartEmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.cartEmpty,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cartEmptyHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // TextButton(
            //   onPressed: () => Navigator.of(context).pop(),
            //   child: Text(l10n.goBack),
            // ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.restaurantName,
    required this.l10n,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItemResponse item;
  final String? restaurantName;
  final AppLocalizations l10n;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  static const double _imageSize = 88;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: item.imageUrl!,
                        width: _imageSize,
                        height: _imageSize,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(context),
                        errorWidget: (_, __, ___) => _placeholder(context),
                      )
                    : _placeholder(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurantName != null && restaurantName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        restaurantName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.variantName != null && item.variantName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.sizeLabel}: ${item.variantName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.totalPrice),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: Icon(Icons.delete_outline_rounded, size: 22, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: onDecrement,
                        isPrimary: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: onIncrement,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: _imageSize,
      height: _imageSize,
      color: AppColors.primary.withOpacity(0.12),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary.withOpacity(0.6), size: 36),
    );
  }

  String _formatPrice(double value) => AppCurrency.format(value, decimalDigits: 2);
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap, required this.isPrimary});

  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 20, color: isPrimary ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.l10n,
  });

  final double subtotal;
  final double deliveryFee;
  final double total;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderSummaryCaps.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.subtotal, value: subtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: l10n.delivery, value: deliveryFee),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.total,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                _format(total),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _format(double v) => AppCurrency.format(v, decimalDigits: 2);
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        Text(_format(value), style: theme.textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  String _format(double v) => AppCurrency.format(v, decimalDigits: 2);
}

class _ProceedToCheckoutButton extends StatelessWidget {
  const _ProceedToCheckoutButton({required this.total, required this.l10n, required this.onPressed});

  final double total;
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(16),
      shadowColor: AppColors.primary.withOpacity(0.4),
      elevation: 6,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.proceedToCheckout,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Text(
                AppCurrency.format(total, decimalDigits: 2),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
