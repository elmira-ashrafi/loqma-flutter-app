import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/error_parser.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/controllers/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/layout/max_width_body.dart';
import '../../../core/layout/responsive_context.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../orders/screens/order_detail_screen.dart';
import '../../support/screens/ticket_detail_screen.dart';
import '../models/app_notification_model.dart';
import '../notification_l10n.dart';
import '../services/notification_service.dart';

/// Loads in-app notifications from GET /api/v1/notifications (Laravel database channel).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<AppNotificationModel> _items = [];
  int _unreadCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (Get.isRegistered<AuthController>() && !Get.find<AuthController>().isLoggedIn) {
      setState(() {
        _loading = false;
        _error = null;
        _items = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.fetchNotifications(limit: 50);
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _unreadCount = result.unreadCount;
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

  Future<void> _onTap(AppNotificationModel n) async {
    try {
      if (!n.isRead) {
        await _service.markAsRead(n.id);
      }
      final tid = n.ticketId;
      if (tid != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TicketDetailScreen(ticketId: tid),
          ),
        );
      } else {
        final oid = n.orderId;
        if (oid != null && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(orderId: oid),
            ),
          );
        }
      }
      if (mounted) await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFriendlyErrorMessage(e),
            style: FontHelper.getTextStyle(
              text: userFriendlyErrorMessage(e),
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllAsRead();
      if (!mounted) return;
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFriendlyErrorMessage(e),
            style: FontHelper.getTextStyle(
              text: userFriendlyErrorMessage(e),
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.clear,
          style: FontHelper.getTextStyle(
            text: l10n.clear,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          l10n.removeAllNotificationsConfirm,
          style: FontHelper.getTextStyle(
            text: l10n.removeAllNotificationsConfirm,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.goBack,
              style: FontHelper.getTextStyle(
                text: l10n.goBack,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.clear,
              style: FontHelper.getTextStyle(
                text: l10n.clear,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _service.clearAll();
      if (!mounted) return;
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFriendlyErrorMessage(e),
            style: FontHelper.getTextStyle(
              text: userFriendlyErrorMessage(e),
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _deleteOne(AppNotificationModel n) async {
    try {
      await _service.deleteNotification(n.id);
      if (!mounted) return;
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userFriendlyErrorMessage(e),
            style: FontHelper.getTextStyle(
              text: userFriendlyErrorMessage(e),
              languageCode: Get.find<LocaleController>().locale.languageCode,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final loggedIn = auth?.isLoggedIn ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.notifications,
          style: FontHelper.getTextStyle(
            text: l10n.notifications,
            languageCode: Get.find<LocaleController>().locale.languageCode,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          if (loggedIn && !_loading && _items.isNotEmpty) ...[
            if (_unreadCount > 0)
              TextButton(
                onPressed: _markAllRead,
                child: Text(
                  l10n.markAllRead,
                  style: FontHelper.getTextStyle(
                    text: l10n.markAllRead,
                    languageCode: Get.find<LocaleController>().locale.languageCode,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined),
              tooltip: l10n.clearAllTooltip,
              onPressed: _clearAll,
            ),
          ],
        ],
      ),
      body: MaxWidthBody(
        child: !loggedIn
            ? _signInPrompt(context, l10n)
            : _loading
                ? NotificationListSkeleton(
                    padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 24),
                  )
                : _error != null
                    ? _errorState(context, l10n)
                    : _items.isEmpty
                        ? _emptyState(context, l10n)
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(context.pageHorizontalPadding, 8, context.pageHorizontalPadding, 24),
                            itemCount: _items.length,
                            itemBuilder: (context, i) {
                              final n = _items[i];
                              return Dismissible(
                                key: Key('n_${n.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: AppColors.error,
                                  child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
                                ),
                                onDismissed: (_) => _deleteOne(n),
                                child: _NotificationTile(
                                  notification: n,
                                  onTap: () => _onTap(n),
                                ),
                              );
                            },
                          ),
                        ),
      ),
    );
  }

  Widget _signInPrompt(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.signInToContinue,
              style: FontHelper.getTextStyle(
                text: l10n.signInToContinue,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allCaughtUp,
              style: FontHelper.getTextStyle(
                text: l10n.allCaughtUp,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: FontHelper.getTextStyle(
                text: _error!,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: Icon(Icons.refresh_rounded),
              label: Text(
                l10n.retry,
                style: FontHelper.getTextStyle(
                  text: l10n.retry,
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_rounded, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l10n.noNotifications,
              style: FontHelper.getTextStyle(
                text: l10n.noNotifications,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allCaughtUp,
              style: FontHelper.getTextStyle(
                text: l10n.allCaughtUp,
                languageCode: Get.find<LocaleController>().locale.languageCode,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !notification.isRead;
    final l10n = AppLocalizations.of(context)!;
    final title = NotificationL10n.localizedTitle(l10n, notification);
    final message = NotificationL10n.localizedMessage(l10n, notification);
    String timeStr;
    try {
      timeStr = DateFormat.yMMMd().add_jm().format(notification.createdAt.toLocal());
    } catch (_) {
      timeStr = '';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: unread ? AppColors.primary.withValues(alpha: 0.06) : theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.iconEmoji ?? '🔔',
                style: FontHelper.getTextStyle(
                  text: notification.iconEmoji ?? '🔔',
                  languageCode: Get.find<LocaleController>().locale.languageCode,
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: FontHelper.getTextStyle(
                              text: title,
                              languageCode: Get.find<LocaleController>().locale.languageCode,
                              fontSize: 14,
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (message.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: FontHelper.getTextStyle(
                          text: message,
                          languageCode: Get.find<LocaleController>().locale.languageCode,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      timeStr,
                      style: FontHelper.getTextStyle(
                        text: timeStr,
                        languageCode: Get.find<LocaleController>().locale.languageCode,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (notification.ticketId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.tapOpenSupportTicket,
                          style: FontHelper.getTextStyle(
                            text: l10n.tapOpenSupportTicket,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (notification.orderId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.tapViewOrderNotification,
                          style: FontHelper.getTextStyle(
                            text: l10n.tapViewOrderNotification,
                            languageCode: Get.find<LocaleController>().locale.languageCode,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppColors.primary,
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
