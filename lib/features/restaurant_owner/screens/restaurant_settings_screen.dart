import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/widgets/app_page_loading.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/controllers/auth_controller.dart';
import '../models/restaurant_owner_models.dart';
import '../services/restaurant_owner_service.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  State<RestaurantSettingsScreen> createState() => _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  final RestaurantOwnerService _service = RestaurantOwnerService();
  final AuthController _auth = Get.find<AuthController>();

  final _nameController = TextEditingController();
  final _nameFaController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _freeDeliveryController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _acceptsCash = false;
  bool _acceptsOnlinePayment = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<RestaurantHour> _hours = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getSettings();
      final restaurant = data.restaurant;
      _nameController.text = restaurant.name;
      _nameFaController.text = restaurant.nameFa ?? '';
      _phoneController.text = restaurant.phone ?? '';
      _emailController.text = restaurant.email ?? '';
      _descriptionController.text = restaurant.description ?? '';
      _addressController.text = restaurant.address ?? '';
      _deliveryFeeController.text = restaurant.deliveryFee.toStringAsFixed(0);
      _minimumOrderController.text = restaurant.minimumOrder.toStringAsFixed(0);
      _freeDeliveryController.text = restaurant.freeDeliveryAbove.toStringAsFixed(0);
      _prepTimeController.text = restaurant.avgPreparationTime.toString();
      _latitudeController.text = restaurant.latitude?.toString() ?? '';
      _longitudeController.text = restaurant.longitude?.toString() ?? '';
      _acceptsCash = restaurant.acceptsCash;
      _acceptsOnlinePayment = restaurant.acceptsOnlinePayment;
      _hours = List<RestaurantHour>.from(
        data.hours.isEmpty
            ? List.generate(7, (index) => RestaurantHour(dayOfWeek: index, openTime: '09:00', closeTime: '22:00'))
            : data.hours,
      );
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFriendlyErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.updateSettings({
        'name': _nameController.text.trim(),
        'name_fa': _nameFaController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'delivery_fee': double.tryParse(_deliveryFeeController.text.trim()) ?? 0,
        'minimum_order': double.tryParse(_minimumOrderController.text.trim()) ?? 0,
        'free_delivery_above': double.tryParse(_freeDeliveryController.text.trim()) ?? 0,
        'avg_preparation_time': int.tryParse(_prepTimeController.text.trim()) ?? 15,
        'latitude': double.tryParse(_latitudeController.text.trim()),
        'longitude': double.tryParse(_longitudeController.text.trim()),
        'accepts_cash': _acceptsCash,
        'accepts_online_payment': _acceptsOnlinePayment,
        'hours': _hours.map((e) => e.toJson()).toList(),
      });
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.restaurantSettingsUpdated), backgroundColor: AppColors.success),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _updateHour(int index, RestaurantHour hour) {
    final next = List<RestaurantHour>.from(_hours);
    next[index] = hour;
    setState(() => _hours = next);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _deliveryFeeController.dispose();
    _minimumOrderController.dispose();
    _freeDeliveryController.dispose();
    _prepTimeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekdayFmt = DateFormat.E(Localizations.localeOf(context).toLanguageTag());
    return Scaffold(
      appBar: AppBar(title: Text(l10n.restaurantSettingsTitle)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _loading
          ? const AppPageLoading()
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _section(
                        title: l10n.basicInformation,
                        child: Column(
                          children: [
                            _field(_nameController, l10n.restaurantNameField),
                            const SizedBox(height: 12),
                            _field(_nameFaController, l10n.restaurantNameDariField),
                            const SizedBox(height: 12),
                            _field(_phoneController, l10n.phone),
                            const SizedBox(height: 12),
                            _field(_emailController, l10n.email),
                            const SizedBox(height: 12),
                            _field(_addressController, l10n.detailRowAddress),
                            const SizedBox(height: 12),
                            _field(_descriptionController, l10n.descriptionFieldLabel, maxLines: 3),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: l10n.deliveryAndPayment,
                        child: Column(
                          children: [
                            _field(_deliveryFeeController, l10n.deliveryFeeFieldLabel, keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _field(_minimumOrderController, l10n.minimumOrderFieldLabel, keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _field(_freeDeliveryController, l10n.freeDeliveryAboveFieldLabel, keyboardType: TextInputType.number),
                            const SizedBox(height: 12),
                            _field(_prepTimeController, l10n.averagePrepTimeFieldLabel, keyboardType: TextInputType.number),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _acceptsCash,
                              onChanged: (value) => setState(() => _acceptsCash = value),
                              title: Text(l10n.acceptCashOnDelivery),
                            ),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _acceptsOnlinePayment,
                              onChanged: (value) => setState(() => _acceptsOnlinePayment = value),
                              title: Text(l10n.acceptOnlinePayment),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: l10n.locationSection,
                        child: Column(
                          children: [
                            _field(_latitudeController, 'Latitude', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                            const SizedBox(height: 12),
                            _field(_longitudeController, 'Longitude', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: l10n.operatingHours,
                        child: Column(
                          children: List.generate(_hours.length, (index) {
                            final hour = _hours[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HourRow(
                                l10n: l10n,
                                label: weekdayFmt.format(DateTime(2026, 1, 4 + hour.dayOfWeek)),
                                hour: hour,
                                onChanged: (next) => _updateHour(index, next),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(l10n.saveSettings),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _auth.logout();
                          if (!mounted) return;
                          Get.offAllNamed(AppRoutes.login);
                        },
                        icon: Icon(Icons.logout_rounded),
                        label: Text(l10n.logout),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _HourRow extends StatelessWidget {
  const _HourRow({
    required this.l10n,
    required this.label,
    required this.hour,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final String label;
  final RestaurantHour hour;
  final ValueChanged<RestaurantHour> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final openController = TextEditingController(text: hour.openTime ?? '09:00');
    final closeController = TextEditingController(text: hour.closeTime ?? '22:00');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w700))),
              Switch(
                value: !hour.isClosed,
                onChanged: (value) => onChanged(
                  RestaurantHour(
                    dayOfWeek: hour.dayOfWeek,
                    openTime: openController.text.trim(),
                    closeTime: closeController.text.trim(),
                    isClosed: !value,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: openController,
                  enabled: !hour.isClosed,
                  decoration: InputDecoration(labelText: l10n.hoursOpenLabel, border: OutlineInputBorder()),
                  onChanged: (value) => onChanged(
                    RestaurantHour(
                      dayOfWeek: hour.dayOfWeek,
                      openTime: value,
                      closeTime: closeController.text.trim(),
                      isClosed: hour.isClosed,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: closeController,
                  enabled: !hour.isClosed,
                  decoration: InputDecoration(labelText: l10n.hoursCloseLabel, border: OutlineInputBorder()),
                  onChanged: (value) => onChanged(
                    RestaurantHour(
                      dayOfWeek: hour.dayOfWeek,
                      openTime: openController.text.trim(),
                      closeTime: value,
                      isClosed: hour.isClosed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
