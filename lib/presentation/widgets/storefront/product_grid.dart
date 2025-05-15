import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unified_storefronts/data/models/product.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;
  final int crossAxisCount;
  final double childAspectRatio;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        return _buildProductItem(context, products[index]);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onProductTap(product),
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
  }
}