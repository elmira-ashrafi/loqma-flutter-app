import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/layout/responsive_context.dart';
import '../../../core/utils/font_helper.dart';

/// Forest-green onboarding palette aligned with Loqma registration / OTP designs.
abstract final class AuthOnboardingColors {
  static const Color primary = Color(0xFF006241);
  static const Color heading = Color(0xFF1A1D1E);
  static const Color subtext = Color(0xFFA0A5BA);
  static const Color lineInactive = Color(0xFFE2E5EA);
  /// Muted CTA (e.g. registration “Continue”) — matches light sage from mocks.
  static const Color sageButton = Color(0xFFB2C9BB);
  static const Color otpFill = Color(0xFFF4F6F8);
  static const Color otpFocusBorder = primary;
}

/// Progress dots for multi-step auth. [activeStep] is 1-based (current step).
class AuthRegistrationStepper extends StatelessWidget {
  const AuthRegistrationStepper({
    super.key,
    required this.activeStep,
    this.totalSteps = 3,
  });

  final int activeStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final total = totalSteps.clamp(2, 6);
    final step = activeStep.clamp(1, total);
    final dot = context.layoutScale(total > 4 ? 28.0 : 32.0);
    final connW = context.layoutScale(total > 4 ? 18.0 : 28.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= total; i++) ...[
          if (i > 1) _connector(step >= i, connW, context.layoutScale(4)),
          _circle(context, i, step >= i, dot),
        ],
      ],
    );
  }

  Widget _circle(BuildContext context, int number, bool filled, double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AuthOnboardingColors.primary : AuthOnboardingColors.lineInactive,
      ),
      child: Text(
        '$number',
        style: GoogleFonts.inter(
          fontSize: context.layoutScale(totalSteps > 4 ? 12.0 : 14.0),
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _connector(bool active, double width, double marginH) {
    return Container(
      width: width,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: marginH),
      decoration: BoxDecoration(
        color: active ? AuthOnboardingColors.primary : AuthOnboardingColors.lineInactive,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class AuthOnboardingPrimaryButton extends StatelessWidget {
  const AuthOnboardingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward_rounded,
    this.backgroundColor,
    this.languageCode,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;
  /// When null, uses [AuthOnboardingColors.primary] (forest green).
  final Color? backgroundColor;
  final String? languageCode;

  @override
  Widget build(BuildContext context) {
    final base = backgroundColor ?? AuthOnboardingColors.primary;
    final lang = languageCode ?? Localizations.localeOf(context).languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final arrowIcon = isRtl ? Icons.arrow_back_rounded : icon;
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: loading ? base.withValues(alpha: 0.75) : base,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Text(
                          label,
                          style: FontHelper.getTextStyle(
                            text: label,
                            languageCode: lang,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ).copyWith(letterSpacing: 0.2),
                        ),
                        const SizedBox(width: 8),
                        Icon(arrowIcon, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded field with green border and leading icon — matches reference inputs.
class AuthOutlinedInput extends StatelessWidget {
  const AuthOutlinedInput({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
    this.borderRadius = 12,
    this.textAlign = TextAlign.start,
    this.textInputAction,
    this.languageCode,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final double borderRadius;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;
  final String? languageCode;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final fieldText = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : const Color(0xFF1A314D);
    final lang = languageCode ?? Localizations.localeOf(context).languageCode;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textAlign: textAlign,
      textInputAction: textInputAction,
      obscureText: obscureText,
      style: FontHelper.getTextStyle(
        text: controller.text.isEmpty ? hintText : controller.text,
        languageCode: lang,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: fieldText,
      ),
      cursorColor: AuthOnboardingColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: FontHelper.getTextStyle(
          text: hintText,
          languageCode: lang,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AuthOnboardingColors.subtext,
        ),
        prefixIcon: Icon(prefixIcon, color: AuthOnboardingColors.subtext, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AuthOnboardingColors.primary, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AuthOnboardingColors.primary, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AuthOnboardingColors.primary, width: 1.5),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
