class Product {
  final String id;
  final String storeId;
  final String sellerId;
  String name;
  String? description;
  double price;
  List<String> imageUrls;
  List<String> tags;
  bool inStock;
  int? quantity;
  bool isFeatured;
  int viewCount;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrls = const [],
    this.tags = const [],
    this.inStock = true,
    this.quantity,
    this.isFeatured = false,
    this.viewCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Product object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'tags': tags,
      'inStock': inStock,
      'quantity': quantity,
      'isFeatured': isFeatured,
      'viewCount': viewCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a Product object from a map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      storeId: map['storeId'],
      sellerId: map['sellerId'],
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      inStock: map['inStock'] ?? true,
      quantity: map['quantity'],
      isFeatured: map['isFeatured'] ?? false,
      viewCount: map['viewCount'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Product with updated fields
  Product copyWith({
    String? id,
    String? storeId,
    String? sellerId,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    List<String>? tags,
    bool? inStock,
    int? quantity,
    bool? isFeatured,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      inStock: inStock ?? this.inStock,
      quantity: quantity ?? this.quantity,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Get the main product image or a placeholder
  String get mainImage => imageUrls.isNotEmpty 
      ? imageUrls.first 
      : 'assets/images/placeholder.png';

  // Format the price with currency symbol
  String formattedPrice(String currencySymbol) {
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, inStock: $inStock)';
  }
}