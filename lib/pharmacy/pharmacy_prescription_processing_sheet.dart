import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/prescription_service.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Modal interactif de traitement d'une ordonnance en 3 étapes strictes pour le pharmacien :
/// Étape 1 : Réception & lecture de l'ordonnance (Nom masqué par QR Code, médicaments visibles)
/// Étape 2 : Coche des produits disponibles en pharmacie
/// Étape 3 : Préparation de l'ordonnance & Envoi du livreur
class PharmacyPrescriptionProcessingSheet extends StatefulWidget {
  const PharmacyPrescriptionProcessingSheet({
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
      builder: (ctx) => PharmacyPrescriptionProcessingSheet(
        prescriptionData: prescriptionData,
        prescriptionId: prescriptionId,
      ),
    );
  }

  @override
  State<PharmacyPrescriptionProcessingSheet> createState() =>
      _PharmacyPrescriptionProcessingSheetState();
}

class _PharmacyPrescriptionProcessingSheetState
    extends State<PharmacyPrescriptionProcessingSheet> {
  int _currentStep = 1;
  bool _revealPatientName = false;
  bool _isSaving = false;

  final Map<int, bool> _availableItems = {};
  late TextEditingController _deliveryNameCtrl;
  late TextEditingController _deliveryPhoneCtrl;

  @override
  void initState() {
    super.initState();
    final data = widget.prescriptionData;

    final existingStatus = data['status'] as String? ?? 'sent_to_pharmacy';
    if (existingStatus == 'in_preparation') {
      _currentStep = 2;
    } else if (existingStatus == 'out_for_delivery' || existingStatus == 'ready' || existingStatus == 'delivered') {
      _currentStep = 3;
    }

    _deliveryNameCtrl = TextEditingController(
      text: (data['delivery_person_name'] as String?) ?? 'Livreur AlloDoctor Express',
    );
    _deliveryPhoneCtrl = TextEditingController(
      text: (data['delivery_person_phone'] as String?) ?? '+225 07 00 00 00',
    );

    // Initialisation des produits cochés
    final rawMeds = data['medications'];
    if (rawMeds is List) {
      final savedAvail = (data['available_medications'] as List?)?.cast<String>();
      for (int i = 0; i < rawMeds.length; i++) {
        final med = rawMeds[i];
        final name = med is Map ? (med['name'] ?? '') : med.toString();
        if (savedAvail != null && savedAvail.isNotEmpty) {
          _availableItems[i] = savedAvail.contains(name);
        } else {
          _availableItems[i] = true; // par défaut coché
        }
      }
    }
  }

  @override
  void dispose() {
    _deliveryNameCtrl.dispose();
    _deliveryPhoneCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _extractMedications() {
    final rawMeds = widget.prescriptionData['medications'];
    final List<Map<String, dynamic>> list = [];
    if (rawMeds is List) {
      for (final m in rawMeds) {
        if (m is Map) {
          list.add(Map<String, dynamic>.from(m));
        } else if (m is String) {
          list.add({'name': m, 'dosage': '', 'duration': ''});
        }
      }
    }
    return list;
  }

  List<String> _getSelectedMedicationNames() {
    final meds = _extractMedications();
    final List<String> names = [];
    for (int i = 0; i < meds.length; i++) {
      if (_availableItems[i] == true) {
        names.add(meds[i]['name'] ?? 'Médicament ${i + 1}');
      }
    }
    return names;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.prescriptionData;
    final patientName = data['patient_name'] ?? 'Patient';
    final patientId = data['patient_id'] ?? 'ALLO-PAT-00000';
    final doctorName = data['doctor_name'] ?? 'Médecin';
    final qrData = data['qr_code_data'] ?? 'ALLO-DOC-${widget.prescriptionId}';
    final deliveryType = data['delivery_type'] as String? ?? 'delivery';
    final deliveryAddress = data['delivery_address'] as String? ?? '';
    final patientUid = data['patient_uid'] as String? ?? '';
    final status = data['status'] as String? ?? 'sent_to_pharmacy';
    final medications = _extractMedications();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Poignée supérieure
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Barre d'en-tête
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traitement Ordonnance',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Processus officine en 3 étapes',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Stepper des 3 étapes
          _buildStepperHeader(),

          const Divider(height: 1),

          // Contenu selon l'étape actuelle
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_currentStep == 1)
                  _buildStep1ReadPrescription(
                    patientName: patientName,
                    patientId: patientId,
                    patientPhone: (data['patient_phone'] as String?)?.isNotEmpty == true
                        ? (data['patient_phone'] as String)
                        : ((data['delivery_phone'] as String?)?.isNotEmpty == true
                            ? (data['delivery_phone'] as String)
                            : '+242 06 719 9098'),
                    doctorName: doctorName,
                    qrData: qrData,
                    medications: medications,
                  )
                else if (_currentStep == 2)
                  _buildStep2CheckStock(
                    medications: medications,
                    patientPhone: (data['patient_phone'] as String?)?.isNotEmpty == true
                        ? (data['patient_phone'] as String)
                        : ((data['delivery_phone'] as String?)?.isNotEmpty == true
                            ? (data['delivery_phone'] as String)
                            : '+242 06 719 9098'),
                  )
                else
                  _buildStep3PrepareAndDeliver(
                    deliveryType: deliveryType,
                    deliveryAddress: deliveryAddress,
                    patientUid: patientUid,
                    patientPhone: (data['patient_phone'] as String?)?.isNotEmpty == true
                        ? (data['patient_phone'] as String)
                        : ((data['delivery_phone'] as String?)?.isNotEmpty == true
                            ? (data['delivery_phone'] as String)
                            : '+242 06 719 9098'),
                    status: status,
                  ),
              ],
            ),
          ),

          // Barre d'actions inférieure
          _buildBottomActionBar(patientUid: patientUid, deliveryType: deliveryType),
        ],
      ),
    );
  }

  /// Header avec indicateur des 3 étapes
  Widget _buildStepperHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          _stepIndicator(1, '1. Lecture & QR', _currentStep >= 1, _currentStep == 1),
          _stepDivider(_currentStep >= 2),
          _stepIndicator(2, '2. Coche Stock', _currentStep >= 2, _currentStep == 2),
          _stepDivider(_currentStep >= 3),
          _stepIndicator(3, '3. Envoi Livreur', _currentStep >= 3, _currentStep == 3),
        ],
      ),
    );
  }

  Widget _stepIndicator(int step, String label, bool isDoneOrCurrent, bool isCurrent) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentStep = step;
          });
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCurrent
                  ? const Color(0xFF165AC5)
                  : (isDoneOrCurrent ? const Color(0xFF16C583) : Colors.grey.shade300),
              child: Text(
                '$step',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? const Color(0xFF165AC5) : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDivider(bool active) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
      color: active ? const Color(0xFF16C583) : Colors.grey.shade300,
    );
  }

  /// Étape 1 : Lecture de l'ordonnance avec Nom masqué par QR Code et Médicaments visibles
  Widget _buildStep1ReadPrescription({
    required String patientName,
    required String patientId,
    required String patientPhone,
    required String doctorName,
    required String qrData,
    required List<Map<String, dynamic>> medications,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge Étape 1
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF165AC5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'ÉTAPE 1 SUR 3 : LECTURE DE L\'ORDONNANCE & CODE QR',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF165AC5),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Carte Sécurisée : NOM DU PATIENT MASQUÉ PAR LE CODE QR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF16C583), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ANONYMISATION MÉDICALE',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16C583),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      patientId,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Code QR centré qui masque et protège le nom
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 140.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nom caché par défaut
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nom du patient : ',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    _revealPatientName
                        ? patientName
                        : '████████ (Masqué par QR)',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _revealPatientName
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF16C583),
                      size: 20,
                    ),
                    tooltip: 'Révéler / Masquer le nom',
                    onPressed: () {
                      setState(() {
                        _revealPatientName = !_revealPatientName;
                      });
                    },
                  ),
                ],
              ),
              Text(
                'L\'identité du patient est certifiée et protégée par ce Code QR.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── BARRE DE COMMUNICATION DIRECTE PHARMACIEN ↔ PATIENT ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Contact Patient :', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                    Text(
                      patientPhone.isNotEmpty ? patientPhone : 'Numéro fourni à la commande',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1D4ED8)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF165AC5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: Text('Appeler', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (patientPhone.isNotEmpty) {
                    await launchURL('tel:$patientPhone');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun numéro patient renseigné')));
                  }
                },
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: Text('WhatsApp', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  if (patientPhone.isNotEmpty) {
                    final clean = patientPhone.replaceAll(RegExp(r'[^0-9]'), '');
                    await launchURL('https://wa.me/$clean');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun numéro patient renseigné')));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Médicaments prescrits VISIBLES sur l'ordonnance
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MÉDICAMENTS PRESCRITS (VISIBLES)',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF334155),
              ),
            ),
            Text(
              'Dr. $doctorName',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.blueGrey),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Aucun médicament renseigné.',
                style: GoogleFonts.outfit(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          ...medications.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final m = entry.value;
            final name = m['name'] ?? 'Médicament';
            final dosage = m['dosage'] ?? '';
            final duration = m['duration'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFF165AC5).withOpacity(0.12),
                    child: Text(
                      '$idx',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF165AC5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (dosage.isNotEmpty)
                          Text('Posologie : $dosage', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700)),
                        if (duration.isNotEmpty)
                          Text('Durée : $duration', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_outline, color: Color(0xFF16C583), size: 20),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// Étape 2 : Coche des produits disponibles dans la pharmacie
  Widget _buildStep2CheckStock({
    required List<Map<String, dynamic>> medications,
    required String patientPhone,
  }) {
    final availableCount = _availableItems.values.where((v) => v).length;
    final totalCount = medications.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge Étape 2
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'ÉTAPE 2 SUR 3 : COCHE DES PRODUITS DISPONIBLES EN PHARMACIE',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD97706),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text(
          'Vérification des stocks officine',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Cochez chaque médicament disponible dans vos rayons. Les produits non disponibles seront signalés au patient.',
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),

        // Résumé de disponibilité
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: availableCount == totalCount ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: availableCount == totalCount ? const Color(0xFF81C784) : const Color(0xFFFDBA74),
            ),
          ),
          child: Row(
            children: [
              Icon(
                availableCount == totalCount ? Icons.verified : Icons.info_outline,
                color: availableCount == totalCount ? Colors.green.shade800 : Colors.orange.shade800,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  availableCount == totalCount
                      ? 'Tous les médicaments ($availableCount/$totalCount) sont disponibles en stock.'
                      : '$availableCount sur $totalCount médicament(s) disponible(s). Contactez le patient pour un équivalent.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: availableCount == totalCount ? Colors.green.shade900 : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── BOUTONS CONTACT DIRECT PATIENT EN CAS DE RUPTURE / CONSEIL ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              const Icon(Icons.support_agent_rounded, color: Color(0xFF165AC5), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Besoin d\'un accord substitution ?', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
                    Text('Patient : $patientPhone', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF165AC5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.phone, size: 14),
                label: Text('Appeler', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => launchURL('tel:$patientPhone'),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 14),
                label: Text('WhatsApp', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  final clean = patientPhone.replaceAll(RegExp(r'[^0-9]'), '');
                  launchURL('https://wa.me/$clean');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Liste des cases à cocher
        ...medications.asMap().entries.map((entry) {
          final idx = entry.key;
          final m = entry.value;
          final name = m['name'] ?? 'Médicament';
          final dosage = m['dosage'] ?? '';
          final isChecked = _availableItems[idx] ?? true;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isChecked ? const Color(0xFF86EFAC) : const Color(0xFFFECACA),
                width: 1.5,
              ),
            ),
            child: CheckboxListTile(
              value: isChecked,
              activeColor: const Color(0xFF16C583),
              title: Text(
                name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isChecked ? const Color(0xFF0F172A) : Colors.grey.shade600,
                  decoration: isChecked ? TextDecoration.none : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                isChecked
                    ? (dosage.isNotEmpty ? 'Dosage: $dosage • DISPONIBLE EN RAYON' : 'DISPONIBLE EN RAYON')
                    : 'RUPTURE DE STOCK (Non disponible)',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isChecked ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                ),
              ),
              secondary: Icon(
                isChecked ? Icons.check_box_rounded : Icons.disabled_by_default_rounded,
                color: isChecked ? const Color(0xFF16C583) : Colors.red,
              ),
              onChanged: (val) {
                setState(() {
                  _availableItems[idx] = val ?? false;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  /// Étape 3 : Préparation de l'ordonnance & Envoi du livreur
  Widget _buildStep3PrepareAndDeliver({
    required String deliveryType,
    required String deliveryAddress,
    required String patientUid,
    required String patientPhone,
    required String status,
  }) {
    final selectedMedNames = _getSelectedMedicationNames();
    final isDelivery = deliveryType == 'delivery';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge Étape 3
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF16C583).withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'ÉTAPE 3 SUR 3 : PRÉPARATION ET EXPÉDITION DU LIVREUR',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF16C583),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Text(
          'Préparation de la commande & Expédition',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Carte récapitulative
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isDelivery ? Icons.delivery_dining : Icons.storefront,
                    color: isDelivery ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDelivery ? 'Mode : Livraison à Domicile' : 'Mode : Retrait en Pharmacie',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              if (isDelivery && deliveryAddress.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Adresse de destination : $deliveryAddress',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Destinataire : $patientPhone', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  InkWell(
                    onTap: () => launchURL('tel:$patientPhone'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF165AC5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Appeler', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      final clean = patientPhone.replaceAll(RegExp(r'[^0-9]'), '');
                      launchURL('https://wa.me/$clean');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('WhatsApp', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Médicaments préparés (${selectedMedNames.length}) :',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selectedMedNames.map((n) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '✓ $n',
                      style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF1B5E20), fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Informations du livreur si mode livraison
        if (isDelivery) ...[
          Text(
            'Informations du Livreur',
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _deliveryNameCtrl,
            decoration: InputDecoration(
              labelText: 'Nom du livreur / Société',
              hintText: 'Ex: Mamadou Livreur Moto',
              prefixIcon: const Icon(Icons.two_wheeler_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _deliveryPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone du livreur',
              hintText: 'Ex: +242 06 123 4567',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Statut actuel & notification
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_active_outlined, color: Color(0xFF165AC5)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dès que vous validez, l\'ordonnance est préparée et le patient est immédiatement alerté de l\'envoi du livreur.',
                  style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF1E3A8A)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Barre d'actions inférieure
  Widget _buildBottomActionBar({
    required String patientUid,
    required String deliveryType,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              child: Text('Précédent', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          if (_currentStep > 1) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 3
                    ? (deliveryType == 'delivery' ? const Color(0xFFD97706) : const Color(0xFF16C583))
                    : const Color(0xFF165AC5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_currentStep == 1) {
                        setState(() {
                          _currentStep = 2;
                        });
                      } else if (_currentStep == 2) {
                        // Passe à l'étape 3 et met à jour le statut Firestore en in_preparation
                        setState(() => _isSaving = true);
                        try {
                          final activeUid = currentUserUid.isNotEmpty ? currentUserUid : (widget.prescriptionData['pharmacy_uid'] as String?);
                          final activeName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : (widget.prescriptionData['pharmacy_name'] as String?);
                          final activePhone = (widget.prescriptionData['pharmacy_phone'] as String?) ?? '+242 06 719 9098';

                          await PrescriptionService.updateOrderStatus(
                            prescriptionId: widget.prescriptionId,
                            newStatus: 'in_preparation',
                            patientUid: patientUid,
                            availableMedications: _getSelectedMedicationNames(),
                            pharmacyUid: activeUid,
                            pharmacyName: activeName,
                            pharmacyPhone: activePhone,
                            messageForPatient: 'Médicaments validés en stock. Préparation en cours.',
                          );
                          setState(() {
                            _currentStep = 3;
                            _isSaving = false;
                          });
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      } else {
                        // Étape 3 : Envoi du livreur ou mise à disposition
                        setState(() => _isSaving = true);
                        try {
                          final isDelivery = deliveryType == 'delivery';
                          final nextStatus = isDelivery ? 'out_for_delivery' : 'ready';
                          final riderName = _deliveryNameCtrl.text.trim();
                          final riderPhone = _deliveryPhoneCtrl.text.trim();
                          final activeUid = currentUserUid.isNotEmpty ? currentUserUid : (widget.prescriptionData['pharmacy_uid'] as String?);
                          final activeName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : (widget.prescriptionData['pharmacy_name'] as String?);
                          final activePhone = (widget.prescriptionData['pharmacy_phone'] as String?) ?? '+242 06 719 9098';

                          await PrescriptionService.updateOrderStatus(
                            prescriptionId: widget.prescriptionId,
                            newStatus: nextStatus,
                            patientUid: patientUid,
                            availableMedications: _getSelectedMedicationNames(),
                            deliveryPersonName: riderName,
                            deliveryPersonPhone: riderPhone,
                            pharmacyUid: activeUid,
                            pharmacyName: activeName,
                            pharmacyPhone: activePhone,
                            messageForPatient: isDelivery
                                ? 'Votre ordonnance a été préparée et le livreur $riderName ($riderPhone) est en route.'
                                : 'Votre ordonnance a été préparée et est prête pour le retrait en pharmacie.',
                          );

                          if (mounted) {
                            setState(() => _isSaving = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isDelivery
                                      ? 'Ordonnance préparée et livreur envoyé avec succès 🚚 !'
                                      : 'Ordonnance préparée et prête au retrait 🏪 !',
                                ),
                                backgroundColor: const Color(0xFF16C583),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() => _isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      }
                    },
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentStep == 1
                          ? 'Passer à la vérification du stock (Étape 2) ➔'
                          : (_currentStep == 2
                              ? 'Valider le stock & Préparer l\'ordonnance ➔'
                              : (deliveryType == 'delivery'
                                  ? 'Confirmer & Envoyer le Livreur 🚚'
                                  : 'Prêt pour Retrait en Pharmacie 🏪')),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
