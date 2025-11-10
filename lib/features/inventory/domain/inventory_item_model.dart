class InventoryItem {
  final String id;
  final String name;
  final String category; // necklace, rings, bracelet
  final String purity; // 22K Gold, 18K Gold, 24K Gold, Platinum
  final double weight; // in grams
  final int stock;
  final double price;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.purity,
    required this.weight,
    required this.stock,
    required this.price,
    this.description,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if item is out of stock
  bool get isOutOfStock => stock <= 0;

  // Get stock status text
  String get stockStatus {
    if (stock <= 0) return 'Out of Stock';
    if (stock < 5) return 'Low Stock';
    return 'In Stock';
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'purity': purity,
      'weight': weight,
      'stock': stock,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore document
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      purity: map['purity'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Copy with method for updates
  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? purity,
    double? weight,
    int? stock,
    double? price,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      stock: stock ?? this.stock,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Categories based on your design
class InventoryCategories {
  static const List<String> categories = [
    'Necklace',
    'Rings',
    'Bracelet',
    'Earrings',
    'Custom'
  ];

  static const List<String> purityOptions = [
    '22K Gold',
    '18K Gold', 
    '24K Gold',
    'Platinum',
    'Silver'
  ];
}

