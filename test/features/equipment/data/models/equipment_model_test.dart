import 'package:flutter_test/flutter_test.dart';
import 'package:pe/features/equipment/data/models/equipment_model.dart';

void main() {
  group('EquipmentModel.fromJson', () {
    test('maps a full device with nested data', () {
      final model = EquipmentModel.fromJson({
        'id': '7',
        'name': 'MacBook Pro 16"',
        'data': {'year': 2023, 'price': 250.0, 'color': 'Silver'},
      });

      expect(model.id, '7');
      expect(model.name, 'MacBook Pro 16"');
      expect(model.year, 2023);
      expect(model.price, 250.0);
      expect(model.category, 'Laptop');
      expect(model.deposit, 50);
      expect(model.rawData?['color'], 'Silver');
    });

    test('tolerates a completely missing (null) data object', () {
      final model = EquipmentModel.fromJson({'id': '1', 'name': 'Mystery Device'});

      expect(model.year, isNull);
      expect(model.price, isNull);
      expect(model.rawData, isNull);
      expect(model.deposit, 20, reason: r'missing price should fall back to the $20 deposit rule');
    });

    test('tolerates a data object missing price/year fields', () {
      final model = EquipmentModel.fromJson({
        'id': '2',
        'name': 'iPhone 13',
        'data': {'color': 'Blue'},
      });

      expect(model.hasPrice, isFalse);
      expect(model.hasYear, isFalse);
      expect(model.category, 'Phone');
    });

    test('parses numeric fields provided as strings', () {
      final model = EquipmentModel.fromJson({
        'id': '3',
        'name': 'Generic Tablet',
        'data': {'year': '2021', 'price': '150'},
      });

      expect(model.year, 2021);
      expect(model.price, 150.0);
    });
  });
}
