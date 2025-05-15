# Unified Storefronts for Sellers - Flutter Project

## Project Structure

```
unified_storefronts/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── theme.dart
│   │   ├── routes.dart
│   │   └── constants.dart
│   ├── core/
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   ├── storage_service.dart
│   │   │   ├── analytics_service.dart
│   │   │   └── api_service.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── image_helpers.dart
│   │       └── voice_to_text_helper.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── seller.dart
│   │   │   ├── product.dart
│   │   │   ├── store.dart
│   │   │   └── analytics.dart
│   │   └── repositories/
│   │       ├── seller_repository.dart
│   │       ├── product_repository.dart
│   │       └── analytics_repository.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── onboarding/
│   │   │   │   ├── register_screen.dart
│   │   │   │   ├── business_info_screen.dart
│   │   │   │   ├── contact_info_screen.dart
│   │   │   │   └── onboarding_complete_screen.dart
│   │   │   ├── store_management/
│   │   │   │   ├── dashboard_screen.dart
│   │   │   │   ├── product_list_screen.dart
│   │   │   │   ├── add_product_screen.dart
│   │   │   │   ├── edit_product_screen.dart
│   │   │   │   └── store_analytics_screen.dart
│   │   │   └── storefront/
│   │   │       ├── store_view_screen.dart
│   │   │       ├── product_detail_screen.dart
│   │   │       └── contact_screen.dart
│   │   ├── widgets/
│   │   │   ├── common/
│   │   │   │   ├── app_bar.dart
│   │   │   │   ├── loading_indicator.dart
│   │   │   │   ├── custom_button.dart
│   │   │   │   └── image_picker.dart
│   │   │   ├── onboarding/
│   │   │   │   ├── step_indicator.dart
│   │   │   │   └── voice_input_widget.dart
│   │   │   ├── product/
│   │   │   │   ├── product_card.dart
│   │   │   │   ├── product_grid.dart
│   │   │   │   └── product_form.dart
│   │   │   └── storefront/
│   │   │       ├── store_header.dart
│   │   │       ├── contact_buttons.dart
│   │   │       └── payment_section.dart
│   │   └── providers/
│   │       ├── auth_provider.dart
│   │       ├── seller_provider.dart
│   │       └── products_provider.dart
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── placeholder.png
│   │   └── onboarding/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

## Key Files Implementation


# Unified Storefronts for Sellers

A Flutter application that enables small and local businesses to create lightweight online storefronts linked directly to communication channels like WhatsApp and Instagram.

## Overview

Unified Storefronts is a micro-Shopify solution that helps small businesses establish their online presence without the complexity of a full e-commerce platform. Sellers can easily create a digital storefront, upload products, and share a unique URL with their customers.

## Features

### For Sellers

- **Simple Onboarding**: Register with phone number, add business details, and quickly set up your store
- **Voice Input**: Add product descriptions through voice recording
- **Product Management**: Add, edit, and manage products with stock status
- **Contact Options**: Connect with customers via WhatsApp, Instagram, or phone calls
- **Analytics**: Track store views, product views, and customer interactions
- **Customization**: Upload logo, banner, and customize store information

### For Customers

- **Browse Products**: View products with images, descriptions, and prices
- **Contact Seller**: Reach out via WhatsApp, Instagram, or phone call
- **Filter Products**: Browse by categories/tags
- **UPI Payments**: Scan QR code for direct payments

## Tech Stack

- **Frontend**: Flutter (Cross-platform)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Voice Input**: Speech-to-Text
- **Analytics**: Firebase Analytics
- **Image Handling**: Image Picker, CachedNetworkImage

## Project Structure

```
unified_storefronts/
├── lib/
│   ├── main.dart                  # Application entry point
│   ├── app.dart                   # App initialization and theme
│   ├── config/                    # App configuration
│   │   ├── theme.dart             # Theme and styling
│   │   ├── routes.dart            # Navigation routes
│   │   └── constants.dart         # App constants
│   ├── core/                      # Core functionality
│   │   ├── services/              # Service classes
│   │   │   ├── auth_service.dart  # Authentication service
│   │   │   ├── storage_service.dart  # File storage service
│   │   │   ├── analytics_service.dart  # Analytics service
│   │   │   └── api_service.dart   # API service
│   │   └── utils/                 # Utility classes
│   │       └── voice_to_text_helper.dart  # Voice input helper
│   ├── data/                      # Data layer
│   │   ├── models/                # Data models
│   │   │   ├── seller.dart        # Seller model
│   │   │   ├── product.dart       # Product model
│   │   │   ├── store.dart         # Store model
│   │   │   └── analytics.dart     # Analytics model
│   ├── presentation/              # UI layer
│   │   ├── screens/               # App screens
│   │   │   ├── onboarding/        # Onboarding screens
│   │   │   ├── store_management/  # Store management screens
│   │   │   └── storefront/        # Customer-facing screens
│   │   ├── widgets/               # Reusable widgets
│   │   │   ├── common/            # Common widgets
│   │   │   ├── onboarding/        # Onboarding widgets
│   │   │   └── storefront/        # Storefront widgets
│   │   └── providers/             # State management
│   │       ├── auth_provider.dart # Auth state
│   │       ├── seller_provider.dart  # Seller state
│   │       └── products_provider.dart  # Products state
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account
- Android Studio or Visual Studio Code with Flutter plugins

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/unified_storefronts.git
cd unified_storefronts
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files (google-services.json for Android, GoogleService-Info.plist for iOS)
   - Enable Authentication, Firestore, and Storage services

4. Run the app:
```bash
flutter run
```

## Project Implementation

### Onboarding Flow

The onboarding process is divided into three steps:
1. **Registration**: Login with mobile number via OTP verification
2. **Business Information**: Add store name, description, category, and upload logo/banner
3. **Contact Information**: Add WhatsApp number, Instagram handle, phone number, and payment details

### Store Management

Sellers can manage their store through:
- **Dashboard**: Overview of store performance, recent products, and quick actions
- **Product Management**: Add, edit, delete products with images, descriptions, and pricing
- **Analytics**: Track store views, product views, and customer interactions

### Customer Storefront

Customers can visit the storefront to:
- **Browse Products**: View all products or filter by categories
- **View Product Details**: See product images, pricing, and description
- **Contact Seller**: Connect via WhatsApp, Instagram, or phone call
- **Make Payments**: Scan QR code for UPI payments

## Future Enhancements

- Smart auto-tagging and categorization via AI
- Voice input translation into regional languages
- Storefront themes and color personalization
- Ratings and reviews
- Integration with ONDC backend for broader commerce reach

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Provider](https://pub.dev/packages/provider) for state management
- [Speech to Text](https://pub.dev/packages/speech_to_text) for voice input
- [Image Picker](https://pub.dev/packages/image_picker) for image selection