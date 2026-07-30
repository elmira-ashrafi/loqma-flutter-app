import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../l10n/app_localizations.dart';
import '../models/account_deletion_request_model.dart';
import '../services/account_deletion_service.dart';
import '../services/account_deletion_monitor.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _service = AccountDeletionService();
  final _reasonController = TextEditingController();

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  AccountDeletionRequestModel? _request;

  @override
  void initState() {
    super.initState();
    _load();
    if (Get.isRegistered<AccountDeletionMonitor>()) {
      Get.find<AccountDeletionMonitor>().start();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    if (_request?.isPending != true && Get.isRegistered<AccountDeletionMonitor>()) {
      Get.find<AccountDeletionMonitor>().ensureStarted();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final request = await _service.getCurrentRequest();
      if (!mounted) return;
      setState(() {
        _request = request;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFriendlyErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Get.find<LocaleController>().locale.languageCode;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C), size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.deleteAccountConfirmTitle,
                  textAlign: TextAlign.center,
                  style: FontHelper.getTextStyle(
                    text: l10n.deleteAccountConfirmTitle,
                    languageCode: localeCode,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.deleteAccountConfirmBody,
                  textAlign: TextAlign.center,
                  style: FontHelper.getTextStyle(
                    text: l10n.deleteAccountConfirmBody,
                    languageCode: localeCode,
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(l10n.goBack),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(l10n.deleteAccountSubmit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final request = await _service.submitRequest(reason: _reasonController.text);
      if (!mounted) return;
      setState(() {
        _request = request;
        _submitting = false;
      });
      if (Get.isRegistered<AccountDeletionMonitor>()) {
        Get.find<AccountDeletionMonitor>().start();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          content: Text(l10n.deleteAccountSubmitted),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(userFriendlyErrorMessage(e)),
        ),
      );
    }
  }

  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      await _service.cancelRequest();
      if (!mounted) return;
      setState(() {
        _request = null;
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.deleteAccountCancelled),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFriendlyErrorMessage(e))),
      );
    }
  }

  String _statusLabel(AppLocalizations l10n) {
    final status = _request?.status;
    return switch (status) {
      'pending' => l10n.deleteAccountStatusPending,
      'approved' => l10n.deleteAccountStatusApproved,
      'rejected' => l10n.deleteAccountStatusRejected,
      'cancelled' => l10n.deleteAccountStatusCancelled,
      _ => status ?? '',
    };
  }

  _DeleteStatusStyle _statusStyle(String? status, bool isDark) {
    return switch (status) {
      'pending' => _DeleteStatusStyle(
        accent: AppColors.warning,
        surface: isDark ? const Color(0xFF3D2E14) : const Color(0xFFFFFBEB),
        icon: Icons.hourglass_top_rounded,
      ),
      'approved' => _DeleteStatusStyle(
        accent: AppColors.success,
        surface: isDark ? const Color(0xFF143D2B) : const Color(0xFFECFDF5),
        icon: Icons.check_circle_outline_rounded,
      ),
      'rejected' => _DeleteStatusStyle(
        accent: const Color(0xFFB91C1C),
        surface: isDark ? const Color(0xFF3D1414) : const Color(0xFFFEF2F2),
        icon: Icons.cancel_outlined,
      ),
      _ => _DeleteStatusStyle(
        accent: AppColors.textSecondaryLight,
        surface: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight,
        icon: Icons.info_outline_rounded,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeCode = Get.find<LocaleController>().locale.languageCode;
    final hPad = context.pageHorizontalPadding;
    final isDark = theme.brightness == Brightness.dark;
    final expandedH = context.isAppExpanded ? 196.0 : (context.isAppMedium ? 176.0 : 160.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceContainerLight,
      body: MaxWidthBody(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(hPad),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          AppButton(label: l10n.retry, onPressed: _load),
                        ],
                      ),
                    ),
                  )
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        expandedHeight: expandedH,
                        elevation: 0,
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        flexibleSpace: FlexibleSpaceBar(
                          titlePadding: const EdgeInsetsDirectional.only(start: 56, bottom: 16),
                          title: Text(
                            l10n.deleteAccountTitle,
                            style: FontHelper.getTextStyle(
                              text: l10n.deleteAccountTitle,
                              languageCode: localeCode,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [const Color(0xFF3D1414), const Color(0xFF1A2320)]
                                        : [const Color(0xFFB91C1C), const Color(0xFF7F1D1D)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -24,
                                top: 20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(hPad, expandedH - 72, hPad, 0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.person_off_outlined, color: Colors.white, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        l10n.deleteAccountSettingsSubtitle,
                                        style: FontHelper.getTextStyle(
                                          text: l10n.deleteAccountSettingsSubtitle,
                                          languageCode: localeCode,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.92),
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
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 28),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _InfoCard(
                              localeCode: localeCode,
                              icon: Icons.info_outline_rounded,
                              iconColor: AppColors.info,
                              title: l10n.deleteAccountTitle,
                              body: l10n.deleteAccountIntro,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 14),
                            _BulletCard(
                              localeCode: localeCode,
                              isDark: isDark,
                              removedTitle: l10n.deleteAccountWhatHappens,
                              keptTitle: l10n.deleteAccountMayBeKept,
                              items: [
                                l10n.deleteAccountRemovedProfile,
                                l10n.deleteAccountRemovedFavorites,
                                l10n.deleteAccountRemovedAccess,
                              ],
                              keptItems: [
                                l10n.deleteAccountKeptOrders,
                                l10n.deleteAccountKeptPayments,
                              ],
                            ),
                            if (_request != null && (_request!.isPending || _request!.isApproved || _request!.isRejected)) ...[
                              const SizedBox(height: 14),
                              _StatusCard(
                                title: l10n.deleteAccountCurrentStatus,
                                status: _statusLabel(l10n),
                                note: _request!.adminNote,
                                localeCode: localeCode,
                                style: _statusStyle(_request!.status, isDark),
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (_request?.isApproved == true)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.success),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        l10n.deleteAccountRedirectingToLogin,
                                        style: FontHelper.getTextStyle(
                                          text: l10n.deleteAccountRedirectingToLogin,
                                          languageCode: localeCode,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_request?.isPending == true)
                              OutlinedButton.icon(
                                onPressed: _submitting ? null : _cancel,
                                icon: const Icon(Icons.close_rounded, size: 18),
                                label: Text(l10n.deleteAccountCancelRequest),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onSurface,
                                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              )
                            else
                              _DangerZoneCard(
                                localeCode: localeCode,
                                l10n: l10n,
                                reasonController: _reasonController,
                                submitting: _submitting,
                                onSubmit: _submit,
                                isDark: isDark,
                              ),
                          ]),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _DeleteStatusStyle {
  const _DeleteStatusStyle({
    required this.accent,
    required this.surface,
    required this.icon,
  });

  final Color accent;
  final Color surface;
  final IconData icon;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.localeCode,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.isDark,
  });

  final String localeCode;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FontHelper.getTextStyle(
                      text: title,
                      languageCode: localeCode,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: FontHelper.getTextStyle(
                      text: body,
                      languageCode: localeCode,
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({
    required this.localeCode,
    required this.isDark,
    required this.removedTitle,
    required this.keptTitle,
    required this.items,
    required this.keptItems,
  });

  final String localeCode;
  final bool isDark;
  final String removedTitle;
  final String keptTitle;
  final List<String> items;
  final List<String> keptItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              removedTitle,
              style: FontHelper.getTextStyle(
                text: removedTitle,
                languageCode: localeCode,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _BulletRow(text: item, color: const Color(0xFFB91C1C), localeCode: localeCode)),
            const SizedBox(height: 14),
            Text(
              keptTitle,
              style: FontHelper.getTextStyle(
                text: keptTitle,
                languageCode: localeCode,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...keptItems.map((item) => _BulletRow(text: item, color: AppColors.primary, localeCode: localeCode)),
          ],
        ),
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.text, required this.color, required this.localeCode});

  final String text;
  final Color color;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: FontHelper.getTextStyle(
                text: text,
                languageCode: localeCode,
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.status,
    required this.localeCode,
    required this.style,
    this.note,
  });

  final String title;
  final String status;
  final String? note;
  final String localeCode;
  final _DeleteStatusStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: style.accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: style.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(style.icon, color: style.accent, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FontHelper.getTextStyle(
                    text: title,
                    languageCode: localeCode,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: FontHelper.getTextStyle(
                    text: status,
                    languageCode: localeCode,
                    fontSize: 15,
                    color: style.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (note != null && note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note!,
                    style: FontHelper.getTextStyle(
                      text: note!,
                      languageCode: localeCode,
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  const _DangerZoneCard({
    required this.localeCode,
    required this.l10n,
    required this.reasonController,
    required this.submitting,
    required this.onSubmit,
    required this.isDark,
  });

  final String localeCode;
  final AppLocalizations l10n;
  final TextEditingController reasonController;
  final bool submitting;
  final VoidCallback onSubmit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB91C1C).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.report_gmailerrorred_outlined, color: Color(0xFFB91C1C), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.deleteAccountDangerZone,
                style: FontHelper.getTextStyle(
                  text: l10n.deleteAccountDangerZone,
                  languageCode: localeCode,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n.deleteAccountReasonLabel,
            style: FontHelper.getTextStyle(
              text: l10n.deleteAccountReasonLabel,
              languageCode: localeCode,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reasonController,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: l10n.deleteAccountReasonHint,
              filled: true,
              fillColor: isDark ? AppColors.surfaceContainerDark : AppColors.surfaceContainerLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFB91C1C), width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: l10n.deleteAccountSubmit,
            onPressed: submitting ? null : onSubmit,
            loading: submitting,
            gradient: const LinearGradient(
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ],
      ),
    );
  }
}
