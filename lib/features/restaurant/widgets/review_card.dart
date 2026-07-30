import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/font_helper.dart';
import '../../../core/utils/relative_time_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../models/review_model.dart';

/// Single review card: avatar, name, time, rating, text.
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.cardWidth,
    this.fullWidth = false,
  });

  final ReviewModel review;
  /// Fixed width for horizontal carousel; ignored when [fullWidth] is true.
  final double? cardWidth;
  /// Full-width stacked layout (narrow screens / vertical list).
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Get.find<LocaleController>().locale.languageCode;
    final localeTag = Localizations.localeOf(context).toString();
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 400;
    final width = fullWidth ? null : (cardWidth ?? (isCompact ? 280.0 : 320.0));
    final displayName = review.customerName.trim().isEmpty
        ? l10n.reviewAnonymousCustomer
        : review.customerName;
    final timeLabel = RelativeTimeL10n.formatIso(l10n, localeTag, review.createdAt);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Container(
        width: width,
        margin: fullWidth ? EdgeInsets.zero : const EdgeInsetsDirectional.only(end: 12),
        padding: EdgeInsets.all(isCompact ? 12 : 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isCompact ? 18 : 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: review.avatarUrl != null && review.avatarUrl!.isNotEmpty
                      ? NetworkImage(review.avatarUrl!)
                      : null,
                  child: review.avatarUrl == null || review.avatarUrl!.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                          style: FontHelper.getTextStyle(
                            text: displayName,
                            languageCode: languageCode,
                            fontWeight: FontWeight.w600,
                            fontSize: isCompact ? 14 : 16,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                SizedBox(width: isCompact ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: FontHelper.getTextStyle(
                          text: displayName,
                          languageCode: languageCode,
                          fontWeight: FontWeight.w600,
                          fontSize: isCompact ? 13 : 14,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (timeLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          timeLabel,
                          style: FontHelper.getTextStyle(
                            text: timeLabel,
                            languageCode: languageCode,
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: isCompact ? 16 : 18, color: AppColors.rating),
                    const SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: FontHelper.getTextStyle(
                        text: review.rating.toStringAsFixed(1),
                        languageCode: languageCode,
                        fontWeight: FontWeight.w700,
                        fontSize: isCompact ? 12 : 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              SizedBox(height: isCompact ? 8 : 10),
              Text(
                review.reviewText!,
                style: FontHelper.getTextStyle(
                  text: review.reviewText!,
                  languageCode: languageCode,
                  fontSize: isCompact ? 12 : 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ).copyWith(height: 1.35),
                maxLines: fullWidth ? null : 4,
                overflow: fullWidth ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
