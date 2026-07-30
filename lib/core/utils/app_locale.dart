import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/locale_controller.dart';

/// Active app language code: `en`, `fa`, or `ps`.
String appLocaleCode(BuildContext context) {
  if (Get.isRegistered<LocaleController>()) {
    return Get.find<LocaleController>().locale.languageCode;
  }
  return Localizations.localeOf(context).languageCode;
}
