
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4RaiDmoanKzwGkFsmKLNZeiUjG9TrMhs',
    appId: '1:997472794504:android:0551dc5b245cbbb34d2c3d',
    messagingSenderId: '997472794504',
    projectId: 'hospitaloptimizationsystem',
    storageBucket: 'hospitaloptimizationsystem.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAAohxiEOoGGNwGhumDfEfIL4xg9sUf7hw',
    appId: '1:997472794504:ios:fc75d625fa7b90614d2c3d',
    messagingSenderId: '997472794504',
    projectId: 'hospitaloptimizationsystem',
    storageBucket: 'hospitaloptimizationsystem.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAAohxiEOoGGNwGhumDfEfIL4xg9sUf7hw',
    appId: '1:997472794504:ios:fc75d625fa7b90614d2c3d',
    messagingSenderId: '997472794504',
    projectId: 'hospitaloptimizationsystem',
    storageBucket: 'hospitaloptimizationsystem.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBtGUURF2X7L4OwHWtdxE_opOdSeYIGlLA',
    appId: '1:997472794504:web:b3080fcf6670bd6f4d2c3d',
    messagingSenderId: '997472794504',
    projectId: 'hospitaloptimizationsystem',
    authDomain: 'hospitaloptimizationsystem.firebaseapp.com',
    storageBucket: 'hospitaloptimizationsystem.firebasestorage.app',
    measurementId: 'G-FH0W9V9W9R',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBtGUURF2X7L4OwHWtdxE_opOdSeYIGlLA',
    appId: '1:997472794504:web:b3080fcf6670bd6f4d2c3d',
    messagingSenderId: '997472794504',
    projectId: 'hospitaloptimizationsystem',
    authDomain: 'hospitaloptimizationsystem.firebaseapp.com',
    storageBucket: 'hospitaloptimizationsystem.firebasestorage.app',
    measurementId: 'G-FH0W9V9W9R',
  );
}
