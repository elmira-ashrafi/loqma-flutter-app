import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_onboarding_theme.dart';

/// Soft green-tinted atmosphere for auth screens (works in light + dark).
class AuthAtmosphereBackground extends StatelessWidget {
  const AuthAtmosphereBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0F1A16),
                  Color(0xFF121916),
                  Color(0xFF0B0F0D),
                ]
              : const [
                  Color(0xFFE8F3EE),
                  Color(0xFFF7FAF8),
                  Color(0xFFFFFFFF),
                ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -80,
            end: -60,
            child: _Blob(
              size: 220,
              color: AuthOnboardingColors.primary.withValues(
                alpha: isDark ? 0.12 : 0.08,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 120,
            start: -70,
            child: _Blob(
              size: 180,
              color: AuthOnboardingColors.primary.withValues(
                alpha: isDark ? 0.08 : 0.05,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
  });

  final String title;
  final String subtitle;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? theme.colorScheme.onSurface : AuthOnboardingColors.heading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLogo) ...[
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Image.asset(
                'assets/icons/loqma_logo_light.png',
                height: 72,
                width: 72,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.restaurant_rounded,
                  size: 56,
                  color: AuthOnboardingColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          title,
          textAlign: TextAlign.start,
          style: FontHelper.getTextStyle(
            text: title,
            languageCode: lang,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.start,
          style: FontHelper.getTextStyle(
            text: subtitle,
            languageCode: lang,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: FontHelper.getTextStyle(
                    text: message,
                    languageCode: lang,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final line = AuthOnboardingColors.lineInactive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Divider(color: line, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              l10n.authOrDivider,
              style: FontHelper.getTextStyle(
                text: l10n.authOrDivider,
                languageCode: lang,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AuthOnboardingColors.subtext,
              ),
            ),
          ),
          Expanded(child: Divider(color: line, thickness: 1)),
        ],
      ),
    );
  }
}

class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : AuthOnboardingColors.heading,
          side: BorderSide(
            color: isDark
                ? Colors.white24
                : AuthOnboardingColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.85),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleGMark(),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      l10n.authContinueWithGoogle,
                      overflow: TextOverflow.ellipsis,
                      style: FontHelper.getTextStyle(
                        text: l10n.authContinueWithGoogle,
                        languageCode: lang,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AuthOnboardingColors.heading,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGMark extends StatelessWidget {
  const _GoogleGMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}

class AuthFooterLinkRow extends StatelessWidget {
  const AuthFooterLinkRow({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onAction,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: FontHelper.getTextStyle(
            text: prompt,
            languageCode: lang,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: FontHelper.getTextStyle(
              text: actionLabel,
              languageCode: lang,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AuthOnboardingColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Auth text field with optional LTR lock (email / phone / password).
class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.errorText,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.forceLtr = false,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool forceLtr;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldText = isDark ? theme.colorScheme.onSurface : const Color(0xFF1A314D);
    final lang = Localizations.localeOf(context).languageCode;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.error
        : AuthOnboardingColors.primary.withValues(alpha: 0.55);
    final focusedBorder = hasError
        ? AppColors.error
        : AuthOnboardingColors.primary;

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      textAlign: forceLtr ? TextAlign.left : TextAlign.start,
      style: FontHelper.getTextStyle(
        text: controller.text.isEmpty ? hintText : controller.text,
        languageCode: forceLtr ? 'en' : lang,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: fieldText,
      ),
      cursorColor: AuthOnboardingColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: FontHelper.getTextStyle(
          text: hintText,
          languageCode: forceLtr ? 'en' : lang,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AuthOnboardingColors.subtext,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: hasError ? AppColors.error : AuthOnboardingColors.subtext,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: focusedBorder, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        forceLtr
            ? Directionality(textDirection: TextDirection.ltr, child: field)
            : field,
        if (hasError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Text(
              errorText!,
              textAlign: TextAlign.start,
              style: FontHelper.getTextStyle(
                text: errorText!,
                languageCode: lang,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
