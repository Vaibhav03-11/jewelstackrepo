import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import '../domain/inventory_item_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _storage = firebase_storage.FirebaseStorage.instance;

  // Collection reference
  CollectionReference get _inventoryCollection =>
      _firestore.collection('inventory');

  // Get all inventory items
  Stream<List<InventoryItem>> getInventoryItems() {
    return _inventoryCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get items by category
  Stream<List<InventoryItem>> getItemsByCategory(String category) {
    return _inventoryCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get low stock items (less than 5)
  Stream<List<InventoryItem>> getLowStockItems() {
    return _inventoryCollection
        .where('stock', isLessThan: 5)
        .orderBy('stock')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get out of stock items
  Stream<List<InventoryItem>> getOutOfStockItems() {
    return _inventoryCollection
        .where('stock', isEqualTo: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Add new inventory item
  
Future<void> addInventoryItem(InventoryItem item, XFile? imageFile) async {
  try {
    // Validate required fields
    if (item.name.isEmpty) throw 'Item name is required';
    if (item.weight <= 0) throw 'Weight must be greater than 0';
    if (item.stock < 0) throw 'Stock cannot be negative';
    if (item.price <= 0) throw 'Price must be greater than 0';

    String? imageUrl;
    
    // Upload image if provided
    if (imageFile != null) {
      // Validate image size (max 5MB)
      final file = File(imageFile.path);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw 'Image size must be less than 5MB';
      }
      
      imageUrl = await _uploadImage(imageFile, item.id);
    }

    // Create item with image URL
    final itemWithImage = item.copyWith(imageUrl: imageUrl);

    await _inventoryCollection.doc(item.id).set(itemWithImage.toMap());
    
  } on FirebaseException catch (e) {
    throw 'Firebase error: ${e.message}';
  } catch (e) {
    throw 'Failed to add item: $e';
  }
}


  // Update inventory item
  Future<void> updateInventoryItem(InventoryItem item, XFile? imageFile) async {
    try {
      String? imageUrl = item.imageUrl;
      
      // Upload new image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, item.id);
      }

      // Update item
      final updatedItem = item.copyWith(
        imageUrl: imageUrl,
        updatedAt: DateTime.now(),
      );

      await _inventoryCollection.doc(item.id).update(updatedItem.toMap());
    } catch (e) {
      throw 'Failed to update item: $e';
    }
  }

  // Delete inventory item
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      // Delete image from storage if exists
      try {
        await _storage.ref('inventory/$itemId').delete();
      } catch (e) {
        // Image might not exist, continue with deletion
      }

      await _inventoryCollection.doc(itemId).delete();
    } catch (e) {
      throw 'Failed to delete item: $e';
    }
  }

  // Update stock quantity
  Future<void> updateStock(String itemId, int newStock) async {
  try {
    if (newStock < 0) throw 'Stock cannot be negative';
    
    await _inventoryCollection.doc(itemId).update({
      'stock': newStock,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  } on FirebaseException catch (e) {
    throw 'Firebase error: ${e.message}';
  } catch (e) {
    throw 'Failed to update stock: $e';
  }
}

  // Upload image to Firebase Storage
  Future<String> _uploadImage(XFile imageFile, String itemId) async {
    try {
    final firebase_storage.Reference storageRef = 
        firebase_storage.FirebaseStorage.instance.ref().child('inventory/$itemId');
    
    final File file = File(imageFile.path);
    final firebase_storage.UploadTask uploadTask = storageRef.putFile(file);
    
    final firebase_storage.TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  } catch (e) {
    print('Image upload error: $e');
    throw 'Failed to upload image. Please try again.';
  }
  }

  // Search inventory items
  Stream<List<InventoryItem>> searchItems(String query) {
    return _inventoryCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => InventoryItem.fromMap(doc.data() as Map<String, dynamic>))
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()) ||
                item.category.toLowerCase().contains(query.toLowerCase()) ||
                item.purity.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }
}