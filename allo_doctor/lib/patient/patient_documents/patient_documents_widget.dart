import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/patient/prescription_view_modal.dart';
import '/backend/prescription_service.dart';
import 'patient_documents_model.dart';
export 'patient_documents_model.dart';

class PatientDocumentsWidget extends StatefulWidget {
  const PatientDocumentsWidget({super.key});

  static String routeName = 'PatientDocuments';
  static String routePath = '/patientDocuments';

  @override
  State<PatientDocumentsWidget> createState() => _PatientDocumentsWidgetState();
}

class _PatientDocumentsWidgetState extends State<PatientDocumentsWidget>
    with TickerProviderStateMixin {
  late PatientDocumentsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPrescriptionFilter = 'all';
  String _patientId = '';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientDocumentsModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    final uid = currentUserUid.isNotEmpty ? currentUserUid : 'patient_cora';
    final pid = await PrescriptionService.getOrCreatePatientId(
      uid,
      displayName: currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Patient',
    );
    if (mounted) safeSetState(() => _patientId = pid);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showHealthQrDialog(BuildContext context) {
    final patientName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Mon Profil Santé';
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
                'ID UNIQUE : ${_patientId.isNotEmpty ? _patientId : "ALLO-PAT-00000"}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF16C583),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Présentez ce QR Code à votre médecin ou pharmacien pour accéder à vos ordonnances et dossiers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Fermer',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF165AC5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUid = currentUserUid.isNotEmpty ? currentUserUid : 'patient_cora';
    final effectiveName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : '';

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF165AC5),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => context.safePop(),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            ),
            Text(
              'Mes Ordonnances & Dossiers',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              onTap: () => _showHealthQrDialog(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.qr_code, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 3.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // Onglets principaux
            Container(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              child: Align(
                alignment: const Alignment(-1.0, 0.0),
                child: TabBar(
                  controller: _model.tabBarController,
                  isScrollable: true,
                  labelColor: const Color(0xFF165AC5),
                  unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                  indicatorColor: const Color(0xFF165AC5),
                  indicatorWeight: 3.0,
                  labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
                  tabs: const [
                    Tab(
                      text: 'Ordonnances',
                      icon: Icon(Icons.receipt_long_rounded, size: 20),
                    ),
                    Tab(
                      text: 'Comptes-rendus SOAP',
                      icon: Icon(Icons.assignment_outlined, size: 20),
                    ),
                    Tab(
                      text: 'Historiques Médicaux',
                      icon: Icon(Icons.history_edu_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _model.tabBarController,
                children: [
                  // ════════════════════════════════════════════════════════
                  // ONGLET 1 : ORDONNANCES REÇUES DU MÉDECIN
                  // ════════════════════════════════════════════════════════
                  _buildPrescriptionsTab(context, effectiveUid, effectiveName),

                  // ════════════════════════════════════════════════════════
                  // ONGLET 2 : COMPTES-RENDUS & DOSSIERS SOAP DU MÉDECIN
                  // ════════════════════════════════════════════════════════
                  _buildSoapNotesTab(context, effectiveUid),

                  // ════════════════════════════════════════════════════════
                  // ONGLET 3 : HISTORIQUE DE LA MALADIE
                  // ════════════════════════════════════════════════════════
                  _buildHistoryTab(context, effectiveUid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1 : Ordonnances ──
  Widget _buildPrescriptionsTab(BuildContext context, String uid, String name) {
    return Column(
      children: [
        // Filtres par statut
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          color: FlutterFlowTheme.of(context).secondaryBackground,
          child: SingleChildScrollView(
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
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('prescriptions')
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF165AC5)));
              }

              final allDocs = snapshot.data?.docs ?? [];
              final myDocs = allDocs.where((doc) {
                final data = doc.data();
                final pUid = (data['patient_uid'] as String?) ?? '';
                final pName = (data['patient_name'] as String?) ?? '';
                // Filtre patient : correspond à l'utilisateur courant ou dev fallback
                final isMe = pUid == uid || (name.isNotEmpty && pName.toLowerCase() == name.toLowerCase()) || uid == 'patient_cora' || uid.isEmpty;
                if (!isMe) return false;

                if (_selectedPrescriptionFilter == 'all') return true;
                final status = data['status'] ?? 'active';
                if (_selectedPrescriptionFilter == 'active') return status == 'active';
                if (_selectedPrescriptionFilter == 'sent_to_pharmacy') {
                  return status == 'sent_to_pharmacy' || status == 'in_preparation' || status == 'ready' || status == 'out_for_delivery';
                }
                if (_selectedPrescriptionFilter == 'delivered') return status == 'delivered';
                return true;
              }).toList();

              if (myDocs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune ordonnance reçue pour le moment',
                          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dès que votre médecin ou clinique émet une ordonnance, elle apparaîtra ici avec son QR code sécurisé et son option de commande en pharmacie.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: myDocs.length,
                itemBuilder: (context, index) {
                  final doc = myDocs[index];
                  final data = doc.data();
                  final doctorName = (data['doctor_name'] as String?) ?? 'Dr. Traitant';
                  final doctorSpecialty = (data['doctor_specialty'] as String?) ?? 'Médecin';
                  final status = (data['status'] as String?) ?? 'active';
                  final isMandatory = (data['is_mandatory'] as bool?) ?? false;
                  final medications = (data['medications'] as List<dynamic>?) ?? [];
                  final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                  final dateStr = createdAt != null
                      ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                      : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header ordonnance
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF165AC5).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person_pin, color: Color(0xFF165AC5), size: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctorName,
                                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        doctorSpecialty,
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const Divider(height: 20),

                          // Infos type & date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMandatory ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isMandatory ? 'STRICT (Non-substituable)' : 'Génériques acceptés',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isMandatory ? Colors.red.shade700 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                              Text(
                                'Émise le $dateStr',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Liste des médicaments
                          Text(
                            'Médicaments prescrits (${medications.length}) :',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Column(
                            children: medications.take(3).map((m) {
                              final medMap = m is Map ? m : {'name': m.toString()};
                              final name = (medMap['name'] as String?) ?? '';
                              final dosage = (medMap['dosage'] as String?) ?? '';
                              final duration = (medMap['duration'] as String?) ?? '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Color(0xFF16C583), size: 14),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '$name ${dosage.isNotEmpty ? "- $dosage" : ""} ${duration.isNotEmpty ? "($duration)" : ""}',
                                        style: GoogleFonts.outfit(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          if (medications.length > 3)
                            Text(
                              '+ ${medications.length - 3} autre(s) médicament(s)...',
                              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                            ),

                          if (data['pharmacy_name'] != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF86EFAC)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_pharmacy_rounded, color: Color(0xFF15803D), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pharmacie : ${data['pharmacy_name']}',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF0F172A)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          status == 'in_preparation'
                                              ? 'Préparation en cours...'
                                              : (status == 'out_for_delivery'
                                                  ? 'Livreur en route 🛵'
                                                  : (status == 'ready' ? 'Prêt en officine 🏪' : 'Transmise à la pharmacie')),
                                          style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF15803D)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quick Call button
                                  InkWell(
                                    onTap: () async {
                                      final phone = (data['pharmacy_phone'] as String?) ?? '+242 06 719 9098';
                                      await launchURL('tel:$phone');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF165AC5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.phone, size: 14, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Quick WhatsApp button
                                  InkWell(
                                    onTap: () async {
                                      final phone = (data['pharmacy_phone'] as String? ?? '242067199098').replaceAll(RegExp(r'[^0-9]'), '');
                                      await launchURL('https://wa.me/$phone');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF25D366),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),
                          // Bouton d'action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF165AC5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                PrescriptionViewModal.show(
                                  context,
                                  prescriptionData: data,
                                  prescriptionId: doc.id,
                                );
                              },
                              icon: const Icon(Icons.qr_code_2, size: 18),
                              label: Text(
                                "Consulter l'ordonnance & QR Code",
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Tab 2 : Dossiers & SOAP ──
  Widget _buildSoapNotesTab(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('soap_notes')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF165AC5)));
        }

        final docs = snapshot.data?.docs.where((doc) {
          final data = doc.data();
          final pUid = (data['patient_uid'] as String?) ?? '';
          return pUid == uid || uid == 'patient_cora' || uid.isEmpty;
        }).toList() ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun compte-rendu médical',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Les comptes-rendus de consultations (S.O.A.P) rédigés et envoyés par vos médecins praticiens apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final doctorName = (data['doctor_name'] as String?) ?? 'Dr. Traitant';
            final createdAt = (data['created_at'] as Timestamp?)?.toDate();
            final dateStr = createdAt != null
                ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                : '';
            final subj = (data['subjective'] as String?) ?? '';
            final obj = (data['objective'] as String?) ?? '';
            final analysis = (data['analysis'] as String?) ?? '';
            final plan = (data['plan'] as String?) ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD29139).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.assignment, color: Color(0xFFD29139), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Compte-rendu de Consultation',
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  doctorName,
                                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dateStr,
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    if (subj.isNotEmpty) ...[
                      _buildSoapSection('S - Subjectif (Symptômes décrits)', subj, Icons.record_voice_over_outlined, const Color(0xFF165AC5)),
                      const SizedBox(height: 10),
                    ],
                    if (obj.isNotEmpty) ...[
                      _buildSoapSection('O - Objectif (Constats cliniques)', obj, Icons.monitor_heart_outlined, const Color(0xFFD29139)),
                      const SizedBox(height: 10),
                    ],
                    if (analysis.isNotEmpty) ...[
                      _buildSoapSection('A - Analyse (Diagnostic)', analysis, Icons.psychology_outlined, const Color(0xFF8A0DCE)),
                      const SizedBox(height: 10),
                    ],
                    if (plan.isNotEmpty) ...[
                      _buildSoapSection('P - Plan de traitement & suivi', plan, Icons.healing_outlined, const Color(0xFF16C583)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSoapSection(String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.outfit(fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }

  // ── Tab 3 : Historique médical ──
  Widget _buildHistoryTab(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('patient_history')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF165AC5)));
        }

        final docs = snapshot.data?.docs.where((doc) {
          final data = doc.data();
          final pUid = (data['patient_uid'] as String?) ?? '';
          return pUid == uid || uid == 'patient_cora' || uid.isEmpty;
        }).toList() ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_outlined, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun historique de maladie enregistré',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Les antécédents et synthèses chronologiques enregistrés dans votre DMP apparaîtront ici.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final doctorName = (data['doctor_name'] as String?) ?? 'Dr. Traitant';
            final desc = (data['description'] as String?) ?? '';
            final createdAt = (data['created_at'] as Timestamp?)?.toDate();
            final dateStr = createdAt != null
                ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: FlutterFlowTheme.of(context).alternate),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enregistré par $doctorName',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        dateStr,
                        style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedPrescriptionFilter == value;
    return InkWell(
      onTap: () => setState(() => _selectedPrescriptionFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF165AC5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF165AC5) : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    String text;
    Color bg;
    Color fg;

    switch (status) {
      case 'active':
        text = 'Disponible';
        bg = const Color(0xFFE8F5E9);
        fg = Colors.green.shade800;
        break;
      case 'sent_to_pharmacy':
        text = 'En pharmacie';
        bg = const Color(0xFFFFF3E0);
        fg = Colors.orange.shade800;
        break;
      case 'in_preparation':
        text = 'En préparation';
        bg = const Color(0xFFE0F7FA);
        fg = Colors.cyan.shade900;
        break;
      case 'ready':
        text = 'Prête';
        bg = const Color(0xFFE8EAF6);
        fg = Colors.indigo.shade800;
        break;
      case 'out_for_delivery':
        text = 'En livraison';
        bg = const Color(0xFFF3E5F5);
        fg = Colors.purple.shade800;
        break;
      case 'delivered':
        text = 'Délivrée';
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        break;
      default:
        text = status;
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
