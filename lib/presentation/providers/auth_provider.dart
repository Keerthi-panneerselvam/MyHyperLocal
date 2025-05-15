import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unified_storefronts/core/services/auth_service.dart';
import 'package:unified_storefronts/data/models/seller.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // State variables
  Seller? _currentSeller;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  String? _errorMessage;
  
  // Getters
  Seller? get currentSeller => _currentSeller;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get userId => _authService.currentUserId;
  String? get errorMessage => _errorMessage;
  bool get hasVerificationId => _verificationId != null;
  
  // Constructor
  AuthProvider() {
    // Try to load the current user on initialization
    _loadCurrentUser();
  }
  
  // Load current user from auth service
  Future<void> _loadCurrentUser() async {
    _setLoading(true);
    
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        _currentSeller = await _authService.getSeller(userId);
      }
    } catch (e) {
      _setErrorMessage('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Verify phone number
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearErrorMessage();
    
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (usually on Android)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setErrorMessage('Verification failed: ${e.message}');
          _setLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setErrorMessage('Failed to send verification code: $e');
      _setLoading(false);
    }
  }
  
  // Verify OTP code
  Future<bool> verifyOtpCode(String otpCode) async {
    if (_verificationId == null) {
      _setErrorMessage('No verification ID found. Please request a new code.');
      return false;
    }
    
    _setLoading(true);
    _clearErrorMessage();
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      
      final success = await _signInWithCredential(credential);
      return success;
    } catch (e) {
      _setErrorMessage('Invalid verification code: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign in with credential
  Future<bool> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _authService.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Check if seller exists
        _currentSeller = await _authService.getSeller(user.uid);
        
        // If not, create a new seller
        if (_currentSeller == null) {
          _currentSeller = await _authService.createSeller(user);
        }
        
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setErrorMessage('Failed to sign in');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Authentication failed: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
      _currentSeller = null;
    } catch (e) {
      _setErrorMessage('Failed to sign out: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    return await _authService.isOnboardingComplete();
  }
  
  // Set onboarding as complete
  Future<void> setOnboardingComplete() async {
    await _authService.setOnboardingComplete();
    
    if (_currentSeller != null) {
      _currentSeller = _currentSeller!.copyWith(isOnboardingComplete: true);
      notifyListeners();
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}