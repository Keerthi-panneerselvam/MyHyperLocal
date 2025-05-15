import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unified_storefronts/data/models/store.dart';

class StoreHeader extends StatelessWidget {
  final Store store;
  final VoidCallback? onShare;

  const StoreHeader({
    super.key,
    required this.store,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store info row
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
                          image: CachedNetworkImageProvider(store.logoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
              
              // Store details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store name and share button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onShare != null)
                          IconButton(
                            onPressed: onShare,
                            icon: const Icon(Icons.share),
                            tooltip: 'Share Store',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Store category
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
          
          // Store description
          if (store.description != null && store.description!.isNotEmpty) ...[
            Text(
              store.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 16),
          ],
          
          // Store tags
          if (store.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: store.tags.map((tag) {
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
          ],
        ],
      ),
    );
  }
}