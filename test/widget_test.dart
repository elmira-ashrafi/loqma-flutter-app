import 'package:flutter_test/flutter_test.dart';
import 'package:overfood/features/restaurants/models/restaurant_detail_model.dart';

void main() {
  test('MenuItemModel parses minimal JSON', () {
    final item = MenuItemModel.fromJson({
      'id': 1,
      'name': 'Burger',
      'price': 250,
    });

    expect(item.name, 'Burger');
    expect(item.price, 250);
  });
}
