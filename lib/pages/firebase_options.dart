import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get web => FirebaseOptions(
        apiKey: "AIzaSyDGsglItoDG47Y0ee6MeqriLyQOBYHGCgw",
  authDomain: "carlease-agreement.firebaseapp.com",
  projectId: "carlease-agreement",
  storageBucket: "carlease-agreement.firebasestorage.app",
  messagingSenderId: "759308330363",
  appId: "1:759308330363:web:c7e168abbee44722fb09de",
  measurementId: "G-GJSR4KEGE3"
      );

  static FirebaseOptions get currentPlatform => web;
}
