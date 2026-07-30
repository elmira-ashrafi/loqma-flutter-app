import 'dart:convert';

import 'package:equatable/equatable.dart';

/// One row from Laravel `notifications` table (database channel).
/// Supports [OrderStatusNotification], [GenericDatabaseNotification], and any
/// payload with title/message in various keys or JSON-encoded [data].
class AppNotificationModel extends Equatable {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  /// Short label from FQN, e.g. `App\Notifications\OrderStatusNotification` → `OrderStatus`.
  String get typeShortName {
    if (type.isEmpty) return '';
    final i = type.lastIndexOf('\\');
    final name = i >= 0 ? type.substring(i + 1) : type;
    return name.replaceAll(RegExp(r'Notification$'), '').trim();
  }

  /// Title for UI: prefers structured fields, then notification class name.
  String get displayTitle {
    final t = _firstNonEmptyString([
      data['title'],
      data['subject'],
      data['heading'],
    ]);
    if (t != null) return t;
    if (typeShortName.isNotEmpty) return typeShortName;
    return 'Notification';
  }

  /// Body text: message, body, content, lines, etc.
  String get displayMessage {
    final m = _firstNonEmptyString([
      data['message'],
      data['body'],
      data['content'],
      data['text'],
      data['line'],
    ]);
    if (m != null) return m;
    final lines = data['lines'];
    if (lines is List && lines.isNotEmpty) {
      return lines.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).join('\n');
    }
    // Fallback: any string values we did not use as title
    final buf = StringBuffer();
    data.forEach((k, v) {
      if (_isMetaKey(k)) return;
      if (v is String && v.isNotEmpty) buf.writeln(v);
    });
    final s = buf.toString().trim();
    return s;
  }

  /// Legacy getters — use [displayTitle] / [displayMessage] for alerts & list.
  String get title => displayTitle;

  String get message => displayMessage;

  int? get orderId => _parseInt(data['order_id']);

  int? get ticketId => _parseInt(data['ticket_id']);

  /// `support_ticket`, `order`, `general`, etc.
  String? get kind => data['kind']?.toString();

  String? get iconEmoji => _firstNonEmptyString([data['icon'], data['emoji']]);

  static String? _firstNonEmptyString(List<dynamic> candidates) {
    for (final c in candidates) {
      if (c == null) continue;
      final s = c.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static bool _isMetaKey(String k) {
    const skip = {
      'title', 'subject', 'heading', 'message', 'body', 'content', 'text', 'line', 'lines',
      'icon', 'emoji', 'kind', 'url',
    };
    return skip.contains(k);
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return int.tryParse(v.toString());
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = _normalizeData(json['data']);

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    final created = json['created_at'];
    final createdAt = parseDt(created) ?? DateTime.now();

    return AppNotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      data: rawData,
      readAt: parseDt(json['read_at']),
      createdAt: createdAt,
    );
  }

  static Map<String, dynamic> _normalizeData(dynamic d) {
    if (d == null) return {};
    if (d is String) {
      final t = d.trim();
      if (t.isEmpty) return {};
      try {
        final decoded = jsonDecode(t);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {'message': t};
      }
      return {'message': t};
    }
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
    return {};
  }

  @override
  List<Object?> get props => [id, readAt];
}
