import '/components/patient_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
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
            ].divide(SizedBox(height: 10.0)),
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
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 14.0, 20.0, 12.0),
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
                  ].divide(SizedBox(width: 8.0)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(ClinicDMPWidget.routeName);
                      },
                      child: wrapWithModel(
                        model: _model.patientCardModel1,
                        updateCallback: () => safeSetState(() {}),
                        child: PatientCardWidget(
                          photo:
                              'https://images.unsplash.com/photo-1489278353717-f64c6ee8a4d2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHxzbWlsZSUyMHxlbnwwfHx8fDE3ODYwODY1NzV8MA&ixlib=rb-4.1.0&q=80&w=1080',
                          name: '',
                          sympto: '',
                          type: 'Domicile',
                          tagBg: FlutterFlowTheme.of(context).warning,
                        ),
                      ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(ClinicDMPWidget.routeName);
                      },
                      child: wrapWithModel(
                        model: _model.patientCardModel2,
                        updateCallback: () => safeSetState(() {}),
                        child: PatientCardWidget(
                          photo:
                              'https://images.unsplash.com/photo-1489278353717-f64c6ee8a4d2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxfHxzbWlsZSUyMHxlbnwwfHx8fDE3ODYwODY1NzV8MA&ixlib=rb-4.1.0&q=80&w=1080',
                          name: '',
                          sympto: '',
                          type: 'Domicile',
                          tagBg: FlutterFlowTheme.of(context).warning,
                        ),
                      ),
                    ),
                  ].divide(SizedBox(height: 14.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
