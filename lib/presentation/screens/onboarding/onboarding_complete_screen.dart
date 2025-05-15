import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key});

  Future<void> _launchStoreUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // Copy the store URL to clipboard
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Store link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Share the store URL
  Future<void> _shareStoreUrl(String url) async {
    try {
      final Uri uri = Uri.parse('https://wa.me/?text=Check out my online store: $url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error sharing URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerProvider = Provider.of<SellerProvider>(context);
    
    return WillPopScope(
      onWillPop: () async => false, // Prevent going back
      child: Scaffold(
        body: sellerProvider.isLoading || sellerProvider.currentStore == null
            ? const LoadingIndicator(message: 'Loading your store...')
            : _buildContent(context, sellerProvider),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SellerProvider sellerProvider) {
    final store = sellerProvider.currentStore!;
    final storeUrl = store.storefrontUrl;
    
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green.shade600,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Congratulations text
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Your store "${store.name}" is now online',
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Store URL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        storeUrl,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(context, storeUrl),
                      tooltip: 'Copy link',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Visit store button
              CustomButton(
                text: 'Visit Your Store',
                icon: Icons.open_in_browser,
                onPressed: () => _launchStoreUrl(storeUrl),
              ),
              
              const SizedBox(height: 16),
              
              // Share store button
              CustomButton(
                text: 'Share on WhatsApp',
                icon: Icons.share,
                isOutlined: true,
                onPressed: () => _shareStoreUrl(storeUrl),
              ),
              
              const SizedBox(height: 16),
              
              // Go to dashboard button
              CustomButton(
                text: 'Go to Dashboard',
                backgroundColor: Colors.grey.shade800,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
                },
              ),
              
              const Spacer(),
              
              // Help text
              const Text(
                'Need help? Contact our support team',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}