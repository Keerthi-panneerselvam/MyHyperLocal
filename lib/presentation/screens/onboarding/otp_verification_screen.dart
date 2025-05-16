// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:unified_storefronts/presentation/providers/phone_auth_provider.dart';
//
// class OtpVerificationScreen extends StatefulWidget {
//   const OtpVerificationScreen({Key? key}) : super(key: key);
//
//   @override
//   _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
// }
//
// class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
//   final _phoneController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Phone Verification'),
//       ),
//       body: Consumer<PhoneAuthProvider>(
//         builder: (context, provider, _) {
//           return Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Test Mode Banner
//                   if (provider.isTestPhoneNumber(_phoneController.text))
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       margin: const EdgeInsets.only(bottom: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             '🧪 TEST MODE',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Using test phone number. OTP code will be: ${provider.getTestVerificationCode(_phoneController.text)}',
//                           ),
//                         ],
//                       ),
//                     ),
//
//                   // Phone Number Input
//                   !provider.codeSent
//                       ? TextFormField(
//                     controller: _phoneController,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number',
//                       hintText: '+1234567890',
//                       prefixIcon: Icon(Icons.phone),
//                     ),
//                     keyboardType: TextInputType.phone,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a phone number';
//                       }
//                       return null;
//                     },
//                     onChanged: (_) => setState(() {}),
//                   )
//                       : const SizedBox.shrink(),
//
//                   const SizedBox(height: 20),
//
//                   // OTP Input Field
//                   provider.codeSent
//                       ? TextFormField(
//                     controller: _otpController,
//                     decoration: const InputDecoration(
//                       labelText: 'Verification Code',
//                       hintText: '123456',
//                       prefixIcon: Icon(Icons.lock),
//                     ),
//                     keyboardType: TextInputType.number,
//                     maxLength: 6,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter the verification code';
//                       }
//                       if (value.length < 6) {
//                         return 'Code must be 6 digits';
//                       }
//                       return null;
//                     },
//                   )
//                       : const SizedBox.shrink(),
//
//                   const SizedBox(height: 20),
//
//                   // Error Message
//                   if (provider.errorMessage != null)
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       margin: const EdgeInsets.only(bottom: 20),
//                       decoration: BoxDecoration(
//                         color: Colors.red.shade100,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         provider.errorMessage!,
//                         style: TextStyle(color: Colors.red.shade800),
//                       ),
//                     ),
//
//                   // Submit Button
//                   ElevatedButton(
//                     onPressed: provider.isLoading
//                         ? null
//                         : () {
//                       if (_formKey.currentState!.validate()) {
//                         if (!provider.codeSent) {
//                           provider.sendVerificationCode(_phoneController.text.trim());
//                         } else {
//                           provider.verifyCode(_otpController.text.trim()).then((success) {
//                             if (success) {
//                               // Navigate to next screen on success
//                               Navigator.of(context).pushReplacementNamed('/dashboard');
//                             }
//                           });
//                         }
//                       }
//                     },
//                     child: provider.isLoading
//                         ? const CircularProgressIndicator(
//                       color: Colors.white,
//                     )
//                         : Text(
//                       provider.codeSent ? 'Verify Code' : 'Send Verification Code',
//                     ),
//                   ),
//
//                   // Back Button when code is sent
//                   if (provider.codeSent)
//                     TextButton(
//                       onPressed: provider.isLoading ? null : () => provider.reset(),
//                       child: const Text('Change Phone Number'),
//                     ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }