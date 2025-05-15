import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/core/services/analytics_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? productId;

  const ProductDetailScreen({
    super.key,
    this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  Product? _product;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Load product data
  Future<void> _loadProductData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.productId != null) {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        _product = await productsProvider.getProduct(widget.productId!);
        
        // Track product view
        if (_product != null) {
          final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
          if (sellerProvider.currentStore != null) {
            await _analyticsService.trackProductView(
              _product!.storeId,
              _product!.sellerId,
              _product!.id,
            );
          }
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading product data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Contact via WhatsApp
  Future<void> _contactViaWhatsApp() async {
    final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
    final store = sellerProvider.currentStore;
    
    if (store?.whatsappNumber == null || _product == null) return;
    
    try {
      // Track contact click
      await _analyticsService.trackContactClick(
        store!.id,
        store.sellerId,
        'whatsapp',
      );
      
      // Format message with product details
      final productName = _product!.name;
      final productPrice = _product!.formattedPrice('₹');
      final message = 'Hi, I\'m interested in your product "$productName" priced at $productPrice. Is it available?';
      
      // Open WhatsApp
      final phoneNumber = store.whatsappNumber!.replaceAll('+', '');
      final encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/$phoneNumber?text=$encodedMessage';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error opening WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading product details...')
          : _product == null
              ? _buildErrorView()
              : _buildProductDetailView(),
    );
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
          const Text(
            'The requested product could not be loaded',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
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

  Widget _buildProductDetailView() {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final store = sellerProvider.currentStore;
    
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share product
                // (For simplicity, we'll skip implementation)
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageGallery(),
          ),
        ),
        
        // Product Details
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  _product!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Price and Stock Status
                Row(
                  children: [
                    Text(
                      _product!.formattedPrice('₹'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _product!.inStock ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _product!.inStock ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: _product!.inStock ? Colors.green.shade800 : Colors.red.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Product Description
                if (_product!.description != null && _product!.description!.isNotEmpty) ...[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Tags
                if (_product!.tags.isNotEmpty) ...[
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _product!.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Seller Info
                if (store != null) ...[
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Store logo
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          image: store.logoUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(store.logoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: store.logoUrl == null
                            ? Icon(
                                Icons.store,
                                size: 20,
                                color: Colors.grey.shade600,
                              )
                            : null,
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Store name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              store.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGallery() {
    // If no images available, show placeholder
    if (_product!.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.image,
            size: 64,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    // If only one image, show it without pagination
    if (_product!.imageUrls.length == 1) {
      return CachedNetworkImage(
        imageUrl: _product!.imageUrls.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: const Icon(
            Icons.error,
            color: Colors.red,
          ),
        ),
      );
    }

    // Multiple images - show with pagination
    return Stack(
      children: [
        // Page View
        PageView.builder(
          controller: _pageController,
          itemCount: _product!.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: _product!.imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
            );
          },
        ),
        
        // Pagination Indicator
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_product!.imageUrls.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _isLoading
  //         ? const LoadingIndicator(message: 'Loading product details...')
  //         : _product == null
  //             ? _buildErrorView()
  //             : _buildProductDetailView(),
  //     bottomNavigationBar: _product != null
  //         ? _buildBottomBar()
  //         : null,
  //   );
  // }

  Widget _buildBottomBar() {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final store = sellerProvider.currentStore;
    
    // Check if WhatsApp number is available
    final hasWhatsApp = store?.whatsappNumber != null && store!.whatsappNumber!.isNotEmpty;
    
    if (!hasWhatsApp) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _product!.inStock ? _contactViaWhatsApp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _product!.inStock ? 'Chat on WhatsApp' : 'Out of Stock',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}