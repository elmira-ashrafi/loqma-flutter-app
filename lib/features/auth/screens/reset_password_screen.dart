import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../models/register_request.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../utils/customer_auth_validation.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.email,
    this.initialCooldownSeconds = 60,
  });

  final String email;
  final int initialCooldownSeconds;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown(widget.initialCooldownSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _resend(AuthController auth) async {
    if (_cooldown > 0) return;
    auth.clearError();
    final result = await auth.forgotPassword(
      ForgotPasswordRequest(email: widget.email),
    );
    if (result != null) {
      _startCooldown(result.resendCooldownSeconds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.authResetCodeSent)),
        );
      }
    }
  }

  Future<void> _submit(AuthController auth) async {
    auth.clearError();
    final l10n = AppLocalizations.of(context)!;

    final otpErr = CustomerAuthValidation.validateSixDigitOtp(
      _otpController.text,
      l10n,
    );
    if (otpErr != null) {
      auth.error.value = otpErr;
      return;
    }
    final passErr = CustomerAuthValidation.validatePassword(
      _passwordController.text,
      l10n,
    );
    if (passErr != null) {
      auth.error.value = passErr;
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      auth.error.value = l10n.passwordsDoNotMatch;
      return;
    }

    final digits = _otpController.text.replaceAll(RegExp(r'\D'), '').substring(0, 6);
    final ok = await auth.resetPassword(
      ResetPasswordRequest(
        email: widget.email,
        otp: digits,
        password: _passwordController.text,
      ),
    );
    if (ok) {
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        l10n.signIn,
        l10n.authPasswordResetSuccess,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(l10n.authResetPasswordTitle)),
      body: SafeArea(
        child: MaxWidthBody(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.pageHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.authEnterResetCode,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (auth.error.value.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      auth.error.value,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }),
                AuthOutlinedInput(
                  controller: _otpController,
                  hintText: l10n.authSixDigitCodeHint,
                  prefixIcon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                AuthOutlinedInput(
                  controller: _passwordController,
                  hintText: l10n.password,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 12),
                AuthOutlinedInput(
                  controller: _confirmController,
                  hintText: l10n.confirmPassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _cooldown > 0 ? null : () => _resend(auth),
                  child: Text(
                    _cooldown > 0
                        ? l10n.authResendCodeInSeconds(_cooldown)
                        : l10n.authResendCode,
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => AuthOnboardingPrimaryButton(
                    label: l10n.authSetNewPassword,
                    loading: auth.isLoading.value,
                    onPressed: auth.isLoading.value ? null : () => _submit(auth),
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
