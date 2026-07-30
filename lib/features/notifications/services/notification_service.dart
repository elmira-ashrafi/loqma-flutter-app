import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../models/app_notification_model.dart';

class NotificationListResult {
  NotificationListResult({required this.items, required this.unreadCount});

  final List<AppNotificationModel> items;
  final int unreadCount;
}

/// Laravel database notifications: [NotificationController] under /api/v1/notifications.
class NotificationService {
  NotificationService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  static Map<String, dynamic>? _asJsonMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final success = raw['success'];
    if (success == false) {
      throw Exception(raw['message']?.toString() ?? 'Request failed');
    }
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return raw;
  }

  /// GET /notifications?limit=20
  Future<NotificationListResult> fetchNotifications({int limit = 30}) async {
    try {
      final res = await _dio.get(
        ApiConstants.notifications,
        queryParameters: {'limit': limit},
      );
      final raw = _asJsonMap(res.data);
      if (raw == null) {
        return NotificationListResult(items: [], unreadCount: 0);
      }
      final data = _unwrap(raw);
      final list = data['notifications'];
      final unread = data['unread_count'];
      final items = <AppNotificationModel>[];
      if (list is List) {
        for (final e in list) {
          final m = _asJsonMap(e);
          if (m != null) {
            items.add(AppNotificationModel.fromJson(m));
          }
        }
      }
      return NotificationListResult(
        items: items,
        unreadCount: unread is int ? unread : (unread is num ? unread.toInt() : 0),
      );
    } on DioException catch (e) {
      throw Exception(messageFromDio(e));
    }
  }

  /// GET /notifications/unread-count
  Future<int> unreadCount() async {
    try {
      final res = await _dio.get(ApiConstants.notificationsUnreadCount);
      final raw = _asJsonMap(res.data);
      if (raw == null) return 0;
      final data = _unwrap(raw);
      final c = data['count'];
      if (c is int) return c;
      if (c is num) return c.toInt();
      return 0;
    } on DioException catch (_) {
      return 0;
    }
  }

  /// POST /notifications/{id}/read
  Future<void> markAsRead(String id) async {
    await _dio.post(ApiConstants.notificationMarkRead(id));
  }

  /// POST /notifications/mark-all-read
  Future<void> markAllAsRead() async {
    await _dio.post(ApiConstants.notificationsMarkAllRead);
  }

  /// DELETE /notifications/{id}
  Future<void> deleteNotification(String id) async {
    await _dio.delete(ApiConstants.notificationById(id));
  }

  /// DELETE /notifications (clear all)
  Future<void> clearAll() async {
    await _dio.delete(ApiConstants.notifications);
  }

  String messageFromDio(DioException e, {AppLocalizations? l10n}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.response?.statusCode == 401) {
      return l10n?.pleaseSignInToViewNotifications ?? 'Please sign in to view notifications.';
    }
    return e.message ?? 'Network error';
  }
}
