/// Arguments for navigating to Restaurant Details screen.
/// Pass [restaurantId] and optionally [initialName], [initialImage], etc.
/// for immediate Hero/header display while full detail loads from API.
class RestaurantDetailsArgs {
  const RestaurantDetailsArgs({
    required this.restaurantId,
    this.initialName,
    this.initialImage,
    this.initialLogo,
    this.initialCover,
    this.initialRating = 0,
    this.initialTotalReviews,
    this.initialDeliveryTime,
    this.initialLocation,
    this.initialCategory,
    this.isOpen = true,
    this.deliveryFee,
    this.minOrder,
    this.freeDeliveryAbove,
  });

  final int restaurantId;
  final String? initialName;
  final String? initialImage;
  /// Optional logo thumbnail URL for header while API detail loads.
  final String? initialLogo;
  /// Optional cover/hero URL for SliverAppBar while API detail loads.
  final String? initialCover;
  final double initialRating;
  final int? initialTotalReviews;
  final String? initialDeliveryTime;
  final String? initialLocation;
  final String? initialCategory;
  final bool isOpen;
  final double? deliveryFee;
  final double? minOrder;
  final double? freeDeliveryAbove;
}
