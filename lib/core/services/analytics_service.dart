import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/data/models/analytics.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get store analytics
  Future<Analytics?> getStoreAnalytics(String storeId, String sellerId) async {
    final doc = await _firestore
        .collection(AppConstants.analyticsCollection)
        .doc(storeId)
        .get();

    if (doc.exists) {
      return Analytics.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    // If analytics don't exist yet, create a new record
    final newAnalytics = Analytics(
      id: storeId,
      storeId: storeId,
      sellerId: sellerId,
    );
    
    await _firestore
        .collection(AppConstants.analyticsCollection)
        .doc(storeId)
        .set(newAnalytics.toMap());
    
    return newAnalytics;
  }

  // Track store page view
  Future<void> trackStorePageView(String storeId, String sellerId) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      final updatedAnalytics = analytics.incrementPageViews();
      
      // Update visitorsByDate map
      final today = DateTime.now().toIso8601String().split('T')[0];
      final visitorsByDate = Map<String, int>.from(updatedAnalytics.visitorsByDate);
      
      if (visitorsByDate.containsKey(today)) {
        visitorsByDate[today] = visitorsByDate[today]! + 1;
      } else {
        visitorsByDate[today] = 1;
      }
      
      await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(storeId)
          .update({
            'pageViews': updatedAnalytics.pageViews,
            'visitorsByDate': visitorsByDate,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    }
  }

  // Track unique visitor
  Future<void> trackUniqueVisitor(String storeId, String sellerId) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      final updatedAnalytics = analytics.incrementUniqueVisitors();
      
      await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(storeId)
          .update({
            'uniqueVisitors': updatedAnalytics.uniqueVisitors,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    }
  }

  // Track product view
  Future<void> trackProductView(String storeId, String sellerId, String productId) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      final updatedAnalytics = analytics.incrementProductViews(productId);
      
      await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(storeId)
          .update({
            'productViews': updatedAnalytics.productViews,
            'productViewsMap': updatedAnalytics.productViewsMap,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    }
  }

  // Track contact button click
  Future<void> trackContactClick(String storeId, String sellerId, String contactType) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      final updatedMap = <String, dynamic>{
        'contactClicks': analytics.contactClicks + 1,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Update specific contact type count
      switch (contactType) {
        case 'whatsapp':
          updatedMap['whatsappClicks'] = analytics.whatsappClicks + 1;
          break;
        case 'instagram':
          updatedMap['instagramClicks'] = analytics.instagramClicks + 1;
          break;
        case 'phone':
          updatedMap['phoneClicks'] = analytics.phoneClicks + 1;
          break;
      }
      
      await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(storeId)
          .update(updatedMap);
    }
  }

  // Track store share
  Future<void> trackStoreShare(String storeId, String sellerId) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      await _firestore
          .collection(AppConstants.analyticsCollection)
          .doc(storeId)
          .update({
            'shareCount': analytics.shareCount + 1,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
    }
  }

  // Get analytics for date range
  Future<Map<String, dynamic>> getAnalyticsForDateRange(
    String storeId, 
    String sellerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final analytics = await getStoreAnalytics(storeId, sellerId);
    
    if (analytics != null) {
      final visitorsByDate = analytics.visitorsByDate;
      final filteredVisitorsByDate = <String, int>{};
      
      // Convert dates to ISO format for comparison
      final startDateString = startDate.toIso8601String().split('T')[0];
      final endDateString = endDate.toIso8601String().split('T')[0];
      
      // Filter visitors by date range
      for (final entry in visitorsByDate.entries) {
        final dateString = entry.key;
        
        if (dateString.compareTo(startDateString) >= 0 && 
            dateString.compareTo(endDateString) <= 0) {
          filteredVisitorsByDate[dateString] = entry.value;
        }
      }
      
      return {
        'totalViews': analytics.pageViews,
        'uniqueVisitors': analytics.uniqueVisitors,
        'productViews': analytics.productViews,
        'contactClicks': analytics.totalContactClicks,
        'shareCount': analytics.shareCount,
        'visitorsByDate': filteredVisitorsByDate,
        'productViewsMap': analytics.productViewsMap,
      };
    }
    
    return {};
  }
}