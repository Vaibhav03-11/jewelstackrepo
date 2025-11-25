class Customer {
  final String id;
  final String name;
  final String contactNumber;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime lastPurchase;
  final int totalOrders;
  final double totalSpent;

  Customer({
    required this.id,
    required this.name,
    required this.contactNumber,
    this.email,
    this.address,
    required this.createdAt,
    required this.lastPurchase,
    required this.totalOrders,
    required this.totalSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastPurchase': lastPurchase.millisecondsSinceEpoch,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'],
      address: map['address'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastPurchase: DateTime.fromMillisecondsSinceEpoch(map['lastPurchase']),
      totalOrders: (map['totalOrders'] ?? 0).toInt(),
      totalSpent: (map['totalSpent'] ?? 0.0).toDouble(),
    );
  }

  Customer copyWith({
    String? name,
    String? contactNumber,
    String? email,
    String? address,
    DateTime? lastPurchase,
    int? totalOrders,
    double? totalSpent,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt,
      lastPurchase: lastPurchase ?? this.lastPurchase,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}