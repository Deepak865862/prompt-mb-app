import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC-38FKVGtTKxV1NsntXZ7YEbRl2E--_KQ",
    authDomain: "prompt-mb.firebaseapp.com",
    projectId: "prompt-mb",
    storageBucket: "prompt-mb.firebasestorage.app",
    messagingSenderId: "416016003294",
    appId: "1:416016003294:web:7b9903302c4484162c124f",
  );
}