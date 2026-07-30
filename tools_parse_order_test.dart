import "dart:convert";
import "package:overfood/features/orders/models/order_model.dart";

void main() {
  final sample = {
    "id": 169,
    "order_number": "AFD-260721-YJKN",
    "status": "delivered",
    "status_display": "Delivered",
    "total": "160.00",
    "created_at": "2026-07-21T12:08:50+04:30",
    "items_count": 1,
    "restaurant": {"id": 14, "name": "UNIQUE", "logo": "https://example.com/a.png"},
  };
  final o = OrderModel.fromJson(sample);
  print("id=${o.id} status=${o.status} total=${o.total} placed=${o.placedAt}");
}
