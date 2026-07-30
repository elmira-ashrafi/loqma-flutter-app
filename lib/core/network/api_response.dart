/// Standard API response wrapper for Laravel-style JSON.
/// Expects: { "data": ..., "message": "..." } or paginated { "data": [...], "meta": {...} }
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  final bool success;
  final T? data;
  final String? message;
  final Map<String, List<String>>? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final data = json['data'];
    T? parsedData;
    if (data != null && fromJsonT != null) {
      parsedData = fromJsonT(data);
    } else if (data != null) {
      parsedData = data as T?;
    }
    Map<String, List<String>>? errors;
    if (json['errors'] != null) {
      final e = json['errors'] as Map<String, dynamic>?;
      errors = e?.map((k, v) => MapEntry(k, (v is List) ? v.map((x) => x.toString()).toList() : [v.toString()]));
    }
    return ApiResponse(
      success: json['success'] as bool? ?? true,
      data: parsedData,
      message: json['message'] as String?,
      errors: errors,
    );
  }

  String get errorMessage {
    if (message != null && message!.isNotEmpty) return message!;
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first.isNotEmpty) return first.first;
    }
    return 'Something went wrong';
  }
}

/// Paginated response: { data: [], meta: { current_page, last_page, total, per_page } }
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  final List<T> data;
  final PaginationMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    List<dynamic> list = json['data'] as List<dynamic>? ?? [];
    Map<String, dynamic> metaJson = _tryMap(json['meta']) ?? {};
    final dataVal = json['data'];
    if (list.isEmpty && dataVal is Map) {
      final inner = Map<String, dynamic>.from(dataVal);
      list = inner['items'] as List<dynamic>? ??
          inner['orders'] as List<dynamic>? ??
          inner['restaurants'] as List<dynamic>? ??
          inner['data'] as List<dynamic>? ??
          [];
      metaJson = _tryMap(inner['pagination']) ?? _tryMap(inner['meta']) ?? metaJson;
    }
    // Top-level items + pagination (e.g. { items: [], orders: [], pagination: {} })
    if (list.isEmpty) {
      list = json['items'] as List<dynamic>? ??
          json['orders'] as List<dynamic>? ??
          json['restaurants'] as List<dynamic>? ??
          [];
      if (metaJson.isEmpty && json['pagination'] != null) {
        metaJson = _tryMap(json['pagination']) ?? {};
      }
    }
    final parsed = <T>[];
    for (final e in list) {
      try {
        if (e is Map) {
          parsed.add(fromJsonT(Map<String, dynamic>.from(e)));
        }
      } catch (_) {}
    }
    return PaginatedResponse(
      data: parsed,
      meta: PaginationMeta.fromJson(metaJson),
    );
  }

  static Map<String, dynamic>? _tryMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }
}

class PaginationMeta {
  const PaginationMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 15,
    this.fetchedCount = 0,
    this.requestedPerPage = 15,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final int fetchedCount;
  final int requestedPerPage;

  bool get hasNextPage {
    if (lastPage > currentPage) return true;
    if (total > 0 && perPage > 0) {
      return currentPage * perPage < total;
    }
    // Fallback when API omits pagination totals: full page likely means more exist.
    if (fetchedCount > 0 && fetchedCount >= requestedPerPage) return true;
    return false;
  }

  int get nextPage => currentPage + 1;

  PaginationMeta copyWith({
    int? currentPage,
    int? lastPage,
    int? total,
    int? perPage,
    int? fetchedCount,
    int? requestedPerPage,
  }) {
    return PaginationMeta(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      perPage: perPage ?? this.perPage,
      fetchedCount: fetchedCount ?? this.fetchedCount,
      requestedPerPage: requestedPerPage ?? this.requestedPerPage,
    );
  }

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toInt() ?? 0,
      perPage: (json['per_page'] as num?)?.toInt() ?? 15,
    );
  }
}
