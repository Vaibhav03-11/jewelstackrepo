class Order {
  final String id;
  final String customerId;
  final String customerName;
  final String customerContact;
  final List<OrderItem> items;
  final String materialType;
  final double goldRate;
  final double totalWeight;
  final double totalAmount;
  final double advancePayment;
  final double balanceDue;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime estimatedDelivery;
  final DateTime? actualDelivery;
  final String? description;
  final List<OrderProgress> progressUpdates; // NEW: Progress tracking

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerContact,
    required this.items,
    required this.materialType,
    required this.goldRate,
    required this.totalWeight,
    required this.totalAmount,
    required this.advancePayment,
    required this.balanceDue,
    required this.status,
    required this.orderDate,
    required this.estimatedDelivery,
    this.actualDelivery,
    this.description,
    required this.progressUpdates, // NEW
  });

  // Get current progress percentage
  double get progressPercentage {
    switch (status) {
      case OrderStatus.pending:
        return 0.2;
      case OrderStatus.confirmed:
        return 0.4;
      case OrderStatus.inProgress:
        return 0.6;
      case OrderStatus.ready:
        return 0.8;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Get latest progress update
  OrderProgress? get latestProgress {
    if (progressUpdates.isEmpty) return null;
    progressUpdates.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return progressUpdates.first;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerContact': customerContact,
      'items': items.map((item) => item.toMap()).toList(),
      'materialType': materialType,
      'goldRate': goldRate,
      'totalWeight': totalWeight,
      'totalAmount': totalAmount,
      'advancePayment': advancePayment,
      'balanceDue': balanceDue,
      'status': status.toString().split('.').last,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDelivery': estimatedDelivery.millisecondsSinceEpoch,
      'actualDelivery': actualDelivery?.millisecondsSinceEpoch,
      'description': description,
      'progressUpdates': progressUpdates.map((update) => update.toMap()).toList(), // NEW
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerContact: map['customerContact'] ?? '',
      items: List<OrderItem>.from(
          (map['items'] ?? []).map((x) => OrderItem.fromMap(x))),
      materialType: map['materialType'] ?? '',
      goldRate: (map['goldRate'] ?? 0.0).toDouble(),
      totalWeight: (map['totalWeight'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      advancePayment: (map['advancePayment'] ?? 0.0).toDouble(),
      balanceDue: (map['balanceDue'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate']),
      estimatedDelivery: DateTime.fromMillisecondsSinceEpoch(map['estimatedDelivery']),
      actualDelivery: map['actualDelivery'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['actualDelivery'])
          : null,
      description: map['description'],
      progressUpdates: List<OrderProgress>.from( // NEW
          (map['progressUpdates'] ?? []).map((x) => OrderProgress.fromMap(x))),
    );
  }

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerContact,
    List<OrderItem>? items,
    String? materialType,
    double? goldRate,
    double? totalWeight,
    double? totalAmount,
    double? advancePayment,
    double? balanceDue,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    String? description,
    List<OrderProgress>? progressUpdates,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerContact: customerContact ?? this.customerContact,
      items: items ?? this.items,
      materialType: materialType ?? this.materialType,
      goldRate: goldRate ?? this.goldRate,
      totalWeight: totalWeight ?? this.totalWeight,
      totalAmount: totalAmount ?? this.totalAmount,
      advancePayment: advancePayment ?? this.advancePayment,
      balanceDue: balanceDue ?? this.balanceDue,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      description: description ?? this.description,
      progressUpdates: progressUpdates ?? this.progressUpdates,
    );
  }
}

// NEW: Order Progress Tracking Model
class OrderProgress {
  final String id;
  final OrderStatus status;
  final String description;
  final DateTime timestamp;
  final String? updatedBy;

  OrderProgress({
    required this.id,
    required this.status,
    required this.description,
    required this.timestamp,
    this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.toString().split('.').last,
      'description': description,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'updatedBy': updatedBy,
    };
  }

  factory OrderProgress.fromMap(Map<String, dynamic> map) {
    return OrderProgress(
      id: map['id'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      description: map['description'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      updatedBy: map['updatedBy'],
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  inProgress,
  ready,
  delivered,
  cancelled,
}

// Added OrderItem model so Order.items has a valid type.
class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double weight;
  final double unitPrice;
  final double totalPrice;
  final String? description;

  var type;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.weight,
    required this.unitPrice,
    required this.totalPrice,
    this.description, required String type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'weight': weight,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'description': description,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0) is int ? map['quantity'] : int.tryParse(map['quantity'].toString()) ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      description: map['description'], type: '',
    );
  }

  OrderItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? weight,
    double? unitPrice,
    double? totalPrice,
    String? description,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      description: description ?? this.description, type: '',
    );
  }
}