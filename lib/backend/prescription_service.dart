import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service pour la gestion des ordonnances, des identifiants uniques patients,
/// et du cycle de vie des commandes en pharmacie (avec livraison).
class PrescriptionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Génère ou récupère l'identifiant unique permanent du patient (ex: ALLO-PAT-73892)
  static Future<String> getOrCreatePatientId(String uid, {String? displayName}) async {
    if (uid.isEmpty) return 'ALLO-PAT-00000';

    try {
      final userDoc = await _firestore.collection('User').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['patient_id'] != null && data['patient_id'].toString().isNotEmpty) {
          return data['patient_id'].toString();
        }
      }

      // Génération d'un identifiant unique permanent court et mémorisable
      final hash = uid.hashCode.abs().toString().padLeft(6, '0');
      final uniqueId = 'ALLO-PAT-${hash.substring(0, hash.length > 6 ? 6 : hash.length)}';

      // Sauvegarde dans le document utilisateur pour le rendre immuable
      await _firestore.collection('User').doc(uid).set({
        'patient_id': uniqueId,
      }, SetOptions(merge: true));

      return uniqueId;
    } catch (e) {
      debugPrint('Erreur génération patient_id: $e');
      final fallbackHash = uid.hashCode.abs().toString().padLeft(5, '0');
      return 'ALLO-PAT-${fallbackHash.substring(0, 5)}';
    }
  }

  /// Crée une nouvelle ordonnance avec signature électronique et type
  static Future<DocumentReference> createPrescription({
    required String patientUid,
    required String patientName,
    required String patientId,
    required String doctorUid,
    required String doctorName,
    required String doctorSpecialty,
    required List<Map<String, dynamic>> medications,
    required String notes,
    required bool isMandatory, // true: strict/non-substituable, false: équivalents autorisés
    required String doctorSignature, // Nom + date + empreinte certifiée
  }) async {
    final now = DateTime.now();
    final prescriptionRef = _firestore.collection('prescriptions').doc();

    // Données pour le QR code
    final qrData = 'ALLO-DOC-PRESCRIPTION|ID:${prescriptionRef.id}|PAT:$patientId|$patientName|DOC:$doctorName|TYPE:${isMandatory ? 'STRICT' : 'EQUIVALENT'}|DATE:${now.toIso8601String()}';

    final data = {
      'prescription_id': prescriptionRef.id,
      'patient_ref': _firestore.collection('User').doc(patientUid),
      'patient_uid': patientUid,
      'patient_name': patientName,
      'patient_id': patientId,
      'doctor_ref': _firestore.collection('User').doc(doctorUid),
      'doctor_uid': doctorUid,
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'medications': medications,
      'notes': notes,
      'is_mandatory': isMandatory,
      'prescription_type': isMandatory ? 'STRICT (Non substituable)' : 'ÉQUIVALENT AUTORISÉ (Génériques acceptés)',
      'doctor_signature': doctorSignature,
      'signature_timestamp': Timestamp.fromDate(now),
      'qr_code_data': qrData,
      'status': 'active', // active, sent_to_pharmacy, in_preparation, ready, out_for_delivery, delivered
      'pharmacy_ref': null,
      'pharmacy_name': null,
      'delivery_type': null, // pickup, delivery
      'delivery_address': null,
      'delivery_phone': null,
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
    };

    await prescriptionRef.set(data);

    // Envoi d'une notification pour le patient
    await _firestore.collection('notifications').add({
      'user_uid': patientUid,
      'title': 'Nouvelle ordonnance disponible',
      'message': 'Le Dr. $doctorName a émis une ordonnance pour vous.',
      'type': 'prescription',
      'reference_id': prescriptionRef.id,
      'created_at': Timestamp.fromDate(now),
      'is_read': false,
    });

    return prescriptionRef;
  }

  /// Le patient transmet l'ordonnance à une pharmacie avec option retrait ou livraison
  static Future<void> sendToPharmacy({
    required String prescriptionId,
    required String pharmacyUid,
    required String pharmacyName,
    required String deliveryType, // 'pickup' ou 'delivery'
    String? deliveryAddress,
    String? deliveryPhone,
  }) async {
    final now = DateTime.now();
    final docRef = _firestore.collection('prescriptions').doc(prescriptionId);

    await docRef.update({
      'pharmacy_ref': _firestore.collection('User').doc(pharmacyUid),
      'pharmacy_uid': pharmacyUid,
      'pharmacy_name': pharmacyName,
      'delivery_type': deliveryType,
      'delivery_address': deliveryAddress,
      'delivery_phone': deliveryPhone,
      'status': 'sent_to_pharmacy',
      'updated_at': Timestamp.fromDate(now),
    });

    // Notification pour la pharmacie
    await _firestore.collection('notifications').add({
      'user_uid': pharmacyUid,
      'title': 'Nouvelle ordonnance reçue',
      'message': 'Un patient vous a transmis une ordonnance (${deliveryType == 'delivery' ? 'Option Livraison' : 'Retrait en pharmacie'}).',
      'type': 'pharmacy_order',
      'reference_id': prescriptionId,
      'created_at': Timestamp.fromDate(now),
      'is_read': false,
    });
  }

  /// La pharmacie met à jour l'état de la commande
  static Future<void> updateOrderStatus({
    required String prescriptionId,
    required String newStatus, // 'in_preparation', 'ready', 'out_for_delivery', 'delivered'
    required String patientUid,
    String? messageForPatient,
  }) async {
    final now = DateTime.now();
    await _firestore.collection('prescriptions').doc(prescriptionId).update({
      'status': newStatus,
      'updated_at': Timestamp.fromDate(now),
    });

    String statusText = 'mise à jour';
    if (newStatus == 'in_preparation') statusText = 'est en cours de préparation';
    if (newStatus == 'ready') statusText = 'est prête pour le retrait en pharmacie';
    if (newStatus == 'out_for_delivery') statusText = 'est en cours de livraison chez vous';
    if (newStatus == 'delivered') statusText = 'a été livrée / retirée';

    // Notification en temps réel pour le patient
    await _firestore.collection('notifications').add({
      'user_uid': patientUid,
      'title': 'Mise à jour de votre ordonnance',
      'message': 'Votre commande $statusText. ${messageForPatient ?? ''}',
      'type': 'order_status',
      'reference_id': prescriptionId,
      'created_at': Timestamp.fromDate(now),
      'is_read': false,
    });
  }
}
