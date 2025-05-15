import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/presentation/providers/products_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:intl/intl.dart';

class StoreAnalyticsScreen extends StatefulWidget {
  const StoreAnalyticsScreen({super.key});

  @override
  State<StoreAnalyticsScreen> createState() => _StoreAnalyticsScreenState();
}

class _StoreAnalyticsScreenState extends State<StoreAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> _productAnalytics = {};
  String _selectedTimeFrame = 'Last 30 days';
  List<String> _mostViewedProductIds = [];
  
  final List<String> _timeFrameOptions = [
    'Last 7 days',
    'Last 30 days',
    'Last 90 days',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  // Load analytics data
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sellerProvider = Provider.of<SellerProvider>(context, listen: false);
      final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
      
      // Calculate date range based on selected time frame
      DateTime startDate;
      final now = DateTime.now();
      
      switch (_selectedTimeFrame) {
        case 'Last 7 days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Last 30 days':
          startDate = now.subtract(const Duration(days: 30));
          break;
        case 'Last 90 days':
          startDate = now.subtract(const Duration(days: 90));
          break;
        case 'All time':
        default:
          startDate = now.subtract(const Duration(days: 365 * 10)); // Very far back
          break;
      }
      
      // Get analytics for date range
      _analytics = await sellerProvider.getStoreAnalytics(
        startDate: startDate,
        endDate: now,
      );
      
      // Process product views
      if (_analytics.containsKey('productViewsMap')) {
        _productAnalytics = _analytics['productViewsMap'] as Map<String, dynamic>;
        
        // Sort product IDs by view count
        _mostViewedProductIds = _productAnalytics.keys.toList()
          ..sort((a, b) => (_productAnalytics[b] as int).compareTo(_productAnalytics[a] as int));
        
        // Limit to top 5
        if (_mostViewedProductIds.length > 5) {
          _mostViewedProductIds = _mostViewedProductIds.sublist(0, 5);
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error loading analytics: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading analytics...')
          : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    final pageViews = _analytics['totalViews'] ?? 0;
    final uniqueVisitors = _analytics['uniqueVisitors'] ?? 0;
    final productViews = _analytics['productViews'] ?? 0;
    final contactClicks = _analytics['contactClicks'] ?? 0;
    final shareCount = _analytics['shareCount'] ?? 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time frame selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTimeFrame,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _timeFrameOptions.map((timeFrame) {
                      return DropdownMenuItem<String>(
                        value: timeFrame,
                        child: Text(timeFrame),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTimeFrame = value;
                        });
                        _loadAnalytics();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Overview stats
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Views',
                pageViews.toString(),
                Icons.visibility,
                Colors.blue,
              ),
              _buildStatCard(
                'Unique Visitors',
                uniqueVisitors.toString(),
                Icons.person,
                Colors.green,
              ),
              _buildStatCard(
                'Product Views',
                productViews.toString(),
                Icons.shopping_bag,
                Colors.purple,
              ),
              _buildStatCard(
                'Contact Actions',
                contactClicks.toString(),
                Icons.phone,
                Colors.amber,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Daily visitors chart
          if (_analytics.containsKey('visitorsByDate') && 
              (_analytics['visitorsByDate'] as Map<String, dynamic>).isNotEmpty) ...[
            const Text(
              'Visitor Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildVisitorTrendsCard(),
            
            const SizedBox(height: 16),
          ],
          
          // Top products
          if (_mostViewedProductIds.isNotEmpty) ...[
            const Text(
              'Top Viewed Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildTopProductsCard(),
            
            const SizedBox(height: 16),
          ],
          
          // Contact analytics
          const Text(
            'Contact Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          _buildContactAnalyticsCard(),
          
          const SizedBox(height: 24),
          
          // Tips card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tips to Increase Visibility',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Add high-quality product images',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Write detailed product descriptions',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Use relevant tags for better discovery',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Share your store link on social media',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Regularly update product availability',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorTrendsCard() {
    final visitorsByDate = _analytics['visitorsByDate'] as Map<String, dynamic>;
    
    // Sort dates
    final sortedDates = visitorsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    // Format dates for display
    final dateFormatter = DateFormat('MMM d');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // For a real chart, you would use a charting library like fl_chart or charts_flutter
            // Here we'll use a simplified representation
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final count = visitorsByDate[date] as int;
                  final maxCount = visitorsByDate.values
                      .map((v) => v as int)
                      .reduce((a, b) => a > b ? a : b);
                  
                  // Calculate bar height (80% of container height maximum)
                  final barHeight = maxCount > 0 
                      ? (count / maxCount) * 160 
                      : 0.0;
                  
                  // Parse date string
                  final dateObj = DateTime.parse(date);
                  final formattedDate = dateFormatter.format(dateObj);
                  
                  return Container(
                    width: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsCard() {
    final productsProvider = Provider.of<ProductsProvider>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mostViewedProductIds.length,
              itemBuilder: (context, index) {
                final productId = _mostViewedProductIds[index];
                final viewCount = _productAnalytics[productId] as int;
                
                // Try to find product in loaded products
                final product = productsProvider.products.firstWhere(
                  (p) => p.id == productId,
                  orElse: () => null,
                );
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    product?.name ?? 'Product $productId',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('$viewCount views'),
                  trailing: Text(
                    product?.formattedPrice('₹') ?? '',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAnalyticsCard() {
    final whatsappClicks = _analytics['whatsappClicks'] ?? 0;
    final instagramClicks = _analytics['instagramClicks'] ?? 0;
    final phoneClicks = _analytics['phoneClicks'] ?? 0;
    final totalContactClicks = _analytics['contactClicks'] ?? 0;
    
    // Calculate percentages
    double whatsappPercentage = totalContactClicks > 0 
        ? (whatsappClicks / totalContactClicks) * 100 
        : 0;
    double instagramPercentage = totalContactClicks > 0 
        ? (instagramClicks / totalContactClicks) * 100 
        : 0;
    double phonePercentage = totalContactClicks > 0 
        ? (phoneClicks / totalContactClicks) * 100 
        : 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact method breakdown
            _buildContactMethodItem(
              'WhatsApp',
              whatsappClicks,
              whatsappPercentage,
              Icons.chat,
              Colors.green,
            ),
            
            const SizedBox(height: 12),
            
            _buildContactMethodItem(
              'Instagram',
              instagramClicks,
              instagramPercentage,
              Icons.camera_alt,
              Colors.purple,
            ),
            
            const SizedBox(height: 12),
            
            _buildContactMethodItem(
              'Phone Call',
              phoneClicks,
              phonePercentage,
              Icons.phone,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethodItem(
    String label,
    int count,
    double percentage,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$count clicks',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}