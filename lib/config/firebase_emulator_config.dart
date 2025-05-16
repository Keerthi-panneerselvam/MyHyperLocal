import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseEmulatorConfig {
  // Call this method in your main.dart before runApp
  static Future<void> setupEmulators() async {
    if (kDebugMode) {
      try {
        // Use 10.0.2.2 for Android emulator, localhost for web or iOS simulator
        final host = defaultTargetPlatform == TargetPlatform.android
            ? '10.0.2.2'
            : 'localhost';

        await FirebaseAuth.instance.useAuthEmulator(host, 9099);

        print('⚙️ Firebase Auth Emulator connected on $host:9099');

        // You can also add emulator connections for other Firebase services here
        // Example:
        // await FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);

      } catch (e) {
        print('⚠️ Failed to connect to Firebase emulators: $e');
      }
    }
  }
}