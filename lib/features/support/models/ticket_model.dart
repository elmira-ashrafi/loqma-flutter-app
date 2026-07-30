import 'package:equatable/equatable.dart';

import '../../../l10n/app_localizations.dart';

/// Support ticket from /customer/tickets and /customer/tickets/{id}.
class TicketModel extends Equatable {
  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.status,
    required this.category,
    required this.priority,
    required this.createdAt,
    this.messages = const [],
    this.orderId,
    this.assignedAgentName,
  });

  final int id;
  final String ticketNumber;
  final String subject;
  final String status;
  final String category;
  final String priority;
  final String createdAt;
  final List<TicketMessageModel> messages;
  final int? orderId;
  final String? assignedAgentName;

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return TicketModel(
      id: (json['id'] as num).toInt(),
      ticketNumber: json['ticket_number'] as String? ?? json['ticketNumber'] as String? ?? '#${json['id']}',
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      category: json['category'] as String? ?? json['category_display'] as String? ?? 'other',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map((e) => TicketMessageModel.fromJson(e))
          .toList(),
      orderId: (json['order_id'] as num?)?.toInt() ?? (json['orderId'] as num?)?.toInt(),
      assignedAgentName: json['assigned_agent']?['name'] as String? ?? json['assignedAgentName'] as String?,
    );
  }

  /// Localized status label for UI.
  String statusLabel(AppLocalizations l10n) {
    switch (status) {
      case 'open':
        return l10n.ticketStatusOpen;
      case 'in_progress':
        return l10n.ticketStatusInProgress;
      case 'waiting_response':
        return l10n.ticketStatusWaiting;
      case 'resolved':
        return l10n.ticketStatusResolved;
      case 'closed':
        return l10n.ticketStatusClosed;
      default:
        return status.replaceAll('_', ' ');
    }
  }

  /// Localized priority label for UI.
  String priorityLabel(AppLocalizations l10n) {
    switch (priority) {
      case 'low':
        return l10n.ticketPriorityLow;
      case 'medium':
        return l10n.ticketPriorityMedium;
      case 'high':
        return l10n.ticketPriorityHigh;
      case 'urgent':
        return l10n.ticketPriorityUrgent;
      default:
        return priority;
    }
  }

  /// Localized category label for UI.
  String categoryLabel(AppLocalizations l10n) {
    switch (category) {
      case 'order':
        return l10n.ticketCategoryOrderIssue;
      case 'payment':
        return l10n.ticketCategoryPayment;
      case 'delivery':
        return l10n.ticketCategoryDelivery;
      case 'restaurant':
        return l10n.ticketCategoryRestaurant;
      case 'account':
        return l10n.ticketCategoryAccount;
      default:
        return l10n.ticketCategoryOther;
    }
  }

  bool get isClosed => status == 'resolved' || status == 'closed';

  @override
  List<Object?> get props => [id, ticketNumber, status];
}

class TicketMessageModel extends Equatable {
  const TicketMessageModel({
    required this.id,
    required this.message,
    required this.isStaff,
    required this.createdAt,
    this.senderName,
  });

  final int id;
  final String message;
  final bool isStaff;
  final String createdAt;
  final String? senderName;

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final isStaff = json['is_staff'] as bool? ?? json['isStaff'] as bool? ?? false;
    return TicketMessageModel(
      id: (json['id'] as num).toInt(),
      message: json['message'] as String? ?? '',
      isStaff: isStaff,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      senderName: user['name'] as String? ?? json['sender_name'] as String? ?? json['senderName'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, isStaff];
}
