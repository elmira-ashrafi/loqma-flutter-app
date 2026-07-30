import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Track screen step keys (pending → delivered) and icon ids.
const List<Map<String, String>> kOrderTrackSteps = [
  {'key': 'pending', 'icon': 'clock'},
  {'key': 'confirmed', 'icon': 'check'},
  {'key': 'preparing', 'icon': 'fire'},
  {'key': 'ready', 'icon': 'package'},
  {'key': 'picked_up', 'icon': 'motorcycle'},
  {'key': 'on_the_way', 'icon': 'truck'},
  {'key': 'delivered', 'icon': 'home'},
];

/// First step index where the driver has the order (`picked_up`); before this the rider stays at the restaurant on the map.
const int kOrderTrackPickedUpStepIndex = 4;

/// Index 0–6 matching [kOrderTrackSteps], same logic as `OrderTrackScreen._currentStepIndex`.
int orderTrackStepIndexFromStatus(String status) {
  final normalized = normalizeOrderStatusKey(status);
  final i = kOrderTrackSteps.indexWhere((m) => m['key'] == normalized);
  return i >= 0 ? i : 0;
}

/// Four-step orders tab milestones: placed → preparing → on the way → delivered.
int fourStepIndexFromOrderStatus(String status) {
  switch (normalizeOrderStatusKey(status)) {
    case 'pending':
      return 0;
    case 'confirmed':
    case 'preparing':
    case 'ready':
      return 1;
    case 'picked_up':
    case 'on_the_way':
      return 2;
    case 'delivered':
      return 3;
    default:
      return 0;
  }
}

bool fourStepNodeDone(int step, String status) {
  if (normalizeOrderStatusKey(status) == 'delivered') return true;
  return step < fourStepIndexFromOrderStatus(status);
}

bool fourStepNodeCurrent(int step, String status) {
  if (normalizeOrderStatusKey(status) == 'delivered') return false;
  return step == fourStepIndexFromOrderStatus(status);
}

/// Merge API status with any known timeline entries (track poll vs detail race).
String resolveOrderTrackStatus(
  String status,
  Iterable<String> timelineStatuses,
) {
  var resolved = status;
  for (final entry in timelineStatuses) {
    if (entry.trim().isEmpty) continue;
    resolved = mergeOrderStatus(resolved, entry);
  }
  return resolved;
}

/// Maps API / display variants to [kOrderTrackSteps] keys.
String normalizeOrderStatusKey(String raw) {
  var s = raw.toLowerCase().trim();
  // Prefer machine keys when display text sneaks in (e.g. "Order Confirmed").
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');

  const aliases = <String, String>{
    'out_for_delivery': 'on_the_way',
    'delivering': 'on_the_way',
    'accepted': 'confirmed',
    'order_placed': 'pending',
    'created': 'pending',
    'placed': 'pending',
    'canceled': 'cancelled',
    'in_preparation': 'preparing',
    'being_prepared': 'preparing',
    'order_confirmed': 'confirmed',
    'order_preparing': 'preparing',
    'preparing_food': 'preparing',
    'ready_for_pickup': 'ready',
    'order_ready': 'ready',
    'order_picked_up': 'picked_up',
    'pickedup': 'picked_up',
    'order_on_the_way': 'on_the_way',
    'on_way': 'on_the_way',
    'order_delivered': 'delivered',
    'completed': 'delivered',
    'complete': 'delivered',
    'order_cancelled': 'cancelled',
    'order_canceled': 'cancelled',
  };

  if (aliases.containsKey(s)) return aliases[s]!;

  if (s.startsWith('order_')) {
    final without = s.substring(6);
    if (aliases.containsKey(without)) return aliases[without]!;
    if (kOrderTrackSteps.any((m) => m['key'] == without)) return without;
  }

  return aliases[s] ?? s;
}

/// True when the order no longer belongs in the active/in-progress list.
bool isTerminalOrderStatus(String raw) {
  final k = normalizeOrderStatusKey(raw);
  return k == 'delivered' || k == 'cancelled' || k == 'refunded';
}

/// Higher rank = further along the delivery pipeline.
int orderStatusProgressRank(String raw) {
  switch (normalizeOrderStatusKey(raw)) {
    case 'pending':
      return 0;
    case 'confirmed':
      return 1;
    case 'preparing':
      return 2;
    case 'ready':
      return 3;
    case 'picked_up':
      return 4;
    case 'on_the_way':
      return 5;
    case 'delivered':
      return 6;
    case 'cancelled':
    case 'refunded':
      return 100;
    default:
      return -1;
  }
}

bool isKnownOrderProgressStatus(String raw) =>
    orderStatusProgressRank(raw) >= 0;

/// Keep the furthest-known status when merging list + track payloads.
String mergeOrderStatus(String baseRaw, String updateRaw) {
  final baseRank = orderStatusProgressRank(baseRaw);
  final updateRank = orderStatusProgressRank(updateRaw);
  if (updateRank < 0 && baseRank >= 0) return baseRaw;
  if (baseRank < 0 && updateRank >= 0) return updateRaw;
  if (updateRank >= baseRank) return updateRaw;
  return baseRaw;
}

/// Localized label for a normalized status key (track + chips).
String localizedOrderTrackStatus(BuildContext context, String normalized, String raw) {
  final l = AppLocalizations.of(context)!;
  switch (normalized) {
    case 'pending':
      return l.trackStatusPending;
    case 'confirmed':
      return l.trackStatusConfirmed;
    case 'preparing':
      return l.trackStatusPreparing;
    case 'ready':
      return l.trackStatusReady;
    case 'picked_up':
      return l.trackStatusPickedUp;
    case 'on_the_way':
      return l.trackStatusOnTheWay;
    case 'delivered':
      return l.trackStatusDelivered;
    case 'cancelled':
    case 'canceled':
      return l.orderStatusCancelled;
    case 'refunded':
      return l.orderStatusRefunded;
    default:
      return raw.replaceAll('_', ' ').split(' ').map((e) {
        if (e.isEmpty) return e;
        return '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}';
      }).join(' ');
  }
}

/// Localized order status from any API `status` / `status_display` value.
String localizedOrderStatus(BuildContext context, String rawStatus) {
  final normalized = normalizeOrderStatusKey(rawStatus);
  return localizedOrderTrackStatus(context, normalized, rawStatus);
}
