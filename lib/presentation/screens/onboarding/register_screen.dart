import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/config/routes.dart';
import 'package:unified_storefronts/presentation/providers/auth_provider.dart';
import 'package:unified_storefronts/presentation/widgets/common/custom_button.dart';
import 'package:unified_storefronts/presentation/widgets/common/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isPhoneSubmitted = false;
  bool _isOtpComplete = false;
  String? _selectedCountryCode = '+91'; // Default to India
  
  final List<String> _countryCodes = [
    '+91', // India
    '+1',  // USA/Canada
    '+44', // UK
    '+65', // Singapore
    '+971', // UAE
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Handle phone number submission
  Future<void> _submitPhoneNumber() async {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text.trim()}';
      await context.read<AuthProvider>().verifyPhoneNumber(phoneNumber);
      setState(() {
        _isPhoneSubmitted = true;
      });
    }
  }

  // Handle OTP verification
  Future<void> _verifyOtp() async {
    if (_otpController.text.length == 6) {
      final success = await context.read<AuthProvider>().verifyOtpCode(_otpController.text);
      
      if (success && mounted) {
        // Check if onboarding was already completed
        final isOnboardingComplete = await context.read<AuthProvider>().isOnboardingComplete();
        
        if (isOnboardingComplete) {
          // Go to dashboard if onboarding was already completed
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else {
          // Go to business info screen for new users
          Navigator.pushReplacementNamed(context, AppRoutes.businessInfo);
        }
      }
    }
  }

  // Validate phone number
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                
                // App logo
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Welcome text
                const Text(
                  'Welcome to Unified Storefronts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Create your own online store in minutes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Phone number input or OTP input
                if (!_isPhoneSubmitted) 
                  _buildPhoneInput(authProvider)
                else 
                  _buildOtpInput(authProvider),
                
                const SizedBox(height: 24),
                
                // Terms and privacy policy
                const Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter your phone number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Phone number input field with country code
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country code dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCountryCode,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    items: _countryCodes.map((code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountryCode = value;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Phone number field
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  decoration: const InputDecoration(
                    hintText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Submit button
          CustomButton(
            text: 'Continue',
            onPressed: authProvider.isLoading ? null : _submitPhoneNumber,
            isLoading: authProvider.isLoading,
          ),
          
          // Error message
          if (authProvider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              authProvider.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpInput(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter verification code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        const Text(
          'We sent a 6-digit code to your phone number',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // OTP input field
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            hintText: '- - - - - -',
            counterText: '',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (value) {
            setState(() {
              _isOtpComplete = value.length == 6;
            });
            
            if (value.length == 6) {
              _verifyOtp();
            }
          },
        ),
        
        const SizedBox(height: 24),
        
        // Verify button
        CustomButton(
          text: 'Verify',
          onPressed: _isOtpComplete && !authProvider.isLoading ? _verifyOtp : null,
          isLoading: authProvider.isLoading,
        ),
        
        const SizedBox(height: 16),
        
        // Resend OTP button
        TextButton(
          onPressed: authProvider.isLoading
              ? null
              : () {
                  // Reset and resend OTP
                  setState(() {
                    _isPhoneSubmitted = false;
                    _otpController.clear();
                  });
                },
          child: const Text('Change Phone Number'),
        ),
        
        // Error message
        if (authProvider.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            authProvider.errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}