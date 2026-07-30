import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../controllers/update_controller.dart';
import '../models/version_model.dart';

/// "Update Available" fallback when Play in-app update API is unavailable (API semver check).
class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({
    super.key,
    required this.model,
    required this.forceUpdate,
  });

  final VersionModel model;
  final bool forceUpdate;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UpdateController>();
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: !forceUpdate,
      child: AlertDialog(
        title: Text(l10n.updateAvailableTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                model.updateMessage.isEmpty
                    ? l10n.updateAvailableMessageDefault
                    : model.updateMessage,
              ),
              Obx(() {
                final err = ctrl.updateError.value;
                if (err == null || err.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    err,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          Obx(() {
            final busy = ctrl.isOpeningStore.value;
            return OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                if (!forceUpdate)
                  TextButton(
                    onPressed: busy ? null : () => Get.back<void>(),
                    child: Text(l10n.later),
                  ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: busy ? null : () => ctrl.openPlayStoreUpdate(model),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.updateNow),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
