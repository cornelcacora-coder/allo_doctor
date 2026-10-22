import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ",
            authDomain: "allo-doctor-app.firebaseapp.com",
            projectId: "allo-doctor-app",
            storageBucket: "allo-doctor-app.firebasestorage.app",
            messagingSenderId: "766343053778",
            appId: "1:766343053778:web:cef082b2c9be395024880b",
            measurementId: "G-0FLHRX36KD"));
  } else {
    await Firebase.initializeApp();
  }
}
