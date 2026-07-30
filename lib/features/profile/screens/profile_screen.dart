import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/phone_display.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../l10n/app_localizations.dart';

/// Profile edit: name, phone, avatar. API: /customer/profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: auth.currentUser?.name ?? '');
    final emailController = TextEditingController(text: auth.currentUser?.email ?? '');
    final phoneController = TextEditingController(text: displayAfghanLocalPhone(auth.currentUser?.phone));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editProfile,
          style: FontHelper.getTextStyle(
            text: l10n.editProfile,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: auth.currentUser?.avatar != null
                      ? null
                      : const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.name)),
          const SizedBox(height: 16),
          TextField(controller: emailController, readOnly: true, decoration: InputDecoration(labelText: l10n.email)),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\+')),
            ],
            decoration: InputDecoration(labelText: l10n.phone),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: l10n.save,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.profileUpdatedSnackbar,
                    style: FontHelper.getTextStyle(
                      text: l10n.profileUpdatedSnackbar,
                      languageCode: Get.find<LocaleController>().locale.languageCode,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
