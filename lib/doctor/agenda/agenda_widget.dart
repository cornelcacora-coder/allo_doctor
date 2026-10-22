import '/components/agenda_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'dart:math' as math;
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgendaModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
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
                                  stream: queryAppointmentsRecord(
                                    queryBuilder: (q) => q
                                        .where('status', isEqualTo: 'pending')
                                        .orderBy('created_at', descending: true),
                                    limit: 20,
                                  ),
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
                                    final appointments =
                                        snapshot.data ?? [];
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
                                                  SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            await appt.reference
                                                                .update({
                                                              'status':
                                                                  'confirmed',
                                                              'updated_at': FieldValue
                                                                  .serverTimestamp(),
                                                            });
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'RDV confirmé ✓'),
                                                                backgroundColor:
                                                                    Color(
                                                                        0xFF00A651),
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                margin:
                                                                    EdgeInsets.all(
                                                                        16),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFF1E1458),
                                                                  Color(
                                                                      0xFF165AC5)
                                                                ],
                                                                begin:
                                                                    AlignmentDirectional(
                                                                        1, -1),
                                                                end:
                                                                    AlignmentDirectional(
                                                                        -1, 1),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Confirmer',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () async {
                                                            await appt.reference
                                                                .update({
                                                              'status':
                                                                  'cancelled',
                                                              'updated_at': FieldValue
                                                                  .serverTimestamp(),
                                                            });
                                                          },
                                                          child: Container(
                                                            height: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .primaryBackground,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade200),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                'Annuler',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red
                                                                      .shade600,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
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
                                  stream: queryAppointmentsRecord(
                                    queryBuilder: (q) => q
                                        .where('status', isEqualTo: 'confirmed')
                                        .orderBy('created_at', descending: true),
                                    limit: 20,
                                  ),
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
                                    final appointments =
                                        snapshot.data ?? [];
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
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Color(0xFFE8F5E9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      'Confirmé',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF00A651),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
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
