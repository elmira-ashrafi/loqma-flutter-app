import 'package:flutter_test/flutter_test.dart';
import 'package:overfood/features/restaurants/models/restaurant_detail_model.dart';

void main() {
  group('MenuItemModel', () {
    test('parses variant_groups and addon_groups from API shape', () {
      final item = MenuItemModel.fromJson({
        'id': 1,
        'name': 'Pizza',
        'price': 300,
        'variant_groups': [
          {
            'id': 10,
            'name': 'Size',
            'variants': [
              {'id': 1, 'name': 'Small', 'price_adjustment': 0, 'is_default': true},
              {'id': 2, 'name': 'Medium', 'price_adjustment': 80},
              {'id': 3, 'name': 'Large', 'price_adjustment': 150},
            ],
          },
        ],
        'addon_groups': [
          {
            'id': 20,
            'name': 'Extras',
            'addons': [
              {'id': 5, 'name': 'Extra cheese', 'price': 50},
            ],
          },
        ],
      });

      expect(item.variantGroupName, 'Size');
      expect(item.variants, hasLength(3));
      expect(item.hasSelectableSizes, isTrue);
      expect(item.variants.first.name, 'Small');
      expect(item.variants.first.price, 0);
      expect(item.variants.first.isDefault, isTrue);
      expect(item.variants[1].price, 80);
      expect(item.addons, hasLength(1));
      expect(item.addons.first.price, 50);
    });

    test('hides size UI when food has no size options', () {
      final item = MenuItemModel.fromJson({
        'id': 2,
        'name': 'Drink',
        'price': 50,
        'variant_groups': [],
      });
      expect(item.variants, isEmpty);
      expect(item.hasSelectableSizes, isFalse);
    });

    test('hides size UI when only one size variant exists', () {
      final item = MenuItemModel.fromJson({
        'id': 3,
        'name': 'Soup',
        'price': 120,
        'variant_groups': [
          {
            'id': 11,
            'name': 'Size',
            'variants': [
              {'id': 9, 'name': 'Small', 'price_adjustment': 0, 'is_default': true},
            ],
          },
        ],
      });
      expect(item.variants, hasLength(1));
      expect(item.hasSelectableSizes, isFalse);
    });
  });
}
