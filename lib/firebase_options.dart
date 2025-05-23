// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB-Hq_LwkWT_Sm7Ib09peqwlyYp4LfMj6Y',
    appId: '1:728005317641:web:775ef2abeaf8b133e5d4d8',
    messagingSenderId: '728005317641',
    projectId: 'myhyperlocal-f5dac',
    authDomain: 'myhyperlocal-f5dac.firebaseapp.com',
    storageBucket: 'myhyperlocal-f5dac.firebasestorage.app',
    measurementId: 'G-KES1JQ4E8D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCMnVzmLJ5U-IJDRyCtNfcDb6Sx5p4MsfI',
    appId: '1:728005317641:android:2d3b3472ecfdfd56e5d4d8',
    messagingSenderId: '728005317641',
    projectId: 'myhyperlocal-f5dac',
    storageBucket: 'myhyperlocal-f5dac.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAPKsDndzV-e9GJkU7NHv4y6www-Uh5iIw',
    appId: '1:728005317641:ios:cb37839d0b8d980ce5d4d8',
    messagingSenderId: '728005317641',
    projectId: 'myhyperlocal-f5dac',
    storageBucket: 'myhyperlocal-f5dac.firebasestorage.app',
    iosBundleId: 'com.example.myhyperlocal',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAPKsDndzV-e9GJkU7NHv4y6www-Uh5iIw',
    appId: '1:728005317641:ios:cb37839d0b8d980ce5d4d8',
    messagingSenderId: '728005317641',
    projectId: 'myhyperlocal-f5dac',
    storageBucket: 'myhyperlocal-f5dac.firebasestorage.app',
    iosBundleId: 'com.example.myhyperlocal',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB-Hq_LwkWT_Sm7Ib09peqwlyYp4LfMj6Y',
    appId: '1:728005317641:web:7cd980e87d31b1fbe5d4d8',
    messagingSenderId: '728005317641',
    projectId: 'myhyperlocal-f5dac',
    authDomain: 'myhyperlocal-f5dac.firebaseapp.com',
    storageBucket: 'myhyperlocal-f5dac.firebasestorage.app',
    measurementId: 'G-99G4EJ2QCC',
  );
}
