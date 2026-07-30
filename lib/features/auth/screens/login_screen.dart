import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../models/login_request.dart';
import '../utils/customer_auth_validation.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../widgets/auth_screen_chrome.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

/// Multi-step login: phone → password. After 3 failed attempts, show forgot password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _totalSteps = 2;
  static const _failThreshold = 3;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _phoneError;
  String? _passwordError;
  bool _obscurePassword = true;
  int _step = 0;
  int _failedPasswordAttempts = 0;
  String? _temporaryPassword;
  bool _checkingTempPassword = false;

  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _showForgotPassword => _failedPasswordAttempts >= _failThreshold;

  bool _validateCurrentStep(AppLocalizations l10n) {
    if (_step == 0) {
      final err = CustomerAuthValidation.validatePhoneField(
        _phoneController.text,
        l10n,
      );
      setState(() => _phoneError = err);
      return err == null;
    }
    final err = CustomerAuthValidation.validateLoginPassword(
      _passwordController.text,
      l10n,
    );
    setState(() => _passwordError = err);
    return err == null;
  }

  Future<void> _goNext() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateCurrentStep(l10n)) return;

    final auth = Get.find<AuthController>();
    final apiPhone = AfghanistanRegion.normalizeCustomerPhoneToApi(
      _phoneController.text.trim(),
    )!;

    setState(() {
      _step = 1;
      _checkingTempPassword = true;
      _temporaryPassword = null;
    });

    final status = await auth.fetchTemporaryPasswordStatus(apiPhone);
    if (!mounted) return;

    setState(() {
      _checkingTempPassword = false;
      if (status != null &&
          status.hasTemporaryPassword &&
          (status.temporaryPassword?.isNotEmpty ?? false)) {
        _temporaryPassword = status.temporaryPassword;
        _passwordController.text = status.temporaryPassword!;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _passwordFocus.requestFocus();
    });
  }

  void _goPrev() {
    if (_step == 0) return;
    setState(() {
      _step = 0;
      _temporaryPassword = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _phoneFocus.requestFocus();
    });
  }

  Future<void> _submitPasswordLogin(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;
    if (!_validateCurrentStep(l10n)) return;

    final apiPhone = AfghanistanRegion.normalizeCustomerPhoneToApi(
      _phoneController.text.trim(),
    )!;

    final ok = await auth.loginWithPassword(
      LoginRequest(
        identifier: apiPhone,
        password: _passwordController.text,
      ),
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _failedPasswordAttempts = 0);
      await auth.navigateAfterAuth();
      return;
    }
    setState(() {
      _failedPasswordAttempts++;
      _passwordError = auth.fieldErrors['password'] ??
          auth.error.value.ifEmpty(l10n.authCheckPasswordAgain);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final lang = Get.find<LocaleController>().locale.languageCode;
    final isPasswordStep = _step == 1;

    return Scaffold(
      body: AuthAtmosphereBackground(
        child: SafeArea(
          child: MaxWidthBody(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isPasswordStep)
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 0),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: _goPrev,
                            tooltip: MaterialLocalizations.of(context)
                                .backButtonTooltip,
                            icon: const Icon(Icons.arrow_back_rounded, size: 22),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          context.pageHorizontalPadding,
                          isPasswordStep ? 8 : 28,
                          context.pageHorizontalPadding,
                          16,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthBrandHeader(
                              title: isPasswordStep
                                  ? l10n.password
                                  : l10n.welcomeBack,
                              subtitle: isPasswordStep
                                  ? l10n.authLoginStepPasswordHint
                                  : l10n.authLoginStepPhoneHint,
                            ),
                            const SizedBox(height: 18),
                            AuthRegistrationStepper(
                              activeStep: _step + 1,
                              totalSteps: _totalSteps,
                            ),
                            const SizedBox(height: 22),
                            Obx(
                              () => AuthErrorBanner(message: auth.error.value),
                            ),
                            if (isPasswordStep &&
                                (_temporaryPassword != null ||
                                    _checkingTempPassword)) ...[
                              if (_checkingTempPassword)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 14),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                      ),
                                    ),
                                  ),
                                )
                              else if (_temporaryPassword != null)
                                _NewPasswordBanner(
                                  password: _temporaryPassword!,
                                  title: l10n.authThisIsYourNewPasswordTitle,
                                  body: l10n.authThisIsYourNewPasswordBody,
                                  usePasswordLabel: l10n.authUseThisPassword,
                                  onUsePassword: () {
                                    setState(() {
                                      _passwordController.text =
                                          _temporaryPassword!;
                                      _passwordError = null;
                                    });
                                  },
                                ),
                              const SizedBox(height: 14),
                            ],
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              child: KeyedSubtree(
                                key: ValueKey(_step),
                                child: isPasswordStep
                                    ? AuthFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocus,
                                        hintText: l10n.password,
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        forceLtr: true,
                                        errorText: _passwordError,
                                        onChanged: (_) {
                                          if (_passwordError != null) {
                                            setState(
                                              () => _passwordError = null,
                                            );
                                          }
                                        },
                                        onSubmitted: (_) =>
                                            _submitPasswordLogin(auth),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AuthOnboardingColors.subtext,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      )
                                    : AuthFormField(
                                        controller: _phoneController,
                                        focusNode: _phoneFocus,
                                        hintText: l10n.authPhoneFieldHint,
                                        prefixIcon: Icons.smartphone_outlined,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.telephoneNumber,
                                        ],
                                        forceLtr: true,
                                        errorText: _phoneError,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[\d\s+\-]'),
                                          ),
                                        ],
                                        onChanged: (_) {
                                          if (_phoneError != null) {
                                            setState(() => _phoneError = null);
                                          }
                                        },
                                        onSubmitted: (_) => _goNext(),
                                      ),
                              ),
                            ),
                            if (isPasswordStep && _showForgotPassword) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: TextButton(
                                  onPressed: () => Get.to(
                                    () => ForgotPasswordScreen(
                                      initialPhone: _phoneController.text.trim(),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.authForgotPassword,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AuthOnboardingColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Obx(
                            () => AuthOnboardingPrimaryButton(
                              label: isPasswordStep
                                  ? l10n.signIn
                                  : l10n.authContinue,
                              loading: auth.isLoading.value,
                              languageCode: lang,
                              onPressed: auth.isLoading.value
                                  ? null
                                  : () {
                                      if (isPasswordStep) {
                                        _submitPasswordLogin(auth);
                                      } else {
                                        _goNext();
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(height: 16),
                          AuthFooterLinkRow(
                            prompt: l10n.dontHaveAccount,
                            actionLabel: l10n.createAccount,
                            onAction: () =>
                                Get.to(() => const RegisterScreen()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

class _NewPasswordBanner extends StatelessWidget {
  const _NewPasswordBanner({
    required this.password,
    required this.title,
    required this.body,
    required this.usePasswordLabel,
    required this.onUsePassword,
  });

  final String password;
  final String title;
  final String body;
  final String usePasswordLabel;
  final VoidCallback onUsePassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuthOnboardingColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AuthOnboardingColors.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AuthOnboardingColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.key_rounded,
                  color: AuthOnboardingColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AuthOnboardingColors.heading,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: AuthOnboardingColors.subtext,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AuthOnboardingColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: SelectableText(
              password,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AuthOnboardingColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onUsePassword,
            child: Text(
              usePasswordLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AuthOnboardingColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
