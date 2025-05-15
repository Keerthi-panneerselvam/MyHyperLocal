class Analytics {
  final String id;
  final String storeId;
  final String sellerId;
  int pageViews;
  int uniqueVisitors;
  int productViews;
  int contactClicks;
  int whatsappClicks;
  int instagramClicks;
  int phoneClicks;
  int shareCount;
  Map<String, int> productViewsMap;
  Map<String, int> visitorsByDate;
  DateTime createdAt;
  DateTime updatedAt;

  Analytics({
    required this.id,
    required this.storeId,
    required this.sellerId,
    this.pageViews = 0,
    this.uniqueVisitors = 0,
    this.productViews = 0,
    this.contactClicks = 0,
    this.whatsappClicks = 0,
    this.instagramClicks = 0,
    this.phoneClicks = 0,
    this.shareCount = 0,
    this.productViewsMap = const {},
    this.visitorsByDate = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Analytics object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeId': storeId,
      'sellerId': sellerId,
      'pageViews': pageViews,
      'uniqueVisitors': uniqueVisitors,
      'productViews': productViews,
      'contactClicks': contactClicks,
      'whatsappClicks': whatsappClicks,
      'instagramClicks': instagramClicks,
      'phoneClicks': phoneClicks,
      'shareCount': shareCount,
      'productViewsMap': productViewsMap,
      'visitorsByDate': visitorsByDate,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create an Analytics object from a map
  factory Analytics.fromMap(Map<String, dynamic> map) {
    return Analytics(
      id: map['id'],
      storeId: map['storeId'],
      sellerId: map['sellerId'],
      pageViews: map['pageViews'] ?? 0,
      uniqueVisitors: map['uniqueVisitors'] ?? 0,
      productViews: map['productViews'] ?? 0,
      contactClicks: map['contactClicks'] ?? 0,
      whatsappClicks: map['whatsappClicks'] ?? 0,
      instagramClicks: map['instagramClicks'] ?? 0,
      phoneClicks: map['phoneClicks'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      productViewsMap: Map<String, int>.from(map['productViewsMap'] ?? {}),
      visitorsByDate: Map<String, int>.from(map['visitorsByDate'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  // Create a copy of the Analytics with updated fields
  Analytics copyWith({
    String? id,
    String? storeId,
    String? sellerId,
    int? pageViews,
    int? uniqueVisitors,
    int? productViews,
    int? contactClicks,
    int? whatsappClicks,
    int? instagramClicks,
    int? phoneClicks,
    int? shareCount,
    Map<String, int>? productViewsMap,
    Map<String, int>? visitorsByDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Analytics(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      sellerId: sellerId ?? this.sellerId,
      pageViews: pageViews ?? this.pageViews,
      uniqueVisitors: uniqueVisitors ?? this.uniqueVisitors,
      productViews: productViews ?? this.productViews,
      contactClicks: contactClicks ?? this.contactClicks,
      whatsappClicks: whatsappClicks ?? this.whatsappClicks,
      instagramClicks: instagramClicks ?? this.instagramClicks,
      phoneClicks: phoneClicks ?? this.phoneClicks,
      shareCount: shareCount ?? this.shareCount,
      productViewsMap: productViewsMap ?? this.productViewsMap,
      visitorsByDate: visitorsByDate ?? this.visitorsByDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Increment page views
  Analytics incrementPageViews() {
    return copyWith(
      pageViews: pageViews + 1,
      updatedAt: DateTime.now(),
    );
  }

  // Increment unique visitors
  Analytics incrementUniqueVisitors() {
    return copyWith(
      uniqueVisitors: uniqueVisitors + 1,
      updatedAt: DateTime.now(),
    );
  }

  // Increment product views
  Analytics incrementProductViews(String productId) {
    final updatedProductViews = productViews + 1;
    final updatedProductViewsMap = Map<String, int>.from(productViewsMap);
    
    if (updatedProductViewsMap.containsKey(productId)) {
      updatedProductViewsMap[productId] = updatedProductViewsMap[productId]! + 1;
    } else {
      updatedProductViewsMap[productId] = 1;
    }
    
    return copyWith(
      productViews: updatedProductViews,
      productViewsMap: updatedProductViewsMap,
      updatedAt: DateTime.now(),
    );
  }

  // Get total contact button clicks
  int get totalContactClicks => contactClicks + whatsappClicks + instagramClicks + phoneClicks;

  @override
  String toString() {
    return 'Analytics(id: $id, pageViews: $pageViews, uniqueVisitors: $uniqueVisitors, productViews: $productViews)';
  }
}