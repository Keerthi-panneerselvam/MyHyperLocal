import 'package:flutter/material.dart';
import 'package:unified_storefronts/core/services/api_service.dart';
import 'package:unified_storefronts/core/services/analytics_service.dart';
import 'package:unified_storefronts/core/services/storage_service.dart';
import 'package:unified_storefronts/data/models/store.dart';
import 'dart:io';

class SellerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // State variables
  Store? _currentStore;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  Store? get currentStore => _currentStore;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasStore => _currentStore != null;
  
  // Load seller's store
  Future<bool> loadSellerStore(String sellerId) async {
    _setLoading(true);
    
    try {
      _currentStore = await _apiService.getSellerStore(sellerId);
      _setLoading(false);
      
      return _currentStore != null;
    } catch (e) {
      _setErrorMessage('Failed to load store: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Create a new store
  Future<bool> createStore({
    required String sellerId,
    required String name,
    required String category,
  }) async {
    _setLoading(true);
    
    try {
      _currentStore = await _apiService.createStore(sellerId, name, category);
      _setLoading(false);
      
      return true;
    } catch (e) {
      _setErrorMessage('Failed to create store: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Update store information
  Future<bool> updateStore({
    String? name,
    String? description,
    String? category,
    String? whatsappNumber,
    String? instagramHandle,
    String? phoneNumber,
    String? upiId,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? tags,
  }) async {
    if (_currentStore == null) {
      _setErrorMessage('No store found. Please create a store first.');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Update slug if name is changing
      String? slug;
      if (name != null && name != _currentStore!.name) {
        slug = Store.generateSlug(name);
        
        // Check if slug is available
        final isAvailable = await _apiService.isSlugAvailable(slug);
        if (!isAvailable) {
          // If not available, append a random suffix
          slug = '$slug-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
        }
      }
      
      final updatedStore = _currentStore!.copyWith(
        name: name,
        description: description,
        category: category,
        whatsappNumber: whatsappNumber,
        instagramHandle: instagramHandle,
        phoneNumber: phoneNumber,
        upiId: upiId,
        address: address,
        latitude: latitude,
        longitude: longitude,
        tags: tags,
        slug: slug,
      );
      
      await _apiService.updateStore(updatedStore);
      _currentStore = updatedStore;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Failed to update store: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Upload store logo
  Future<bool> uploadStoreLogo(File imageFile) async {
    if (_currentStore == null) {
      _setErrorMessage('No store found. Please create a store first.');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Delete existing logo if any
      if (_currentStore!.logoUrl != null) {
        await _storageService.deleteImage(_currentStore!.logoUrl!);
      }
      
      // Upload new logo
      final logoUrl = await _storageService.uploadStoreLogo(
        imageFile,
        _currentStore!.id,
      );
      
      // Update store with new logo URL
      final updatedStore = _currentStore!.copyWith(logoUrl: logoUrl);
      await _apiService.updateStore(updatedStore);
      _currentStore = updatedStore;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Failed to upload logo: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Upload store banner
  Future<bool> uploadStoreBanner(File imageFile) async {
    if (_currentStore == null) {
      _setErrorMessage('No store found. Please create a store first.');
      return false;
    }
    
    _setLoading(true);
    
    try {
      // Delete existing banner if any
      if (_currentStore!.bannerUrl != null) {
        await _storageService.deleteImage(_currentStore!.bannerUrl!);
      }
      
      // Upload new banner
      final bannerUrl = await _storageService.uploadStoreBanner(
        imageFile,
        _currentStore!.id,
      );
      
      // Update store with new banner URL
      final updatedStore = _currentStore!.copyWith(bannerUrl: bannerUrl);
      await _apiService.updateStore(updatedStore);
      _currentStore = updatedStore;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setErrorMessage('Failed to upload banner: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Get store analytics
  Future<Map<String, dynamic>> getStoreAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentStore == null) {
      return {};
    }
    
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      return await _analyticsService.getAnalyticsForDateRange(
        _currentStore!.id,
        _currentStore!.sellerId,
        start,
        end,
      );
    } catch (e) {
      _setErrorMessage('Failed to get analytics: $e');
      return {};
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