import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Geodesic helpers for ETA / distance (no network).
abstract final class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusM = 6371000;

  /// Great-circle distance in meters (Haversine).
  static double haversineMeters(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLat = (b.latitude - a.latitude) * math.pi / 180;
    final dLng = (b.longitude - a.longitude) * math.pi / 180;
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return _earthRadiusM * c;
  }

  static double haversineKm(LatLng a, LatLng b) => haversineMeters(a, b) / 1000;

  /// Typical urban delivery speed (~25 km/h) for rough ETA when API ETA is missing.
  static int etaMinutesFromDistanceKm(double distanceKm, {double avgSpeedKmh = 25}) {
    if (distanceKm <= 0 || avgSpeedKmh <= 0) return 1;
    final hours = distanceKm / avgSpeedKmh;
    final mins = (hours * 60).ceil();
    return mins.clamp(1, 999);
  }

  /// Bearing from [from] to [to] in degrees clockwise from north (0–360).
  static double bearingDegrees(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLon = (to.longitude - from.longitude) * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    final brng = math.atan2(y, x) * 180 / math.pi;
    return (brng + 360) % 360;
  }

  /// Point at fraction [t] along [path] (0 = start, 1 = end). Requires at least 2 points.
  static LatLng pointAlongPath(List<LatLng> path, double t) {
    if (path.isEmpty) throw ArgumentError('path empty');
    if (path.length == 1) return path.first;
    t = t.clamp(0.0, 1.0);
    final maxIndex = t * (path.length - 1);
    final i = maxIndex.floor().clamp(0, path.length - 2);
    final frac = maxIndex - i;
    final a = path[i];
    final b = path[i + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * frac,
      a.longitude + (b.longitude - a.longitude) * frac,
    );
  }
}
