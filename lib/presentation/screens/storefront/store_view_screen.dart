import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'package:unified_storefronts/data/models/store.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/presentation/widgets/storefront/contact_buttons.dart';
import 'package:unified_storefronts/presentation/widgets/storefront/product_grid.dart';
import 'package:unified_storefronts/presentation/widgets/storefront/store_header.dart';
import 'package:unified_storefronts/core/services/analytics_service.dart';

class StoreViewScreen extends StatefulWidget {
  const StoreViewScreen({super.key});

  @override
  State<StoreViewScreen> createState() => _StoreViewScreenState();
}

class _StoreViewScreenState extends State<StoreViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  Store? _store;
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoreData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load store data
  Future<void> _loadStoreData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      // Get store
      _store = sellerProvider.currentStore;
      
      if (_store != null) {
        // Track store view
        await _analyticsService.trackStorePageView(_store!.id, _store!.sellerId);
        
        // Load store products
        await productsProvider.loadStoreProducts(_store!.id);
        _products = productsProvider.products;
        
        // Get featured products
        _featuredProducts = await productsProvider.getFeaturedProducts(_store!.id);
        
        // Extract unique product categories from tags
        final Set<String> categoriesSet = <String>{};
        for (final product in _products) {
          categoriesSet.addAll(product.tags);
        }
        
        _categories = ['All', ...categoriesSet.toList()];
        _selectedCategory = 'All';
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading store data: $e');
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
    if (_store?.whatsappNumber == null) return;
    
    try {
      // Track contact click
      await _analyticsService.trackContactClick(
        _store!.id, 
        _store!.sellerId, 
        'whatsapp',
      );
      
      // Open WhatsApp
      final phoneNumber = _store!.whatsappNumber!.replaceAll('+', '');
      final url = 'https://wa.me/$phoneNumber';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error opening WhatsApp: $e');
    }
  }

  // Open Instagram
  Future<void> _openInstagram() async {
    if (_store?.instagramHandle == null) return;
    
    try {
      // Track contact click
      await _analyticsService.trackContactClick(
        _store!.id, 
        _store!.sellerId, 
        'instagram',
      );
      
      // Open Instagram
      final username = _store!.instagramHandle!.replaceAll('@', '');
      final url = 'https://instagram.com/$username';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error opening Instagram: $e');
    }
  }

  // Make phone call
  Future<void> _makePhoneCall() async {
    if (_store?.phoneNumber == null) return;
    
    try {
      // Track contact click
      await _analyticsService.trackContactClick(
        _store!.id, 
        _store!.sellerId, 
        'phone',
      );
      
      // Make phone call
      final url = 'tel:${_store!.phoneNumber}';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error making phone call: $e');
    }
  }

  // Share store
  Future<void> _shareStore() async {
    if (_store == null) return;
    
    try {
      await _analyticsService.trackStoreShare(_store!.id, _store!.sellerId);
      
      // For simplicity, we'll just open a WhatsApp share
      final url = 'https://wa.me/?text=Check out this store: ${_store!.storefrontUrl}';
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error sharing store: $e');
    }
  }

  // View product details
  void _viewProductDetails(Product product) {
    if (_store == null) return;
    
    // Track product view
    _analyticsService.trackProductView(
      _store!.id, 
      _store!.sellerId, 
      product.id,
    );
    
    // Navigate to product detail screen
    Navigator.pushNamed(
      context, 
      AppRoutes.productDetail,
      arguments: product.id,
    );
  }

  // Filter products by category
  List<Product> _getFilteredProducts() {
    if (_selectedCategory == 'All') {
      return _products;
    } else {
      return _products.where((product) => product.tags.contains(_selectedCategory)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading store...')
          : _store == null
              ? _buildErrorView()
              : _buildStoreView(),
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
            'Store not found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The requested store could not be loaded',
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

  Widget _buildStoreView() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareStore,
                tooltip: 'Share Store',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _store!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              background: _store!.bannerUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _store!.bannerUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        child: Center(
                          child: Icon(
                            Icons.store,
                            size: 48,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      child: Center(
                        child: Icon(
                          Icons.store,
                          size: 48,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
            ),
          ),

          // Store Header
          SliverToBoxAdapter(
            child: StoreHeader(
              store: _store!,
              onShare: _shareStore,
            ),
          ),

          // Contact Buttons
          SliverToBoxAdapter(
            child: ContactButtons(
              whatsappNumber: _store!.whatsappNumber,
              instagramHandle: _store!.instagramHandle,
              phoneNumber: _store!.phoneNumber,
              onWhatsAppTap: _contactViaWhatsApp,
              onInstagramTap: _openInstagram,
              onPhoneTap: _makePhoneCall,
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Products'),
                  Tab(text: 'About'),
                ],
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
              ),
              backgroundColor: Colors.white,
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Products Tab
                _buildProductsTab(),
                
                // About Tab
                _buildAboutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    // Get filtered products
    final filteredProducts = _getFilteredProducts();
    
    return Column(
      children: [
        // Featured Products Section (if any)
        if (_featuredProducts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProducts.length,
              itemBuilder: (context, index) {
                final product = _featuredProducts[index];
                
                return SizedBox(
                  width: 160,
                  child: Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      onTap: () => _viewProductDetails(product),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          SizedBox(
                            height: 100,
                            width: double.infinity,
                            child: product.imageUrls.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.imageUrls.first,
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
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                          
                          // Product Details
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.formattedPrice('₹'),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 32),
        ],
        
        // Category Filter
        SizedBox(
          height: 40,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    }
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Product Grid
        Expanded(
          child: filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedCategory != 'All')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                          },
                          child: const Text('Show all products'),
                        ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _viewProductDetails(product),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Expanded(
                              child: product.imageUrls.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
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
                                    )
                                  : Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            
                            // Product Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.formattedPrice('₹'),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!product.inStock) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Out of Stock',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_store!.description != null && _store!.description!.isNotEmpty) ...[
            const Text(
              'About Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _store!.description!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
          ],
          
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_store!.whatsappNumber != null) ...[
            _buildContactItem(
              Icons.chat,
              'WhatsApp',
              _store!.whatsappNumber!,
              Colors.green,
              _contactViaWhatsApp,
            ),
            const SizedBox(height: 12),
          ],
          
          if (_store!.phoneNumber != null) ...[
            _buildContactItem(
              Icons.phone,
              'Phone',
              _store!.phoneNumber!,
              Colors.blue,
              _makePhoneCall,
            ),
            const SizedBox(height: 12),
          ],
          
          if (_store!.instagramHandle != null) ...[
            _buildContactItem(
              Icons.camera_alt,
              'Instagram',
              _store!.instagramHandle!,
              Colors.purple,
              _openInstagram,
            ),
            const SizedBox(height: 12),
          ],
          
          if (_store!.address != null) ...[
            _buildContactItem(
              Icons.location_on,
              'Address',
              _store!.address!,
              Colors.red,
              null,
            ),
            const SizedBox(height: 12),
          ],
          
          const SizedBox(height: 24),
          
          // Payment Information
          if (_store!.upiId != null || _store!.qrCodeUrl != null) ...[
            const Text(
              'Payment Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_store!.upiId != null)
              _buildContactItem(
                Icons.payment,
                'UPI ID',
                _store!.upiId!,
                Colors.amber,
                null,
              ),
              
            if (_store!.qrCodeUrl != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Scan to Pay',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _store!.qrCodeUrl!,
                      fit: BoxFit.cover,
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
              ),
            ],
          ],
          
          const SizedBox(height: 32),
          
          // Store Info
          Center(
            child: Column(
              children: [
                const Text(
                  'Powered by',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unified Storefronts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
}

// Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, {this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}