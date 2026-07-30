import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class TicketService {
  TicketService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<Map<String, dynamic>> getTickets({String? status}) async {
    final response = await _dio.get(
      ApiConstants.customerTickets,
      queryParameters: status != null && status.isNotEmpty ? {'status': status} : null,
    );
    final data = response.data as Map<String, dynamic>? ?? {};

    // Backend may respond in multiple shapes:
    // - { data: [ ...tickets ], stats: {...} }
    // - { data: { tickets: [ ... ], stats: {...} } }
    // - { tickets: [ ... ], stats: {...} }
    // - [ ...tickets ]
    final dynamic root = data['data'] ?? data;
    List<dynamic> list;
    Map<String, dynamic> stats;

    if (root is List) {
      list = root;
      stats = data['stats'] as Map<String, dynamic>? ?? {};
    } else if (root is Map<String, dynamic>) {
      if (root['tickets'] is List) {
        list = root['tickets'] as List<dynamic>;
      } else if (root['data'] is List) {
        list = root['data'] as List<dynamic>;
      } else if (root['tickets'] is Map<String, dynamic> &&
          (root['tickets'] as Map<String, dynamic>)['data'] is List) {
        // e.g. { data: { tickets: { data: [ ... ] , ... }, stats: {...} } }
        list = ((root['tickets'] as Map<String, dynamic>)['data'] as List).cast<dynamic>();
      } else {
        // Last resort: first list value inside root.
        final firstListValue = root.values.firstWhere(
          (v) => v is List,
          orElse: () => const [],
        );
        list = firstListValue is List ? firstListValue.cast<dynamic>() : const [];
      }
      stats = root['stats'] as Map<String, dynamic>? ?? (data['stats'] as Map<String, dynamic>? ?? {});
    } else {
      list = const [];
      stats = const {};
    }

    final items = list
        .whereType<Map<String, dynamic>>()
        .map((e) => TicketModel.fromJson(e))
        .toList();
    return {
      'items': items,
      'open': (stats['open'] as num?)?.toInt() ?? 0,
      'resolved': (stats['resolved'] as num?)?.toInt() ?? 0,
    };
  }

  Future<TicketModel> getTicketById(int id) async {
    final response = await _dio.get(ApiConstants.customerTicketById(id));
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return TicketModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<TicketModel> createTicket({
    required String subject,
    required String category,
    required String priority,
    required String message,
    int? orderId,
  }) async {
    final response = await _dio.post(
      ApiConstants.customerTickets,
      data: {
        'subject': subject,
        'category': category,
        'priority': priority,
        'message': message,
        if (orderId != null) 'order_id': orderId,
      },
    );
    final data = response.data as Map<String, dynamic>? ?? {};
    final raw = data['data'] ?? data;
    return TicketModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> reply(int ticketId, String message) async {
    await _dio.post(
      ApiConstants.customerTicketReply(ticketId),
      data: {'message': message},
    );
  }

  Future<void> close(int ticketId) async {
    await _dio.post(ApiConstants.customerTicketClose(ticketId));
  }

  Future<void> reopen(int ticketId) async {
    await _dio.post(ApiConstants.customerTicketReopen(ticketId));
  }
}
