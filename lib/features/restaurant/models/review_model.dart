import '../../../../core/constants/api_constants.dart';

/// A single customer review for the restaurant details screen.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.customerName,
    this.avatarUrl,
    required this.rating,
    this.reviewText,
    this.createdAt,
  });

  final String id;
  final String customerName;
  final String? avatarUrl;
  final double rating;
  final String? reviewText;
  /// ISO-8601 timestamp from API; format in UI with [RelativeTimeL10n].
  final String? createdAt;

  /// Maps [ReviewController::formatRestaurantReview] JSON item.
  factory ReviewModel.fromApiJson(Map<String, dynamic> json) {
    final user = json['user'];
    var name = '';
    String? avatar;
    if (user is Map) {
      final u = Map<String, dynamic>.from(user);
      name = (u['name'] as String?)?.trim() ?? '';
      avatar = _resolveMediaUrl(u['avatar'] as String?);
    }

    final ratingVal = (json['restaurant_rating'] as num?)?.toDouble() ?? 0;
    final rawText = json['restaurant_review'] as String?;
    final text = rawText?.trim();
    final created = json['created_at'] as String?;

    final idVal = json['id'];
    return ReviewModel(
      id: idVal?.toString() ?? '',
      customerName: name,
      avatarUrl: avatar,
      rating: ratingVal,
      reviewText: text != null && text.isNotEmpty ? text : null,
      createdAt: created,
    );
  }

  static String? _resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/api/v1.*'), '');
    return u.startsWith('/') ? '$base$u' : '$base/$u';
  }

}
