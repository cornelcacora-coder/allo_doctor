import '/components/clinic_card_widget.dart';
import '/components/get_medical_appointment_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_list_model.dart';
export 'clinic_list_model.dart';

class ClinicListWidget extends StatefulWidget {
  const ClinicListWidget({super.key});

  static String routeName = 'ClinicList';
  static String routePath = '/clinicList';

  @override
  State<ClinicListWidget> createState() => _ClinicListWidgetState();
}

class _ClinicListWidgetState extends State<ClinicListWidget> {
  late ClinicListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicListModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  List<String> _extractServices(Map<String, dynamic> data) {
    final raw = data['services'] ?? data['specialty'] ?? data['specialite'];
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString().trim().toLowerCase()).where((s) => s.isNotEmpty).toList();
    }
    if (raw is String) {
      return raw
          .split(RegExp(r'[,;•|\n]'))
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [raw.toString().trim().toLowerCase()];
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            backgroundColor: Color(0xFF4954F8),
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
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
                            Icons.arrow_back_ios_sharp,
                            color: FlutterFlowTheme.of(context).alternate,
                            size: 24.0,
                          ),
                        ),
                        Image.asset(
                          'assets/images/5987354.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          ' Cliniques & Examens',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).onPrimary,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                    Icon(
                      Icons.more_vert_sharp,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ],
                ),
                Text(
                  'Trouvez la clinique qui réalise votre examen',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).onprimary80,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodySmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        lineHeight: 1.5,
                      ),
                ),
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(9999.0),
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 6.0, 6.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: 200.0,
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                onChanged: (_) => safeSetState(() {}),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  safeSetState(() {});
                                },
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixIcon: (_model.textController?.text.isNotEmpty ?? false)
                                      ? IconButton(
                                          icon: Icon(Icons.clear_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 20),
                                          onPressed: () {
                                            _model.textController?.clear();
                                            safeSetState(() {});
                                          },
                                        )
                                      : null,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Recherchez une Clinique ...',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.search_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24.0,
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 10.0)),
            ),
            actions: [],
            centerTitle: false,
            toolbarHeight: double.infinity,
            elevation: 4.0,
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Container(
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TROUVER UN MEDECIN',
                                      style: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    FlutterFlowChoiceChips(
                                      options: [
                                        ChipData('Tous', Icons.person_outline),
                                        ChipData('Radio'),
                                        ChipData('Echographie'),
                                        ChipData('IRM'),
                                        ChipData('ECG'),
                                        ChipData('Analyse'),
                                        ChipData('Scanner')
                                      ],
                                      onChanged: (val) => safeSetState(() =>
                                          _model.choiceChipsValue =
                                              val?.firstOrNull),
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Color(0xFF165AC5),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        iconSize: 16.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        iconSize: 16.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      chipSpacing: 14.0,
                                      rowSpacing: 12.0,
                                      multiselect: false,
                                      alignment: WrapAlignment.start,
                                      controller:
                                          _model.choiceChipsValueController ??=
                                              FormFieldController<List<String>>(
                                        [],
                                      ),
                                      wrapped: true,
                                    ),
                                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                     stream: FirebaseFirestore.instance
                                         .collection('users')
                                         .where('role', isEqualTo: 'clinique')
                                         .snapshots(),
                                     builder: (context, snapshot) {
                                       if (snapshot.hasError) {
                                         return Center(
                                           child: Padding(
                                             padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Icon(Icons.local_hospital_outlined, size: 56.0, color: Color(0xFF165AC5)),
                                                 SizedBox(height: 12.0),
                                                 Text(
                                                   'Aucune clinique disponible',
                                                   textAlign: TextAlign.center,
                                                   style: FlutterFlowTheme.of(context).titleMedium.override(
                                                     font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                   ),
                                                 ),
                                                 SizedBox(height: 6.0),
                                                 Text(
                                                   'Les cliniques et centres de santé s\'afficheront ici dès qu\'ils seront ajoutés.',
                                                   textAlign: TextAlign.center,
                                                   style: FlutterFlowTheme.of(context).labelMedium,
                                                 ),
                                               ],
                                             ),
                                           ),
                                         );
                                       }
                                       if (!snapshot.hasData) {
                                         return Center(
                                           child: Padding(
                                             padding: EdgeInsets.all(20.0),
                                             child: CircularProgressIndicator(
                                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF165AC5)),
                                             ),
                                           ),
                                         );
                                       }
                                        var docs = snapshot.data!.docs;
                                        final selectedFilter = _model.choiceChipsValue;
                                        final searchQuery = _model.textController?.text.trim().toLowerCase() ?? '';
                                        if (searchQuery.isNotEmpty) {
                                          docs = docs.where((d) {
                                            final data = d.data();
                                            final name = ((data['display_name'] as String?) ??
                                                (data['name'] as String?) ??
                                                (data['displayName'] as String?) ??
                                                '').toLowerCase();
                                            final city = (data['city'] as String? ?? '').toLowerCase();
                                            final addr = (data['address'] as String? ?? (data['location'] as String? ?? '')).toLowerCase();
                                            final services = _extractServices(data);
                                            return name.contains(searchQuery) ||
                                                city.contains(searchQuery) ||
                                                addr.contains(searchQuery) ||
                                                services.any((s) => s.contains(searchQuery));
                                          }).toList();
                                        }
                                        if (selectedFilter != null && selectedFilter != 'Tous') {
                                          docs = docs.where((d) {
                                            final services = _extractServices(d.data());
                                            final filterLower = selectedFilter.toLowerCase();
                                            return services.any((s) => s.contains(filterLower) || filterLower.contains(s));
                                          }).toList();
                                        }
                                       if (docs.isEmpty) {
                                         return Center(
                                           child: Padding(
                                             padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Icon(Icons.local_hospital_outlined, size: 56.0, color: Color(0xFF165AC5)),
                                                 SizedBox(height: 12.0),
                                                 Text(
                                                   'Aucune clinique disponible',
                                                   textAlign: TextAlign.center,
                                                   style: FlutterFlowTheme.of(context).titleMedium.override(
                                                     font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                   ),
                                                 ),
                                                 SizedBox(height: 6.0),
                                                 Text(
                                                   'Les cliniques et centres de santé s\'afficheront ici dès qu\'ils seront ajoutés.',
                                                   textAlign: TextAlign.center,
                                                   style: FlutterFlowTheme.of(context).labelMedium,
                                                 ),
                                               ],
                                             ),
                                           ),
                                         );
                                       }
                                       return Column(
                                         children: docs.map((doc) {
                                           final data = doc.data();
                                           final name = ((data['display_name'] as String?) ??
                                                (data['name'] as String?) ??
                                                (data['displayName'] as String?) ??
                                                'Clinique').trim();
                                           final location = (data['address'] as String?) ?? (data['city'] as String?) ?? (data['location'] as String?) ?? 'Brazzaville';
                                           final cover = (data['cover'] as String?) ?? (data['photo_url'] as String?);
                                           final phone = (data['phone_number'] as String?) ?? (data['phone'] as String?) ?? (data['phoneNumber'] as String?) ?? '';

                                           return ClinicCardWidget(
                                             name: name,
                                             location: location,
                                             cover: cover,
                                             bookMeet: () async {
                                               await showModalBottomSheet(
                                                 isScrollControlled: true,
                                                 backgroundColor: Colors.transparent,
                                                 enableDrag: false,
                                                 context: context,
                                                 builder: (context) {
                                                   return GestureDetector(
                                                     onTap: () {
                                                       FocusScope.of(context).unfocus();
                                                       FocusManager.instance.primaryFocus?.unfocus();
                                                     },
                                                     child: Padding(
                                                       padding: MediaQuery.viewInsetsOf(context),
                                                       child: GetMedicalAppointmentWidget(
                                                         isDoctorView: false,
                                                       ),
                                                     ),
                                                   );
                                                 },
                                               ).then((value) => safeSetState(() {}));
                                             },
                                             contactClinic: () async {
                                               if (phone.isNotEmpty) {
                                                 await launchURL('https://wa.me/$phone');
                                               }
                                             },
                                           );
                                         }).toList().divide(SizedBox(height: 24.0)),
                                       );
                                     },
                                   ),
                                ].divide(SizedBox(height: 24.0)),
                                ),
                              ),
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
  }
}
