import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<CollectionReference<Map<String, dynamic>>> _ordersCollection() async {
    final String shopId = await _getCurrentShopId();
    return _firestore.collection('shops').doc(shopId).collection('orders');
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

  // Get all orders
  Stream<List<Order>> getOrders() async* {
    final collection = await _ordersCollection();
    yield* collection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data()))
            .toList());
  }

  // Get orders by customer
  Stream<List<Order>> getOrdersByCustomer(String customerId) async* {
    final collection = await _ordersCollection();
    yield* collection
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data()))
            .toList());
  }

  // Get orders due soon (within 3 days)
  Stream<List<Order>> getOrdersDueSoon() async* {
    final collection = await _ordersCollection();
    final threeDaysFromNow = DateTime.now().add(Duration(days: 3));
    yield* collection
        .where('estimatedDelivery', isLessThanOrEqualTo: threeDaysFromNow.millisecondsSinceEpoch)
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data()))
            .toList());
  }

  // Get in-process orders
  Stream<List<Order>> getInProcessOrders() async* {
    final collection = await _ordersCollection();
    yield* collection
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data()))
            .toList());
  }

  // Create new order
  Future<void> createOrder(Order order) async {
    try {
      final collection = await _ordersCollection();
      await collection.doc(order.id).set(order.toMap());
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
      final collection = await _ordersCollection();
      final progress = OrderProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: newStatus,
        description: progressDescription,
        timestamp: DateTime.now(),
        updatedBy: updatedBy,
      );

      await collection.doc(orderId).update({
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
      final collection = await _ordersCollection();
      // Get current order to maintain status
      final doc = await collection.doc(orderId).get();
      if (doc.exists) {
        final order = Order.fromMap(doc.data() as Map<String, dynamic>);
        
        final progress = OrderProgress(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          status: order.status, // Keep current status
          description: description,
          timestamp: DateTime.now(),
          updatedBy: updatedBy,
        );

        await collection.doc(orderId).update({
          'progressUpdates': FieldValue.arrayUnion([progress.toMap()]),
        });
      }
    } catch (e) {
      throw 'Failed to add daily progress: $e';
    }
  }

  // Update progress percentage (can only be increased, not decreased)
  Future<void> updateProgressPercentage({
    required String orderId,
    required double newProgressPercentage,
  }) async {
    try {
      final collection = await _ordersCollection();
      final doc = await collection.doc(orderId).get();
      
      if (doc.exists) {
        final order = Order.fromMap(doc.data() as Map<String, dynamic>);
        
        // Ensure progress can only go up, not down
        final currentMax = order.maxProgressPercentage ?? 0.0;
        if (newProgressPercentage < currentMax) {
          throw 'Progress cannot be decreased. Current: ${(currentMax * 100).toInt()}%, Attempted: ${(newProgressPercentage * 100).toInt()}%';
        }
        
        // Cap at 1.0
        final cappedProgress = newProgressPercentage > 1.0 ? 1.0 : newProgressPercentage;
        
        await collection.doc(orderId).update({
          'maxProgressPercentage': cappedProgress,
        });
      }
    } catch (e) {
      throw 'Failed to update progress percentage: $e';
    }
  }

  // Get orders that need progress updates (in-process orders)
  Stream<List<Order>> getOrdersNeedingProgressUpdates() async* {
    final collection = await _ordersCollection();
    yield* collection
        .where('status', whereIn: ['pending', 'confirmed', 'inProgress', 'ready'])
        .orderBy('estimatedDelivery')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromMap(doc.data()))
            .toList());
  }

  // Get order progress timeline
  Stream<List<OrderProgress>> getOrderProgressTimeline(String orderId) async* {
    final collection = await _ordersCollection();
    yield* collection.doc(orderId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return <OrderProgress>[];
      }

      final order = Order.fromMap(snapshot.data()!);
      order.progressUpdates.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return order.progressUpdates;
    });
  }


  // Update payment
  Future<void> updatePayment(String orderId, double advancePayment, double balanceDue) async {
    try {
      final collection = await _ordersCollection();
      await collection.doc(orderId).update({
        'advancePayment': advancePayment,
        'balanceDue': balanceDue,
      });
    } catch (e) {
      throw 'Failed to update payment: $e';
    }
  }

  // Update only estimated delivery date
  Future<void> updateEstimatedDeliveryDate(String orderId, DateTime estimatedDelivery) async {
    try {
      final collection = await _ordersCollection();
      await collection.doc(orderId).update({
        'estimatedDelivery': estimatedDelivery.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw 'Failed to update delivery date: $e';
    }
  }

  // Update only pending amount (balance due)
  Future<void> updatePendingAmount(String orderId, double balanceDue) async {
    try {
      final collection = await _ordersCollection();
      await collection.doc(orderId).update({
        'balanceDue': balanceDue,
      });
    } catch (e) {
      throw 'Failed to update pending amount: $e';
    }
  }
}