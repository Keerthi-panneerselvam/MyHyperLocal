import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/core/services/storage_service.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/presentation/widgets/onboarding/voice_input_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProductScreen extends StatefulWidget {
  final String? productId;

  const EditProductScreen({
    super.key,
    this.productId,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tagsController = TextEditingController();
  
  bool _isFeatured = false;
  bool _inStock = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  
  Product? _product;
  List<String> _productImages = [];
  List<File> _newImageFiles = [];
  List<String> _imagesToDelete = [];

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  // Load product data
  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.productId != null) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        _product = await productsProvider.getProduct(widget.productId!);
        
        if (_product != null) {
          // Initialize form fields
          _nameController.text = _product!.name;
          _descriptionController.text = _product!.description ?? '';
          _priceController.text = _product!.price.toString();
          _tagsController.text = _product!.tags.join(', ');
          _isFeatured = _product!.isFeatured;
          _inStock = _product!.inStock;
          _productImages = List<String>.from(_product!.imageUrls);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading product: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Pick additional images
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _storageService.pickMultipleImages();
      
      if (pickedFiles.isNotEmpty) {
        final List<File> newImages = pickedFiles.map((file) => File(file.path)).toList();
        
        setState(() {
          // Ensure we don't exceed max images
          final totalImages = _productImages.length + _newImageFiles.length + newImages.length;
          
          if (totalImages > AppConstants.maxProductImages) {
            _errorMessage = 'You can only upload up to ${AppConstants.maxProductImages} images';
            
            // Add only as many as we can
            final remainingSlots = AppConstants.maxProductImages - _productImages.length - _newImageFiles.length;
            if (remainingSlots > 0) {
              _newImageFiles.addAll(newImages.take(remainingSlots));
            }
          } else {
            _errorMessage = null;
            _newImageFiles.addAll(newImages);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  // Remove existing image
  void _removeExistingImage(String imageUrl) {
    setState(() {
      _productImages.remove(imageUrl);
      _imagesToDelete.add(imageUrl);
    });
  }

  // Remove new image
  void _removeNewImage(int index) {
    setState(() {
      _newImageFiles.removeAt(index);
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

  // Update product
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (_product == null) {
        throw Exception('Product not found');
      }

      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      // Parse price
      final price = double.parse(_priceController.text);
      
      // Parse tags
      final List<String> tags = _tagsController.text.isEmpty
          ? []
          : _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      // Delete removed images
      if (_imagesToDelete.isNotEmpty) {
        for (final imageUrl in _imagesToDelete) {
          await _storageService.deleteImage(imageUrl);
        }
      }

      // Upload new images
      List<String> allImageUrls = List<String>.from(_productImages);
      
      if (_newImageFiles.isNotEmpty) {
        final uploadedImageUrls = await _storageService.uploadMultipleProductImages(
          _newImageFiles,
          _product!.id,
        );
        
        allImageUrls.addAll(uploadedImageUrls);
      }

      // Update product
      final success = await productsProvider.updateProduct(
        productId: _product!.id,
        name: _nameController.text.trim(),
        price: price,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        imageUrls: allImageUrls,
        tags: tags.isEmpty ? null : tags,
        inStock: _inStock,
        isFeatured: _isFeatured,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
        
        Navigator.pop(context);
      } else if (mounted) {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating product: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          // Delete product button
          if (_product != null && !_isLoading && !_isSaving)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteProduct,
              tooltip: 'Delete Product',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading product...')
          : _product == null
              ? _buildErrorView()
              : _buildForm(),
    );
  }

  // Confirm delete product
  Future<void> _confirmDeleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${_product!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        final success = await productsProvider.deleteProduct(_product!.id);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully')),
          );
          
          Navigator.pop(context);
        } else if (mounted) {
          throw Exception('Failed to delete product');
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error deleting product: $e';
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Product not found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'The product could not be loaded',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
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
              initialText: _product?.description,
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
            
            // In Stock Toggle
            SwitchListTile(
              title: const Text('In Stock'),
              subtitle: const Text('Set product availability status'),
              value: _inStock,
              onChanged: (value) {
                setState(() {
                  _inStock = value;
                });
              },
              secondary: const Icon(Icons.inventory),
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
            
            // Update Button
            CustomButton(
              text: 'Update Product',
              onPressed: _isSaving ? null : _updateProduct,
              isLoading: _isSaving,
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
        
        // Existing Images Grid
        if (_productImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _productImages.length,
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
                      child: CachedNetworkImage(
                        imageUrl: _productImages[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeExistingImage(_productImages[index]),
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
        
        // New Images Grid
        if (_newImageFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          
          const Text(
            'New Images',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _newImageFiles.length,
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
                        _newImageFiles[index],
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
                      onTap: () => _removeNewImage(index),
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
                  if (_productImages.isEmpty && index == 0)
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
        ],
        
        const SizedBox(height: 16),
        
        // Add Image Button
        if (_productImages.length + _newImageFiles.length < AppConstants.maxProductImages)
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