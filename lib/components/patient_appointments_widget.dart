import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientAppointmentsWidget extends StatefulWidget {
  const PatientAppointmentsWidget({super.key});

  @override
  State<PatientAppointmentsWidget> createState() => _PatientAppointmentsWidgetState();
}

class _PatientAppointmentsWidgetState extends State<PatientAppointmentsWidget> {
  String _selectedFilter = 'all'; // 'all', 'confirmed', 'pending', 'rescheduled'

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;
    final email = currentUserEmail;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF165AC5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.calendar_month_rounded, color: Color(0xFF165AC5), size: 22),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes Rendez-vous',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                        Text(
                          'Statut de vos consultations en direct',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tous'),
                _buildFilterChip('confirmed', 'Validés'),
                _buildFilterChip('rescheduled', 'Reportés'),
                _buildFilterChip('pending', 'En attente'),
                _buildFilterChip('refused', 'Refusés'),
              ],
            ),
          ),
          // Appointments stream
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF165AC5)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Erreur de chargement: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                // Filter for current patient
                final myAppts = docs.where((d) {
                  final data = d.data();
                  final pId = data['patient_id'] as String?;
                  final pEmail = data['patient_email'] as String?;
                  final pRef = data['patient_ref'] as DocumentReference?;

                  final matchId = (pId != null && uid.isNotEmpty && pId == uid);
                  final matchEmail = (pEmail != null && email.isNotEmpty && pEmail.toLowerCase() == email.toLowerCase());
                  final matchRef = (pRef != null && currentUserReference != null && pRef.path == currentUserReference?.path);

                  return matchId || matchEmail || matchRef;
                }).toList();

                // Sort newest first
                myAppts.sort((a, b) {
                  final ta = (a.data()['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final tb = (b.data()['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return tb.compareTo(ta);
                });

                // Apply status filter
                final filtered = myAppts.where((doc) {
                  if (_selectedFilter == 'all') return true;
                  final st = doc.data()['status'] as String? ?? 'pending';
                  if (_selectedFilter == 'refused') {
                    return st == 'refused' || st == 'cancelled';
                  }
                  return st == _selectedFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 56, color: Colors.grey.shade400),
                          SizedBox(height: 14),
                          Text(
                            _selectedFilter == 'all'
                                ? 'Aucun rendez-vous trouvé'
                                : 'Aucun rendez-vous dans cette catégorie',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Vos consultations apparaîtront ici dès que vous aurez réservé un créneau.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final doc = filtered[idx];
                    final data = doc.data();
                    return _buildAppointmentCard(doc.reference, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        selected: isSelected,
        selectedColor: Color(0xFF165AC5),
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (val) {
          if (val) setState(() => _selectedFilter = key);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(DocumentReference ref, Map<String, dynamic> data) {
    final doctorName = (data['doctor_name'] as String?)?.isNotEmpty == true
        ? data['doctor_name'] as String
        : 'Docteur';
    final type = data['appointment_type'] as String? ?? 'Consultation';
    final consultMode = data['consult_mode'] as String? ?? 'cabinet';
    final day = data['day'] as String? ?? 'Date non définie';
    final slot = data['time_slot'] as String? ?? '';
    final status = data['status'] as String? ?? 'pending';

    // Rescheduled details
    final reschedDay = data['rescheduled_day'] as String? ?? '';
    final reschedSlot = data['rescheduled_slot'] as String? ?? '';
    final reschedNote = data['rescheduled_note'] as String? ?? '';

    // Status visual configuration
    Color statusBg;
    Color statusFg;
    IconData statusIcon;
    String statusTitle;
    String statusDescription;

    if (status == 'confirmed') {
      statusBg = Color(0xFFE8F5E9);
      statusFg = Color(0xFF00A651);
      statusIcon = Icons.check_circle_rounded;
      statusTitle = 'Validé par le médecin';
      statusDescription = 'Votre rendez-vous est confirmé par le docteur.';
    } else if (status == 'rescheduled') {
      statusBg = Color(0xFFFFF3CD);
      statusFg = Color(0xFFE67E22);
      statusIcon = Icons.update_rounded;
      statusTitle = 'Reporté par le médecin';
      statusDescription = reschedDay.isNotEmpty
          ? 'Nouveau créneau proposé : $reschedDay ${reschedSlot.isNotEmpty ? "à $reschedSlot" : ""}'
          : 'Le médecin a proposé une nouvelle date.';
    } else if (status == 'refused' || status == 'cancelled') {
      statusBg = Color(0xFFFFEBEE);
      statusFg = Color(0xFFE74C3C);
      statusIcon = Icons.cancel_rounded;
      statusTitle = status == 'refused' ? 'Refusé par le médecin' : 'Annulé';
      statusDescription = 'Le médecin n\'a pas pu valider ce rendez-vous.';
    } else {
      statusBg = Color(0xFFE3F2FD);
      statusFg = Color(0xFF1976D2);
      statusIcon = Icons.hourglass_top_rounded;
      statusTitle = 'En attente de validation';
      statusDescription = 'Le docteur va examiner et confirmer votre demande sous peu.';
    }

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'confirmed'
              ? Color(0xFF00A651).withOpacity(0.3)
              : status == 'rescheduled'
                  ? Color(0xFFE67E22).withOpacity(0.4)
                  : FlutterFlowTheme.of(context).alternate,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Doctor info and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF165AC5).withOpacity(0.12),
                  child: Icon(Icons.person_pin_rounded, color: Color(0xFF165AC5), size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName.startsWith('Dr') ? doctorName : 'Dr. $doctorName',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primaryText,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        type,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusFg.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusFg),
                      SizedBox(width: 4),
                      Text(
                        statusTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(height: 1),
            SizedBox(height: 10),

            // Date, time & mode row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF8A0DCE)),
                SizedBox(width: 6),
                Text(
                  '$day ${slot.isNotEmpty ? "• $slot" : ""}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A0DCE),
                  ),
                ),
                Spacer(),
                Icon(
                  consultMode == 'domicile'
                      ? Icons.home_outlined
                      : consultMode == 'teleconsultation'
                          ? Icons.videocam_outlined
                          : Icons.local_hospital_outlined,
                  size: 15,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
                SizedBox(width: 4),
                Text(
                  consultMode == 'domicile'
                      ? 'À domicile'
                      : consultMode == 'teleconsultation'
                          ? 'Téléconsultation'
                          : 'Au cabinet',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),

            // Explanatory banner
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusFg),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusDescription,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusFg,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'rescheduled' && reschedNote.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      'Motif : $reschedNote',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFB9770E),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Option to cancel pending appointment
            if (status == 'pending') ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (cCtx) => AlertDialog(
                        title: Text('Annuler cette demande ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        content: Text('Voulez-vous vraiment annuler cette demande de rendez-vous ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(cCtx, false),
                            child: Text('Non, garder'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () => Navigator.pop(cCtx, true),
                            child: Text('Oui, annuler'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.update({
                        'status': 'cancelled',
                        'updated_at': FieldValue.serverTimestamp(),
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Demande annulée.'),
                            backgroundColor: Colors.grey.shade800,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(Icons.close, size: 14, color: Colors.grey.shade600),
                  label: Text(
                    'Annuler ma demande',
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
