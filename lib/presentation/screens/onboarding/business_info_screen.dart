import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/presentation/providers/auth_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/image_picker.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/presentation/widgets/onboarding/voice_input_widget.dart';
import 'package:unified_storefronts/presentation/widgets/onboarding/step_indicator.dart';

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({super.key});

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  String _selectedCategory = 'Retail';
  File? _logoImageFile;
  File? _bannerImageFile;
  bool _isCreatingStore = false;

  // Business categories
  final List<String> _categories = [
    'Retail',
    'Food & Beverages',
    'Fashion',
    'Electronics',
    'Grocery',
    'Handicrafts',
    'Home Decor',
    'Beauty & Personal Care',
    'Services',
    'Other',
  ];

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    super.dispose();
  }

  // Validate store name
  String? _validateStoreName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a store name';
    }
    if (value.length > AppConstants.maxStoreNameLength) {
      return 'Store name is too long';
    }
    return null;
  }

  // Handle logo image selection
  void _onLogoImageSelected(File file) {
    if (file.path.isEmpty) {
      setState(() {
        _logoImageFile = null;
      });
    } else {
      setState(() {
        _logoImageFile = file;
      });
    }
  }

  // Handle banner image selection
  void _onBannerImageSelected(File file) {
    if (file.path.isEmpty) {
      setState(() {
        _bannerImageFile = null;
      });
    } else {
      setState(() {
        _bannerImageFile = file;
      });
    }
  }

  // Create store and move to next screen
  Future<void> _createStoreAndContinue() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingStore = true;
    });

    final sellerId = context.read<AuthProvider>().userId;
    if (sellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() {
        _isCreatingStore = false;
      });
      return;
    }

    final sellerProvider = context.read<SellerProvider>();

    try {
      // Create the store
      final success = await sellerProvider.createStore(
        sellerId: sellerId,
        name: _storeNameController.text.trim(),
        category: _selectedCategory,
      );

      if (!success) {
        throw Exception('Failed to create store');
      }

      // Update store description if provided
      if (_storeDescriptionController.text.isNotEmpty) {
        await sellerProvider.updateStore(
          description: _storeDescriptionController.text.trim(),
        );
      }

      // Upload logo if selected
      if (_logoImageFile != null) {
        await sellerProvider.uploadStoreLogo(_logoImageFile!);
      }

      // Upload banner if selected
      if (_bannerImageFile != null) {
        await sellerProvider.uploadStoreBanner(_bannerImageFile!);
      }

      // Navigate to contact info screen
      if (mounted) {
        Navigator.pushNamed(context, AppRoutes.contactInfo);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingStore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerProvider = Provider.of<SellerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Information'),
      ),
      body: sellerProvider.isLoading || authProvider.isLoading
          ? const LoadingIndicator(message: 'Loading...')
          : _buildContent(sellerProvider),
    );
  }

  Widget _buildContent(SellerProvider sellerProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(
                currentStep: 1,
                totalSteps: 3,
                labels: ['Register', 'Business', 'Contact'],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Tell us about your business',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Add your store details to create your online storefront',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Store name
              const Text(
                'Store Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your store name',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: _validateStoreName,
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 16),
              
              // Store description
              VoiceInputWidget(
                controller: _storeDescriptionController,
                label: 'Store Description',
                hintText: 'Describe your store (or tap the mic to speak)',
                maxLines: 3,
                maxLength: AppConstants.maxDescriptionLength,
              ),
              
              const SizedBox(height: 16),
              
              // Store category
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Store Logo
              const Text(
                'Store Logo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Upload a logo for your store (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 8),
              
              ImagePickerWidget(
                selectedImageFile: _logoImageFile,
                onImageSelected: _onLogoImageSelected,
                height: 120,
                width: 120,
                placeholderText: 'Tap to add logo',
                icon: Icons.add_photo_alternate,
              ),
              
              const SizedBox(height: 24),
              
              // Store Banner
              const Text(
                'Store Banner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Upload a banner image for your store (optional)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 8),
              
              ImagePickerWidget(
                selectedImageFile: _bannerImageFile,
                onImageSelected: _onBannerImageSelected,
                height: 150,
                placeholderText: 'Tap to add banner image',
                icon: Icons.add_photo_alternate,
              ),
              
              const SizedBox(height: 32),
              
              // Continue button
              CustomButton(
                text: 'Continue',
                onPressed: _isCreatingStore ? null : _createStoreAndContinue,
                isLoading: _isCreatingStore,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}