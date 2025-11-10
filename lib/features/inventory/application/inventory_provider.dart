import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'inventory_service.dart';
import '../domain/inventory_item_model.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();

  List<InventoryItem> _allItems = [];
  List<InventoryItem> _filteredItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<InventoryItem> get allItems => _allItems;
  List<InventoryItem> get filteredItems => _filteredItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // Load all inventory items
  Stream<List<InventoryItem>> getInventoryItems() {
    return _inventoryService.getInventoryItems();
  }

  // Initialize provider
  void initialize() {
    getInventoryItems().listen((items) {
      _allItems = items;
      _applyFilters();
      notifyListeners();
    });
  }

  // Add new inventory item
  Future<void> addItem(InventoryItem item, XFile? imageFile) async {
    _setLoading(true);
    try {
      await _inventoryService.addInventoryItem(item, imageFile);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update inventory item
  Future<void> updateItem(InventoryItem item, XFile? imageFile) async {
    _setLoading(true);
    try {
      await _inventoryService.updateInventoryItem(item, imageFile);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Delete inventory item
  Future<void> deleteItem(String itemId) async {
    _setLoading(true);
    try {
      await _inventoryService.deleteInventoryItem(itemId);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update stock quantity
  Future<void> updateStock(String itemId, int newStock) async {
    _setLoading(true);
    try {
      await _inventoryService.updateStock(itemId, newStock);
    } catch (e) {
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Search items
  void searchItems(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters
  void _applyFilters() {
    List<InventoryItem> result = _allItems;

    // Apply category filter
    if (_selectedCategory != 'All') {
      result = result.where((item) => item.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.purity.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    _filteredItems = result;
  }

  // Get dashboard statistics
  Map<String, int> getDashboardStats() {
    final totalItems = _allItems.length;
    final lowStockItems = _allItems.where((item) => item.stock < 5 && item.stock > 0).length;
    final outOfStockItems = _allItems.where((item) => item.stock == 0).length;
    final totalValue = _allItems.fold(0.0, (sum, item) => sum + (item.price * item.stock)).toInt();

    return {
      'totalItems': totalItems,
      'lowStock': lowStockItems,
      'outOfStock': outOfStockItems,
      'totalValue': totalValue,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}