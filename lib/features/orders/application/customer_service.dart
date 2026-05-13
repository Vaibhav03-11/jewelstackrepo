import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CollectionReference<Map<String, dynamic>>> _customersCollection() async {
    final String shopId = await _getCurrentShopId();
    return _firestore.collection('shops').doc(shopId).collection('customers');
  }

  Future<String> _getCurrentShopId() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw 'User not authenticated';
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final shopId = (userDoc.data()?['shopId'] as String?)?.trim();
    if (shopId == null || shopId.isEmpty) {
      throw 'No shopId found for current user';
    }
    return shopId;
  }

  // Get all customers
  Stream<List<Customer>> getCustomers() async* {
    final collection = await _customersCollection();
    yield* collection
        .orderBy('lastPurchase', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromMap(doc.data()))
            .toList());
  }

  // Search customers
  Stream<List<Customer>> searchCustomers(String query) async* {
    final collection = await _customersCollection();
    yield* collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromMap(doc.data()))
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.contactNumber.contains(query))
            .toList());
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    try {
      final collection = await _customersCollection();
      await collection.doc(customer.id).set(customer.toMap());
    } catch (e) {
      throw 'Failed to add customer: $e';
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      final collection = await _customersCollection();
      await collection.doc(customer.id).update(customer.toMap());
    } catch (e) {
      throw 'Failed to update customer: $e';
    }
  }

  // Delete customer
  Future<void> deleteCustomer(String customerId) async {
    try {
      final collection = await _customersCollection();
      await collection.doc(customerId).delete();
    } catch (e) {
      throw 'Failed to delete customer: $e';
    }
  }

  // Update customer after order
  Future<void> updateCustomerAfterOrder(String customerId, double orderAmount) async {
    try {
      final collection = await _customersCollection();
      final doc = await collection.doc(customerId).get();
      if (doc.exists) {
        final customer = Customer.fromMap(doc.data() as Map<String, dynamic>);
        final updatedCustomer = customer.copyWith(
          lastPurchase: DateTime.now(),
          totalOrders: customer.totalOrders + 1,
          totalSpent: customer.totalSpent + orderAmount,
        );
        await collection.doc(customerId).update(updatedCustomer.toMap());
      }
    } catch (e) {
      throw 'Failed to update customer after order: $e';
    }
  }
}