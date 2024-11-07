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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCGeQo6NCHhnvkFFUXdlXmT-hHH6aoJ4gE',
    appId: '1:989988877327:web:90c827c2e714e4407e5f7a',
    messagingSenderId: '989988877327',
    projectId: 'panda-flix-e2f69',
    authDomain: 'panda-flix-e2f69.firebaseapp.com',
    storageBucket: 'panda-flix-e2f69.firebasestorage.app',
    measurementId: 'G-GTQ1MDL782',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8wWcakHAFGXAJootKLcUJAIJtjoeoUUM',
    appId: '1:989988877327:android:4f379ec89aaa5d0f7e5f7a',
    messagingSenderId: '989988877327',
    projectId: 'panda-flix-e2f69',
    storageBucket: 'panda-flix-e2f69.firebasestorage.app',
  );
}
