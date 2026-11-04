import '/components/agenda_card_widget.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_agenda_model.dart';
export 'clinic_agenda_model.dart';

class ClinicAgendaWidget extends StatefulWidget {
  const ClinicAgendaWidget({super.key});

  static String routeName = 'ClinicAgenda';
  static String routePath = '/clinicAgenda';

  @override
  State<ClinicAgendaWidget> createState() => _ClinicAgendaWidgetState();
}

class _ClinicAgendaWidgetState extends State<ClinicAgendaWidget>
    with TickerProviderStateMixin {
  late ClinicAgendaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicAgendaModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'clinique');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F766E),
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
                      color: FlutterFlowTheme.of(context).secondaryBackground,
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
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
                      color: FlutterFlowTheme.of(context).secondaryBackground,
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
        body: SafeArea(
          child: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Title row
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
                        Expanded(
                          child: Text(
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
                                  color: FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleLarge
                                      .fontStyle,
                                  lineHeight: 1.4,
                                ),
                          ),
                        ),
                      ].divide(SizedBox(width: 8.0)),
                    ),
                  ),
                  // Tabs + TabBarView
                  Expanded(
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
                            unselectedLabelStyle:
                                FlutterFlowTheme.of(context).titleMedium,
                            indicatorColor:
                                FlutterFlowTheme.of(context).tertiary,
                            tabs: [
                              Tab(text: 'Aujourd\'hui'),
                              Tab(text: 'A venir'),
                            ],
                            controller: _model.tabBarController,
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('appointments')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: const Color(0xFF0F766E),
                                  ),
                                );
                              }
                              final allDocs = snapshot.data?.docs.where((doc) {
                                final data = doc.data();
                                final clinicId = data['clinic_uid'] as String?;
                                final doctorId = data['doctor_uid'] as String?;
                                return (clinicId != null && clinicId == currentUserUid) ||
                                    (doctorId != null && doctorId == currentUserUid);
                              }).toList() ?? [];

                              final now = DateTime.now();
                              final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                              final todayDocs = allDocs.where((doc) {
                                final data = doc.data();
                                final day = (data['day'] as String?) ?? '';
                                final aptDate = data['appointment_date'];
                                if (day.contains(todayStr)) return true;
                                if (aptDate is Timestamp) {
                                  final d = aptDate.toDate();
                                  return d.year == now.year && d.month == now.month && d.day == now.day;
                                }
                                return true;
                              }).toList();

                              final upcomingDocs = allDocs.where((doc) {
                                final data = doc.data();
                                final status = (data['status'] as String? ?? 'pending').toLowerCase();
                                return status != 'completed' && status != 'cancelled';
                              }).toList();

                              Widget buildAptList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, String emptyMsg) {
                                if (docs.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.event_busy_outlined, size: 48, color: FlutterFlowTheme.of(context).secondaryText),
                                          const SizedBox(height: 12),
                                          Text(emptyMsg, style: GoogleFonts.outfit(fontSize: 16, color: FlutterFlowTheme.of(context).secondaryText)),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
                                  itemCount: docs.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data();
                                    final patientName = (data['patient_name'] as String?)?.trim().isNotEmpty == true
                                        ? data['patient_name'] as String
                                        : ((data['userName'] as String?) ?? 'Patient');
                                    final patientUid = (data['patient_uid'] as String?) ?? (data['patient_id'] as String?) ?? docs[index].id;
                                    final patientPhoto = (data['patient_photo'] as String?) ?? (data['photo_url'] as String?);
                                    final sympto = (data['symptoms'] as String?) ?? (data['motif'] as String?) ?? 'Consultation';
                                    final type = (data['consult_mode'] as String?) ?? (data['appointment_type'] as String?) ?? 'Clinique';
                                    DateTime? aptTime;
                                    final rawDate = data['appointment_date'] ?? data['created_at'];
                                    if (rawDate is Timestamp) {
                                      aptTime = rawDate.toDate();
                                    } else {
                                      aptTime = DateTime.now();
                                    }

                                    return AgendaCardWidget(
                                      patientName: patientName,
                                      photo: patientPhoto,
                                      time: aptTime,
                                      sympto: sympto,
                                      type: type,
                                      onClick: () async {
                                        context.pushNamed(
                                          ClinicDMPWidget.routeName,
                                          queryParameters: {
                                            if (patientUid.isNotEmpty) 'patientUid': patientUid,
                                            'patientName': patientName,
                                            if (patientPhoto != null && patientPhoto.isNotEmpty) 'patientPhoto': patientPhoto,
                                            'symptoms': sympto,
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              }

                              return TabBarView(
                                controller: _model.tabBarController,
                                children: [
                                  buildAptList(todayDocs, 'Aucun rendez-vous pour aujourd\'hui'),
                                  buildAptList(upcomingDocs, 'Aucun rendez-vous à venir'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90.0), // Padding for bottom nav bar
                ],
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: wrapWithModel(
                      model: _model.navBarClinicModel,
                      updateCallback: () => safeSetState(() {}),
                      child: NavBarClinicWidget(),
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
