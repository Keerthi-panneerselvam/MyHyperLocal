// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
//
// class PhoneAuthProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String? _verificationId;
//   int? _resendToken;
//   String? _errorMessage;
//   bool _isLoading = false;
//   bool _codeSent = false;
//
//   bool get isLoading => _isLoading;
//   bool get codeSent => _codeSent;
//   String? get errorMessage => _errorMessage;
//
//   // For testing purposes - in a real app you might want to hide this
//   // behind a feature flag or only enable in debug mode
//   final bool _isTestMode = kDebugMode;
//
//   // Test phone numbers that will automatically work with Firebase Auth
//   final List<String> _testPhoneNumbers = [
//     '+16505551234', // Always sends 123456 as the code
//     '+16505556789', // Always sends 654321 as the code
//   ];
//
//   // This method will tell you if a phone number is a test number
//   bool isTestPhoneNumber(String phoneNumber) {
//     return _testPhoneNumbers.contains(phoneNumber);
//   }
//
//   // Get the automatic code for a test phone number
//   String? getTestVerificationCode(String phoneNumber) {
//     if (phoneNumber == '+16505551234') return '123456';
//     if (phoneNumber == '+16505556789') return '654321';
//     return null;
//   }
//
//   // Reset the state
//   void reset() {
//     _verificationId = null;
//     _resendToken = null;
//     _errorMessage = null;
//     _isLoading = false;
//     _codeSent = false;
//     notifyListeners();
//   }
//
//   // Send verification code
//   Future<void> sendVerificationCode(String phoneNumber) async {
//     try {
//       _isLoading = true;
//       _errorMessage = null;
//       notifyListeners();
//
//       // Display test mode information if applicable
//       if (_isTestMode && isTestPhoneNumber(phoneNumber)) {
//         debugPrint('📱 TESTING: Using test phone number');
//         debugPrint('📱 TESTING: The OTP code will be: ${getTestVerificationCode(phoneNumber)}');
//       }
//
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           // This callback will be triggered on Android devices
//           // that support automatic SMS code verification
//           _isLoading = false;
//           notifyListeners();
//           await _auth.signInWithCredential(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           _isLoading = false;
//           _errorMessage = e.message ?? 'Verification failed';
//           notifyListeners();
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           _verificationId = verificationId;
//           _resendToken = resendToken;
//           _isLoading = false;
//           _codeSent = true;
//           notifyListeners();
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//           notifyListeners();
//         },
//         // You can optionally set a timeout for code sending
//         timeout: const Duration(seconds: 60),
//       );
//     } catch (e) {
//       _isLoading = false;
//       _errorMessage = e.toString();
//       notifyListeners();
//     }
//   }
//
//   // Verify the OTP code
//   Future<bool> verifyCode(String smsCode) async {
//     try {
//       _isLoading = true;
//       _errorMessage = null;
//       notifyListeners();
//
//       if (_verificationId == null) {
//         _errorMessage = 'Verification ID is null. Please request a code first.';
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//
//       // Create a PhoneAuthCredential with the provided code
//       // Use the correct method to create the credential
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: smsCode,
//       );
//
//       // Sign in the user with the credential
//       await _auth.signInWithCredential(credential);
//
//       _isLoading = false;
//       _codeSent = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _isLoading = false;
//       if (e is FirebaseAuthException) {
//         _errorMessage = e.message ?? 'Code verification failed';
//       } else {
//         _errorMessage = e.toString();
//       }
//       notifyListeners();
//       return false;
//     }
//   }
// }