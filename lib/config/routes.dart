import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/business_info_screen.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/contact_info_screen.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/onboarding_complete_screen.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/otp_verification_screen.dart';
import 'package:unified_storefronts/presentation/screens/onboarding/register_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/add_product_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/dashboard_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/edit_product_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/product_list_screen.dart';
import 'package:unified_storefronts/presentation/screens/store_management/store_analytics_screen.dart';
import 'package:unified_storefronts/presentation/screens/storefront/product_detail_screen.dart';
import 'package:unified_storefronts/presentation/screens/storefront/store_view_screen.dart';

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route names
  static const String register = '/register';
  static const String businessInfo = '/business-info';
  static const String contactInfo = '/contact-info';
  static const String onboardingComplete = '/onboarding-complete';
  static const String dashboard = '/dashboard';
  static const String productList = '/product-list';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String storeAnalytics = '/store-analytics';
  static const String storeView = '/store-view';
  static const String productDetail = '/product-detail';
  static const String otpVerification = '/otp_verification';

  // Route map
  static final Map<String, WidgetBuilder> routes = {
    register: (context) => const RegisterScreen(),
    businessInfo: (context) => const BusinessInfoScreen(),
    contactInfo: (context) => const ContactInfoScreen(),
    onboardingComplete: (context) => const OnboardingCompleteScreen(),
    dashboard: (context) => const DashboardScreen(),
    productList: (context) => const ProductListScreen(),
    addProduct: (context) => const AddProductScreen(),
    editProduct: (context) => const EditProductScreen(),
    storeAnalytics: (context) => const StoreAnalyticsScreen(),
    storeView: (context) => const StoreViewScreen(),
    productDetail: (context) => const ProductDetailScreen(),
    // otpVerification: (context) => const OtpVerificationScreen(),
  };
}