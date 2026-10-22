import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/index.dart';

/// Roles applicatifs de l'app mobile.
/// Le role 'admin' n'existe que dans la console web.
const kAppRoles = ['patient', 'medecin', 'pharmacie', 'clinique'];

/// Route d'accueil correspondant a un role.
String homeRouteForRole(String? role) {
  switch (role) {
    case 'medecin':
      return HomeDoctorWidget.routeName;
    case 'pharmacie':
      return HomePharmacyWidget.routeName;
    case 'clinique':
      return HomeCliniqueWidget.routeName;
    default:
      return HomeHubWidget.routeName;
  }
}

/// Libelle lisible d'un role.
String roleLabel(String? role) {
  switch (role) {
    case 'medecin':
      return 'médecin';
    case 'pharmacie':
      return 'pharmacie';
    case 'clinique':
      return 'clinique';
    default:
      return 'patient';
  }
}

/// Lit le role de l'utilisateur connecte (null si inconnu / illisible).
///
/// Le profil Firestore fait foi. En complement, un dossier d'agrement
/// VALIDE dans 'practitioners' prime sur un role 'patient' heredite : c'est
/// l'administration qui active l'accès d'un praticien.
Future<String?> currentUserRole() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;

  String? role;
  try {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = snap.data();
    if (data != null) {
      final value = (data['role'] ?? data['userCategory'] ?? '').toString();
      if (value.isNotEmpty) role = value;
    }
  } catch (_) {
    role = null;
  }

  if (role == null || role == 'patient') {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('practitioners')
          .doc(uid)
          .get();
      final data = snap.data();
      if (snap.exists && data != null) {
        final status = (data['status'] ?? '').toString();
        if (status == 'validé' || status == 'valide') {
          final type = (data['type'] ?? '').toString();
          if (kAppRoles.contains(type) && type != 'patient') role = type;
        }
      }
    } catch (_) {
      // Dossier illisible : on conserve le role du profil.
    }
  }

  return role;
}

/// L'utilisateur connecte a-t-il le role attendu ?
/// Le role provient du profil Firestore (que les regles rendent immuable
/// pour son proprietaire) : il ne peut pas etre usurpe depuis l'URL.
/// Un administrateur passe partout.
Future<bool> hasRole(String expectedRole) async {
  final role = await currentUserRole();
  if (role == null) return false;
  if (role == 'admin') return true;
  return role == expectedRole;
}

/// Redirige l'utilisateur vers l'accueil correspondant a son role.
Future<void> redirectToOwnHome(BuildContext context) async {
  final role = await currentUserRole();
  if (!context.mounted) return;
  context.goNamed(homeRouteForRole(role));
}

/// Verifie l'acces a un espace de role.
/// Retourne true si l'acces est autorise. Sinon, l'utilisateur est
/// redirige vers son propre accueil et la fonction retourne false.
Future<bool> guardRole(BuildContext context, String expectedRole) async {
  final role = await currentUserRole();
  // Un administrateur n'est pas bloque par un garde-fou de role.
  if (role == expectedRole || role == 'admin') return true;

  if (!context.mounted) return false;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Cet espace est réservé aux comptes ${roleLabel(expectedRole)}. '
        'Vous êtes connecté en tant que ${roleLabel(role)}.',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xFF14563C),
    ),
  );

  context.goNamed(homeRouteForRole(role));
  return false;
}
