import 'package:flutter/material.dart';
import 'package:unified_storefronts/core/services/api_service.dart';
import 'package:unified_storefronts/core/services/analytics_service.dart';
import 'package:unified_storefronts/core/services/storage_service.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'dart:io';

class ProductsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // State variables
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get productCount => _products.length;
  
  // Retrieve products for a store
  Future<void> loadStoreProducts(String storeId) async {
    _setLoading(true);
    
    try {
      _products = await _apiService.getStoreProducts(storeId);
      _setLoading(false);
    } catch (e) {
      _setErrorMessage('Failed to load products: $e');
      _setLoading(false);
    }
  }
  
  // Get featured products
  Future<List<Product>> getFeaturedProducts(String storeId) async {
    try {
      return await _apiService.getFeaturedProducts(storeId);
    } catch (e) {
      _setErrorMessage('Failed to load featured products: $e');
      return [];
    }
  }
  
  // Get product by ID
  Future<Product?> getProduct(String productId) async {
    try {
      return await _apiService.getProduct(productId);
    } catch (e) {
      _setErrorMessage('Failed to load product: $e');
      return null;
    }
  }
  
  // Create a new product
  Future<Product?> createProduct({
    required String storeId,
    required String sellerId,
    required String name,
    required double price,
    String? description,
    List<File>? imageFiles,
    List<String>? tags,
    bool isFeatured = false,
  }) async {
    _setLoading(true);
    
    try {
      // Create basic product
      final product = await _apiService.createProduct(storeId, sellerId, name, price);
      
      // Add additional details
      Product updatedProduct = product.copyWith(
        description: description,
        tags: tags,
        isFeatured: isFeatured,
      );
      
      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final imageUrls = await _storageService.uploadMultipleProductImages(
          imageFiles,
          product.id,
        );
        
        updatedProduct = updatedProduct.copyWith(imageUrls: imageUrls);
      }
      
      // Update product with additional details
      await _apiService.updateProduct(updatedProduct);
      
      // Add to local products list
      _products.add(updatedProduct);
      
      _setLoading(false);
      notifyListeners();
      
      return updatedProduct;
    } catch (e) {
      _setErrorMessage('Failed to create product: $e');
      _setLoading(false);
      return null;
    }
  }
  
  // Update product
  Future<bool> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    List<String>? imageUrls,
    List<String>? tags,
    bool? inStock,
    int? quantity,
    bool? isFeatured,
  }) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      final product = _products[index];
      
      final updatedProduct = product.copyWith(
        name: name,
        description: description,
        price: price,
        imageUrls: imageUrls,
        tags: tags,
        inStock: inStock,
        quantity: quantity,
        isFeatured: isFeatured,
      );
      
      await _apiService.updateProduct(updatedProduct);
      
      // Update in local list
      _products[index] = updatedProduct;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Delete product
  Future<bool> deleteProduct(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Get product before removing from the list
      final product = _products[index];
      
      // Delete product from Firestore
      await _apiService.deleteProduct(productId);
      
      // Delete product images
      if (product.imageUrls.isNotEmpty) {
        await _storageService.deleteMultipleImages(product.imageUrls);
      }
      
      // Remove from local list
      _products.removeAt(index);
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to delete product: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Add image to product
  Future<bool> addProductImage(String productId, File imageFile) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Upload image
      final imageUrl = await _storageService.uploadProductImage(
        imageFile,
        productId,
      );
      
      // Add URL to product's images
      final product = _products[index];
      final updatedImageUrls = List<String>.from(product.imageUrls)..add(imageUrl);
      
      final updatedProduct = product.copyWith(imageUrls: updatedImageUrls);
      
      // Update product
      await _apiService.updateProduct(updatedProduct);
      
      // Update in local list
      _products[index] = updatedProduct;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to add product image: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Remove image from product
  Future<bool> removeProductImage(String productId, String imageUrl) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Delete image from storage
      await _storageService.deleteImage(imageUrl);
      
      // Remove URL from product's images
      final product = _products[index];
      final updatedImageUrls = List<String>.from(product.imageUrls)
        ..remove(imageUrl);
      
      final updatedProduct = product.copyWith(imageUrls: updatedImageUrls);
      
      // Update product
      await _apiService.updateProduct(updatedProduct);
      
      // Update in local list
      _products[index] = updatedProduct;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to remove product image: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Toggle product in-stock status
  Future<bool> toggleProductInStock(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      final product = _products[index];
      
      final updatedProduct = product.copyWith(
        inStock: !product.inStock,
      );
      
      await _apiService.updateProduct(updatedProduct);
      
      // Update in local list
      _products[index] = updatedProduct;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Toggle product featured status
  Future<bool> toggleProductFeatured(String productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      _setErrorMessage('Product not found');
      return false;
    }
    
    _setLoading(true);
    
    try {
      final product = _products[index];
      
      final updatedProduct = product.copyWith(
        isFeatured: !product.isFeatured,
      );
      
      await _apiService.updateProduct(updatedProduct);
      
      // Update in local list
      _products[index] = updatedProduct;
      
      _setLoading(false);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to update product: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Track product view
  Future<void> trackProductView(String storeId, String sellerId, String productId) async {
    try {
      await _analyticsService.trackProductView(storeId, sellerId, productId);
    } catch (e) {
      print('Error tracking product view: $e');
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
