import '/components/labo_card_widget.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/components/suivie_card_widget.dart';
import '/components/track_card_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_labo_model.dart';
export 'clinic_labo_model.dart';

class ClinicLaboWidget extends StatefulWidget {
  const ClinicLaboWidget({super.key});

  static String routeName = 'ClinicLabo';
  static String routePath = '/clinicLabo';

  @override
  State<ClinicLaboWidget> createState() => _ClinicLaboWidgetState();
}

class _ClinicLaboWidgetState extends State<ClinicLaboWidget>
    with TickerProviderStateMixin {
  late ClinicLaboModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicLaboModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
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
        backgroundColor: Color(0xFFF8F9FA),
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
                    'Mon Laboratoire',
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
                  // Header "EXAMENS & ANALYSES"
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
                            'EXAMENS & ANALYSES',
                            style: FlutterFlowTheme.of(context)
                                .titleLarge
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryText,
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
                  // TabBar + TabBarView
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
                                const Color(0xFF0F766E),
                            tabs: [
                              Tab(text: 'Imagerie'),
                              Tab(text: 'Biologie'),
                              Tab(text: 'Suivie'),
                            ],
                            controller: _model.tabBarController,
                            onTap: (i) async {
                              [() async {}, () async {}, () async {}][i]();
                            },
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _model.tabBarController,
                            children: [
                              // ─── Tab 1 : IMAGERIE ───
                              _buildLaboTab(
                                chips: [
                                  ChipData('Radio'),
                                  ChipData('Echographie'),
                                  ChipData('Endoscopie'),
                                  ChipData('IRM'),
                                  ChipData('Mammographie'),
                                  ChipData('ECG'),
                                  ChipData('Scanner'),
                                ],
                                chipController: _model
                                        .choiceChipsValueController1 ??=
                                    FormFieldController<List<String>>([]),
                                onChipChanged: (val) => safeSetState(
                                    () => _model.choiceChipsValue1 =
                                        val?.firstOrNull),
                                selectedValue: _model.choiceChipsValue1,
                                orderType: 'imagerie',
                              ),

                              // ─── Tab 2 : BIOLOGIE ───
                              _buildLaboTab(
                                chips: [
                                  ChipData('VIH'),
                                  ChipData('Bilan rénal'),
                                  ChipData('Glycémie'),
                                  ChipData('NFS'),
                                  ChipData('GERH'),
                                  ChipData('Bilan hépatique'),
                                  ChipData('Groupe sanguin'),
                                ],
                                chipController: _model
                                        .choiceChipsValueController2 ??=
                                    FormFieldController<List<String>>([]),
                                onChipChanged: (val) => safeSetState(
                                    () => _model.choiceChipsValue2 =
                                        val?.firstOrNull),
                                selectedValue: _model.choiceChipsValue2,
                                orderType: 'biologie',
                              ),

                              // ─── Tab 3 : SUIVIE ───
                              _buildSuivieTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom padding for NavBar
                  SizedBox(height: 90.0),
                ],
              ),
              // NavBar overlay
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

  /// Construit un onglet Imagerie ou Biologie connecté à Firestore.
  Widget _buildLaboTab({
    required List<ChipData> chips,
    required FormFieldController<List<String>> chipController,
    required void Function(List<String>?) onChipChanged,
    required String? selectedValue,
    required String orderType,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: 10.0),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
          child: FlutterFlowChoiceChips(
            options: chips,
            onChanged: onChipChanged,
            selectedChipStyle: ChipStyle(
              backgroundColor: const Color(0xFF0F766E),
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    letterSpacing: 0.0,
                  ),
              iconColor: FlutterFlowTheme.of(context).secondaryBackground,
              iconSize: 16.0,
              elevation: 0.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
            unselectedChipStyle: ChipStyle(
              backgroundColor:
                  FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.outfit(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
              iconColor: FlutterFlowTheme.of(context).secondaryText,
              iconSize: 16.0,
              elevation: 0.0,
              borderRadius: BorderRadius.circular(8.0),
            ),
            chipSpacing: 8.0,
            rowSpacing: 8.0,
            multiselect: false,
            alignment: WrapAlignment.start,
            controller: chipController,
            wrapped: true,
          ),
        ),
        SizedBox(height: 8.0),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lab_orders')
                .where('clinic_uid', isEqualTo: currentUserUid)
                .where('order_type', isEqualTo: orderType)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF0F766E),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Filtre chip si sélectionné
              final filtered = selectedValue != null && selectedValue.isNotEmpty
                  ? docs.where((d) {
                      final examName = ((d.data()
                                  as Map<String, dynamic>)['exam_name'] ??
                              '')
                          .toString()
                          .toLowerCase();
                      return examName.contains(selectedValue.toLowerCase());
                    }).toList()
                  : docs;

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.science_outlined,
                          size: 48,
                          color: FlutterFlowTheme.of(context).secondaryText),
                      SizedBox(height: 12),
                      Text(
                        'Aucun examen en attente',
                        style: GoogleFonts.outfit(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.all(16.0),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.0),
                itemBuilder: (context, i) {
                  final data =
                      filtered[i].data() as Map<String, dynamic>;
                  final patientName =
                      (data['patient_name'] as String?) ?? 'Patient';
                  final examName =
                      (data['exam_name'] as String?) ?? orderType;
                  final price = data['price'] ?? data['prix'] ?? 0;
                  final createdAt =
                      (data['created_at'] as Timestamp?)?.toDate() ??
                          DateTime.now();
                  final orderId = filtered[i].id;

                  return LaboCardWidget(
                    patient: patientName,
                    examenName: examName,
                    price: price is int ? price : int.tryParse(price.toString()) ?? 0,
                    date: createdAt,
                    sendOrder: () async {
                      await FirebaseFirestore.instance
                          .collection('lab_orders')
                          .doc(orderId)
                          .update({'status': 'accepted'});
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construit l'onglet Suivie connecté à Firestore.
  Widget _buildSuivieTab() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: AlignmentDirectional(-1.0, 0.0),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: FlutterFlowChoiceChips(
              options: [
                ChipData('En attente'),
                ChipData('En cours'),
                ChipData('Terminé'),
              ],
              onChanged: (val) => safeSetState(
                  () => _model.choiceChipsValue3 = val?.firstOrNull),
              selectedChipStyle: ChipStyle(
                backgroundColor: const Color(0xFF0F766E),
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      letterSpacing: 0.0,
                    ),
                iconColor: FlutterFlowTheme.of(context).secondaryBackground,
                iconSize: 16.0,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
              unselectedChipStyle: ChipStyle(
                backgroundColor:
                    FlutterFlowTheme.of(context).secondaryBackground,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.outfit(),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
                iconColor: FlutterFlowTheme.of(context).secondaryText,
                iconSize: 16.0,
                elevation: 0.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
              chipSpacing: 8.0,
              rowSpacing: 8.0,
              multiselect: false,
              alignment: WrapAlignment.start,
              controller: _model.choiceChipsValueController3 ??=
                  FormFieldController<List<String>>([]),
              wrapped: true,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lab_orders')
                .where('clinic_uid', isEqualTo: currentUserUid)
                .orderBy('created_at', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF0F766E),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // Filtre par statut si chip sélectionné
              final statusFilter = _model.choiceChipsValue3;
              final filtered = statusFilter != null && statusFilter.isNotEmpty
                  ? docs.where((d) {
                      final status = ((d.data()
                                  as Map<String, dynamic>)['status'] ??
                              '')
                          .toString()
                          .toLowerCase();
                      final filterLow = statusFilter.toLowerCase();
                      if (filterLow.contains('attente'))
                        return status == 'pending' || status == 'en attente';
                      if (filterLow.contains('cours'))
                        return status == 'accepted' || status == 'en cours';
                      if (filterLow.contains('termin'))
                        return status == 'done' || status == 'terminé';
                      return true;
                    }).toList()
                  : docs;

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 48,
                          color: FlutterFlowTheme.of(context).secondaryText),
                      SizedBox(height: 12),
                      Text(
                        'Aucun suivi disponible',
                        style: GoogleFonts.outfit(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.0),
                itemBuilder: (context, i) {
                  final data =
                      filtered[i].data() as Map<String, dynamic>;
                  final patientName =
                      (data['patient_name'] as String?) ??
                          (data['userName'] as String?) ??
                          'Patient';
                  final status =
                      (data['status'] as String?) ?? 'En attente';
                  final examType =
                      (data['exam_name'] as String?) ?? 'Examen';
                  final createdAt =
                      (data['created_at'] as Timestamp?)?.toDate();

                  return InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (ctx) {
                          return GestureDetector(
                            onTap: () {
                              FocusScope.of(ctx).unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            child: Padding(
                              padding:
                                  MediaQuery.viewInsetsOf(ctx),
                              child: TrackCardWidget(statu: status),
                            ),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    child: SuivieCardWidget(
                      patient: patientName,
                      exameType: examType,
                      statu: status,
                      time: createdAt,
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
}
