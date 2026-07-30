import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/afghanistan_region.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/controllers/locale_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/register_request.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../widgets/auth_location_block.dart';
import '../utils/customer_auth_validation.dart';

/// Required for Google users missing phone or name before home.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _city;

  @override
  void initState() {
    super.initState();
    final auth = Get.find<AuthController>();
    final u = auth.currentUser;
    if (u != null) {
      if (u.name.trim().isNotEmpty) _nameController.text = u.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;

    final nameErr = CustomerAuthValidation.validateDisplayName(
      _nameController.text,
      l10n,
    );
    if (nameErr != null) {
      auth.error.value = nameErr;
      return;
    }
    final phoneErr = CustomerAuthValidation.validatePhoneField(
      _phoneController.text,
      l10n,
    );
    if (phoneErr != null) {
      auth.error.value = phoneErr;
      return;
    }

    final apiPhone = AfghanistanRegion.normalizeCustomerPhoneToApi(
      _phoneController.text.trim(),
    )!;

    final ok = await auth.completeProfile(
      CompleteProfileRequest(
        name: _nameController.text.trim(),
        phone: apiPhone,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        city: _city,
      ),
    );
    if (ok) await auth.navigateAfterAuth();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final lang = Get.find<LocaleController>().locale.languageCode;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: MaxWidthBody(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      32,
                      context.pageHorizontalPadding,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.authCompleteProfileTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.authCompleteProfileSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Obx(() {
                          if (auth.error.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              auth.error.value,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          );
                        }),
                        AuthOutlinedInput(
                          controller: _nameController,
                          hintText: l10n.fullName,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 12),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: AuthOutlinedInput(
                            controller: _phoneController,
                            hintText: AfghanistanRegion.phoneNumberHint,
                            prefixIcon: Icons.smartphone_outlined,
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthLocationBlock(
                          addressController: _addressController,
                          requireAddress: false,
                          onCoordinatesChanged: ({latitude, longitude, city}) {
                            _latitude = latitude;
                            _longitude = longitude;
                            _city = city;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    0,
                    context.pageHorizontalPadding,
                    16,
                  ),
                  child: Obx(
                    () => AuthOnboardingPrimaryButton(
                      label: l10n.authContinue,
                      loading: auth.isLoading.value,
                      languageCode: lang,
                      onPressed:
                          auth.isLoading.value ? null : () => _submit(auth),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
