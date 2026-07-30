import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network image with decode/memory cache sized to layout — reduces RAM and jank.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  static int? _cachePx(BuildContext context, double? logical) {
    if (logical == null || !logical.isFinite || logical <= 0) return null;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (logical * dpr).round().clamp(1, 2048);
  }

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = height;
    final memW = _cachePx(context, w);
    final memH = _cachePx(context, h);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: w,
      height: h,
      fit: fit,
      memCacheWidth: memW,
      memCacheHeight: memH,
      maxWidthDiskCache: memW != null ? (memW * 2).clamp(1, 2048) : null,
      maxHeightDiskCache: memH != null ? (memH * 2).clamp(1, 2048) : null,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
