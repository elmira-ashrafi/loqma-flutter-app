import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/afghan_phone_input_formatter.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../models/register_request.dart';
import '../utils/customer_auth_validation.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../widgets/auth_screen_chrome.dart';

/// Request admin to set a temporary password (name + phone).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialPhone});

  final String? initialPhone;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  String? _nameError;
  String? _phoneError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;
    final nameErr = CustomerAuthValidation.validateDisplayName(
      _nameController.text,
      l10n,
    );
    final phoneErr = CustomerAuthValidation.validatePhoneField(
      _phoneController.text,
      l10n,
    );
    setState(() {
      _nameError = nameErr;
      _phoneError = phoneErr;
    });
    if (nameErr != null || phoneErr != null) return;

    final apiPhone = AfghanistanRegion.normalizeCustomerPhoneToApi(
      _phoneController.text.trim(),
    )!;

    final result = await auth.requestAdminPasswordReset(
      AdminPasswordResetRequest(
        name: _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        phone: apiPhone,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _submitted = true);
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
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 0),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offAllNamed(AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 22),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      8,
                      context.pageHorizontalPadding,
                      16,
                    ),
                    child: _submitted
                        ? _SuccessCard(l10n: l10n)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthBrandHeader(
                                showLogo: false,
                                title: l10n.authForgotPassword,
                                subtitle: l10n.authForgotPasswordAdminSubtitle,
                              ),
                              const SizedBox(height: 22),
                              Obx(
                                () =>
                                    AuthErrorBanner(message: auth.error.value),
                              ),
                              AuthFormField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                hintText: l10n.fullName,
                                prefixIcon: Icons.badge_outlined,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                errorText: _nameError,
                                onChanged: (_) {
                                  if (_nameError != null) {
                                    setState(() => _nameError = null);
                                  }
                                },
                                onSubmitted: (_) =>
                                    _phoneFocus.requestFocus(),
                              ),
                              const SizedBox(height: 12),
                              AuthFormField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                hintText: l10n.authPhoneFieldHint,
                                prefixIcon: Icons.smartphone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                forceLtr: true,
                                errorText: _phoneError,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[\d\s+\-]'),
                                  ),
                                  AfghanPhoneInputFormatter(),
                                ],
                                onChanged: (_) {
                                  if (_phoneError != null) {
                                    setState(() => _phoneError = null);
                                  }
                                },
                                onSubmitted: (_) => _submit(auth),
                              ),
                            ],
                          ),
                  ),
                ),
                if (!_submitted)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      0,
                      context.pageHorizontalPadding,
                      16,
                    ),
                    child: Obx(
                      () => AuthOnboardingPrimaryButton(
                        label: l10n.authRequestPasswordReset,
                        loading: auth.isLoading.value,
                        languageCode: lang,
                        icon: Icons.send_rounded,
                        onPressed: auth.isLoading.value
                            ? null
                            : () => _submit(auth),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      context.pageHorizontalPadding,
                      0,
                      context.pageHorizontalPadding,
                      16,
                    ),
                    child: AuthOnboardingPrimaryButton(
                      label: l10n.authHaveAccountSignIn,
                      languageCode: lang,
                      onPressed: () => Get.offAllNamed(AppRoutes.login),
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

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AuthOnboardingColors.primary.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 44,
            color: AuthOnboardingColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.authPasswordResetRequestSentTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AuthOnboardingColors.heading,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authPasswordResetRequestSentBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AuthOnboardingColors.subtext,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
