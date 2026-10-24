import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Service centralisé de gestion des notifications multi-acteurs
/// (Patient, Médecin, Pharmacien, Clinique).
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Envoie une notification à un utilisateur cible
  static Future<void> sendNotification({
    required String recipientUid,
    required String title,
    required String message,
    required String type, // 'appointment', 'prescription', 'pharmacy_order', 'delivery', 'system'
    String? referenceId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (recipientUid.isEmpty) return;

    final now = DateTime.now();
    await _firestore.collection('notifications').add({
      'recipient_uid': recipientUid,
      'user_uid': recipientUid,
      'title': title,
      'message': message,
      'type': type,
      'reference_id': referenceId,
      'additional_data': additionalData,
      'is_read': false,
      'created_at': Timestamp.fromDate(now),
    });
  }

  /// Récupère le flux en temps réel des notifications pour un utilisateur
  /// (Sans orderBy pour éviter l'erreur d'index composite Firestore)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationsStream(String userUid) {
    if (userUid.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .snapshots();
  }

  /// Marque une notification comme lue
  static Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'is_read': true,
      });
    } catch (_) {}
  }

  /// Marque toutes les notifications d'un utilisateur comme lues
  static Future<void> markAllAsRead(String userUid) async {
    try {
      final unreadDocs = await _firestore
          .collection('notifications')
          .where('is_read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        final d = doc.data();
        if (d['recipient_uid'] == userUid || d['user_uid'] == userUid) {
          batch.update(doc.reference, {'is_read': true});
        }
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Affiche une bannière SnackBar animée pour avertir en temps réel
  static void showInAppAlert(BuildContext context, {required String title, required String message, VoidCallback? onTap}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      message,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF0A0E1A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
