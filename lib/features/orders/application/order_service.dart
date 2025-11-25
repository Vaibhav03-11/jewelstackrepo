import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../domain/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _ordersCollection => _firestore.collection('orders');

  // Get all orders
  Stream<List<Order>> getOrders() {
    return _ordersCollection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get orders by customer
  Stream<List<Order>> getOrdersByCustomer(String customerId) {
    return _ordersCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get orders due soon (within 3 days)
  Stream<List<Order>> getOrdersDueSoon() {
    final threeDaysFromNow = DateTime.now().add(Duration(days: 3));
    return _ordersCollection
        .where('estimatedDelivery', isLessThanOrEqualTo: threeDaysFromNow.millisecondsSinceEpoch)
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get in-process orders
  Stream<List<Order>> getInProcessOrders() {
    return _ordersCollection
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Create new order
  Future<void> createOrder(Order order) async {
    try {
      await _ordersCollection.doc(order.id).set(order.toMap());
    } catch (e) {
      throw 'Failed to create order: $e';
    }
  }

  // Update order status
  Future<void> updateOrderStatusWithProgress({
    required String orderId,
    required OrderStatus newStatus,
    required String progressDescription,
    String? updatedBy,
  }) async {
    try {
      final progress = OrderProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: newStatus,
        description: progressDescription,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      );

      await _ordersCollection.doc(orderId).update({
        'status': newStatus.toString().split('.').last,
        'progressUpdates': FieldValue.arrayUnion([progress.toMap()]),
        if (newStatus == OrderStatus.delivered) 
          'actualDelivery': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // Add daily progress update
  Future<void> addDailyProgressUpdate({
    required String orderId,
    required String description,
    String? updatedBy,
  }) async {
    try {
      // Get current order to maintain status
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        final order = Order.fromMap(doc.data() as Map<String, dynamic>);
        
        final progress = OrderProgress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          status: order.status, // Keep current status
          description: description,
          timestamp: DateTime.now(),
          updatedBy: updatedBy,
        );

        await _ordersCollection.doc(orderId).update({
          'progressUpdates': FieldValue.arrayUnion([progress.toMap()]),
        });
      }
    } catch (e) {
      throw 'Failed to add daily progress: $e';
    }
  }

  // Get orders that need progress updates (in-process orders)
  Stream<List<Order>> getOrdersNeedingProgressUpdates() {
    return _ordersCollection
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress', 'ready'])
        .orderBy('estimatedDelivery')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get order progress timeline
  Stream<List<OrderProgress>> getOrderProgressTimeline(String orderId) {
    return _ordersCollection.doc(orderId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final order = Order.fromMap(snapshot.data() as Map<String, dynamic>);
        // Sort by timestamp descending (newest first)
        order.progressUpdates.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return order.progressUpdates;
      }
      return [];
    });
  }


  // Update payment
  Future<void> updatePayment(String orderId, double advancePayment, double balanceDue) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'advancePayment': advancePayment,
        'balanceDue': balanceDue,
      });
    } catch (e) {
      throw 'Failed to update payment: $e';
    }
  }
}