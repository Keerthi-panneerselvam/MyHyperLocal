import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/data/models/product.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;

  // Filter options
  final List<String> _filterOptions = [
    'All',
    'In Stock',
    'Out of Stock',
    'Featured',
  ];

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  // Refresh products
  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      if (sellerProvider.currentStore != null) {
        await productsProvider.loadStoreProducts(sellerProvider.currentStore!.id);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Filter products based on search query and filter option
  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      // Apply status filter
      bool matchesFilter;
      switch (_selectedFilter) {
        case 'In Stock':
          matchesFilter = product.inStock;
          break;
        case 'Out of Stock':
          matchesFilter = !product.inStock;
          break;
        case 'Featured':
          matchesFilter = product.isFeatured;
          break;
        default: // 'All'
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // Toggle product in stock status
  Future<void> _toggleProductInStock(String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      await productsProvider.toggleProductInStock(productId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Delete product
  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
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
        _isLoading = true;
      });

      try {
        final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
        await productsProvider.deleteProduct(product.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete product: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    final allProducts = productsProvider.products;
    final filteredProducts = _getFilteredProducts(allProducts);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading || productsProvider.isLoading
          ? const LoadingIndicator(message: 'Loading products...')
          : Column(
              children: [
                // Search bar and filter
                _buildSearchAndFilter(),
                
                // Product count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredProducts.length} products found',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedFilter = 'All';
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                    ],
                  ),
                ),
                
                // No products message
                if (allProducts.isEmpty)
                  _buildNoProductsMessage()
                // No search results message
                else if (filteredProducts.isEmpty)
                  _buildNoSearchResultsMessage()
                // Product list
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return _buildProductItem(filteredProducts[index]);
                        },
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addProduct)
              .then((_) => _refreshProducts());
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filter options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No products yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first product to start selling',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addProduct);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsMessage() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matching products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.editProduct,
            arguments: product.id,
          ).then((_) => _refreshProducts());
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: SizedBox(
                height: 180,
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
                            size: 32,
                            color: Colors.red,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product price
                  Text(
                    product.formattedPrice('₹'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Product description
                  if (product.description != null && product.description!.isNotEmpty)
                    Text(
                      product.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Product tags
                  if (product.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stock status toggle
                      OutlinedButton.icon(
                        onPressed: () => _toggleProductInStock(product.id),
                        icon: Icon(
                          product.inStock ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: product.inStock ? Colors.green : Colors.red,
                        ),
                        label: Text(
                          product.inStock ? 'In Stock' : 'Out of Stock',
                          style: TextStyle(
                            color: product.inStock ? Colors.green : Colors.red,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: product.inStock ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      
                      Row(
                        children: [
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.editProduct,
                                arguments: product.id,
                              ).then((_) => _refreshProducts());
                            },
                          ),
                          
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            color: Colors.red,
                            onPressed: () => _deleteProduct(context, product),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}