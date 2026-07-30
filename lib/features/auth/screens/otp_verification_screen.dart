import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../core/constants/afghanistan_region.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/localized_number.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/auth_controller.dart';
import '../models/send_otp_request.dart';
import '../models/verify_otp_request.dart';
import '../utils/auth_otp_digits.dart';
import '../utils/otp_digit_input_formatter.dart';
import '../widgets/auth_onboarding_theme.dart';
import '../utils/customer_auth_validation.dart';

/// Phone OTP verification: 3 digit boxes, onboarding layout, 2-minute resend cooldown.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.apiPhone, this.name});

  /// E.164 form sent to the API (`+937xxxxxxxx`).
  final String apiPhone;

  final String? name;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _resendCooldownSeconds = 120;

  late final List<TextEditingController> _digitCtrls;
  late final List<FocusNode> _digitNodes;
  Timer? _cooldown;
  int _secondsRemaining = _resendCooldownSeconds;
  StreamSubscription<String>? _smsCodeSub;
  bool _otpFillProgrammatic = false;

  String get _displayPhone => AfghanistanRegion.formatLocalPhoneSpaced(
    AfghanistanRegion.formatApiPhoneForDisplay(widget.apiPhone),
  );

  String _otpCode() =>
      List.generate(3, (i) => normalizeOtpDigit(_digitCtrls[i].text)).join();

  void _setDigitAt(int i, String westernDigit) {
    _digitCtrls[i].text = westernDigit.isEmpty
        ? ''
        : displayOtpDigit(context, westernDigit);
  }

  @override
  void initState() {
    super.initState();
    _digitCtrls = List.generate(3, (_) => TextEditingController());
    _digitNodes = List.generate(3, (_) => FocusNode());
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _digitNodes.first.requestFocus();
      }
    });
    _smsCodeSub = SmsAutoFill().code.listen(_onSmsCode);
    unawaited(
      SmsAutoFill().listenForCode(smsCodeRegexPattern: r'\d{3,6}'),
    );
  }

  /// SMS User Consent / platform OTP listener — extract digits and fill boxes.
  void _onSmsCode(String raw) {
    if (!mounted) return;
    final digits = extractWesternOtpDigits(raw, maxLen: 3);
    if (digits.length >= 3) {
      _applyOtpDigits(digits.substring(0, 3));
    }
  }

  void _applyOtpDigits(String threeDigits) {
    if (threeDigits.length != 3) return;
    _otpFillProgrammatic = true;
    try {
      for (var i = 0; i < 3; i++) {
        _setDigitAt(i, threeDigits[i]);
      }
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } finally {
      _otpFillProgrammatic = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// Paste or OS autofill may insert multiple digits into one box.
  void _distributeDigitsFromBox(int startIndex, String westernDigits) {
    if (westernDigits.isEmpty) return;
    _otpFillProgrammatic = true;
    try {
      for (var k = 0; k < westernDigits.length && startIndex + k < 3; k++) {
        _setDigitAt(startIndex + k, westernDigits[k]);
      }
      final lastFilled = startIndex + westernDigits.length - 1;
      final focusIdx = lastFilled >= 2 ? 2 : lastFilled + 1;
      _digitNodes[focusIdx.clamp(0, 2)].requestFocus();
    } finally {
      _otpFillProgrammatic = false;
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _onDigitChanged(int i, String value) {
    if (_otpFillProgrammatic) return;

    final extracted = extractWesternOtpDigits(value, maxLen: 3);

    if (extracted.length >= 3) {
      _applyOtpDigits(extracted.substring(0, 3));
      return;
    }

    if (extracted.length > 1) {
      _distributeDigitsFromBox(i, extracted);
      return;
    }

    if (value.isEmpty || extracted.isEmpty) {
      if (_digitCtrls[i].text.isNotEmpty) {
        _digitCtrls[i].clear();
      } else if (i > 0) {
        _digitNodes[i - 1].requestFocus();
      }
      setState(() {});
      return;
    }

    _setDigitAt(i, extracted);
    if (i < 2) {
      _digitNodes[i + 1].requestFocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _smsCodeSub?.cancel();
    unawaited(SmsAutoFill().unregisterListener());
    _cooldown?.cancel();
    for (final c in _digitCtrls) {
      c.dispose();
    }
    for (final n in _digitNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    _cooldown?.cancel();
    setState(() => _secondsRemaining = _resendCooldownSeconds);
    _cooldown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_secondsRemaining <= 0) {
          t.cancel();
          return;
        }
        _secondsRemaining--;
      });
    });
  }

  String _mmss(int sec) {
    if (sec <= 0) {
      return localizeAppDigitsInString(context, '00:00');
    }
    final m = sec ~/ 60;
    final s = sec % 60;
    final raw =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return localizeAppDigitsInString(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : const Color(0xFF1A314D);

    final languageCode = Get.find<LocaleController>().locale.languageCode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: MaxWidthBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 44),
                      child: AuthRegistrationStepper(activeStep: 3),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.pageHorizontalPadding,
                    24,
                    context.pageHorizontalPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.verifyOtpTitle,
                        textAlign: TextAlign.start,
                        style: FontHelper.getTextStyle(
                          text: l10n.verifyOtpTitle,
                          languageCode: languageCode,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.otpEnterCodeWhatsApp,
                        textAlign: TextAlign.start,
                        style: FontHelper.getTextStyle(
                          text: l10n.otpEnterCodeWhatsApp,
                          languageCode: languageCode,
                          fontSize: 16.0,
                          fontWeight: FontWeight.normal,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          _displayPhone,
                          textAlign: TextAlign.center,
                          style: FontHelper.getTextStyle(
                            text: _displayPhone,
                            languageCode: 'en',
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Obx(() {
                        if (auth.error.value.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    auth.error.value,
                                    textAlign: TextAlign.start,
                                    style: FontHelper.getTextStyle(
                                      text: auth.error.value,
                                      languageCode: languageCode,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.error,
                                    ),
                                    maxLines: 8,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      otpDigitFieldsLtr(
                        child: AutofillGroup(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: TextDirection.ltr,
                            children: List.generate(3, (i) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: SizedBox(
                                  width: 56,
                                  child: TextField(
                                    controller: _digitCtrls[i],
                                    focusNode: _digitNodes[i],
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.ltr,
                                    keyboardType: TextInputType.number,
                                    textInputAction: i == 2
                                        ? TextInputAction.done
                                        : TextInputAction.next,
                                    style: FontHelper.getTextStyle(
                                      text: '0',
                                      languageCode: languageCode,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.w700,
                                      color: titleColor,
                                    ),
                                    autofillHints: i == 0
                                        ? const [AutofillHints.oneTimeCode]
                                        : null,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    inputFormatters: [
                                      OtpDigitInputFormatter(context),
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: AuthOnboardingColors.otpFill,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(
                                          color: AuthOnboardingColors
                                              .otpFocusBorder,
                                          width: 1.6,
                                        ),
                                      ),
                                    ),
                                    onChanged: (v) => _onDigitChanged(i, v),
                                  ),
                                ),
                              );
                            }),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => AuthOnboardingPrimaryButton(
                        label: l10n.verifyAndContinue,
                        languageCode: languageCode,
                        loading: auth.isLoading.value,
                        onPressed: auth.isLoading.value
                            ? null
                            : () async {
                                auth.clearError();
                                final otp = _otpCode();
                                final otpErr =
                                    CustomerAuthValidation.validateThreeDigitOtp(
                                  otp,
                                  l10n,
                                );
                                if (otpErr != null) {
                                  auth.error.value = otpErr;
                                  return;
                                }
                                final otpDigits = _otpCode();
                                if (otpDigits.length != 3) {
                                  auth.error.value = l10n.otpIncompleteCode;
                                  return;
                                }
                                final ok = await auth.verifyCustomerOtp(
                                  VerifyOtpRequest(
                                    phone: widget.apiPhone,
                                    otp: otpDigits,
                                    name: widget.name,
                                  ),
                                );
                                if (ok) {
                                  Get.offAllNamed(auth.resolveLandingRoute());
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _secondsRemaining > 0
                          ? null
                          : () async {
                              auth.clearError();
                              final phoneErr =
                                  CustomerAuthValidation.validatePhoneField(
                                widget.apiPhone,
                                l10n,
                              );
                              if (phoneErr != null) {
                                auth.error.value = phoneErr;
                                return;
                              }
                              final ok = await auth.sendCustomerOtp(
                                SendOtpRequest(phone: widget.apiPhone),
                              );
                              if (!mounted) {
                                return;
                              }
                              if (ok) {
                                for (final c in _digitCtrls) {
                                  c.clear();
                                }
                                _digitNodes.first.requestFocus();
                                _startCooldown();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.otpSentAgain,
                                      style: FontHelper.getTextStyle(
                                        text: l10n.otpSentAgain,
                                        languageCode: languageCode,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      child: Text(
                        _secondsRemaining > 0
                            ? '${l10n.resendOtp}  ${_mmss(_secondsRemaining)}'
                            : l10n.resendOtp,
                        textAlign: TextAlign.center,
                        style: FontHelper.getTextStyle(
                          text: _secondsRemaining > 0
                              ? '${l10n.resendOtp}  ${_mmss(_secondsRemaining)}'
                              : l10n.resendOtp,
                          languageCode: languageCode,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: _secondsRemaining > 0
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
