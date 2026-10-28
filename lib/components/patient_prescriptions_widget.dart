import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/patient/prescription_view_modal.dart';
import '/backend/prescription_service.dart';

/// Widget affichant l'Identifiant Unique Permanent du Patient
/// et l'historique complet classé de ses ordonnances avec filtre et QR code.
class PatientPrescriptionsWidget extends StatefulWidget {
  const PatientPrescriptionsWidget({super.key});

  @override
  State<PatientPrescriptionsWidget> createState() => _PatientPrescriptionsWidgetState();
}

class _PatientPrescriptionsWidgetState extends State<PatientPrescriptionsWidget> {
  String _selectedFilter = 'all'; // 'all', 'active', 'pharmacy', 'delivered'
  String _patientId = '';

  @override
  void initState() {
    super.initState();
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    final uid = currentUserUid.isNotEmpty ? currentUserUid : 'patient_bitodi_cora';
    final pid = await PrescriptionService.getOrCreatePatientId(uid, displayName: currentUserDisplayName);
    if (mounted) setState(() => _patientId = pid);
  }

  void _showPatientQrDialog(BuildContext context) {
    final patientName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'BITODI Cornelca Cora';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            'Ma Carte Santé Numérique',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: QrImageView(
                data: 'ALLO-PATIENT-ID:$_patientId|NAME:$patientName',
                version: QrVersions.auto,
                size: 180,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              patientName,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0E1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID UNIQUE : $_patientId',
                style: GoogleFonts.outfit(color: const Color(0xFF16C583), fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Présentez ce QR Code à votre médecin ou pharmacien pour un accès immédiat à votre dossier.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Fermer', style: GoogleFonts.outfit(color: const Color(0xFF16C583), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : Titre + Carte Identifiant Unique
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16C583).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF16C583), size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes Ordonnances & Documents',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Classées & sécurisées par QR Code',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _showPatientQrDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0E1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code, color: Color(0xFF16C583), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        _patientId.isNotEmpty ? _patientId : 'Mon ID',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16C583),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Filtres par statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'Toutes'),
                const SizedBox(width: 8),
                _buildFilterChip('active', 'Disponibles'),
                const SizedBox(width: 8),
                _buildFilterChip('sent_to_pharmacy', 'En pharmacie'),
                const SizedBox(width: 8),
                _buildFilterChip('delivered', 'Délivrées'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Liste des ordonnances depuis Firestore
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('prescriptions')
                .orderBy('created_at', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Color(0xFF16C583)),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              final filteredDocs = docs.where((doc) {
                if (_selectedFilter == 'all') return true;
                final status = doc.data()['status'] ?? 'active';
                if (_selectedFilter == 'active') return status == 'active';
                if (_selectedFilter == 'sent_to_pharmacy') {
                  return status == 'sent_to_pharmacy' || status == 'in_preparation' || status == 'ready' || status == 'out_for_delivery';
                }
                if (_selectedFilter == 'delivered') return status == 'delivered';
                return true;
              }).toList();

              if (filteredDocs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Aucune ordonnance trouvée',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Les ordonnances prescrites par vos médecins apparaîtront ici avec QR code et option de transmission.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: filteredDocs.map((doc) {
                  final data = doc.data();
                  final doctorName = data['doctor_name'] ?? 'Dr. Traitant';
                  final doctorSpecialty = data['doctor_specialty'] ?? 'Médecine générale';
                  final status = data['status'] ?? 'active';
                  final isMandatory = data['is_mandatory'] ?? false;
                  final pharmacyName = data['pharmacy_name'] as String?;
                  final deliveryType = data['delivery_type'] as String?;
                  final medications = (data['medications'] as List<dynamic>?) ?? [];
                  final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                  final dateStr = createdAt != null ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}' : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => PrescriptionViewModal.show(
                        context,
                        prescriptionData: data,
                        prescriptionId: doc.id,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF16C583).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.qr_code_scanner, color: Color(0xFF16C583), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Dr. $doctorName',
                                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (dateStr.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Text(
                                            dateStr,
                                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$doctorSpecialty • ${medications.length} médicament(s)',
                                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isMandatory ? Colors.red.shade50 : Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isMandatory ? Colors.red.shade200 : Colors.green.shade200),
                                        ),
                                        child: Text(
                                          isMandatory ? 'Non substituable' : 'Génériques autorisés',
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isMandatory ? Colors.red.shade800 : Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (pharmacyName != null)
                                        Expanded(
                                          child: Text(
                                            '➔ $pharmacyName (${deliveryType == 'delivery' ? 'Livraison' : 'Retrait'})',
                                            style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16C583) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
