import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/presentation/providers/auth_provider.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Initialize store and product data
  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      if (authProvider.userId != null) {
        // Load seller's store
        final hasStore = await sellerProvider.loadSellerStore(authProvider.userId!);
        
        if (hasStore && sellerProvider.currentStore != null) {
          // Load store products
          await productsProvider.loadStoreProducts(sellerProvider.currentStore!.id);
          
          // Get store analytics
          _analytics = await sellerProvider.getStoreAnalytics();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Open store URL
  Future<void> _openStoreUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showErrorSnackBar('Could not open store link');
    }
  }

  // Copy store URL to clipboard
  Future<void> _copyStoreUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store link copied to clipboard')),
    );
  }

  // Share store URL
  Future<void> _shareStoreUrl(String url) async {
    try {
      final Uri uri = Uri.parse('https://wa.me/?text=Check out my online store: $url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showErrorSnackBar('Could not share store link');
    }
  }

  // Sign out
  Future<void> _signOut() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if all providers are loading
    final isLoading = _isLoading || 
                      sellerProvider.isLoading || 
                      productsProvider.isLoading ||
                      authProvider.isLoading;
    
    // Check if store exists
    final hasStore = sellerProvider.currentStore != null;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: isLoading
          ? const LoadingIndicator(message: 'Loading your store...')
          : !hasStore
              ? _buildNoStoreView()
              : _buildDashboardContent(sellerProvider, productsProvider),
      floatingActionButton: hasStore && !isLoading
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addProduct);
              },
              tooltip: 'Add Product',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNoStoreView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.store_mall_directory,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Store Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t created a store yet. Let\'s get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Create Your Store',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.businessInfo);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    SellerProvider sellerProvider, 
    ProductsProvider productsProvider,
  ) {
    final store = sellerProvider.currentStore!;
    final productCount = productsProvider.productCount;
    
    return RefreshIndicator(
      onRefresh: _initializeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store card
              _buildStoreCard(store),
              
              const SizedBox(height: 24),
              
              // Stats cards
              _buildStatsCard(productCount),
              
              const SizedBox(height: 24),
              
              // Recent activity
              _buildRecentActivity(),
              
              const SizedBox(height: 24),
              
              // Quick actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(store) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Store logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    image: store.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(store.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: store.logoUrl == null
                      ? Icon(
                          Icons.store,
                          size: 30,
                          color: Colors.grey.shade600,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Store info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
            
            const SizedBox(height: 16),
            
            // Store URL
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      store.storefrontUrl,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _copyStoreUrl(store.storefrontUrl),
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: const Text('Visit'),
                    onPressed: () => _openStoreUrl(store.storefrontUrl),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    onPressed: () => _shareStoreUrl(store.storefrontUrl),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.businessInfo);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(int productCount) {
    final pageViews = _analytics['totalViews'] ?? 0;
    final visitorCount = _analytics['uniqueVisitors'] ?? 0;
    final contactClicks = _analytics['contactClicks'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Store Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                Icons.visibility,
                pageViews.toString(),
                'Views',
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.people,
                visitorCount.toString(),
                'Visitors',
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.shopping_basket,
                productCount.toString(),
                'Products',
                Colors.amber,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.phone_in_talk,
                contactClicks.toString(),
                'Contacts',
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.storeAnalytics);
          },
          child: const Text('View detailed analytics'),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final products = productsProvider.products;
    
    // Take only first 3 products or less
    final recentProducts = products.length > 3 
        ? products.sublist(0, 3) 
        : products;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.productList);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Show message if no products
        if (recentProducts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No products yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add your first product to start selling',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: recentProducts.map((product) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: product.imageUrls.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(product.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey.shade200,
                    ),
                    child: product.imageUrls.isEmpty
                        ? Icon(
                            Icons.image,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    product.formattedPrice('₹'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.inStock ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 12,
                        color: product.inStock ? Colors.green.shade800 : Colors.red.shade800,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.editProduct,
                      arguments: product.id,
                    );
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                Icons.add_circle,
                'Add Product',
                Colors.purple.shade100,
                Colors.purple.shade700,
                () {
                  Navigator.pushNamed(context, AppRoutes.addProduct);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionItem(
                Icons.view_list,
                'Manage Products',
                Colors.green.shade100,
                Colors.green.shade700,
                () {
                  Navigator.pushNamed(context, AppRoutes.productList);
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionItem(
                Icons.share,
                'Share Store',
                Colors.blue.shade100,
                Colors.blue.shade700,
                () {
                  final store = Provider.of<SellerProvider>(context, listen: false).currentStore;
                  if (store != null) {
                    _shareStoreUrl(store.storefrontUrl);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionItem(
                Icons.edit,
                'Edit Store',
                Colors.amber.shade100,
                Colors.amber.shade700,
                () {
                  Navigator.pushNamed(context, AppRoutes.businessInfo);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color backgroundColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}