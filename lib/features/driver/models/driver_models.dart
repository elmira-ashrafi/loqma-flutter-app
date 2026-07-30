import 'package:equatable/equatable.dart';

/// Basic driver info from /driver/dashboard & /driver/profile.
class DriverInfo extends Equatable {
  const DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.status,
    this.isOnline = false,
    this.isAvailable = true,
    this.totalDeliveries = 0,
    this.rating = 0,
    this.totalReviews = 0,
  });

  final int id;
  final String name;
  final String phone;
  final String? avatar;
  final String? status;
  final bool isOnline;
  final bool isAvailable;
  final int totalDeliveries;
  final double rating;
  final int totalReviews;

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return DriverInfo(
      id: (json['id'] as num?)?.toInt() ?? (user['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? user['name'] as String? ?? '',
      phone: json['phone'] as String? ?? user['phone'] as String? ?? '',
      avatar: json['avatar'] as String? ?? user['avatar'] as String?,
      status: json['status'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
    );
  }

  DriverInfo copyWith({
    int? id,
    String? name,
    String? phone,
    String? avatar,
    String? status,
    bool? isOnline,
    bool? isAvailable,
    int? totalDeliveries,
    double? rating,
    int? totalReviews,
  }) {
    return DriverInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      isAvailable: isAvailable ?? this.isAvailable,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, avatar, status, isOnline, isAvailable, totalDeliveries, rating, totalReviews];
}

/// Order summary used on dashboard, orders list, and details.
class DriverOrder extends Equatable {
  const DriverOrder({
    required this.id,
    required this.status,
    required this.orderNumber,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantPhone,
    this.deliveryName,
    this.deliveryPhone,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.total = 0,
    this.deliveryFee = 0,
    this.driverEarning = 0,
    this.itemsCount = 0,
    this.createdAt,
  });

  final int id;
  final String status;
  final String orderNumber;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? restaurantPhone;
  final String? deliveryName;
  final String? deliveryPhone;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final double total;
  final double deliveryFee;
  final double driverEarning;
  final int itemsCount;
  final String? createdAt;

  factory DriverOrder.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>?;

    return DriverOrder(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      orderNumber: json['order_number'] as String? ?? json['orderNumber'] as String? ?? '#${json['id']}',
      restaurantName: json['restaurant_name'] as String? ?? restaurant?['name'] as String?,
      restaurantAddress: json['restaurant_address'] as String? ?? restaurant?['address'] as String?,
      restaurantPhone: json['restaurant_phone'] as String? ?? restaurant?['phone'] as String?,
      deliveryName: json['delivery_name'] as String?,
      deliveryPhone: json['delivery_phone'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String?,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      driverEarning: (json['driver_earning'] as num?)?.toDouble() ?? (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      itemsCount: (json['items_count'] as num?)?.toInt() ?? (json['items'] as List?)?.length ?? 0,
      createdAt: json['created_at'] as String?,
    );
  }

  bool get isActive {
    final s = status.toLowerCase();
    return s != 'delivered' && s != 'cancelled' && s != 'refunded';
  }

  @override
  List<Object?> get props => [id, status, orderNumber];
}

/// Dashboard payload from /driver/dashboard.
class DriverDashboardData extends Equatable {
  const DriverDashboardData({
    required this.driver,
    this.todayEarnings = 0,
    this.weekEarnings = 0,
    this.pendingEarnings = 0,
    this.activeOrders = const [],
    this.availableOrders = const [],
    this.upcomingOrders = const [],
    this.recentOrders = const [],
  });

  final DriverInfo driver;
  final double todayEarnings;
  final double weekEarnings;
  final double pendingEarnings;
  final List<DriverOrder> activeOrders;
  final List<DriverOrder> availableOrders;
  final List<DriverOrder> upcomingOrders;
  final List<DriverOrder> recentOrders;

  factory DriverDashboardData.fromJson(Map<String, dynamic> json) {
    final driverJson = json['driver'] as Map<String, dynamic>? ?? json;

    List<DriverOrder> parseList(dynamic raw) {
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().map(DriverOrder.fromJson).toList();
      }
      if (raw is Map<String, dynamic> && raw['data'] is List) {
        return (raw['data'] as List).whereType<Map<String, dynamic>>().map(DriverOrder.fromJson).toList();
      }
      return const [];
    }

    return DriverDashboardData(
      driver: DriverInfo.fromJson(driverJson),
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? (json['todayEarnings'] as num?)?.toDouble() ?? 0,
      weekEarnings: (json['week_earnings'] as num?)?.toDouble() ?? (json['weekEarnings'] as num?)?.toDouble() ?? 0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? (json['pendingEarnings'] as num?)?.toDouble() ?? 0,
      activeOrders: parseList(json['active_orders']),
      availableOrders: parseList(json['available_orders']),
      upcomingOrders: parseList(json['upcoming_orders']),
      recentOrders: parseList(json['recent_orders']),
    );
  }

  DriverDashboardData copyWith({
    DriverInfo? driver,
    double? todayEarnings,
    double? weekEarnings,
    double? pendingEarnings,
    List<DriverOrder>? activeOrders,
    List<DriverOrder>? availableOrders,
    List<DriverOrder>? upcomingOrders,
    List<DriverOrder>? recentOrders,
  }) {
    return DriverDashboardData(
      driver: driver ?? this.driver,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weekEarnings: weekEarnings ?? this.weekEarnings,
      pendingEarnings: pendingEarnings ?? this.pendingEarnings,
      activeOrders: activeOrders ?? this.activeOrders,
      availableOrders: availableOrders ?? this.availableOrders,
      upcomingOrders: upcomingOrders ?? this.upcomingOrders,
      recentOrders: recentOrders ?? this.recentOrders,
    );
  }

  @override
  List<Object?> get props => [driver];
}

