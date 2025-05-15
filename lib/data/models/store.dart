import 'package:unified_storefronts/data/models/seller.dart';

class Store {
  final String id;
  final String sellerId;
  String name;
  String? description;
  String category;
  String? logoUrl;
  String? bannerUrl;
  String? whatsappNumber;
  String? instagramHandle;
  String? phoneNumber;
  String? upiId;
  String? qrCodeUrl;
  String? address;
  double? latitude;
  double? longitude;
  List<String> tags;
  String slug;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;

  Store({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.category,
    this.logoUrl,
    this.bannerUrl,
    this.whatsappNumber,
    this.instagramHandle,
    this.phoneNumber,
    this.upiId,
    this.qrCodeUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.tags = const [],
    required this.slug,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Generate a slug from store name
  static String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special chars
        .replaceAll(RegExp(r'\s+'), '-'); // Replace spaces with hyphens
  }

  // Convert Store object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'whatsappNumber': whatsappNumber,
      'instagramHandle': instagramHandle,
      'phoneNumber': phoneNumber,
      'upiId': upiId,
      'qrCodeUrl': qrCodeUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'slug': slug,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create a Store object from a map
  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'],
      sellerId: map['sellerId'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      logoUrl: map['logoUrl'],
      bannerUrl: map['bannerUrl'],
      whatsappNumber: map['whatsappNumber'],
      instagramHandle: map['instagramHandle'],
      phoneNumber: map['phoneNumber'],
      upiId: map['upiId'],
      qrCodeUrl: map['qrCodeUrl'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      tags: List<String>.from(map['tags'] ?? []),
      slug: map['slug'],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Store with updated fields
  Store copyWith({
    String? id,
    String? sellerId,
    String? name,
    String? description,
    String? category,
    String? logoUrl,
    String? bannerUrl,
    String? whatsappNumber,
    String? instagramHandle,
    String? phoneNumber,
    String? upiId,
    String? qrCodeUrl,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tags,
    String? slug,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      slug: slug ?? this.slug,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Get storefront URL
  String get storefrontUrl => 'https://locallink.store/$slug';

  @override
  String toString() {
    return 'Store(id: $id, name: $name, category: $category, slug: $slug)';
  }
}