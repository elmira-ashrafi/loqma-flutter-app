import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Locale-aware relative timestamps for orders, reviews, and similar UI.
abstract final class RelativeTimeL10n {
  static String? formatIso(AppLocalizations l10n, String localeTag, String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      return format(l10n, localeTag, DateTime.parse(iso).toLocal());
    } catch (_) {
      return null;
    }
  }

  static String format(AppLocalizations l10n, String localeTag, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l10n.relativeTimeJustNow;
    if (diff.inMinutes < 60) return l10n.relativeTimeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.relativeTimeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.relativeTimeDaysAgo(diff.inDays);
    if (diff.inDays < 30) {
      return l10n.relativeTimeWeeksAgo((diff.inDays / 7).floor().clamp(1, 52));
    }
    if (diff.inDays < 365) {
      return l10n.relativeTimeMonthsAgo((diff.inDays / 30).floor().clamp(1, 12));
    }
    return l10n.relativeTimeYearsAgo((diff.inDays / 365).floor().clamp(1, 99));
  }

  /// Order cards: relative text for recent orders, short date after a week.
  static String? formatIsoForOrderPlaced(AppLocalizations l10n, String localeTag, String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return l10n.relativeTimeJustNow;
      if (diff.inMinutes < 60) return l10n.relativeTimeMinutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l10n.relativeTimeHoursAgo(diff.inHours);
      if (diff.inDays < 7) return l10n.relativeTimeDaysAgo(diff.inDays);
      return DateFormat.MMMd(localeTag).format(dt);
    } catch (_) {
      return null;
    }
  }

  static String placedAtLine(AppLocalizations l10n, String localeTag, String? iso) {
    final rel = formatIsoForOrderPlaced(l10n, localeTag, iso);
    if (rel == null || rel.isEmpty) return '';
    return l10n.ordersTabPlacedRelative(rel);
  }

  static String shortDate(AppLocalizations l10n, String localeTag, DateTime dt) {
    return DateFormat.MMMd(localeTag).format(dt);
  }
}
