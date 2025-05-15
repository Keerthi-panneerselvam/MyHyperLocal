import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/core/services/storage_service.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/presentation/widgets/onboarding/voice_input_widget.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  
  List<File> _selectedImages = [];
  bool _isFeatured = false;
  bool _isUploading = false;
  String? _errorMessage;
  
  final StorageService _storageService = StorageService();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _storageService.pickMultipleImages();
      
      if (pickedFiles.isNotEmpty) {
        final List<File> newImages = pickedFiles.map((file) => File(file.path)).toList();
        
        setState(() {
          // Ensure we don't exceed max images
          if (_selectedImages.length + newImages.length > AppConstants.maxProductImages) {
            _errorMessage = 'You can only upload up to ${AppConstants.maxProductImages} images';
            _selectedImages = [
              ..._selectedImages,
              ...newImages.take(AppConstants.maxProductImages - _selectedImages.length)
            ];
          } else {
            _errorMessage = null;
            _selectedImages = [..._selectedImages, ...newImages];
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  // Remove image at index
  void _removeImageAtIndex(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Validate product name
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a product name';
    }
    if (value.length > AppConstants.maxProductNameLength) {
      return 'Product name is too long';
    }
    return null;
  }

  // Validate price
  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    
    return null;
  }

  // Create product
  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      if (sellerProvider.currentStore == null) {
        throw Exception('No store found. Please create a store first.');
      }

      // Parse price
      final price = double.parse(_priceController.text);
      
      // Parse tags
      final List<String> tags = _tagsController.text.isEmpty
          ? []
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      // Create product
      final product = await productsProvider.createProduct(
        storeId: sellerProvider.currentStore!.id,
        sellerId: sellerProvider.currentStore!.sellerId,
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        imageFiles: _selectedImages.isEmpty ? null : _selectedImages,
        tags: tags.isEmpty ? null : tags,
        isFeatured: _isFeatured,
      );

      if (product != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product "${product.name}" created successfully')),
        );
        
        Navigator.pop(context);
      } else if (mounted) {
        throw Exception('Failed to create product');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating product: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _isUploading
          ? const LoadingIndicator(message: 'Creating product...')
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            _buildImageSection(),
            
            const SizedBox(height: 24),
            
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter product name',
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: _validateName,
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 16),
            
            // Product Description
            VoiceInputWidget(
              controller: _descriptionController,
              label: 'Product Description (Optional)',
              hintText: 'Enter description or tap mic to speak',
              maxLines: 3,
              maxLength: AppConstants.maxDescriptionLength,
            ),
            
            const SizedBox(height: 16),
            
            // Product Price
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter product price',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: _validatePrice,
            ),
            
            const SizedBox(height: 16),
            
            // Product Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (Optional)',
                hintText: 'Enter tags separated by commas',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Featured Toggle
            SwitchListTile(
              title: const Text('Featured Product'),
              subtitle: const Text('Show this product on your store homepage'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() {
                  _isFeatured = value;
                });
              },
              secondary: const Icon(Icons.star),
            ),
            
            const SizedBox(height: 24),
            
            // Error Message
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Create Button
            CustomButton(
              text: 'Create Product',
              onPressed: _createProduct,
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Images',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Add up to ${AppConstants.maxProductImages} images',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected Images Grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeImageAtIndex(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Main',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        
        const SizedBox(height: 16),
        
        // Add Image Button
        if (_selectedImages.length < AppConstants.maxProductImages)
          Center(
            child: OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}