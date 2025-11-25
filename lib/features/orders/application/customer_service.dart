import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _customersCollection => _firestore.collection('customers');

  // Get all customers
  Stream<List<Customer>> getCustomers() {
    return _customersCollection
        .orderBy('lastPurchase', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Search customers
  Stream<List<Customer>> searchCustomers(String query) {
    return _customersCollection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Customer.fromMap(doc.data() as Map<String, dynamic>))
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.contactNumber.contains(query))
            .toList());
  }

  // Add new customer
  Future<void> addCustomer(Customer customer) async {
    try {
      await _customersCollection.doc(customer.id).set(customer.toMap());
    } catch (e) {
      throw 'Failed to add customer: $e';
    }
  }

  // Update customer
  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customersCollection.doc(customer.id).update(customer.toMap());
    } catch (e) {
      throw 'Failed to update customer: $e';
    }
  }

  // Update customer after order
  Future<void> updateCustomerAfterOrder(String customerId, double orderAmount) async {
    try {
      final doc = await _customersCollection.doc(customerId).get();
      if (doc.exists) {
        final customer = Customer.fromMap(doc.data() as Map<String, dynamic>);
        final updatedCustomer = customer.copyWith(
          lastPurchase: DateTime.now(),
          totalOrders: customer.totalOrders + 1,
          totalSpent: customer.totalSpent + orderAmount,
        );
        await _customersCollection.doc(customerId).update(updatedCustomer.toMap());
      }
    } catch (e) {
      throw 'Failed to update customer after order: $e';
    }
  }
}