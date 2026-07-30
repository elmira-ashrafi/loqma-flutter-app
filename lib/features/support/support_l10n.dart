import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/localized_number.dart';
import '../../l10n/app_localizations.dart';
import 'models/ticket_model.dart';

/// Localized ticket status, priority, category, and date formatting.
abstract final class SupportL10n {
  static const List<String?> statusFilterKeys = [
    null,
    'open',
    'in_progress',
    'waiting_response',
    'resolved',
    'closed',
  ];

  static const List<String> categoryKeys = [
    'order',
    'payment',
    'delivery',
    'restaurant',
    'account',
    'other',
  ];

  static const List<String> priorityKeys = [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  static List<String> statusFilterLabels(AppLocalizations l10n) => [
        l10n.all,
        l10n.ticketStatusOpen,
        l10n.ticketStatusInProgress,
        l10n.ticketStatusWaiting,
        l10n.ticketStatusResolved,
        l10n.ticketStatusClosed,
      ];

  static String statusLabel(AppLocalizations l10n, String status) {
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

  static String priorityLabel(AppLocalizations l10n, String priority) {
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

  static String categoryLabel(AppLocalizations l10n, String category) {
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

  static String formatTicketDate(BuildContext context, String iso, {bool includeTime = false}) {
    if (iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final localeTag = Localizations.localeOf(context).toString();
      final pattern = includeTime ? 'MMM d, HH:mm' : 'MMM d, y';
      final raw = DateFormat(pattern, localeTag).format(dt);
      return localizeAppDigitsInString(context, raw);
    } catch (_) {
      return iso;
    }
  }

  static String replyCountLabel(BuildContext context, AppLocalizations l10n, TicketModel ticket) {
    return l10n.ticketReplyCount(formatAppInteger(context, ticket.messages.length));
  }
}
