import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/presentation/providers/auth_provider.dart';
import 'package:unified_storefronts/presentation/providers/seller_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/image_picker.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';
import 'package:unified_storefronts/presentation/widgets/onboarding/step_indicator.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();
  final _phoneController = TextEditingController();
  final _upiIdController = TextEditingController();
  File? _qrCodeImageFile;
  bool _isUpdatingStore = false;

  @override
  void initState() {
    super.initState();
    
    // Pre-fill the WhatsApp number with the user's phone number
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentSeller != null && 
        authProvider.currentSeller!.phoneNumber.isNotEmpty) {
      _whatsappController.text = authProvider.currentSeller!.phoneNumber
          .replaceAll('+', ''); // Remove the '+' prefix
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _instagramController.dispose();
    _phoneController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  // Handle QR code image selection
  void _onQrCodeImageSelected(File file) {
    if (file.path.isEmpty) {
      setState(() {
        _qrCodeImageFile = null;
      });
    } else {
      setState(() {
        _qrCodeImageFile = file;
      });
    }
  }

  // Validate phone number
  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty && value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Update store contact info and complete onboarding
  Future<void> _updateContactInfoAndFinish() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdatingStore = true;
    });

    final authProvider = context.read<AuthProvider>();
    final sellerProvider = context.read<SellerProvider>();

    try {
      // Format phone numbers with country code if not already included
      String whatsappNumber = _whatsappController.text.trim();
      if (whatsappNumber.isNotEmpty && !whatsappNumber.startsWith('+')) {
        whatsappNumber = '+$whatsappNumber';
      }

      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }

      // Update store with contact info
      await sellerProvider.updateStore(
        whatsappNumber: whatsappNumber.isNotEmpty ? whatsappNumber : null,
        instagramHandle: _instagramController.text.isNotEmpty 
            ? _instagramController.text.trim() 
            : null,
        phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
        upiId: _upiIdController.text.isNotEmpty 
            ? _upiIdController.text.trim() 
            : null,
      );

      // Upload QR code image if selected
      if (_qrCodeImageFile != null) {
        // This would typically upload to storage and update the store
        // with the QR code URL, but for simplicity we're omitting that
      }

      // Mark onboarding as complete
      await authProvider.setOnboardingComplete();

      // Navigate to onboarding complete screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingComplete);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final sellerProvider = Provider.of<SellerProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Information'),
      ),
      body: sellerProvider.isLoading || authProvider.isLoading
          ? const LoadingIndicator(message: 'Loading...')
          : _buildContent(sellerProvider),
    );
  }

  Widget _buildContent(SellerProvider sellerProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepIndicator(
                currentStep: 3,
                totalSteps: 3,
                labels: ['Register', 'Business', 'Contact'],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'How can customers reach you?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Add contact details for your customers',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // WhatsApp number
              const Text(
                'WhatsApp Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _whatsappController,
                decoration: const InputDecoration(
                  hintText: 'Enter WhatsApp number',
                  prefixIcon: Icon(FontAwesomeIcons.whatsapp),
                  prefixText: '+',
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Instagram handle
              const Text(
                'Instagram Handle (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  hintText: 'Enter Instagram username',
                  prefixIcon: Icon(Icons.camera_alt),
                  prefixText: '@',
                ),
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 16),
              
              // Phone number
              const Text(
                'Phone Number (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+',
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Payment information
              const Text(
                'Payment Information (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // UPI ID
              const Text(
                'UPI ID',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter your UPI ID',
                  prefixIcon: Icon(Icons.payment),
                ),
                keyboardType: TextInputType.text,
              ),
              
              const SizedBox(height: 16),
              
              // QR Code
              const Text(
                'Payment QR Code (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Upload your payment QR code',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 8),
              
              ImagePickerWidget(
                selectedImageFile: _qrCodeImageFile,
                onImageSelected: _onQrCodeImageSelected,
                height: 180,
                width: 180,
                placeholderText: 'Tap to add QR code',
                icon: Icons.qr_code,
              ),
              
              const SizedBox(height: 32),
              
              // Finish button
              CustomButton(
                text: 'Finish Setup',
                onPressed: _isUpdatingStore ? null : _updateContactInfoAndFinish,
                isLoading: _isUpdatingStore,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}