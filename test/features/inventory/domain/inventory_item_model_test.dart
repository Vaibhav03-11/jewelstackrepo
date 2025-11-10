import 'package:flutter_test/flutter_test.dart';
import 'package:jewelstack/features/inventory/domain/inventory_item_model.dart';

void main() {
  group('InventoryItem Model Tests', () {
    test('should create inventory item with correct properties', () {
      final item = InventoryItem(
        id: '1',
        name: 'Test Necklace',
        category: 'Necklace',
        purity: '22K Gold',
        weight: 8.5,
        stock: 3,
        price: 74200,
        description: 'Test description',
        imageUrl: 'https://example.com/image.jpg',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(item.id, '1');
      expect(item.name, 'Test Necklace');
      expect(item.isOutOfStock, false);
      expect(item.stockStatus, 'In Stock');
    });

    test('should detect out of stock items', () {
      final item = InventoryItem(
        id: '1',
        name: 'Test Item',
        category: 'Rings',
        purity: '18K Gold',
        weight: 3.1,
        stock: 0,
        price: 71100,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(item.isOutOfStock, true);
      expect(item.stockStatus, 'Out of Stock');
    });

    test('should convert to and from map correctly', () {
      final originalItem = InventoryItem(
        id: '1',
        name: 'Test Item',
        category: 'Necklace',
        purity: '22K Gold',
        weight: 8.5,
        stock: 3,
        price: 74200,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = originalItem.toMap();
      final convertedItem = InventoryItem.fromMap(map);

      expect(convertedItem.id, originalItem.id);
      expect(convertedItem.name, originalItem.name);
      expect(convertedItem.weight, originalItem.weight);
    });
  });
}