// File generated manually from google-services.json
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBPQXgL1XIAHX44yRcqyHPE9P033aMNg8Q',
    appId: '1:1066069615803:web:49a76711b5133c97f8f59e', // Corrected suffix for web
    messagingSenderId: '1066069615803',
    projectId: 'paymint-44cf1',
    authDomain: 'paymint-44cf1.firebaseapp.com',
    storageBucket: 'paymint-44cf1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPQXgL1XIAHX44yRcqyHPE9P033aMNg8Q',
    appId: '1:1066069615803:android:49a76711b5133c97f8f59e',
    messagingSenderId: '1066069615803',
    projectId: 'paymint-44cf1',
    storageBucket: 'paymint-44cf1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPQXgL1XIAHX44yRcqyHPE9P033aMNg8Q',
    appId: '1:1066069615803:ios:49a76711b5133c97f8f59e',
    messagingSenderId: '1066069615803',
    projectId: 'paymint-44cf1',
    storageBucket: 'paymint-44cf1.firebasestorage.app',
    iosBundleId: 'com.example.paymint',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPQXgL1XIAHX44yRcqyHPE9P033aMNg8Q',
    appId: '1:1066069615803:ios:49a76711b5133c97f8f59e',
    messagingSenderId: '1066069615803',
    projectId: 'paymint-44cf1',
    storageBucket: 'paymint-44cf1.firebasestorage.app',
    iosBundleId: 'com.example.paymint',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBPQXgL1XIAHX44yRcqyHPE9P033aMNg8Q',
    appId: '1:1066069615803:web:49a76711b5133c97f8f59e',
    messagingSenderId: '1066069615803',
    projectId: 'paymint-44cf1',
    authDomain: 'paymint-44cf1.firebaseapp.com',
    storageBucket: 'paymint-44cf1.firebasestorage.app',
  );
}
