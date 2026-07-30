import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/routes/app_pages.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../models/register_request.dart';
import '../utils/customer_auth_validation.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../widgets/auth_screen_chrome.dart';

/// Multi-step registration: name → phone → password → confirm → register.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const _totalSteps = 4;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _nameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _step = 0;

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  bool _validateCurrentStep(AppLocalizations l10n) {
    switch (_step) {
      case 0:
        final err = CustomerAuthValidation.validateDisplayName(
          _nameController.text,
          l10n,
        );
        setState(() => _nameError = err);
        return err == null;
      case 1:
        final err = CustomerAuthValidation.validatePhoneField(
          _phoneController.text,
          l10n,
        );
        setState(() => _phoneError = err);
        return err == null;
      case 2:
        final err = CustomerAuthValidation.validatePassword(
          _passwordController.text,
          l10n,
        );
        setState(() => _passwordError = err);
        return err == null;
      case 3:
        final err = CustomerAuthValidation.validatePasswordConfirmation(
          _passwordController.text,
          _confirmPasswordController.text,
          l10n,
        );
        setState(() => _confirmError = err);
        return err == null;
      default:
        return false;
    }
  }

  void _goNext() {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateCurrentStep(l10n)) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _focusForStep(_step);
    }
  }

  void _goPrev() {
    if (_step > 0) {
      setState(() => _step--);
      _focusForStep(_step);
      return;
    }
    _leave();
  }

  void _focusForStep(int step) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (step) {
        case 0:
          _nameFocus.requestFocus();
        case 1:
          _phoneFocus.requestFocus();
        case 2:
          _passwordFocus.requestFocus();
        case 3:
          _confirmFocus.requestFocus();
      }
    });
  }

  void _leave() {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _submit(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;
    if (!_validateCurrentStep(l10n)) return;

    final apiPhone = AfghanistanRegion.normalizeCustomerPhoneToApi(
      _phoneController.text.trim(),
    )!;

    final ok = await auth.registerWithPassword(
      RegisterRequest(
        name: _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        phone: apiPhone,
        password: _passwordController.text,
      ),
    );
    if (!mounted) return;
    if (ok) {
      await auth.navigateAfterAuth();
      return;
    }
    _applyServerFieldErrors(auth);
  }

  void _applyServerFieldErrors(AuthController auth) {
    final fields = auth.fieldErrors;
    setState(() {
      if (fields['name'] != null) {
        _nameError = fields['name'];
        _step = 0;
      }
      if (fields['phone'] != null) {
        _phoneError = fields['phone'];
        _step = 1;
      }
      if (fields['password'] != null) {
        _passwordError = fields['password'];
        _step = 2;
      }
      if (fields['password_confirmation'] != null) {
        _confirmError = fields['password_confirmation'];
        _step = 3;
      }
    });
  }

  String _stepTitle(AppLocalizations l10n) {
    return switch (_step) {
      0 => l10n.authWhatsYourName,
      1 => l10n.authEnterPhoneNumber,
      2 => l10n.password,
      3 => l10n.confirmPassword,
      _ => l10n.createAccount,
    };
  }

  String _stepSubtitle(AppLocalizations l10n) {
    return switch (_step) {
      0 => l10n.authRegisterStepNameHint,
      1 => l10n.authRegisterStepPhoneHint,
      2 => l10n.authRegisterStepPasswordHint,
      3 => l10n.authRegisterStepConfirmHint,
      _ => l10n.authRegisterSubtitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final lang = Get.find<LocaleController>().locale.languageCode;
    final isLast = _step == _totalSteps - 1;

    return Scaffold(
      body: AuthAtmosphereBackground(
        child: SafeArea(
          child: MaxWidthBody(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 0),
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
                        8,
                        context.pageHorizontalPadding,
                        16,
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthBrandHeader(
                            showLogo: false,
                            title: _stepTitle(l10n),
                            subtitle: _stepSubtitle(l10n),
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) {
                              return FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _buildStepField(l10n),
                            ),
                          ),
                          if (_step == 0) ...[
                            const SizedBox(height: 20),
                            AuthFooterLinkRow(
                              prompt: l10n.alreadyHaveAccount,
                              actionLabel: l10n.authHaveAccountSignIn,
                              onAction: _leave,
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
                    child: Obx(
                      () => AuthOnboardingPrimaryButton(
                        label: isLast ? l10n.signUp : l10n.authContinue,
                        loading: auth.isLoading.value,
                        languageCode: lang,
                        onPressed: auth.isLoading.value
                            ? null
                            : () {
                                if (isLast) {
                                  _submit(auth);
                                } else {
                                  _goNext();
                                }
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepField(AppLocalizations l10n) {
    switch (_step) {
      case 0:
        return AuthFormField(
          controller: _nameController,
          focusNode: _nameFocus,
          hintText: l10n.fullName,
          prefixIcon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          errorText: _nameError,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
          onSubmitted: (_) => _goNext(),
        );
      case 1:
        return AuthFormField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          hintText: l10n.authPhoneFieldHint,
          prefixIcon: Icons.smartphone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          forceLtr: true,
          errorText: _phoneError,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s+\-]')),
          ],
          onChanged: (_) {
            if (_phoneError != null) setState(() => _phoneError = null);
          },
          onSubmitted: (_) => _goNext(),
        );
      case 2:
        return AuthFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          hintText: l10n.password,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          forceLtr: true,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
          onSubmitted: (_) => _goNext(),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AuthOnboardingColors.subtext,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        );
      default:
        return AuthFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmFocus,
          hintText: l10n.confirmPassword,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          forceLtr: true,
          errorText: _confirmError,
          onChanged: (_) {
            if (_confirmError != null) setState(() => _confirmError = null);
          },
          onSubmitted: (_) => _submit(Get.find<AuthController>()),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AuthOnboardingColors.subtext,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        );
    }
  }
}
