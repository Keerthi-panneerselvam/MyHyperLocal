import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_storefronts/config/constants.dart';
import 'package:unified_storefronts/data/models/seller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Phone number authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Sign in with phone auth credential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  // Create new seller in Firestore
  Future<Seller> createSeller(User user) async {
    final seller = Seller(
      id: user.uid,
      phoneNumber: user.phoneNumber ?? '',
    );

    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(user.uid)
        .set(seller.toMap());

    return seller;
  }

  // Get seller from Firestore
  Future<Seller?> getSeller(String sellerId) async {
    final doc = await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(sellerId)
        .get();

    if (doc.exists) {
      return Seller.fromMap(doc.data() as Map<String, dynamic>);
    }
    
    return null;
  }

  // Update seller information
  Future<void> updateSeller(Seller seller) async {
    await _firestore
        .collection(AppConstants.sellersCollection)
        .doc(seller.id)
        .update(seller.toMap());
  }

  // Sign out
  Future<void> signOut() async {
    // Clear stored auth token and user ID
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.onboardingCompleteKey);
    
    // Sign out from Firebase
    await _auth.signOut();
  }
  
  // Get user auth data from SharedPreferences
  Future<String?> getSavedAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.authTokenKey);
  }
  
  // Save user auth data to SharedPreferences
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.authTokenKey, token);
  }
  
  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingCompleteKey) ?? false;
  }
  
  // Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingCompleteKey, true);
    
    if (currentUserId != null) {
      final seller = await getSeller(currentUserId!);
      if (seller != null) {
        await updateSeller(seller.copyWith(isOnboardingComplete: true));
      }
    }
  }
}