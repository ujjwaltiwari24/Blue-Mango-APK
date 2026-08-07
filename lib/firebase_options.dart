import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

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
        return ios;

      default:
        throw UnsupportedError(
          'Firebase is not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDBGddVQn9ctJnGK1llLrK76QNHnYvV0L0",
    appId: "1:440718406293:android:b2e998d90865dd8402e19c",
    messagingSenderId: "440718406293",
    projectId: "bluemango-4b2c1",
    storageBucket: "bluemango-4b2c1.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "YOUR_IOS_API_KEY",
    appId: "YOUR_IOS_APP_ID",
    messagingSenderId: "440718406293",
    projectId: "bluemango-4b2c1",
    storageBucket: "bluemango-4b2c1.firebasestorage.app",
    iosBundleId: "com.bluemango",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCoYqZTHh_rjet97WZlhZe6SuTU4nrxxnI",
    appId: "1:440718406293:web:849eb9d7d2083a9002e19c",
    messagingSenderId: "440718406293",
    projectId: "bluemango-4b2c1",
    authDomain: "bluemango-4b2c1.firebaseapp.com",
    storageBucket: "bluemango-4b2c1.firebasestorage.app",
    measurementId: "G-92B2MR2W3V",
  );
}