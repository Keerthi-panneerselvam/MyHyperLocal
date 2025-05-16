import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseWebConfig {
  static void setupRecaptcha() {
    if (kIsWeb) {
      FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: false, // Set to true for testing only
      );
    }
  }
}