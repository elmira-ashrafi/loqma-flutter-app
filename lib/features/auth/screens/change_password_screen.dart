import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../utils/customer_auth_validation.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../widgets/auth_screen_chrome.dart';

/// Forced password change after admin assigns a temporary password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _currentError;
  String? _passwordError;
  String? _confirmError;
  bool _obscureCurrent = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;
    final currentErr = CustomerAuthValidation.validateLoginPassword(
      _currentController.text,
      l10n,
    );
    final passErr = CustomerAuthValidation.validatePassword(
      _passwordController.text,
      l10n,
    );
    final confirmErr = CustomerAuthValidation.validatePasswordConfirmation(
      _passwordController.text,
      _confirmController.text,
      l10n,
    );
    setState(() {
      _currentError = currentErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });
    if (currentErr != null || passErr != null || confirmErr != null) return;

    final ok = await auth.changePassword(
      currentPassword: _currentController.text,
      newPassword: _passwordController.text,
    );
    if (!mounted) return;
    if (ok) {
      Get.snackbar(
        l10n.authPasswordUpdatedTitle,
        l10n.authPasswordUpdatedBody,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AuthOnboardingColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      await auth.navigateAfterAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final lang = Get.find<LocaleController>().locale.languageCode;

    return Scaffold(
      body: AuthAtmosphereBackground(
        child: SafeArea(
          child: MaxWidthBody(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      28,
                      context.pageHorizontalPadding,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AuthOnboardingColors.primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AuthOnboardingColors.primary
                                  .withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.lock_reset_rounded,
                                size: 40,
                                color: AuthOnboardingColors.primary,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.authAdminDefaultPasswordTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AuthOnboardingColors.heading,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.authAdminDefaultPasswordBody,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: AuthOnboardingColors.subtext,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Obx(
                          () => AuthErrorBanner(message: auth.error.value),
                        ),
                        AuthFormField(
                          controller: _currentController,
                          hintText: l10n.authTemporaryPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureCurrent,
                          textInputAction: TextInputAction.next,
                          forceLtr: true,
                          errorText: _currentError,
                          onChanged: (_) {
                            if (_currentError != null) {
                              setState(() => _currentError = null);
                            }
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AuthOnboardingColors.subtext,
                            ),
                            onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _passwordController,
                          hintText: l10n.authNewPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          forceLtr: true,
                          errorText: _passwordError,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AuthOnboardingColors.subtext,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _confirmController,
                          hintText: l10n.confirmPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          forceLtr: true,
                          errorText: _confirmError,
                          onChanged: (_) {
                            if (_confirmError != null) {
                              setState(() => _confirmError = null);
                            }
                          },
                          onSubmitted: (_) => _submit(auth),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AuthOnboardingColors.subtext,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
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
                      label: l10n.authSetNewPassword,
                      loading: auth.isLoading.value,
                      languageCode: lang,
                      onPressed: auth.isLoading.value
                          ? null
                          : () => _submit(auth),
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
