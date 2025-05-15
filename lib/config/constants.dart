class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App info
  static const String appName = 'Unified Storefronts';
  static const String appVersion = '1.0.0';
  
  // Firebase collections
  static const String sellersCollection = 'sellers';
  static const String productsCollection = 'products';
  static const String storesCollection = 'stores';
  static const String analyticsCollection = 'analytics';
  
  // Storage paths
  static const String profileImagesPath = 'profile_images';
  static const String storeImagesPath = 'store_images';
  static const String productImagesPath = 'product_images';
  
  // Shared preferences keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
  
  // URLs and links
  static const String baseStorefrontUrl = 'https://locallink.store/';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String helpCenterUrl = 'https://example.com/help';
  
  // Default values
  static const int maxProductImages = 5;
  static const int maxStoreNameLength = 50;
  static const int maxProductNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please try again.';
  static const String uploadErrorMessage = 'Failed to upload image. Please try again.';
  
  // Success messages
  static const String productAddedMessage = 'Product added successfully!';
  static const String productUpdatedMessage = 'Product updated successfully!';
  static const String productDeletedMessage = 'Product deleted successfully!';
  static const String storeUpdatedMessage = 'Store information updated successfully!';
  static const String onboardingCompleteMessage = 'Congratulations! Your store is now live.';
}