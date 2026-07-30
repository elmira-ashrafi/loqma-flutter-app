import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_constants.dart';
import '../controllers/locale_controller.dart';
import '../l10n/language_display_names.dart';
import '../layout/max_width_body.dart';
import '../layout/responsive_context.dart';
import '../routes/app_pages.dart';
import '../utils/font_helper.dart';

/// First-launch language selection gate.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _complete(BuildContext context, Locale locale) async {
    final localeCtrl = Get.find<LocaleController>();
    localeCtrl.setLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.languageSelectionDoneKey, true);
    if (!context.mounted) return;
    Get.offAllNamed(AppRoutes.bootstrap);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hPad = context.pageHorizontalPadding;
    final compact = MediaQuery.sizeOf(context).width < 400;
    final localeCtrl = Get.find<LocaleController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Obx(
          () => Text(
            l10n.appLanguage,
            style: FontHelper.getTextStyle(
              text: l10n.appLanguage,
              languageCode: localeCtrl.locale.languageCode,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
      ),
      body: MaxWidthBody(
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () {
                  final languageCode = localeCtrl.locale.languageCode;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.languageSelectionTitle,
                        style: FontHelper.getTextStyle(
                          text: l10n.languageSelectionTitle,
                          languageCode: languageCode,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 24 : 28,
                          color: cs.onSurface,
                        ),
                      ),
                      SizedBox(height: compact ? 8 : 10),
                      Text(
                        l10n.languageSelectionSubtitle,
                        style: FontHelper.getTextStyle(
                          text: l10n.languageSelectionSubtitle,
                          languageCode: languageCode,
                          fontSize: compact ? 14 : 15,
                          fontWeight: FontWeight.normal,
                          color: cs.onSurfaceVariant,
                        ).copyWith(height: 1.35),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: compact ? 18 : 22),
              Obx(
                () => Expanded(
                  child: ListView(
                    children: [
                      _LanguageOptionTile(
                        label: LanguageDisplayNames.english,
                        selected: localeCtrl.locale == LocaleController.localeEn,
                        onTap: () => localeCtrl.setLocale(LocaleController.localeEn),
                      ),
                      _LanguageOptionTile(
                        label: LanguageDisplayNames.pashto,
                        selected: localeCtrl.locale == LocaleController.localePs,
                        onTap: () => localeCtrl.setLocale(LocaleController.localePs),
                      ),
                      _LanguageOptionTile(
                        label: LanguageDisplayNames.dari,
                        selected: localeCtrl.locale == LocaleController.localeFa,
                        onTap: () => localeCtrl.setLocale(LocaleController.localeFa),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: compact ? 10 : 12),
              Obx(
                () => FilledButton(
                  onPressed: () => _complete(context, localeCtrl.locale),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(compact ? 48 : 52),
                  ),
                  child: Text(
                    l10n.continueAction,
                    style: FontHelper.getTextStyle(
                      text: l10n.continueAction,
                      languageCode: localeCtrl.locale.languageCode,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onPrimary,
                    ),
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

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fontLanguageCode = LanguageDisplayNames.fontLanguageCode(label);

    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: FontHelper.getTextStyle(
          text: label,
          languageCode: fontLanguageCode,
          fontSize: 17,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? cs.primary : cs.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      trailing: Icon(
        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
    );
  }
}
