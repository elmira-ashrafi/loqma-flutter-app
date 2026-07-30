import 'package:equatable/equatable.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  return fallback;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == '1' || normalized == 'true' || normalized == 'yes') return true;
    if (normalized == '0' || normalized == 'false' || normalized == 'no') return false;
  }
  return fallback;
}

class RestaurantOwnerInfo extends Equatable {
  const RestaurantOwnerInfo({
    required this.id,
    required this.name,
    this.status = 'pending',
    this.isOpen = false,
    this.nameFa,
    this.namePs,
    this.description,
    this.phone,
    this.email,
    this.address,
    this.deliveryFee = 0,
    this.minimumOrder = 0,
    this.freeDeliveryAbove = 0,
    this.avgPreparationTime = 0,
    this.acceptsCash = false,
    this.acceptsOnlinePayment = false,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String status;
  final bool isOpen;
  final String? nameFa;
  final String? namePs;
  final String? description;
  final String? phone;
  final String? email;
  final String? address;
  final double deliveryFee;
  final double minimumOrder;
  final double freeDeliveryAbove;
  final int avgPreparationTime;
  final double? latitude;
  final double? longitude;
  final bool acceptsCash;
  final bool acceptsOnlinePayment;

  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isActive => status == 'active';

  factory RestaurantOwnerInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantOwnerInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      isOpen: _asBool(json['is_open']),
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      deliveryFee: _asDouble(json['delivery_fee']),
      minimumOrder: _asDouble(json['minimum_order']),
      freeDeliveryAbove: _asDouble(json['free_delivery_above']),
      avgPreparationTime: _asInt(json['avg_preparation_time']),
      latitude: json['latitude'] == null ? null : _asDouble(json['latitude']),
      longitude: json['longitude'] == null ? null : _asDouble(json['longitude']),
      acceptsCash: _asBool(json['accepts_cash']),
      acceptsOnlinePayment: _asBool(json['accepts_online_payment']),
    );
  }

  @override
  List<Object?> get props => [id, name, status, isOpen];
}

class RestaurantOwnerStats extends Equatable {
  const RestaurantOwnerStats({
    this.todayOrders = 0,
    this.todayRevenue = 0,
    this.pendingOrders = 0,
    this.rating = 0,
  });

  final int todayOrders;
  final double todayRevenue;
  final int pendingOrders;
  final double rating;

  factory RestaurantOwnerStats.fromJson(Map<String, dynamic> json) {
    return RestaurantOwnerStats(
      todayOrders: _asInt(json['today_orders']),
      todayRevenue: _asDouble(json['today_revenue']),
      pendingOrders: _asInt(json['pending_orders']),
      rating: _asDouble(json['rating']),
    );
  }

  @override
  List<Object?> get props => [todayOrders, todayRevenue, pendingOrders, rating];
}

class RestaurantOrderLine extends Equatable {
  const RestaurantOrderLine({
    required this.name,
    this.quantity = 0,
  });

  final String name;
  final int quantity;

  factory RestaurantOrderLine.fromJson(Map<String, dynamic> json) {
    return RestaurantOrderLine(
      name: json['name'] as String? ?? '',
      quantity: _asInt(json['quantity']),
    );
  }

  @override
  List<Object?> get props => [name, quantity];
}

class RestaurantOwnerOrder extends Equatable {
  const RestaurantOwnerOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.total = 0,
    this.createdAt,
    this.customerName,
    this.customerPhone,
    this.driverName,
    this.items = const [],
  });

  final int id;
  final String orderNumber;
  final String status;
  final double total;
  final String? createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? driverName;
  final List<RestaurantOrderLine> items;

  bool get isPending => status == 'pending';
  bool get canStartPreparing => status == 'confirmed';
  bool get canMarkReady => status == 'preparing';
  bool get isFinished => status == 'delivered' || status == 'cancelled';

  factory RestaurantOwnerOrder.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final driver = json['driver'] as Map<String, dynamic>?;
    final rawItems = json['items'] as List? ?? const [];
    return RestaurantOwnerOrder(
      id: _asInt(json['id']),
      orderNumber: json['order_number'] as String? ?? '#${json['id']}',
      status: json['status'] as String? ?? 'pending',
      total: _asDouble(json['total']),
      createdAt: json['created_at'] as String?,
      customerName: user?['name'] as String?,
      customerPhone: user?['phone'] as String?,
      driverName: driver?['name'] as String?,
      items: rawItems
          .whereType<Map>()
          .map((e) => RestaurantOrderLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, orderNumber, status, total];
}

class RestaurantWeekPoint extends Equatable {
  const RestaurantWeekPoint({
    required this.date,
    this.orders = 0,
    this.revenue = 0,
  });

  final String date;
  final int orders;
  final double revenue;

  factory RestaurantWeekPoint.fromJson(Map<String, dynamic> json) {
    return RestaurantWeekPoint(
      date: json['date'] as String? ?? '',
      orders: _asInt(json['orders']),
      revenue: _asDouble(json['revenue']),
    );
  }

  @override
  List<Object?> get props => [date, orders, revenue];
}

class RestaurantOwnerDashboardData extends Equatable {
  const RestaurantOwnerDashboardData({
    required this.restaurant,
    required this.stats,
    this.pendingOrders = const [],
    this.activeOrders = const [],
    this.recentOrders = const [],
    this.weeklyStats = const [],
  });

  final RestaurantOwnerInfo restaurant;
  final RestaurantOwnerStats stats;
  final List<RestaurantOwnerOrder> pendingOrders;
  final List<RestaurantOwnerOrder> activeOrders;
  final List<RestaurantOwnerOrder> recentOrders;
  final List<RestaurantWeekPoint> weeklyStats;

  factory RestaurantOwnerDashboardData.fromJson(Map<String, dynamic> json) {
    List<RestaurantOwnerOrder> parseOrders(dynamic raw) {
      final list = raw as List? ?? const [];
      return list
          .whereType<Map>()
          .map((e) => RestaurantOwnerOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    List<RestaurantWeekPoint> parseWeekly(dynamic raw) {
      final list = raw as List? ?? const [];
      return list
          .whereType<Map>()
          .map((e) => RestaurantWeekPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return RestaurantOwnerDashboardData(
      restaurant: RestaurantOwnerInfo.fromJson(
        Map<String, dynamic>.from(json['restaurant'] as Map? ?? const {}),
      ),
      stats: RestaurantOwnerStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
      ),
      pendingOrders: parseOrders(json['pending_orders']),
      activeOrders: parseOrders(json['active_orders']),
      recentOrders: parseOrders(json['recent_orders']),
      weeklyStats: parseWeekly(json['weekly_stats']),
    );
  }

  @override
  List<Object?> get props => [restaurant, stats, pendingOrders, activeOrders, recentOrders, weeklyStats];
}

class RestaurantHour extends Equatable {
  const RestaurantHour({
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    this.isClosed = true,
  });

  final int dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  factory RestaurantHour.fromJson(Map<String, dynamic> json) {
    return RestaurantHour(
      dayOfWeek: _asInt(json['day_of_week']),
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      isClosed: _asBool(json['is_closed'], true),
    );
  }

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'open_time': openTime,
        'close_time': closeTime,
        'is_closed': isClosed ? 1 : 0,
      };

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime, isClosed];
}

class RestaurantOwnerSettingsData extends Equatable {
  const RestaurantOwnerSettingsData({
    required this.restaurant,
    this.hours = const [],
  });

  final RestaurantOwnerInfo restaurant;
  final List<RestaurantHour> hours;

  factory RestaurantOwnerSettingsData.fromJson(Map<String, dynamic> json) {
    final rawHours = json['hours'] as List? ?? const [];
    return RestaurantOwnerSettingsData(
      restaurant: RestaurantOwnerInfo.fromJson(
        Map<String, dynamic>.from(json['restaurant'] as Map? ?? const {}),
      ),
      hours: rawHours
          .whereType<Map>()
          .map((e) => RestaurantHour.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [restaurant, hours];
}

class MenuItemSizeVariant extends Equatable {
  const MenuItemSizeVariant({
    required this.id,
    required this.name,
    this.priceAdjustment = 0,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final double priceAdjustment;
  final bool isDefault;

  factory MenuItemSizeVariant.fromJson(Map<String, dynamic> json) {
    return MenuItemSizeVariant(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      priceAdjustment: _asDouble(json['price_adjustment'] ?? json['priceAdjustment']),
      isDefault: _asBool(json['is_default']),
    );
  }

  @override
  List<Object?> get props => [id, name, priceAdjustment];
}

class RestaurantMenuItem extends Equatable {
  const RestaurantMenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.nameFa,
    this.namePs,
    this.description,
    this.price = 0,
    this.discountedPrice,
    this.imageUrl,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isSpecialOffer = false,
    this.offerLabel,
    this.discountStart,
    this.discountEnd,
    this.preparationTime,
    this.sizeGroupId,
    this.sizeVariants = const [],
  });

  final int id;
  final int categoryId;
  final String name;
  final String? nameFa;
  final String? namePs;
  final String? description;
  final double price;
  final double? discountedPrice;
  final String? imageUrl;
  final bool isAvailable;
  final bool isFeatured;
  final bool isSpecialOffer;
  final String? offerLabel;
  final String? discountStart;
  final String? discountEnd;
  final int? preparationTime;
  final int? sizeGroupId;
  final List<MenuItemSizeVariant> sizeVariants;

  bool get hasSizes => sizeVariants.isNotEmpty;

  double? sizePrice(String sizeName) {
    final normalized = sizeName.toLowerCase();
    for (final variant in sizeVariants) {
      if (variant.name.toLowerCase() == normalized) {
        return price + variant.priceAdjustment;
      }
    }
    return null;
  }

  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) {
    String? iso(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    final sizeData = _parseSizeVariants(json);

    return RestaurantMenuItem(
      id: _asInt(json['id']),
      categoryId: _asInt(json['food_category_id']),
      name: json['name'] as String? ?? '',
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      description: json['description'] as String?,
      price: _asDouble(json['price']),
      discountedPrice: json['discounted_price'] == null ? null : _asDouble(json['discounted_price']),
      imageUrl: json['image_url'] as String?,
      isAvailable: _asBool(json['is_available'], true),
      isFeatured: _asBool(json['is_featured']),
      isSpecialOffer: _asBool(json['is_special_offer']),
      offerLabel: json['offer_label'] as String?,
      discountStart: iso(json['discount_start']),
      discountEnd: iso(json['discount_end']),
      preparationTime: json['preparation_time'] == null ? null : _asInt(json['preparation_time']),
      sizeGroupId: sizeData.$1,
      sizeVariants: sizeData.$2,
    );
  }

  static (int?, List<MenuItemSizeVariant>) _parseSizeVariants(Map<String, dynamic> json) {
    final groups = json['variant_groups'] as List? ?? const [];
    if (groups.isEmpty) return (null, const []);

    Map<String, dynamic>? sizeGroup;
    for (final raw in groups) {
      if (raw is! Map) continue;
      final group = Map<String, dynamic>.from(raw);
      final name = (group['name'] as String? ?? '').toLowerCase();
      if (name == 'size' || sizeGroup == null) {
        sizeGroup = group;
        if (name == 'size') break;
      }
    }
    if (sizeGroup == null) return (null, const []);

    final variants = (sizeGroup['variants'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => MenuItemSizeVariant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return (_asInt(sizeGroup['id']), variants);
  }

  @override
  List<Object?> get props =>
      [id, categoryId, name, price, discountedPrice, imageUrl, isAvailable, isFeatured, isSpecialOffer, offerLabel, sizeVariants];
}

class RestaurantMenuCategory extends Equatable {
  const RestaurantMenuCategory({
    required this.id,
    required this.name,
    this.nameFa,
    this.namePs,
    this.description,
    this.isActive = true,
    this.sortOrder = 0,
    this.items = const [],
  });

  final int id;
  final String name;
  final String? nameFa;
  final String? namePs;
  final String? description;
  final bool isActive;
  final int sortOrder;
  final List<RestaurantMenuItem> items;

  factory RestaurantMenuCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? const [];
    return RestaurantMenuCategory(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      nameFa: json['name_fa'] as String?,
      namePs: json['name_ps'] as String?,
      description: json['description'] as String?,
      isActive: _asBool(json['is_active'], true),
      sortOrder: _asInt(json['sort_order']),
      items: rawItems
          .whereType<Map>()
          .map((e) => RestaurantMenuItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, isActive, sortOrder, items];
}
