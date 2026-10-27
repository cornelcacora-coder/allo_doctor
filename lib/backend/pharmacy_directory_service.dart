import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service centralisant l'annuaire des pharmacies réelles inscrites sur la plateforme.
class PharmacyDirectoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Plus aucune pharmacie statique / exemple : seules les vraies pharmacies s'affichent
  static final List<Map<String, dynamic>> defaultPharmacies = [];

  /// Méthode conservée pour compatibilité d'appel, n'insère plus aucun faux exemple
  static Future<void> seedDefaultPharmaciesIfEmpty() async {
    // Ne peuple rien : les pharmacies doivent être créées par les utilisateurs
    return;
  }

  /// Récupère la liste complète et dédupliquée des pharmacies réelles disponibles
  static Future<List<Map<String, dynamic>>> getMergedPharmacies() async {
    final Map<String, Map<String, dynamic>> map = {};

    // 1. Charger depuis Firestore collection 'pharmacies' (exclure les anciens mocks)
    try {
      final snap = await _firestore.collection('pharmacies').get();
      for (final doc in snap.docs) {
        if (doc.id.startsWith('pharma_')) continue; // Ignore les anciens mocks
        final d = doc.data();
        final name = (d['name'] as String?)?.trim() ?? (d['pharmacy_name'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) {
          map[doc.id] = {
            'id': doc.id,
            'name': name,
            'address': (d['address'] as String?) ?? (d['city'] as String?) ?? 'Brazzaville',
            'city': (d['city'] as String?) ?? 'Brazzaville',
            'phone_number': (d['phone_number'] as String?) ?? (d['phone'] as String?) ?? '',
            'phone': (d['phone'] as String?) ?? (d['phone_number'] as String?) ?? '',
            'is_guard': (d['is_guard'] as bool?) ?? false,
            'is_open': (d['is_open'] as bool?) ?? true,
            'is_available': (d['is_available'] as bool?) ?? true,
            'guard_hours': (d['guard_hours'] as String?) ?? (d['hours'] as String?) ?? '08h - 20h',
            'hours': (d['hours'] as String?) ?? (d['guard_hours'] as String?) ?? '08h - 20h',
            'photo_url': (d['photo_url'] as String?) ?? '',
          };
        }
      }
    } catch (_) {}

    // 2. Charger depuis Firestore collection 'users' où role == 'pharmacie'
    try {
      final userSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'pharmacie')
          .get();
      for (final doc in userSnap.docs) {
        if (map.containsKey(doc.id)) continue;
        final d = doc.data();
        final name = (d['name'] as String?)?.trim() ?? (d['nom'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) {
          map[doc.id] = {
            'id': doc.id,
            'name': name,
            'address': (d['address'] as String?) ?? (d['city'] as String?) ?? (d['ville'] as String?) ?? 'Brazzaville',
            'city': (d['city'] as String?) ?? (d['ville'] as String?) ?? 'Brazzaville',
            'phone_number': (d['phone'] as String?) ?? (d['telephone'] as String?) ?? '',
            'phone': (d['phone'] as String?) ?? (d['telephone'] as String?) ?? '',
            'is_guard': (d['is_guard'] as bool?) ?? false,
            'is_open': (d['is_open'] as bool?) ?? true,
            'is_available': (d['is_available'] as bool?) ?? true,
            'guard_hours': '08h00 - 20h00',
            'hours': '08h00 - 20h00',
            'photo_url': (d['photo_url'] as String?) ?? '',
          };
        }
      }
    } catch (_) {}

    return map.values.toList();
  }
}
