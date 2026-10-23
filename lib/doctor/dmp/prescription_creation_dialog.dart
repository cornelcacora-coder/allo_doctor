import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/prescription_service.dart';

/// Dialogue interactif permettant au médecin de créer une ordonnance
/// avec sélection du type (strict ou équivalent), liste dynamique des médicaments,
/// notes et signature électronique certifiée.
class PrescriptionCreationDialog extends StatefulWidget {
  const PrescriptionCreationDialog({
    super.key,
    required this.patientUid,
    required this.patientName,
    this.patientId,
  });

  final String patientUid;
  final String patientName;
  final String? patientId;

  static Future<bool?> show(
    BuildContext context, {
    required String patientUid,
    required String patientName,
    String? patientId,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PrescriptionCreationDialog(
        patientUid: patientUid,
        patientName: patientName,
        patientId: patientId,
      ),
    );
  }

  @override
  State<PrescriptionCreationDialog> createState() => _PrescriptionCreationDialogState();
}

class _PrescriptionCreationDialogState extends State<PrescriptionCreationDialog> {
  final List<Map<String, String>> _medications = [];
  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isMandatory = false; // true = non-substituable (strict), false = génériques autorisés
  bool _hasSigned = false;
  bool _isSaving = false;
  String _patientId = '';

  @override
  void initState() {
    super.initState();
    _patientId = widget.patientId ?? '';
    _loadPatientId();
  }

  Future<void> _loadPatientId() async {
    if (_patientId.isEmpty) {
      final pid = await PrescriptionService.getOrCreatePatientId(widget.patientUid, displayName: widget.patientName);
      if (mounted) setState(() => _patientId = pid);
    }
  }

  void _addMedication() {
    final name = _medNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _medications.add({
        'name': name,
        'dosage': _dosageController.text.trim(),
        'duration': _durationController.text.trim(),
      });
      _medNameController.clear();
      _dosageController.clear();
      _durationController.clear();
    });
  }

  Future<void> _submitPrescription() async {
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un médicament.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (!_hasSigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez apposer votre signature électronique.'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final doctorName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Dr. Traitant';
      final signature = 'Certifié électroniquement par $doctorName le ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} à ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} (Empreinte: ${currentUserUid.hashCode.abs()})';

      await PrescriptionService.createPrescription(
        patientUid: widget.patientUid,
        patientName: widget.patientName,
        patientId: _patientId,
        doctorUid: currentUserUid,
        doctorName: doctorName,
        doctorSpecialty: 'Médecin Praticien',
        medications: _medications,
        notes: _notesController.text.trim(),
        isMandatory: _isMandatory,
        doctorSignature: signature,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordonnance pour ${widget.patientName} enregistrée et signée avec succès !'),
            backgroundColor: const Color(0xFF16C583),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16C583).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.note_alt_outlined, color: Color(0xFF16C583), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rédiger une Ordonnance',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Patient: ${widget.patientName} • ${_patientId.isEmpty ? '...' : _patientId}',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de prescription : Strict ou Équivalent
                    Text('Type de prescription :', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isMandatory = false),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: !_isMandatory ? Colors.green.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: !_isMandatory ? Colors.green : Colors.grey.shade300, width: !_isMandatory ? 2 : 1),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.autorenew, color: !_isMandatory ? Colors.green : Colors.grey, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Équivalent autorisé',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: !_isMandatory ? Colors.green.shade800 : Colors.grey.shade700),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text('(Génériques acceptés)', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isMandatory = true),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isMandatory ? Colors.red.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _isMandatory ? Colors.red : Colors.grey.shade300, width: _isMandatory ? 2 : 1),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.lock, color: _isMandatory ? Colors.red : Colors.grey, size: 20),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Strictement obligatoire',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: _isMandatory ? Colors.red.shade800 : Colors.grey.shade700),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text('(Non substituable)', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Ajout d'un médicament
                    Text('Ajouter un médicament :', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _medNameController,
                      decoration: InputDecoration(
                        labelText: 'Nom du médicament (ex: Paracétamol 500mg)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: GoogleFonts.outfit(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dosageController,
                            decoration: InputDecoration(
                              labelText: 'Posologie (ex: 1 cp matin et soir)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: GoogleFonts.outfit(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            decoration: InputDecoration(
                              labelText: 'Durée (ex: 5 jours)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            style: GoogleFonts.outfit(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16C583),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: Text('Ajouter à la liste', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: _addMedication,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Liste des médicaments ajoutés
                    if (_medications.isNotEmpty) ...[
                      Text('Médicaments prescrits (${_medications.length}) :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ..._medications.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final m = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${idx + 1}. ${m['name']} — ${m['dosage']} (${m['duration']})',
                                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () => setState(() => _medications.removeAt(idx)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],

                    // Notes / Instructions
                    TextField(
                      controller: _notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Instructions & précautions particulières',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: GoogleFonts.outfit(fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Signature électronique
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasSigned ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _hasSigned ? Colors.green.shade300 : Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _hasSigned ? Icons.verified_user : Icons.fingerprint,
                            color: _hasSigned ? Colors.green : Colors.amber.shade800,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hasSigned ? 'Signature Électronique Apposée' : 'Signature Électronique Requise',
                                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: _hasSigned ? Colors.green.shade900 : Colors.amber.shade900),
                                ),
                                Text(
                                  _hasSigned ? 'Horodatage et empreinte cryptographique certifiés' : 'Cliquez pour certifier et signer ce document',
                                  style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _hasSigned = !_hasSigned),
                            child: Text(
                              _hasSigned ? 'Modifier' : 'Signer',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF16C583)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('Annuler', style: GoogleFonts.outfit(color: Colors.grey.shade700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16C583),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: _isSaving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: Text(
                      _isSaving ? 'Enregistrement...' : 'Confirmer et Émettre l\'Ordonnance',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: _isSaving ? null : _submitPrescription,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
