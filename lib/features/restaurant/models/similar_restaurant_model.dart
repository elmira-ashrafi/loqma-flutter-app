/// Minimal restaurant info for "Similar restaurants" horizontal list.
class SimilarRestaurantModel {
  const SimilarRestaurantModel({
    required this.id,
    required this.name,
    this.image,
    this.rating = 0,
    this.category,
  });

  final int id;
  final String name;
  final String? image;
  final double rating;
  final String? category;
}
