import '/components/patient_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_patients_model.dart';
export 'clinic_patients_model.dart';

class ClinicPatientsWidget extends StatefulWidget {
  const ClinicPatientsWidget({super.key});

  static String routeName = 'ClinicPatients';
  static String routePath = '/clinicPatients';

  @override
  State<ClinicPatientsWidget> createState() => _ClinicPatientsWidgetState();
}

class _ClinicPatientsWidgetState extends State<ClinicPatientsWidget> {
  late ClinicPatientsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicPatientsModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      // Garde-fou : cet espace est reserve aux comptes cliniques.
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
          backgroundColor: FlutterFlowTheme.of(context).warning,
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
                      Icons.arrow_back_ios_new,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 24.0,
                    ),
                  ),
                  Text(
                    'Mes Patients',
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
                  Icon(
                    Icons.more_vert_sharp,
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    size: 24.0,
                  ),
                ],
              ),
            ].divide(const SizedBox(height: 10.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 4.0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 4.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF165C40),
                        borderRadius: BorderRadius.circular(2.0),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Text(
                      'Mes Consultations',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
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
                  ].divide(const SizedBox(width: 8.0)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final docs = snapshot.data?.docs.where((doc) {
                      final data = doc.data();
                      final clinicId = data['clinic_uid'] as String?;
                      final doctorId = data['doctor_uid'] as String?;
                      return clinicId == currentUserUid ||
                          doctorId == currentUserUid ||
                          (clinicId == null && doctorId == null);
                    }).toList() ?? [];
                    final displayedDocs = _searchQuery.isEmpty ? docs : docs.where((doc) {
                      final data = doc.data();
                      final pName = (data['patient_name'] as String? ?? '').toLowerCase();
                      final day = (data['day'] as String? ?? '').toLowerCase();
                      final timeSlot = (data['time_slot'] as String? ?? '').toLowerCase();
                      return pName.contains(_searchQuery) || day.contains(_searchQuery) || timeSlot.contains(_searchQuery);
                    }).toList();

                    if (displayedDocs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: FlutterFlowTheme.of(context).secondaryText,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucun patient trouvé',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedDocs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14.0),
                      itemBuilder: (context, index) {
                        final data = displayedDocs[index].data();
                        final patientName = (data['patient_name'] as String?)?.trim().isNotEmpty == true
                            ? data['patient_name'] as String
                            : ((data['userName'] as String?) ?? 'Patient');
                        final patientPhoto = (data['patient_photo'] as String?) ??
                            (data['photoUrl'] as String?) ??
                            (data['photo_url'] as String?) ??
                            '';
                        final type = (data['consult_mode'] as String?) ??
                            (data['appointment_type'] as String?) ??
                            'Domicile';
                        final day = (data['day'] as String?) ?? '';
                        final timeSlot = (data['time_slot'] as String?) ?? '';
                        final sympto = day.isNotEmpty
                            ? (day + (timeSlot.isNotEmpty ? ' • $timeSlot' : ''))
                            : ((data['symptoms'] as String?) ?? 'Consultation');
                        final patientUid = (data['patient_uid'] as String?) ??
                            (data['patient_id'] as String?) ??
                            docs[index].id;

                        return InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.pushNamed(
                              ClinicDMPWidget.routeName,
                              queryParameters: {
                                if (patientUid.isNotEmpty) 'patientUid': patientUid,
                                'patientName': patientName,
                                if (patientPhoto.isNotEmpty) 'patientPhoto': patientPhoto,
                                'symptoms': sympto,
                              },
                            );
                          },
                          child: PatientCardWidget(
                            photo: patientPhoto,
                            name: patientName,
                            sympto: sympto,
                            type: type,
                            tagBg: FlutterFlowTheme.of(context).warning,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
