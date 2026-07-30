import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/maps/address_placemark_parser.dart';
import '../../../core/maps/address_text_utils.dart';
import '../../../core/maps/maps_geocode_service.dart';
import '../../../core/maps/reverse_geocode_result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/widgets/app_cart_notice.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/localized_city_fields.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({
    super.key,
    this.address,
    this.initialName,
    this.initialPhone,
  });

  final AddressModel? address;
  final String? initialName;
  final String? initialPhone;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AddressService();
  final _mapsGeocode = MapsGeocodeService();
  final _labelController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _instructionsController = TextEditingController();
  int? _cityId;
  bool _isDefault = false;
  List<CityModel> _cities = [];
  bool _loadingCities = true;
  bool _saving = false;
  bool _locating = false;
  double? _latitude;
  double? _longitude;

  bool get _isEdit => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      final a = widget.address!;
      _labelController.text = a.label;
      _fullNameController.text = a.fullName;
      _phoneController.text = a.phone;
      _cityId = a.cityId;
      _areaController.text = a.area;
      _streetController.text = a.street;
      _buildingController.text = a.building ?? '';
      _floorController.text = a.floor ?? '';
      _apartmentController.text = a.apartment ?? '';
      _instructionsController.text = a.deliveryInstructions ?? '';
      _isDefault = a.isDefault;
      _latitude = a.latitude;
      _longitude = a.longitude;
    } else {
      _labelController.text = 'Home';
      _fullNameController.text = widget.initialName ?? '';
      _phoneController.text = widget.initialPhone ?? '';
    }
    _loadCities();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final list = await _service.getCities();
      if (mounted) {
        setState(() {
          _cities = list;
          _loadingCities = false;
          if (_cityId == null && list.isNotEmpty) _cityId = list.first.id;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  LocalizedCityFields _resolvedCityFields() {
    if (_cityId == null) {
      return widget.address?.city ?? const LocalizedCityFields();
    }
    for (final c in _cities) {
      if (c.id == _cityId) return c.localized;
    }
    return widget.address?.city ?? const LocalizedCityFields();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cityId == null && _cities.isNotEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectCity), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _resolveCoordinatesBeforeSave();
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        label: _labelController.text.trim().isEmpty ? 'Home' : _labelController.text.trim(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        cityId: _cityId,
        city: _resolvedCityFields(),
        area: _areaController.text.trim(),
        street: _sanitizedStreetForSave(),
        building: _buildingController.text.trim().isEmpty ? null : _buildingController.text.trim(),
        floor: _floorController.text.trim().isEmpty ? null : _floorController.text.trim(),
        apartment: _apartmentController.text.trim().isEmpty ? null : _apartmentController.text.trim(),
        deliveryInstructions: _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
      );
      if (_isEdit) {
        await _service.updateAddress(address);
      } else {
        await _service.createAddress(address);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppAddressSavedNoticeAfterPop(updated: _isEdit);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFriendlyErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _sanitizedStreetForSave() {
    final raw = _streetController.text.trim();
    if (raw.isEmpty || AddressTextUtils.isPlusCode(raw)) {
      final area = _areaController.text.trim();
      if (area.isNotEmpty && !AddressTextUtils.isPlusCode(area)) return area;
      return raw.isNotEmpty ? raw : area;
    }
    return raw;
  }

  Future<void> _resolveCoordinatesBeforeSave() async {
    if (_latitude != null && _longitude != null) return;
    final query = _geocodeQueryFromForm();
    if (query.isEmpty) return;
    final hit = await _mapsGeocode.geocode(query);
    if (hit == null) return;
    _latitude = hit.lat;
    _longitude = hit.lng;
  }

  String _geocodeQueryFromForm() {
    String cityName = '';
    if (_cityId != null) {
      for (final c in _cities) {
        if (c.id == _cityId) {
          cityName = c.name;
          break;
        }
      }
    }
    return AddressTextUtils.joinParts([
      _buildingController.text.trim(),
      AddressTextUtils.meaningfulLine(_streetController.text),
      _areaController.text.trim(),
      cityName,
      'Afghanistan',
    ]);
  }

  void _applyResolvedFields({
    required double latitude,
    required double longitude,
    String? street,
    String? area,
    String? building,
    int? cityId,
  }) {
    _latitude = latitude;
    _longitude = longitude;
    if (street != null && street.isNotEmpty) {
      _streetController.text = street;
    }
    if (area != null && area.isNotEmpty) {
      _areaController.text = area;
    }
    if (building != null && building.isNotEmpty) {
      _buildingController.text = building;
    }
    if (cityId != null) _cityId = cityId;
  }

  Future<void> _useCurrentLocation() async {
    if (_cities.isEmpty) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.citiesStillLoading),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _locating = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.turnOnLocationServices),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationPermissionRequired),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final serverHit = await _mapsGeocode.reverseGeocode(pos.latitude, pos.longitude);
      if (serverHit != null && _applyServerReverseGeocode(serverHit, pos.latitude, pos.longitude)) {
        if (!mounted) return;
        _showLocationAppliedSnack(serverCityDetected: _cityId != null);
        return;
      }

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.couldNotResolveAddress),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final parsed = AddressPlacemarkParser.parse(placemarks.first);
      var street = parsed.street;
      if (street.isEmpty) {
        street = parsed.placeName ?? '';
      }
      if (street.isEmpty) {
        street = AppLocalizations.of(context)!.defaultLocationStreetFallback;
      }
      final area = parsed.area;
      final matchedCityId = _matchCityIdFromPlacemark(placemarks.first, _cities);

      if (!mounted) return;
      setState(() {
        _applyResolvedFields(
          latitude: pos.latitude,
          longitude: pos.longitude,
          street: street,
          area: area,
          building: parsed.building,
          cityId: matchedCityId ?? _cityId,
        );
      });

      if (!mounted) return;
      _showLocationAppliedSnack(serverCityDetected: matchedCityId != null);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotGetLocation('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  bool _applyServerReverseGeocode(ReverseGeocodeResult hit, double lat, double lng) {
    final street = AddressTextUtils.meaningfulLine(hit.street);
    final area = AddressTextUtils.meaningfulLine(hit.area);
    final building = AddressTextUtils.meaningfulLine(hit.building);
    final matchedCityId = _matchCityIdFromName(hit.city, _cities);

    if (street == null && area == null && hit.formattedAddress == null) {
      return false;
    }

    var resolvedStreet = street ?? '';
    if (resolvedStreet.isEmpty && area != null) {
      resolvedStreet = area;
    }

    setState(() {
      _applyResolvedFields(
        latitude: lat,
        longitude: lng,
        street: resolvedStreet,
        area: area ?? '',
        building: building,
        cityId: matchedCityId ?? _cityId,
      );
    });
    return true;
  }

  void _showLocationAppliedSnack({required bool serverCityDetected}) {
    final l10n = AppLocalizations.of(context)!;
    if (!serverCityDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cityNotDetectedChoose),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.locationAppliedReviewSave),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.chevron_left_rounded),
        ),
        title: Text(_isEdit ? l10n.editAddressScreenTitle : l10n.addAddress),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _loadingCities && _cities.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        labelText: l10n.addressLabelShort,
                        hintText: l10n.addressLabelHint,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_cities.isNotEmpty)
                      DropdownButtonFormField<int>(
                        initialValue: _cityId,
                        decoration: InputDecoration(
                          labelText: l10n.cityRequiredLabel,
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        items: _cities
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.provinceName != null
                                        ? '${c.displayName} (${c.provinceName})'
                                        : c.displayName,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _cityId = v),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: '${l10n.fullName} ${l10n.requiredFieldIndicator}',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.contactFormRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: '${l10n.phoneNumber} ${l10n.requiredFieldIndicator}',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.contactFormRequired : null,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: (_loadingCities || _locating || _saving) ? null : _useCurrentLocation,
                      icon: _locating
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : Icon(Icons.my_location_rounded),
                      label: Text(_locating ? l10n.gettingLocationEllipsis : l10n.useCurrentLocationAction),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    if (_latitude != null && _longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.coordinatesSavedHint(
                            _latitude!.toStringAsFixed(5),
                            _longitude!.toStringAsFixed(5),
                          ),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        labelText: l10n.areaFieldLabel,
                        hintText: l10n.districtHint,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _streetController,
                      decoration: InputDecoration(
                        labelText: l10n.streetAddressRequiredLabel,
                        hintText: l10n.streetHint,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? l10n.contactFormRequired : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _buildingController,
                            decoration: InputDecoration(
                              labelText: l10n.buildingFieldLabel,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _floorController,
                            decoration: InputDecoration(
                              labelText: l10n.floorFieldLabel,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _apartmentController,
                            decoration: InputDecoration(
                              labelText: l10n.apartmentFieldLabel,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surfaceContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l10n.deliveryInstructionsLabel,
                        hintText: l10n.deliveryNotesHint,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n.setAsDefaultAddress),
                      value: _isDefault,
                      onChanged: (v) => setState(() => _isDefault = v),
                      activeThumbColor: AppColors.primary,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
                            )
                          : Text(_isEdit ? l10n.updateAddressButton : l10n.saveAddressButton),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

int? _matchCityIdFromName(String? cityName, List<CityModel> cities) {
  final needle = cityName?.trim().toLowerCase();
  if (needle == null || needle.isEmpty) return null;
  for (final city in cities) {
    final n = city.name.toLowerCase().trim();
    if (n.isEmpty) continue;
    if (needle == n || needle.contains(n) || n.contains(needle)) return city.id;
  }
  return null;
}

int? _matchCityIdFromPlacemark(Placemark p, List<CityModel> cities) {
  final candidates = <String>{};
  void add(String? s) {
    final t = s?.trim();
    if (t != null && t.isNotEmpty) candidates.add(t);
  }

  add(p.locality);
  add(p.subAdministrativeArea);
  add(p.administrativeArea);
  add(p.subLocality);

  for (final city in cities) {
    final n = city.name.toLowerCase().trim();
    if (n.isEmpty) continue;
    for (final c in candidates) {
      final cl = c.toLowerCase();
      if (cl == n || cl.contains(n) || n.contains(cl)) return city.id;
    }
  }
  return null;
}
