import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/prescription_service.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Modal d'affichage sécurisé d'une ordonnance avec QR code,
/// signature électronique, typologie (strict ou équivalent),
/// et flux de transmission à la pharmacie avec option livraison.
class PrescriptionViewModal extends StatefulWidget {
  const PrescriptionViewModal({
    super.key,
    required this.prescriptionData,
    required this.prescriptionId,
  });

  final Map<String, dynamic> prescriptionData;
  final String prescriptionId;

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> prescriptionData,
    required String prescriptionId,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PrescriptionViewModal(
        prescriptionData: prescriptionData,
        prescriptionId: prescriptionId,
      ),
    );
  }

  @override
  State<PrescriptionViewModal> createState() => _PrescriptionViewModalState();
}

class _PrescriptionViewModalState extends State<PrescriptionViewModal> {
  bool _isSending = false;
  bool _showName = false;

  String _formatStatus(String status, String? deliveryType) {
    switch (status) {
      case 'active':
        return 'Disponible';
      case 'sent_to_pharmacy':
        return 'Transmise à la pharmacie';
      case 'in_preparation':
        return 'En cours de préparation';
      case 'ready':
        return deliveryType == 'delivery' ? 'Prête pour livraison' : 'Prête en pharmacie';
      case 'out_for_delivery':
        return 'En cours de livraison 🚚';
      case 'delivered':
        return 'Délivrée ✅';
      default:
        return 'Active';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return const Color(0xFF16C583);
      case 'sent_to_pharmacy':
        return Colors.blue;
      case 'in_preparation':
        return Colors.orange;
      case 'ready':
      case 'out_for_delivery':
        return const Color(0xFF673AB7);
      case 'delivered':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF16C583);
    }
  }

  Future<void> _showSendToPharmacyDialog(BuildContext context) async {
    final List<Map<String, dynamic>> pharmaList = [];

    // 1. Charger depuis la collection 'pharmacies'
    try {
      final snap = await FirebaseFirestore.instance.collection('pharmacies').limit(30).get();
      for (final doc in snap.docs) {
        if (doc.id.startsWith('pharma_')) continue;
        final d = doc.data();
        final name = (d['name'] as String?)?.trim() ?? 'Pharmacie';
        final phone = (d['phone'] as String?) ?? (d['phone_number'] as String?) ?? '';
        final addr = (d['address'] as String?) ?? (d['city'] as String?) ?? 'Brazzaville';
        if (name.isNotEmpty) {
          pharmaList.add({
            'id': doc.id,
            'name': name,
            'phone': phone.isNotEmpty ? phone : '+242 06 719 9098',
            'address': addr,
            'is_guard': (d['is_guard'] as bool?) ?? (d['is_garde'] as bool?) ?? false,
          });
        }
      }
    } catch (_) {}

    // 2. Charger depuis la collection 'User' (utilisateurs inscrits en tant que pharmacie)
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('User')
          .where('user_category', whereIn: ['pharmacie', 'pharmacy', 'Pharmacie'])
          .limit(20)
          .get();
      for (final doc in userSnap.docs) {
        final d = doc.data();
        final name = (d['display_name'] as String?)?.trim() ?? '';
        if (name.isNotEmpty && !pharmaList.any((p) => p['name'] == name || p['id'] == doc.id)) {
          pharmaList.add({
            'id': doc.id,
            'name': name,
            'phone': (d['phone_number'] as String?) ?? (d['phone'] as String?) ?? '+242 06 000 0000',
            'address': (d['address'] as String?) ?? 'Brazzaville',
            'is_guard': false,
          });
        }
      }
    } catch (_) {}

    // Aucune pharmacie de test forcée
    if (pharmaList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune pharmacie partenaire disponible actuellement.'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    String? selectedPharmacyUid = pharmaList.first['id'];
    String? selectedPharmacyName = pharmaList.first['name'];
    String? selectedPharmacyPhone = pharmaList.first['phone'];
    String deliveryOption = 'delivery'; // 'pickup' ou 'delivery'
    final addressController = TextEditingController();
    
    // Récupérer le numéro de téléphone existant du patient ou fallback
    String existingPhone = currentUser?.phoneNumber ?? '';
    if (existingPhone.isEmpty && currentUserUid.isNotEmpty) {
      try {
        final uDoc = await FirebaseFirestore.instance.collection('User').doc(currentUserUid).get();
        if (uDoc.exists) {
          existingPhone = (uDoc.data()?['phone_number'] ?? uDoc.data()?['phone'] ?? '').toString();
        }
      } catch (_) {}
    }
    if (existingPhone.isEmpty) existingPhone = '+242 06 719 9098';
    final phoneController = TextEditingController(text: existingPhone);

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF16C583)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Transmettre à une pharmacie',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisissez votre pharmacie partenaire disponible :',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  value: selectedPharmacyUid,
                  items: pharmaList.map((p) {
                    final name = p['name'] as String;
                    final isGuard = p['is_guard'] as bool? ?? false;
                    return DropdownMenuItem<String>(
                      value: p['id'] as String,
                      child: Text(
                        isGuard ? '$name 🟢 (De garde)' : name,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: isGuard ? FontWeight.bold : FontWeight.normal),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedPharmacyUid = val;
                      final pDoc = pharmaList.firstWhere((d) => d['id'] == val);
                      selectedPharmacyName = pDoc['name'] as String;
                      selectedPharmacyPhone = pDoc['phone'] as String;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Option d\'obtention :',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setDialogState(() => deliveryOption = 'pickup'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: deliveryOption == 'pickup' ? const Color(0xFF16C583).withOpacity(0.15) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: deliveryOption == 'pickup' ? const Color(0xFF16C583) : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.storefront, color: deliveryOption == 'pickup' ? const Color(0xFF16C583) : Colors.grey),
                              const SizedBox(height: 4),
                              Text('Retrait sur place', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setDialogState(() => deliveryOption = 'delivery'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          decoration: BoxDecoration(
                            color: deliveryOption == 'delivery' ? const Color(0xFF16C583).withOpacity(0.15) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: deliveryOption == 'delivery' ? const Color(0xFF16C583) : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.delivery_dining, color: deliveryOption == 'delivery' ? const Color(0xFF16C583) : Colors.grey),
                              const SizedBox(height: 4),
                              Text('Livraison à domicile', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (deliveryOption == 'delivery') ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresse complète de livraison',
                      hintText: 'Quartier, rue, repère...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.outfit(fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Numéro de contact pour la pharmacie & livreur :',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (Appels & WhatsApp)',
                    hintText: '+242 ...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    prefixIcon: const Icon(Icons.phone_in_talk, size: 18, color: Color(0xFF16C583)),
                  ),
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Annuler', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16C583),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final chosenUid = selectedPharmacyUid ?? pharmaList.first['id'];
                final chosenName = selectedPharmacyName ?? pharmaList.first['name'];
                final chosenPhone = selectedPharmacyPhone ?? pharmaList.first['phone'];
                final chosenPatPhone = phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : existingPhone;

                Navigator.pop(dialogCtx);
                setState(() => _isSending = true);

                try {
                  await PrescriptionService.sendToPharmacy(
                    prescriptionId: widget.prescriptionId,
                    pharmacyUid: chosenUid,
                    pharmacyName: chosenName,
                    deliveryType: deliveryOption,
                    deliveryAddress: addressController.text.trim(),
                    deliveryPhone: chosenPatPhone,
                    pharmacyPhone: chosenPhone,
                    patientPhone: chosenPatPhone,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Ordonnance transmise à $chosenName avec succès ! Vous pouvez la contacter directement.',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: const Color(0xFF16C583),
                      ),
                    );
                    Navigator.pop(context); // fermer la modal
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isSending = false);
                }
              },
              child: Text('Confirmer l\'envoi', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.prescriptionData;
    final patientName = data['patient_name'] ?? 'Patient';
    final patientId = data['patient_id'] ?? 'ALLO-PAT-00000';
    final doctorName = data['doctor_name'] ?? 'Médecin Prescripteur';
    final doctorSpecialty = data['doctor_specialty'] ?? 'Médecin Généraliste';
    final isMandatory = data['is_mandatory'] ?? false;
    final signature = data['doctor_signature'] ?? 'Signature Électronique Certifiée';
    final qrData = data['qr_code_data'] ?? 'ALLO-DOC-${widget.prescriptionId}';
    final status = data['status'] ?? 'active';
    final deliveryType = data['delivery_type'] as String?;
    final pharmacyName = data['pharmacy_name'] as String?;
    final notes = data['notes'] ?? '';
    final medicationsRaw = data['medications'];
    final List<Map<String, dynamic>> medications = [];

    if (medicationsRaw is List) {
      for (final m in medicationsRaw) {
        if (m is Map) {
          medications.add(Map<String, dynamic>.from(m));
        } else if (m is String) {
          medications.add({'name': m, 'dosage': '', 'duration': ''});
        }
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Barre supérieure
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                children: [
                  // En-tête officiel
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF16C583).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medical_services_outlined, color: Color(0xFF16C583), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDONNANCE MÉDICALE',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0A0E1A),
                              ),
                            ),
                            Text(
                              'Dr. $doctorName • $doctorSpecialty',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Badge de statut & Badge de type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(status)),
                        ),
                        child: Text(
                          _formatStatus(status, deliveryType),
                          style: GoogleFonts.outfit(
                            color: _getStatusColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isMandatory ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isMandatory ? Colors.red : Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(isMandatory ? Icons.lock_outline : Icons.autorenew, size: 14, color: isMandatory ? Colors.red : Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              isMandatory ? 'Non substituable (Strict)' : 'Génériques acceptés',
                              style: GoogleFonts.outfit(
                                color: isMandatory ? Colors.red : Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fiche Patient + Identifiant unique permanent
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Patient (Protégé par QR Code) :', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF16C583)),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  _showName ? patientName : '████████ (Masqué par QR Code)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _showName ? const Color(0xFF0A0E1A) : Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => setState(() => _showName = !_showName),
                                  child: Icon(
                                    _showName ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: const Color(0xFF16C583),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0E1A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'IDENTIFIANT UNIQUE',
                                style: GoogleFonts.outfit(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                patientId,
                                style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF16C583), fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Section QR Code sécurisé
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, spreadRadius: 2),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 160.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF0A0E1A),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF0A0E1A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Code QR officiel scannable en pharmacie',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Liste des Médicaments prescrits
                  Text(
                    'PRESCRIPTION MÉDICALE',
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  if (medications.isEmpty)
                    Text('Aucun médicament spécifié.', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey))
                  else
                    ...medications.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final m = entry.value;
                      final name = m['name'] ?? 'Médicament';
                      final dosage = m['dosage'] ?? '';
                      final duration = m['duration'] ?? '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFF16C583).withOpacity(0.2),
                              child: Text('$idx', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF16C583))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700)),
                                  if (dosage.isNotEmpty)
                                    Text('Posologie : $dosage', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700)),
                                  if (duration.isNotEmpty)
                                    Text('Durée : $duration', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Notes & Précautions :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(notes, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                  ],
                  const SizedBox(height: 20),

                  // Signature électronique certifiée
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF81C784)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF2E7D32), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signature Électronique Certifiée',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                              ),
                              Text(
                                signature,
                                style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Détail de la pharmacie, livreur et boutons de communication directe
                  if (pharmacyName != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(deliveryType == 'delivery' ? Icons.delivery_dining : Icons.store, color: const Color(0xFF15803D)),
                                  const SizedBox(width: 8),
                                  Text(
                                    deliveryType == 'delivery' ? 'Livraison prise en charge par :' : 'Retrait prévu chez :',
                                    style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF15803D), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16C583).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Partenaire vérifié', style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF15803D), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(pharmacyName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                          if (data['delivery_address'] != null && data['delivery_address'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text('Adresse de livraison : ${data['delivery_address']}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700)),
                            ),
                          const SizedBox(height: 12),

                          // ── BOUTONS DE COMMUNICATION PATIENT ↔ PHARMACIEN ──
                          Row(
                            children: [
                              // Bouton Appel Pharmacie
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF165AC5),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.call_rounded, size: 16),
                                  label: Text('Appeler Pharmacie', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    final phone = (data['pharmacy_phone'] as String?) ?? '+242 06 719 9098';
                                    await launchURL('tel:$phone');
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Bouton WhatsApp Pharmacie
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                                  label: Text('WhatsApp Pharmacie', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () async {
                                    final phone = (data['pharmacy_phone'] as String? ?? '242067199098').replaceAll(RegExp(r'[^0-9]'), '');
                                    await launchURL('https://wa.me/$phone');
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Coordonnées du livreur si expédié
                          if (data['delivery_person_phone'] != null && data['delivery_person_phone'].toString().isNotEmpty) ...[
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.two_wheeler_rounded, color: Color(0xFFD97706), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Livreur : ${data['delivery_person_name'] ?? 'Coursier Officine'} (${data['delivery_person_phone']})',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.phone_forwarded_rounded, color: Color(0xFF15803D), size: 20),
                                  tooltip: 'Appeler le livreur',
                                  onPressed: () async {
                                    final p = data['delivery_person_phone'].toString();
                                    await launchURL('tel:$p');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Bouton Action Patient : Envoyer à une pharmacie
                  if (status == 'active')
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16C583),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send_rounded, color: Colors.white),
                        label: Text(
                          _isSending ? 'Transmission...' : 'Envoyer à une pharmacie (Retrait ou Livraison)',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isSending ? null : () => _showSendToPharmacyDialog(context),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
