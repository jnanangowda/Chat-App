import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKdjX2DAcgT_yklBZdTe9D6hIbQAiE-vc',
    appId: '1:907954904111:android:f4245d78b8d46b898fbada',
    messagingSenderId: '907954904111',
    projectId: 'chatapp-81c13',
    storageBucket: 'chatapp-81c13.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKdjX2DAcgT_yklBZdTe9D6hIbQAiE-vc',
    appId: '1:907954904111:ios:f4245d78b8d46b898fbada',
    messagingSenderId: '907954904111',
    projectId: 'chatapp-81c13',
    storageBucket: 'chatapp-81c13.firebasestorage.app',
    iosBundleId: 'com.example.professionalchatapp',
  );
}
