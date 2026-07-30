import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/maps/address_placemark_parser.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_onboarding_theme.dart';
import 'auth_screen_chrome.dart';

/// GPS + manual address entry for registration / complete-profile flows.
class AuthLocationBlock extends StatefulWidget {
  const AuthLocationBlock({
    super.key,
    required this.addressController,
    this.onCoordinatesChanged,
    this.requireAddress = true,
    this.errorText,
  });

  final TextEditingController addressController;
  final void Function({double? latitude, double? longitude, String? city})?
      onCoordinatesChanged;
  final bool requireAddress;
  final String? errorText;

  @override
  State<AuthLocationBlock> createState() => _AuthLocationBlockState();
}

class _AuthLocationBlockState extends State<AuthLocationBlock> {
  bool _locating = false;
  double? _latitude;
  double? _longitude;
  String? _city;

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _locating = true);
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        if (mounted) {
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
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationPermissionRequired),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final parsed = AddressPlacemarkParser.parse(pm);
        final parts = [parsed.street, parsed.area]
            .where((s) => s.trim().isNotEmpty)
            .toList();
        final line = parts.join(', ');
        if (line.isNotEmpty) {
          widget.addressController.text = line;
        } else {
          widget.addressController.text = AfghanistanRegion.geocodingCityLine;
        }
        _city = pm.locality ?? pm.subAdministrativeArea;
      } else {
        widget.addressController.text = AfghanistanRegion.geocodingCityLine;
      }

      widget.onCoordinatesChanged?.call(
        latitude: _latitude,
        longitude: _longitude,
        city: _city,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.couldNotDetectLocation),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Get.find<LocaleController>().locale.languageCode;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AuthOnboardingColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AuthOnboardingColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.authYourLocation,
              style: FontHelper.getTextStyle(
                text: l10n.authYourLocation,
                languageCode: lang,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.authRegisterLocationHint,
              style: FontHelper.getTextStyle(
                text: l10n.authRegisterLocationHint,
                languageCode: lang,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _locating ? null : _useCurrentLocation,
                icon: _locating
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AuthOnboardingColors.primary,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                label: Text(
                  _locating
                      ? l10n.gettingLocationEllipsis
                      : l10n.useCurrentLocationAction,
                  overflow: TextOverflow.ellipsis,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuthOnboardingColors.primary,
                  side: const BorderSide(color: AuthOnboardingColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AuthFormField(
              controller: widget.addressController,
              hintText: l10n.authAddressHint,
              prefixIcon: Icons.location_on_outlined,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              errorText: widget.errorText,
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    l10n.coordinatesSavedHint(
                      _latitude!.toStringAsFixed(5),
                      _longitude!.toStringAsFixed(5),
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
