import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'package:unified_storefronts/data/models/seller.dart';
import 'package:unified_storefronts/data/models/store.dart';
import 'package:uuid/uuid.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Store methods
  // Create store
  Future<Store> createStore(String sellerId, String name, String category) async {
    final storeId = _uuid.v4();
    final slug = Store.generateSlug(name);
    
    final store = Store(
      id: storeId,
      sellerId: sellerId,
      name: name,
      category: category,
      slug: slug,
    );
    
    await _firestore
        .collection(AppConstants.storesCollection)
        .doc(storeId)
        .set(store.toMap());
    
    return store;
  }

  // Get store by id
  Future<Store?> getStore(String storeId) async {
    final doc = await _firestore
        .collection(AppConstants.storesCollection)
        .doc(storeId)
        .get();

    if (doc.exists) {
      return Store.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    return null;
  }

  // Get store by slug
  Future<Store?> getStoreBySlug(String slug) async {
    final query = await _firestore
        .collection(AppConstants.storesCollection)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Store.fromMap(query.docs.first.data());
    }
    
    return null;
  }

  // Get seller's store
  Future<Store?> getSellerStore(String sellerId) async {
    final query = await _firestore
        .collection(AppConstants.storesCollection)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return Store.fromMap(query.docs.first.data());
    }
    
    return null;
  }

  // Update store
  Future<void> updateStore(Store store) async {
    await _firestore
        .collection(AppConstants.storesCollection)
        .doc(store.id)
        .update(store.toMap());
  }

  // Check if slug is available
  Future<bool> isSlugAvailable(String slug) async {
    final query = await _firestore
        .collection(AppConstants.storesCollection)
        .where('slug', isEqualTo: slug)
        .limit(1)
        .get();

    return query.docs.isEmpty;
  }

  // Product methods
  // Create product
  Future<Product> createProduct(String storeId, String sellerId, String name, double price) async {
    final productId = _uuid.v4();
    
    final product = Product(
      id: productId,
      storeId: storeId,
      sellerId: sellerId,
      name: name,
      price: price,
    );
    
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .set(product.toMap());
    
    return product;
  }

  // Get product by id
  Future<Product?> getProduct(String productId) async {
    final doc = await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .get();

    if (doc.exists) {
      return Product.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    return null;
  }

  // Get store products
  Future<List<Product>> getStoreProducts(String storeId) async {
    final query = await _firestore
        .collection(AppConstants.productsCollection)
        .where('storeId', isEqualTo: storeId)
        .get();

    return query.docs
        .map((doc) => Product.fromMap(doc.data()))
        .toList();
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts(String storeId) async {
    final query = await _firestore
        .collection(AppConstants.productsCollection)
        .where('storeId', isEqualTo: storeId)
        .where('isFeatured', isEqualTo: true)
        .get();

    return query.docs
        .map((doc) => Product.fromMap(doc.data()))
        .toList();
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(product.id)
        .update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore
        .collection(AppConstants.productsCollection)
        .doc(productId)
        .delete();
  }

  // Seller methods
  // Get seller by id
  Future<Seller?> getSeller(String sellerId) async {
    final doc = await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(sellerId)
        .get();

    if (doc.exists) {
      return Seller.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    return null;
  }

  // Update seller
  Future<void> updateSeller(Seller seller) async {
    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(seller.id)
        .update(seller.toMap());
  }
}