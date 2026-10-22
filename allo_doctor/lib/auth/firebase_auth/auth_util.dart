import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth get _auth => FirebaseAuth.instance;

User? get currentUser => _auth.currentUser;

bool get loggedIn => currentUser != null;

String get currentUserUid => currentUser?.uid ?? '';

String get currentUserEmail => currentUser?.email ?? '';

String get currentUserDisplayName => currentUser?.displayName ?? '';

String get currentUserPhoto => currentUser?.photoURL ?? '';

DocumentReference? get currentUserReference => loggedIn
    ? FirebaseFirestore.instance.collection('users').doc(currentUserUid)
    : null;

