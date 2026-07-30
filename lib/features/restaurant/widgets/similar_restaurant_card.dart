import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_network_image.dart';
import '../models/similar_restaurant_model.dart';

/// Horizontal card for similar restaurants section.
class SimilarRestaurantCard extends StatelessWidget {
  const SimilarRestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  final SimilarRestaurantModel restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 400;
    final cardWidth = (isCompact ? 140 : 160).toDouble();
    final imageHeight = (isCompact ? 90 : 100).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: restaurant.image != null && restaurant.image!.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: restaurant.image!,
                        width: cardWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(cardWidth, imageHeight),
                        errorWidget: (_, __, ___) => _placeholder(cardWidth, imageHeight),
                      )
                    : _placeholder(cardWidth, imageHeight),
              ),
              Padding(
                padding: EdgeInsets.all(isCompact ? 8 : 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 12 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurant.category != null) ...[
                      SizedBox(height: isCompact ? 2 : 4),
                      Text(
                        restaurant.category!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (restaurant.rating > 0) ...[
                      SizedBox(height: isCompact ? 4 : 6),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: AppColors.rating),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: AppColors.primary.withOpacity(0.15),
      child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 40),
    );
  }
}
