import 'package:cloud_firestore/cloud_firestore.dart';

class OrderExpirationService {
  /// Annule automatiquement les commandes dont la création date de plus de 24 heures
  /// et qui n'ont pas encore été livrées (statut non 'delivered' et non 'cancelled').
  static Future<void> checkAndCancelExpiredOrders({
    String? patientUid,
    String? pharmacyId,
  }) async {
    try {
      final now = DateTime.now();
      final threshold = now.subtract(const Duration(hours: 24));
      

      Query query = FirebaseFirestore.instance.collection('orders');

      if (patientUid != null && patientUid.isNotEmpty) {
        query = query.where('patient_uid', isEqualTo: patientUid);
      }
      if (pharmacyId != null && pharmacyId.isNotEmpty) {
        query = query.where('pharmacy_id', isEqualTo: pharmacyId);
      }

      final snapshot = await query.get();
      final batch = FirebaseFirestore.instance.batch();
      bool hasUpdates = false;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final status = (data['status'] as String?) ?? 'pending';

        // Si la commande n'est pas encore livrée ni déjà annulée
        if (status != 'delivered' && status != 'cancelled') {
          final createdAt = data['created_at'];
          DateTime? createdDate;

          if (createdAt is Timestamp) {
            createdDate = createdAt.toDate();
          } else if (createdAt is String) {
            createdDate = DateTime.tryParse(createdAt);
          }

          // Si la commande a été créée il y a plus de 24h
          if (createdDate != null && createdDate.isBefore(threshold)) {
            batch.update(doc.reference, {
              'status': 'cancelled',
              'cancelled_reason': 'Délai de livraison dépassé (plus de 24h sans livraison)',
              'cancelled_at': FieldValue.serverTimestamp(),
              'auto_cancelled': true,
            });
            hasUpdates = true;
          }
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (_) {
      // Ignorer silencieusement pour ne pas bloquer l'interface
    }
  }
}
