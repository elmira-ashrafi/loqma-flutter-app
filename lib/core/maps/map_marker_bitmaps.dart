import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// High-DPI custom markers for [GoogleMap]: restaurant logo pin, pulsing delivery dot, driver badge.
abstract final class MapMarkerBitmaps {
  MapMarkerBitmaps._();

  static const int _pulseFrameCount = 4;

  /// Restaurant: circular logo (or letter) on a modern pin with shadow.
  static Future<BitmapDescriptor> restaurantMarker({
    required String? logoUrl,
    required String fallbackLetter,
    required Color accentColor,
    double pixelRatio = 3,
  }) async {
    ui.Image? decoded;
    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      decoded = await _loadNetworkImage(logoUrl.trim());
    }
    final letter = fallbackLetter.isNotEmpty ? fallbackLetter.substring(0, 1).toUpperCase() : 'R';
    final bytes = await _paintRestaurantPin(
      logo: decoded,
      letter: letter,
      accent: accentColor,
      pixelRatio: pixelRatio,
    );
    decoded?.dispose();
    return BitmapDescriptor.bytes(bytes);
  }

  /// Delivery / user location: [frameIndex] 0..3 drives the pulse ring.
  static Future<BitmapDescriptor> deliveryMarker({
    required Color accentColor,
    required int frameIndex,
    double pixelRatio = 3,
  }) async {
    final bytes = await _paintUserLocationPulse(
      accent: accentColor,
      frameIndex: frameIndex % _pulseFrameCount,
      pixelRatio: pixelRatio,
    );
    return BitmapDescriptor.bytes(bytes);
  }

  static Future<List<BitmapDescriptor>> deliveryPulseFrames({
    required Color accentColor,
    double pixelRatio = 3,
  }) async {
    final out = <BitmapDescriptor>[];
    for (var i = 0; i < _pulseFrameCount; i++) {
      out.add(await deliveryMarker(accentColor: accentColor, frameIndex: i, pixelRatio: pixelRatio));
    }
    return out;
  }

  /// Driver: compact badge (distinct from delivery).
  static Future<BitmapDescriptor> driverMarker({
    required Color accentColor,
    double pixelRatio = 3,
  }) async {
    final bytes = await _paintDriverBadge(accent: accentColor, pixelRatio: pixelRatio);
    return BitmapDescriptor.bytes(bytes);
  }

  /// Small chevron for route direction (points up; use [Marker.rotation] for bearing).
  static Future<BitmapDescriptor> routeArrowMarker({
    required Color fillColor,
    double pixelRatio = 3,
  }) async {
    final bytes = await _paintRouteArrow(fill: fillColor, pixelRatio: pixelRatio);
    return BitmapDescriptor.bytes(bytes);
  }

  /// Leading-edge dot along the animated route.
  static Future<BitmapDescriptor> routeProgressDotMarker({
    required Color color,
    double pixelRatio = 3,
  }) async {
    final bytes = await _paintRouteProgressDot(color: color, pixelRatio: pixelRatio);
    return BitmapDescriptor.bytes(bytes);
  }

  /// Customer / drop-off: home icon with the same pulse rings as [deliveryPulseFrames].
  static Future<BitmapDescriptor> homeDeliveryMarker({
    required Color accentColor,
    required int frameIndex,
    double pixelRatio = 3,
  }) async {
    final bytes = await _paintHomeLocationPulse(
      accent: accentColor,
      frameIndex: frameIndex % _pulseFrameCount,
      pixelRatio: pixelRatio,
    );
    return BitmapDescriptor.bytes(bytes);
  }

  static Future<List<BitmapDescriptor>> homeDeliveryPulseFrames({
    required Color accentColor,
    double pixelRatio = 3,
  }) async {
    final out = <BitmapDescriptor>[];
    for (var i = 0; i < _pulseFrameCount; i++) {
      out.add(await homeDeliveryMarker(accentColor: accentColor, frameIndex: i, pixelRatio: pixelRatio));
    }
    return out;
  }

  static Future<ui.Image?> _loadNetworkImage(String url) async {
    final completer = Completer<ui.Image?>();
    // Decode at marker size (~120 logical px) to avoid full-res bitmap RAM spikes.
    final stream = NetworkImage(url).resolve(
      const ImageConfiguration(size: Size(120, 120)),
    );
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        stream.removeListener(listener);
        completer.complete(info.image);
      },
      onError: (_, __) {
        stream.removeListener(listener);
        completer.complete(null);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  static Future<Uint8List> _paintRestaurantPin({
    required ui.Image? logo,
    required String letter,
    required Color accent,
    required double pixelRatio,
  }) async {
    const w = 120.0;
    const h = 150.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);

    final cx = w / 2;
    const logoR = 34.0;
    const pinTop = 18.0;

    // Soft ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h - 14), width: 52, height: 14),
      shadowPaint,
    );

    // Pin body (rounded teardrop)
    final pinPath = Path()
      ..moveTo(cx, h - 8)
      ..quadraticBezierTo(cx - 22, 92, cx - 40, 78)
      ..arcToPoint(
        Offset(cx + 40, 78),
        radius: const Radius.circular(40),
        clockwise: false,
      )
      ..quadraticBezierTo(cx + 22, 92, cx, h - 8)
      ..close();

    final pinGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color.lerp(Colors.white, accent, 0.08)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(pinPath, pinGradient);

    final pinBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accent.withValues(alpha: 0.85);
    canvas.drawPath(pinPath, pinBorder);

    // Logo circle
    final circleCenter = Offset(cx, pinTop + logoR);
    final bgCircle = Paint()..color = Colors.white;
    canvas.drawCircle(circleCenter, logoR + 3, bgCircle);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = SweepGradient(
        colors: [
          accent,
          Color.lerp(accent, Colors.white, 0.35)!,
          accent,
        ],
      ).createShader(Rect.fromCircle(center: circleCenter, radius: logoR + 3));
    canvas.drawCircle(circleCenter, logoR + 1.5, ringPaint);

    if (logo != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: circleCenter, radius: logoR)));
      final src = Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble());
      final dst = Rect.fromCircle(center: circleCenter, radius: logoR);
      canvas.drawImageRect(logo, src, dst, Paint()..filterQuality = FilterQuality.high);
      canvas.restore();
    } else {
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            color: accent,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, circleCenter.dy - tp.height / 2));
    }

    // Food badge (fork) — restaurant → delivery UX cue
    final badgeC = Offset(cx + 26, pinTop + logoR + 8);
    canvas.drawCircle(
      badgeC,
      14,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      badgeC,
      14,
      Paint()
        ..color = accent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final fork = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(badgeC.dx + i * 3.5, badgeC.dy - 6),
        Offset(badgeC.dx + i * 3.5, badgeC.dy + 4),
        fork,
      );
    }
    canvas.drawLine(
      Offset(badgeC.dx, badgeC.dy + 4),
      Offset(badgeC.dx, badgeC.dy + 9),
      fork,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _paintUserLocationPulse({
    required Color accent,
    required int frameIndex,
    required double pixelRatio,
  }) async {
    const w = 112.0;
    const h = 112.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);

    final cx = w / 2;
    final cy = h / 2;

    // Pulse rings (animated feel)
    final t = frameIndex / _pulseFrameCount;
    final pulseExpand = t * 8;
    for (var i = 2; i >= 0; i--) {
      final r = 36.0 + pulseExpand + i * 10.0;
      final a = (0.14 - i * 0.035) * (1.0 - t * 0.25);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = accent.withValues(alpha: a.clamp(0.04, 0.2))
          ..style = PaintingStyle.fill,
      );
    }

    // Outer glass ring
    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Color.lerp(Colors.white, accent, 0.15)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 28)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner dot + gradient core
    final core = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(Colors.white, accent, 0.2)!,
          accent,
          Color.lerp(accent, Colors.black, 0.15)!,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 14));
    canvas.drawCircle(Offset(cx, cy), 14, core);

    // Directional tick (subtle “navigation” cue)
    final tick = Path()
      ..moveTo(cx, cy - 22)
      ..lineTo(cx - 5, cy - 14)
      ..lineTo(cx + 5, cy - 14)
      ..close();
    canvas.drawPath(
      tick,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _paintHomeLocationPulse({
    required Color accent,
    required int frameIndex,
    required double pixelRatio,
  }) async {
    const w = 112.0;
    const h = 112.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);

    final cx = w / 2;
    final cy = h / 2;

    final t = frameIndex / _pulseFrameCount;
    final pulseExpand = t * 8;
    for (var i = 2; i >= 0; i--) {
      final r = 36.0 + pulseExpand + i * 10.0;
      final a = (0.14 - i * 0.035) * (1.0 - t * 0.25);
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = accent.withValues(alpha: a.clamp(0.04, 0.2))
          ..style = PaintingStyle.fill,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Color.lerp(Colors.white, accent, 0.12)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 28)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      28,
      Paint()
        ..color = accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Simple house icon (home / drop-off)
    final house = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;
    final roof = Path()
      ..moveTo(cx, cy - 16)
      ..lineTo(cx - 18, cy - 2)
      ..lineTo(cx + 18, cy - 2)
      ..close();
    canvas.drawPath(roof, house);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 10), width: 28, height: 20),
        const Radius.circular(3),
      ),
      house,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy + 12), width: 8, height: 12),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _paintRouteArrow({
    required Color fill,
    required double pixelRatio,
  }) async {
    const w = 56.0;
    const h = 56.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);
    final cx = w / 2;
    final cy = h / 2;

    final path = Path()
      ..moveTo(cx, cy - 18)
      ..lineTo(cx + 16, cy + 4)
      ..lineTo(cx + 6, cy + 4)
      ..lineTo(cx + 6, cy + 18)
      ..lineTo(cx - 6, cy + 18)
      ..lineTo(cx - 6, cy + 4)
      ..lineTo(cx - 16, cy + 4)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _paintRouteProgressDot({
    required Color color,
    required double pixelRatio,
  }) async {
    const w = 40.0;
    const h = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);
    final cx = w / 2;
    final cy = h / 2;

    canvas.drawCircle(
      Offset(cx, cy + 1),
      14,
      Paint()..color = Colors.black.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      11,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            color,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 11)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      11,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Future<Uint8List> _paintDriverBadge({
    required Color accent,
    required double pixelRatio,
  }) async {
    const w = 104.0;
    const h = 104.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final scale = pixelRatio;
    canvas.scale(scale);

    final cx = w / 2;
    final cy = h / 2;

    canvas.drawCircle(
      Offset(cx, cy + 2),
      30,
      Paint()..color = Colors.black.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    final hex = _hexPath(Offset(cx, cy), 32);
    canvas.drawPath(
      hex,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(Colors.orange.shade400, accent, 0.3)!,
            Color.lerp(accent, Colors.deepOrange, 0.2)!,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 32)),
    );
    canvas.drawPath(
      hex,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Simple scooter / delivery icon (stroke)
    final icon = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx - 10, cy + 8), 5, icon);
    canvas.drawCircle(Offset(cx + 12, cy + 8), 5, icon);
    canvas.drawLine(Offset(cx - 14, cy - 2), Offset(cx + 6, cy - 2), icon);
    canvas.drawLine(Offset(cx + 6, cy - 2), Offset(cx + 14, cy + 4), icon);

    final picture = recorder.endRecording();
    final img = await picture.toImage((w * scale).round(), (h * scale).round());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return data!.buffer.asUint8List();
  }

  static Path _hexPath(Offset c, double r) {
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = c.dx + r * math.cos(angle);
      final y = c.dy + r * math.sin(angle);
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    p.close();
    return p;
  }
}
