import '/components/agenda_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/notification_service.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agenda_model.dart';
export 'agenda_model.dart';

class AgendaWidget extends StatefulWidget {
  const AgendaWidget({super.key});

  static String routeName = 'Agenda';
  static String routePath = '/agenda';

  @override
  State<AgendaWidget> createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget>
    with TickerProviderStateMixin {
  late AgendaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<List<AppointmentsRecord>>? _pendingAppointmentsStream;
  Stream<List<AppointmentsRecord>>? _confirmedAppointmentsStream;
  String? _lastLoadedUid;

  void _initStreams() {
    final uid = currentUserUid;
    if (uid.isNotEmpty && uid != _lastLoadedUid) {
      _lastLoadedUid = uid;
      _pendingAppointmentsStream = queryAppointmentsRecord(
        queryBuilder: (q) => q.where('status', isEqualTo: 'pending'),
        limit: 50,
      );
      _confirmedAppointmentsStream = queryAppointmentsRecord(
        queryBuilder: (q) => q.where('status', whereIn: ['confirmed', 'rescheduled', 'cancelled', 'refused']),
        limit: 50,
      );
    } else if (uid.isEmpty) {
      _lastLoadedUid = null;
      _pendingAppointmentsStream = null;
      _confirmedAppointmentsStream = null;
    }
  }

  
  Future<void> _rescheduleAppointment(BuildContext context, AppointmentsRecord appt) async {
    final dayController = TextEditingController(text: appt.day.isNotEmpty ? appt.day : 'Demain');
    final timeController = TextEditingController(text: appt.timeSlot.isNotEmpty ? appt.timeSlot : '10h00 - 10h30');
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.schedule_send_rounded, color: Color(0xFFE67E22)),
            SizedBox(width: 8),
            Text('Reporter le rendez-vous', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient : ${appt.patientName.isNotEmpty ? appt.patientName : "Patient"}',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: FlutterFlowTheme.of(context).primaryText),
              ),
              SizedBox(height: 14),
              TextField(
                controller: dayController,
                decoration: InputDecoration(
                  labelText: 'Nouvelle date (ex: Demain, 26 Octobre)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Nouveau créneau (ex: 11h - 11h30)',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Motif du report (visible par le patient)',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Annuler', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE67E22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newDay  = dayController.text.trim();
              final newSlot = timeController.text.trim();
              final note    = noteController.text.trim();
              await appt.reference.update({
                'status': 'rescheduled',
                'rescheduled_day': newDay,
                'rescheduled_slot': newSlot,
                'rescheduled_note': note,
                'updated_at': FieldValue.serverTimestamp(),
              });

              // ── Notification → Patient ──
              if (appt.patientId.isNotEmpty) {
                await NotificationService.sendNotification(
                  recipientUid: appt.patientId,
                  title: '📅 Rendez-vous reporté',
                  message: 'Le Dr. ${currentUserDisplayName.isNotEmpty ? currentUserDisplayName : "votre médecin"} a reporté votre rendez-vous au $newDay à $newSlot.${note.isNotEmpty ? " Motif : $note" : ""}',
                  type: 'appointment',
                  referenceId: appt.reference.id,
                );
              }
              // ── Notification → Médecin (confirmation de son action) ──
              await NotificationService.sendNotification(
                recipientUid: currentUserUid,
                title: '✅ Report envoyé',
                message: 'Vous avez reporté le rendez-vous de ${appt.patientName.isNotEmpty ? appt.patientName : "Patient"} au $newDay à $newSlot.',
                type: 'appointment',
                referenceId: appt.reference.id,
              );

              if (dCtx.mounted) Navigator.pop(dCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rendez-vous reporté — le patient a été notifié ✓'),
                    backgroundColor: Color(0xFFE67E22),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            child: Text('Confirmer le report', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPatientMedicalRecordDialog(BuildContext context, AppointmentsRecord appt) {
    final docs = List<Map<String, dynamic>>.from(
      appt.medicalDocuments.map((e) => Map<String, dynamic>.from(e as Map)),
    );
    // Tri chronologique décroissant (du plus récent au plus ancien)
    docs.sort((a, b) {
      final int tA = a['timestamp'] as int? ?? 0;
      final int tB = b['timestamp'] as int? ?? 0;
      return tB.compareTo(tA);
    });

    final crList = docs.where((d) => (d['category'] as String? ?? '').contains('Compte-rendu')).toList();
    final bioList = docs.where((d) => (d['category'] as String? ?? '').contains('biologiques') || (d['category'] as String? ?? '').contains('imagerie')).toList();
    final ordoList = docs.where((d) => (d['category'] as String? ?? '').contains('Ordonnances') || (d['category'] as String? ?? '').contains('traitements')).toList();
    final otherList = docs.where((d) => !crList.contains(d) && !bioList.contains(d) && !ordoList.contains(d)).toList();

    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.folder_shared_rounded, color: Color(0xFF165AC5), size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dossier patient — ${appt.patientName.isNotEmpty ? appt.patientName : "Patient"}',
                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (appt.appointmentCause.isNotEmpty) ...[
                  Text('Cause principale du rendez-vous :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF165AC5))),
                  SizedBox(height: 2),
                  Text(appt.appointmentCause, style: GoogleFonts.outfit(fontSize: 12)),
                  SizedBox(height: 10),
                ],
                if (appt.symptoms.isNotEmpty) ...[
                  Text('Signes & symptômes actuels :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8A0DCE))),
                  SizedBox(height: 2),
                  Text(appt.symptoms, style: GoogleFonts.outfit(fontSize: 12)),
                  SizedBox(height: 10),
                ],
                if (appt.hasMedicalRecord) ...[
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF00A651).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF00A651).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: Color(0xFF00A651), size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Le patient possède un dossier médical antérieur. Importation de l\'historique activée.',
                            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF00A651)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                ],
                Text(
                  'Pièces classées par catégorie & chronologie :',
                  style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // 1. Comptes-rendus
                _buildCategoryGroup(
                  '1. Comptes-rendus (Consultation & Hospitalisation)',
                  crList,
                  Color(0xFF165AC5),
                  Icons.description_outlined,
                ),
                SizedBox(height: 10),

                // 2. Examens bio & imagerie
                _buildCategoryGroup(
                  '2. Examens biologiques & Imagerie (Radios, IRM)',
                  bioList,
                  Color(0xFF8A0DCE),
                  Icons.biotech_outlined,
                ),
                SizedBox(height: 10),

                // 3. Ordonnances & traitements
                _buildCategoryGroup(
                  '3. Ordonnances & Suivis de traitements',
                  ordoList,
                  Color(0xFF00A651),
                  Icons.medication_outlined,
                ),
                if (otherList.isNotEmpty) ...[
                  SizedBox(height: 10),
                  _buildCategoryGroup(
                    'Autres documents',
                    otherList,
                    Colors.grey.shade700,
                    Icons.attach_file,
                  ),
                ],
                if (docs.isEmpty && !appt.hasMedicalRecord)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Aucune pièce jointe transmise pour ce rendez-vous.',
                      style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF165AC5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGroup(String title, List<Map<String, dynamic>> items, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('${items.length}', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            SizedBox(height: 6),
            ...items.map((item) {
              final isConfirmed = item['status'] == 'Confirmé';
              return Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      item['date'] ?? '',
                      style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF165AC5)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['title'] ?? 'Document',
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isConfirmed ? Color(0xFF00A651).withOpacity(0.12) : Color(0xFFE67E22).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['status'] ?? 'Confirmé',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isConfirmed ? Color(0xFF00A651) : Color(0xFFE67E22),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Aucune pièce dans cette catégorie.', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgendaModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _initStreams();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Garde-fou : cet espace est reserve aux comptes médecins.
      await guardRole(context, 'medecin');
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initStreams();

    if (currentUserUid.isEmpty) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).tertiary,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: Icon(
                      Icons.settings_outlined,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ),
                  Text(
                    'Mon Agenda',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleLarge.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed(
                        ProfileEditWidget.routeName,
                        queryParameters: {
                          'role': serializeParam(
                            'Doctor',
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    child: Icon(
                      Icons.edit_sharp,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 4.0,
        ),
        body: Container(
          height: double.infinity,
          child: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 14.0, 20.0, 12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 4.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: Color(0xFF165C40),
                              borderRadius: BorderRadius.circular(2.0),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          Text(
                            'Mes Rendez-vous',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.8,
                      decoration: BoxDecoration(),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment(-1.0, 0),
                            child: TabBar(
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor:
                                  FlutterFlowTheme.of(context).primaryText,
                              unselectedLabelColor:
                                  FlutterFlowTheme.of(context).secondaryText,
                              labelStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              unselectedLabelStyle: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                              indicatorColor:
                                  FlutterFlowTheme.of(context).tertiary,
                              tabs: [
                                Tab(
                                  text: 'Aujourd\'hui',
                                ),
                                Tab(
                                  text: 'A venir',
                                ),
                              ],
                              controller: _model.tabBarController,
                              onTap: (i) async {
                                [() async {}, () async {}][i]();
                              },
                            ),
                          ),
                           Expanded(
                            child: TabBarView(
                              controller: _model.tabBarController,
                              children: [
                                // ─── Onglet "Aujourd'hui" (status: pending) ───
                                StreamBuilder<List<AppointmentsRecord>>(
                                  stream: _pendingAppointmentsStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Text(
                                            'Aucun rendez-vous pour le moment',
                                            style: FlutterFlowTheme.of(context).labelMedium,
                                          ),
                                        ),
                                      );
                                    }
                                    final allAppts = List<AppointmentsRecord>.from(snapshot.data ?? []);
                                    final appointments = allAppts.where((a) {
                                      final docId = a.doctorId;
                                      final docName = a.doctorName;
                                      if (docId.isNotEmpty && currentUserUid.isNotEmpty && docId == currentUserUid) return true;
                                      if (docName.isNotEmpty && currentUserDisplayName.isNotEmpty && docName.toLowerCase() == currentUserDisplayName.toLowerCase()) return true;
                                      return docId.isEmpty && docName.isEmpty;
                                    }).toList()
                                      ..sort((a, b) => (b.createdAt ?? DateTime(0))
                                          .compareTo(a.createdAt ?? DateTime(0)));
                                    if (appointments.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.event_available_outlined,
                                                size: 56,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Aucun rendez-vous en attente',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .copyWith(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: EdgeInsets.all(24),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: appointments.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 14),
                                        itemBuilder: (context, idx) {
                                          final appt = appointments[idx];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .alternate,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 36,
                                                            height: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .accent2,
                                                              shape:
                                                                  BoxShape.circle,
                                                            ),
                                                            child: Icon(
                                                              Icons
                                                                  .person_outline,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primary,
                                                              size: 20,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                appt.patientName
                                                                        .isNotEmpty
                                                                    ? appt
                                                                        .patientName
                                                                    : 'Patient',
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .bodyMedium
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              ),
                                                              Text(
                                                                appt.appointmentType,
                                                                style: FlutterFlowTheme
                                                                        .of(context)
                                                                    .labelSmall
                                                                    .copyWith(
                                                                      color: FlutterFlowTheme
                                                                              .of(
                                                                                  context)
                                                                          .secondaryText,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFFFF3CD),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          'En attente',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFFF9800),
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Divider(height: 1),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons.today_outlined,
                                                          size: 16,
                                                          color:
                                                              Color(0xFF8A0DCE)),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        '${appt.day}  •  ${appt.timeSlot}',
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .labelSmall
                                                            .copyWith(
                                                              color: Color(
                                                                  0xFF8A0DCE),
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                            ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Icon(
                                                          Icons
                                                              .video_call_outlined,
                                                          size: 16,
                                                          color:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .success),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        appt.consultMode,
                                                        style: FlutterFlowTheme
                                                                .of(context)
                                                            .labelSmall
                                                            .copyWith(
                                                              color:
                                                                  FlutterFlowTheme
                                                                          .of(
                                                                              context)
                                                                      .success,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (appt.appointmentCause.isNotEmpty || appt.symptoms.isNotEmpty || appt.hasMedicalRecord || appt.medicalDocuments.isNotEmpty) ...[
                                                     SizedBox(height: 8),
                                                     Container(
                                                       width: double.infinity,
                                                       padding: EdgeInsets.all(8),
                                                       decoration: BoxDecoration(
                                                         color: FlutterFlowTheme.of(context).primaryBackground,
                                                         borderRadius: BorderRadius.circular(8),
                                                         border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                                       ),
                                                       child: Column(
                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                         children: [
                                                           if (appt.appointmentCause.isNotEmpty)
                                                             Text(
                                                               'Motif : ' + appt.appointmentCause,
                                                               style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF165AC5)),
                                                             ),
                                                           if (appt.symptoms.isNotEmpty)
                                                             Padding(
                                                               padding: EdgeInsets.only(top: 2),
                                                               child: Text(
                                                                 'Symptômes : ' + appt.symptoms,
                                                                 style: GoogleFonts.outfit(fontSize: 11, color: FlutterFlowTheme.of(context).primaryText),
                                                               ),
                                                             ),
                                                           SizedBox(height: 4),
                                                           InkWell(
                                                             onTap: () => _showPatientMedicalRecordDialog(context, appt),
                                                             child: Row(
                                                               mainAxisSize: MainAxisSize.min,
                                                               children: [
                                                                 Icon(Icons.folder_shared_outlined, size: 14, color: Color(0xFF8A0DCE)),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   appt.hasMedicalRecord ? 'Consulter dossier médical complet' : 'Voir les pièces du dossier (' + appt.medicalDocuments.length.toString() + ')',
                                                                   style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8A0DCE), decoration: TextDecoration.underline),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ],
                                                   SizedBox(height: 12),
                                                   Row(
                                                     children: [
                                                       // 1. Bouton Valider
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await appt.reference.update({
                                                               'status': 'confirmed',
                                                               'updated_at': FieldValue.serverTimestamp(),
                                                             });
                                                             if (context.mounted) {
                                                               ScaffoldMessenger.of(context).showSnackBar(
                                                                 SnackBar(
                                                                   content: Text('Rendez-vous validé avec succès ✓'),
                                                                   backgroundColor: Color(0xFF00A651),
                                                                   behavior: SnackBarBehavior.floating,
                                                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                 ),
                                                               );
                                                             }
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: Color(0xFF00A651),
                                                               borderRadius: BorderRadius.circular(8),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Valider',
                                                                   style: TextStyle(
                                                                     color: Colors.white,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // 2. Bouton Reporter
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await _rescheduleAppointment(context, appt);
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: Color(0xFFE67E22),
                                                               borderRadius: BorderRadius.circular(8),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.schedule, color: Colors.white, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Reporter',
                                                                   style: TextStyle(
                                                                     color: Colors.white,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // 3. Bouton Refuser
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             final confirm = await showDialog<bool>(
                                                               context: context,
                                                               builder: (dCtx) => AlertDialog(
                                                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                                 title: Text('Refuser le rendez-vous ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                                                 content: Text('Le patient sera averti que sa demande a été refusée.'),
                                                                 actions: [
                                                                   TextButton(
                                                                     onPressed: () => Navigator.pop(dCtx, false),
                                                                     child: Text('Annuler', style: TextStyle(color: Colors.grey.shade600)),
                                                                   ),
                                                                   ElevatedButton(
                                                                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                                     onPressed: () => Navigator.pop(dCtx, true),
                                                                     child: Text('Refuser'),
                                                                   ),
                                                                 ],
                                                               ),
                                                             );
                                                             if (confirm == true) {
                                                               await appt.reference.update({
                                                                 'status': 'refused',
                                                                 'updated_at': FieldValue.serverTimestamp(),
                                                               });
                                                              // ── Notification → Patient ──
                                                              if (appt.patientId.isNotEmpty) {
                                                                await NotificationService.sendNotification(
                                                                  recipientUid: appt.patientId,
                                                                  title: '❌ Rendez-vous refusé',
                                                                  message: 'Le Dr. ${currentUserDisplayName.isNotEmpty ? currentUserDisplayName : "votre médecin"} ne peut malheureusement pas accepter ce rendez-vous.',
                                                                  type: 'appointment',
                                                                  referenceId: appt.reference.id,
                                                                );
                                                              }

                                                              
                                                               if (context.mounted) {
                                                                 ScaffoldMessenger.of(context).showSnackBar(
                                                                   SnackBar(
                                                                     content: Text('Rendez-vous refusé.'),
                                                                     backgroundColor: Colors.red,
                                                                     behavior: SnackBarBehavior.floating,
                                                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                   ),
                                                                 );
                                                               }
                                                             }
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: FlutterFlowTheme.of(context).primaryBackground,
                                                               borderRadius: BorderRadius.circular(8),
                                                               border: Border.all(color: Colors.red.shade300),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Refuser',
                                                                   style: TextStyle(
                                                                     color: Colors.red.shade600,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                // ─── Onglet "À venir" (status: confirmed) ─────
                                StreamBuilder<List<AppointmentsRecord>>(
                                  stream: _confirmedAppointmentsStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: FlutterFlowTheme.of(context)
                                              .tertiary,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Text(
                                            'Aucun rendez-vous pour le moment',
                                            style: FlutterFlowTheme.of(context).labelMedium,
                                          ),
                                        ),
                                      );
                                    }
                                    final allAppts = List<AppointmentsRecord>.from(snapshot.data ?? []);
                                    final appointments = allAppts.where((a) {
                                      final docId = a.doctorId;
                                      final docName = a.doctorName;
                                      if (docId.isNotEmpty && currentUserUid.isNotEmpty && docId == currentUserUid) return true;
                                      if (docName.isNotEmpty && currentUserDisplayName.isNotEmpty && docName.toLowerCase() == currentUserDisplayName.toLowerCase()) return true;
                                      return docId.isEmpty && docName.isEmpty;
                                    }).toList()
                                      ..sort((a, b) => (b.createdAt ?? DateTime(0))
                                          .compareTo(a.createdAt ?? DateTime(0)));
                                    if (appointments.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 56,
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                              ),
                                              SizedBox(height: 16),
                                              Text(
                                                'Aucun rendez-vous confirmé',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .copyWith(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return Padding(
                                      padding: EdgeInsets.all(24),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: appointments.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 14),
                                        itemBuilder: (context, idx) {
                                          final appt = appointments[idx];
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context)
                                                  .secondaryBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Color(0xFF00A651)
                                                    .withOpacity(0.3),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(14),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Color(0xFFE8F5E9),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          Color(0xFF00A651),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          appt.patientName
                                                                  .isNotEmpty
                                                              ? appt.patientName
                                                              : 'Patient',
                                                          style:
                                                              FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          '${appt.day}  •  ${appt.timeSlot}  •  ${appt.consultMode}',
                                                          style:
                                                              FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelSmall
                                                                  .copyWith(
                                                                    color: FlutterFlowTheme
                                                                            .of(
                                                                                context)
                                                                        .secondaryText,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      final st = appt.status;
                                                      Color bg = Color(0xFFE8F5E9);
                                                      Color txt = Color(0xFF00A651);
                                                      String label = 'Confirmé';
                                                      if (st == 'rescheduled') {
                                                        bg = Color(0xFFFFF3CD);
                                                        txt = Color(0xFFE67E22);
                                                        label = 'Reporté';
                                                      } else if (st == 'refused') {
                                                        bg = Color(0xFFFFEBEE);
                                                        txt = Colors.red.shade700;
                                                        label = 'Refusé';
                                                      } else if (st == 'cancelled') {
                                                        bg = Color(0xFFEEEEEE);
                                                        txt = Colors.grey.shade700;
                                                        label = 'Annulé';
                                                      }
                                                      return Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: bg,
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Text(
                                                              label,
                                                              style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                          if (st == 'confirmed') ...[
                                                            SizedBox(width: 6),
                                                            InkWell(
                                                              onTap: () => _rescheduleAppointment(context, appt),
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Color(0xFFE67E22).withOpacity(0.12),
                                                                  borderRadius: BorderRadius.circular(6),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(Icons.schedule, size: 12, color: Color(0xFFE67E22)),
                                                                    SizedBox(width: 3),
                                                                    Text('Reporter', style: TextStyle(color: Color(0xFFE67E22), fontSize: 10, fontWeight: FontWeight.bold)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Container(
                      height: 72.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context
                                        .pushNamed(HomeDoctorWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_rounded,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Accueil',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        ConsultationWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.personal_video,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Consultation',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: 0.0 * (math.pi / 180),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                      ProfileEditWidget.routeName,
                                      queryParameters: {
                                        'role': serializeParam(
                                          'Doctor',
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: Container(
                                    width: 56.0,
                                    height: 56.0,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        FlutterFlowTheme.of(context)
                                            .designToken
                                            .shadow
                                            .lg
                                      ],
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context).primary,
                                          Color(0xFF0EE796)
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(1.0, -1.0),
                                        end: AlignmentDirectional(-1.0, 1.0),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(9999.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.edit_calendar_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      size: 28.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(VisiteWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Visite',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(AgendaWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bookmarks_outlined,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Agenda',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
