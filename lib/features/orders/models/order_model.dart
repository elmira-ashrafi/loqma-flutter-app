import 'package:equatable/equatable.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/l10n/localized_content.dart';
import '../../../core/l10n/localized_entity_fields.dart';

/// Laravel may send decimals as [String] or [num].
double? _parseCoord(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

String? _parseOptionalString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

/// API may send `0` for unset delivery ETA when the restaurant only sets prep time.
String? _parseEstimatedDeliveryTime(dynamic value) {
  final text = _parseOptionalString(value);
  if (text == null) return null;
  final digits = RegExp(r'^\d+$').firstMatch(text);
  if (digits != null) {
    final minutes = int.tryParse(digits.group(0)!);
    if (minutes == null || minutes <= 0) return null;
  }
  final withUnit = RegExp(r'^(\d+)\s*min$', caseSensitive: false).firstMatch(text);
  if (withUnit != null) {
    final minutes = int.tryParse(withUnit.group(1)!);
    if (minutes == null || minutes <= 0) return null;
  }
  return text;
}

/// True when [raw] is a real ETA (not empty / not `0`).
bool isUsableEstimatedDeliveryTime(String? raw) {
  return _parseEstimatedDeliveryTime(raw) != null;
}

/// Order from /customer/orders and /customer/orders/{id}.
class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.status,
    this.orderNumber,
    this.total = 0,
    this.restaurantName,
    this.restaurantNameFa,
    this.restaurantNamePs,
    this.restaurantLocalizedName,
    this.restaurantImage,
    this.restaurantPhone,
    this.restaurantAddress,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.deliveryTime,
    this.avgPreparationTime,
    this.estimatedPrepTime,
    this.placedAt,
    this.deliveryAddress,
    this.deliveryName,
    this.deliveryPhone,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.deliveryInstructions,
    this.estimatedDeliveryTime,
    this.timeline = const [],
    this.items,
    this.itemsCount,
    this.subtotal,
    this.deliveryFee,
    this.paymentMethod,
    this.paymentStatus,
    this.driver,
  });

  final int id;
  final String status;
  final String? orderNumber;
  final double total;
  final String? restaurantName;
  final String? restaurantNameFa;
  final String? restaurantNamePs;
  final String? restaurantLocalizedName;
  final String? restaurantImage;

  String? get displayRestaurantName {
    final en = restaurantName?.trim() ?? '';
    final fa = restaurantNameFa?.trim();
    final ps = restaurantNamePs?.trim();
    final localized = restaurantLocalizedName?.trim();
    if (en.isEmpty && (fa == null || fa.isEmpty) && (ps == null || ps.isEmpty) && (localized == null || localized.isEmpty)) {
      return null;
    }
    return LocalizedContent.restaurantDisplayName(
      en: en,
      fa: restaurantNameFa,
      ps: restaurantNamePs,
      localizedFromApi: restaurantLocalizedName,
    );
  }
  final String? restaurantPhone;
  final String? restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  /// Restaurant window, same as [RestaurantModel.deliveryTime] (e.g. `"35-45 min"`).
  final String? deliveryTime;
  /// Restaurant average prep minutes from nested `restaurant` (same as home cards).
  final int? avgPreparationTime;
  /// Minutes set when the restaurant confirms the order (`estimated_prep_time`).
  final int? estimatedPrepTime;
  final String? placedAt;
  final String? deliveryAddress;
  final String? deliveryName;
  final String? deliveryPhone;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? deliveryInstructions;
  final String? estimatedDeliveryTime;
  final List<OrderStatusStep> timeline;
  final List<OrderItemModel>? items;
  final int? itemsCount;

  int get effectiveItemCount => items?.length ?? itemsCount ?? 0;

  final double? subtotal;
  final double? deliveryFee;
  final String? paymentMethod;
  final String? paymentStatus;
  final OrderDriverModel? driver;

  /// Customer may cancel only before the restaurant accepts the order.
  bool get canBeCancelledByCustomer {
    final s = status.toLowerCase();
    return s == 'pending';
  }

  /// ISO timestamp used for display and queue ordering (never drops a known date).
  String? get effectivePlacedAt {
    final direct = placedAt?.trim();
    if (direct != null && direct.isNotEmpty && parseOrderDateTime(direct) != null) {
      return direct;
    }
    return placedDateTime(this)?.toIso8601String();
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'];
    String? name;
    String? logo;
    String? phone;
    String? address;
    double? lat;
    double? lng;
    String? deliveryTime;
    int? avgPrep;
    String? nameFa;
    String? namePs;
    String? localizedName;
    if (restaurant is Map) {
      final r = Map<String, dynamic>.from(restaurant);
      name = r['name'] as String?;
      nameFa = r['name_fa'] as String?;
      namePs = r['name_ps'] as String?;
      localizedName = r['localized_name'] as String?;
      logo = r['logo'] as String?;
      phone = r['phone'] as String?;
      address = r['address'] as String?;
      lat = _parseCoord(r['latitude']) ?? _parseCoord(r['lat']);
      lng = _parseCoord(r['longitude']) ?? _parseCoord(r['lng']);
      deliveryTime = r['delivery_time'] as String? ?? r['deliveryTime'] as String?;
      final prep = r['avg_preparation_time'] ?? r['avg_prep_time'];
      avgPrep = prep is num ? prep.toInt() : int.tryParse('$prep');
    }
    deliveryTime ??=
        json['restaurant_delivery_time'] as String? ?? json['deliveryTime'] as String?;
    avgPrep ??= _parseOptionalInt(
      json['restaurant_avg_preparation_time'] ?? json['avg_preparation_time'],
    );
    final estimatedPrep = _parseOptionalInt(json['estimated_prep_time']);
    final driverJson = json['driver'];
    OrderDriverModel? driverModel;
    if (driverJson is Map<String, dynamic>) {
      driverModel = OrderDriverModel.fromJson(driverJson);
    }
    final rawItems = json['order_items'] ?? json['items'];
    List<OrderItemModel>? itemsList;
    if (rawItems is List) {
      itemsList = rawItems
          .whereType<Map>()
          .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    final del = json['delivery'];
    double? delLat = _parseCoord(json['delivery_latitude']) ?? _parseCoord(json['delivery_lat']);
    double? delLng = _parseCoord(json['delivery_longitude']) ?? _parseCoord(json['delivery_lng']);
    if (del is Map<String, dynamic>) {
      delLat ??= _parseCoord(del['latitude']) ?? _parseCoord(del['lat']);
      delLng ??= _parseCoord(del['longitude']) ?? _parseCoord(del['lng']);
    }

    final timeline = _parseTimeline(json);
    final placedAt = _resolvePlacedAt(json, timeline);

    return OrderModel(
      id: _parseId(json['id']),
      status: _parseOrderStatus(json),
      orderNumber: json['order_number'] as String? ?? json['orderNumber'] as String?,
      total: _parseDouble(json['total']),
      restaurantName: name ?? json['restaurant_name'] as String? ?? json['restaurantName'] as String?,
      restaurantNameFa: nameFa ?? json['restaurant_name_fa'] as String?,
      restaurantNamePs: namePs ?? json['restaurant_name_ps'] as String?,
      restaurantLocalizedName: localizedName ?? json['restaurant_localized_name'] as String?,
      restaurantImage: logo ?? json['restaurant_image'] as String? ?? json['restaurantImage'] as String?,
      restaurantPhone: phone ?? json['restaurant_phone'] as String?,
      restaurantAddress: address ?? json['restaurant_address'] as String?,
      restaurantLatitude: lat ?? _parseCoord(json['restaurant_latitude']) ?? _parseCoord(json['restaurant_lat']),
      restaurantLongitude: lng ?? _parseCoord(json['restaurant_longitude']) ?? _parseCoord(json['restaurant_lng']),
      deliveryTime: deliveryTime,
      avgPreparationTime: avgPrep,
      estimatedPrepTime: estimatedPrep,
      placedAt: placedAt,
      deliveryAddress: _parseOptionalString(json['delivery_address']) ??
          _parseOptionalString(json['deliveryAddress']) ??
          _deliveryFromJson(json)['address'],
      deliveryName: _parseOptionalString(json['delivery_name']) ??
          _parseOptionalString(json['deliveryName']) ??
          _deliveryFromJson(json)['name'],
      deliveryPhone: _parseOptionalString(json['delivery_phone']) ??
          _parseOptionalString(json['deliveryPhone']) ??
          _deliveryFromJson(json)['phone'],
      deliveryLatitude: delLat,
      deliveryLongitude: delLng,
      deliveryInstructions: json['delivery_instructions'] as String? ?? json['deliveryInstructions'] as String?,
      // Laravel may return minutes as an integer or a timestamp as a string.
      // `0` means unset (restaurant confirm currently writes 0 for delivery ETA).
      estimatedDeliveryTime: _parseEstimatedDeliveryTime(
        json['estimated_delivery_time'] ??
            json['estimatedDeliveryTime'] ??
            json['estimated_delivery_at'] ??
            json['estimated_delivery'],
      ),
      timeline: timeline,
      items: itemsList,
      itemsCount: (json['items_count'] as num?)?.toInt() ?? (json['itemsCount'] as num?)?.toInt(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? (json['sub_total'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? (json['delivery_fee'] as num?)?.toDouble(),
      paymentMethod: json['payment_method'] as String? ?? json['paymentMethod'] as String?,
      paymentStatus: json['payment_status'] as String? ?? json['paymentStatus'] as String?,
      driver: driverModel,
    );
  }

  static int? _parseOptionalInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  static int _parseId(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v, [double fallback = 0]) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  /// Prefer machine status keys (`preparing`) over localized display labels.
  static String _parseOrderStatus(Map<String, dynamic> json) {
    final raw = (json['status'] as String?)?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    final display = (json['status_display'] as String?)?.trim();
    if (display != null && display.isNotEmpty) return display;
    return 'pending';
  }

  static String? _parsePlacedAt(dynamic v) {
    if (v == null) return null;
    if (v is num) {
      final n = v.toDouble();
      final ms = n > 1e12 ? n.round() : (n * 1000).round();
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toIso8601String();
    }
    if (v is String) {
      final trimmed = v.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return v.toString();
  }

  static DateTime? parseOrderDateTime(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    var dt = DateTime.tryParse(trimmed);
    if (dt != null) return dt;

    if (trimmed.contains(' ') && !trimmed.contains('T')) {
      dt = DateTime.tryParse(trimmed.replaceFirst(' ', 'T'));
      if (dt != null) return dt;
    }

    final match = RegExp(r'^(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}:\d{2})').firstMatch(trimmed);
    if (match != null) {
      dt = DateTime.tryParse('${match.group(1)}T${match.group(2)}');
      if (dt != null) return dt;
    }

    return null;
  }

  static String? _resolvePlacedAt(Map<String, dynamic> json, List<OrderStatusStep> timeline) {
    for (final key in [
      'created_at',
      'placed_at',
      'placedAt',
      'ordered_at',
      'paid_at',
      'updated_at',
    ]) {
      final parsed = _parsePlacedAt(json[key]);
      if (parsed != null && parseOrderDateTime(parsed) != null) return parsed;
    }
    return _earliestTimelineIso(timeline);
  }

  static String? _earliestTimelineIso(List<OrderStatusStep> timeline) {
    DateTime? earliest;
    String? iso;
    for (final step in timeline) {
      final dt = parseOrderDateTime(step.completedAt);
      if (dt != null && (earliest == null || dt.isBefore(earliest))) {
        earliest = dt;
        iso = step.completedAt;
      }
    }
    return iso ?? earliest?.toIso8601String();
  }

  static DateTime? placedDateTime(OrderModel order) {
    final fromField = parseOrderDateTime(order.placedAt);
    if (fromField != null) return fromField;

    DateTime? earliest;
    for (final step in order.timeline) {
      final dt = parseOrderDateTime(step.completedAt);
      if (dt != null && (earliest == null || dt.isBefore(earliest))) {
        earliest = dt;
      }
    }
    return earliest;
  }

  /// Microsecond key for strict newest-first queue ordering.
  static int queueSortKey(OrderModel order) {
    final dt = placedDateTime(order);
    if (dt != null) return dt.microsecondsSinceEpoch;
    return order.id;
  }

  static int compareNewestFirst(OrderModel a, OrderModel b) {
    final byTime = queueSortKey(b).compareTo(queueSortKey(a));
    if (byTime != 0) return byTime;
    return b.id.compareTo(a.id);
  }

  static List<OrderModel> sortedNewestFirst(Iterable<OrderModel> orders) {
    final sorted = List<OrderModel>.from(orders);
    sorted.sort(compareNewestFirst);
    return sorted;
  }

  static List<OrderStatusStep> _parseTimeline(Map<String, dynamic> json) {
    final raw = json['timeline'] ?? json['status_history'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => OrderStatusStep.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Map<String, String?> _deliveryFromJson(Map<String, dynamic> json) {
    final d = json['delivery'];
    if (d is Map) {
      final map = Map<String, dynamic>.from(d);
      return {
        'name': _parseOptionalString(map['name']) ??
            _parseOptionalString(map['customer_name']) ??
            _parseOptionalString(map['full_name']),
        'phone': _parseOptionalString(map['phone']) ??
            _parseOptionalString(map['customer_phone']),
        'address': _parseOptionalString(map['address']) ??
            _parseOptionalString(json['delivery_address']) ??
            _parseOptionalString(json['deliveryAddress']),
      };
    }
    return {'name': null, 'phone': null, 'address': null};
  }

  /// Laravel stores menu images under `storage/`; APIs may return a raw path or full URL.
  static String? resolveMediaUrl(String? path) {
    if (path == null) return null;
    final p = path.trim();
    if (p.isEmpty) return null;
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    final origin = ApiConstants.apiOrigin;
    if (p.startsWith('/storage/')) return '$origin$p';
    if (p.startsWith('storage/')) return '$origin/$p';
    if (p.startsWith('/')) return '$origin$p';
    return '$origin/storage/$p';
  }

  /// Merge with another order (e.g. detail) while keeping this order's driver.
  OrderModel copyWith({
    int? id,
    String? status,
    String? orderNumber,
    double? total,
    String? restaurantName,
    String? restaurantNameFa,
    String? restaurantNamePs,
    String? restaurantLocalizedName,
    String? restaurantImage,
    String? restaurantPhone,
    String? restaurantAddress,
    double? restaurantLatitude,
    double? restaurantLongitude,
    String? deliveryTime,
    int? avgPreparationTime,
    int? estimatedPrepTime,
    String? placedAt,
    String? deliveryAddress,
    String? deliveryName,
    String? deliveryPhone,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? deliveryInstructions,
    String? estimatedDeliveryTime,
    List<OrderStatusStep>? timeline,
    List<OrderItemModel>? items,
    int? itemsCount,
    double? subtotal,
    double? deliveryFee,
    String? paymentMethod,
    String? paymentStatus,
    OrderDriverModel? driver,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      orderNumber: orderNumber ?? this.orderNumber,
      total: total ?? this.total,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantNameFa: restaurantNameFa ?? this.restaurantNameFa,
      restaurantNamePs: restaurantNamePs ?? this.restaurantNamePs,
      restaurantLocalizedName: restaurantLocalizedName ?? this.restaurantLocalizedName,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantLatitude: restaurantLatitude ?? this.restaurantLatitude,
      restaurantLongitude: restaurantLongitude ?? this.restaurantLongitude,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      avgPreparationTime: avgPreparationTime ?? this.avgPreparationTime,
      estimatedPrepTime: estimatedPrepTime ?? this.estimatedPrepTime,
      placedAt: placedAt ?? this.placedAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryName: deliveryName ?? this.deliveryName,
      deliveryPhone: deliveryPhone ?? this.deliveryPhone,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      timeline: timeline ?? this.timeline,
      items: items ?? this.items,
      itemsCount: itemsCount ?? this.itemsCount,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      driver: driver ?? this.driver,
    );
  }

  @override
  List<Object?> get props => [id, status];
}

class OrderItemModel extends Equatable {
  const OrderItemModel({
    this.id,
    required this.name,
    this.localized = const LocalizedEntityFields(name: ''),
    this.description,
    this.quantity = 1,
    this.unitPrice = 0,
    this.total,
    this.imageUrl,
  });

  final int? id;
  final String name;
  final LocalizedEntityFields localized;
  final String? description;

  String get displayName => localized.displayName;
  final int quantity;
  final double unitPrice;
  final double? total;
  final String? imageUrl;

  double get lineTotal => total ?? (quantity * unitPrice);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final food = json['food'] ?? json['product'] ?? json['food_item'];
    final merged = Map<String, dynamic>.from(json);
    if (food is Map) {
      final foodMap = Map<String, dynamic>.from(food);
      for (final key in ['name', 'name_fa', 'name_ps', 'localized_name', 'description', 'description_fa', 'description_ps', 'localized_description']) {
        final foodVal = foodMap[key];
        if (foodVal != null && (merged[key] == null || '${merged[key]}'.trim().isEmpty)) {
          merged[key] = foodVal;
        }
      }
      merged.putIfAbsent('image', () => foodMap['image'] ?? foodMap['image_url'] ?? foodMap['thumbnail']);
    }
    final fields = LocalizedEntityFields.fromJson(merged);
    String? img = _parseOptionalString(json['image']) ??
        _parseOptionalString(json['image_url']) ??
        _parseOptionalString(json['imageUrl']) ??
        _parseOptionalString(json['thumbnail']);
    if (food is Map) {
      final foodMap = Map<String, dynamic>.from(food);
      img ??= _parseOptionalString(foodMap['image']) ??
          _parseOptionalString(foodMap['image_url']) ??
          _parseOptionalString(foodMap['imageUrl']) ??
          _parseOptionalString(foodMap['thumbnail']);
    }
    final qty = (json['quantity'] as num?)?.toInt() ?? (json['qty'] as num?)?.toInt() ?? 1;
    final unit = (json['unit_price'] as num?)?.toDouble() ?? (json['unitPrice'] as num?)?.toDouble() ?? 0.0;
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt(),
      name: fields.name.isNotEmpty ? fields.name : 'Item',
      localized: fields,
      description: fields.displayDescription,
      quantity: qty,
      unitPrice: unit,
      total: (json['total'] as num?)?.toDouble() ??
          (json['line_total'] as num?)?.toDouble() ??
          (json['subtotal'] as num?)?.toDouble(),
      imageUrl: OrderModel.resolveMediaUrl(img),
    );
  }

  @override
  List<Object?> get props => [id, name, quantity];
}

class OrderStatusStep extends Equatable {
  const OrderStatusStep({
    required this.status,
    this.label,
    this.completedAt,
    this.isCompleted = false,
  });

  final String status;
  final String? label;
  final String? completedAt;
  final bool isCompleted;

  factory OrderStatusStep.fromJson(Map<String, dynamic> json) {
    return OrderStatusStep(
      status: json['status'] as String? ?? '',
      label: json['label'] as String?,
      completedAt: json['completed_at'] as String? ??
          json['completedAt'] as String? ??
          json['created_at'] as String?,
      isCompleted: json['is_completed'] as bool? ?? json['isCompleted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [status, isCompleted];
}

/// Driver info from order track API (supports real-time location).
class OrderDriverModel extends Equatable {
  const OrderDriverModel({
    required this.name,
    this.avatarUrl,
    this.phone,
    this.rating,
    this.vehicleType,
    this.vehiclePlate,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String? avatarUrl;
  final String? phone;
  final double? rating;
  final String? vehicleType;
  final String? vehiclePlate;
  /// Real-time driver position from track API (optional).
  final double? latitude;
  final double? longitude;

  factory OrderDriverModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    final name = user['name'] as String? ?? json['name'] as String? ?? 'Driver';
    String? avatar = user['avatar'] as String? ?? json['avatar'] as String?;
    if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('http')) {
      avatar = avatar;
    }
    final lat = _parseCoord(json['latitude']) ?? _parseCoord(json['lat']) ?? _parseCoord(user['latitude']);
    final lng = _parseCoord(json['longitude']) ?? _parseCoord(json['lng']) ?? _parseCoord(user['longitude']);
    return OrderDriverModel(
      name: name,
      avatarUrl: avatar ?? user['avatar_url'] as String? ?? json['avatar_url'] as String?,
      phone: user['phone'] as String? ?? json['phone'] as String?,
      rating: (user['rating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble(),
      vehicleType: json['vehicle_type'] as String? ?? json['vehicleType'] as String?,
      vehiclePlate: json['vehicle_plate'] as String? ?? json['vehiclePlate'] as String?,
      latitude: lat,
      longitude: lng,
    );
  }

  @override
  List<Object?> get props => [name, phone, latitude, longitude];
}
