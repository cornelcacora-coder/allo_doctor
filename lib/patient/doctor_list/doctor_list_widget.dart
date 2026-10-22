import '/components/nav_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'doctor_list_model.dart';
export 'doctor_list_model.dart';

class DoctorListWidget extends StatefulWidget {
  const DoctorListWidget({super.key});

  static String routeName = 'DoctorList';
  static String routePath = '/doctorList';

  @override
  State<DoctorListWidget> createState() => _DoctorListWidgetState();
}

class _DoctorListWidgetState extends State<DoctorListWidget> {
  late DoctorListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DoctorListModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset(
                          'assets/images/physics.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Médecin',
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
                  'Consultez chez vous ou en téléconsultation',
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
                                decoration: InputDecoration(
                                  isDense: true,
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
                                  hintText: 'Recherchezun médecin ...',
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
                                      ChipData('Disponible',
                                          Icons.event_available_rounded),
                                      ChipData('Domicile', Icons.home_outlined)
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.choiceChipsValue =
                                            val?.firstOrNull),
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).primary,
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
                                            color: FlutterFlowTheme.of(context)
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
                                      borderRadius: BorderRadius.circular(8.0),
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
                                            color: FlutterFlowTheme.of(context)
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
                                      borderRadius: BorderRadius.circular(8.0),
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
                                        .collection('practitioners')
                                        .where('type', isEqualTo: 'medecin')
                                        .where('status', isEqualTo: 'validé')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(40.0),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                FlutterFlowTheme.of(context).primary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(24.0),
                                            child: Text(
                                              'Erreur lors du chargement des médecins.',
                                              textAlign: TextAlign.center,
                                              style: FlutterFlowTheme.of(context).bodySmall,
                                            ),
                                          ),
                                        );
                                      }

                                      final docs = snapshot.data?.docs ?? [];
                                      final searchQuery = _model.textController?.text.trim().toLowerCase() ?? '';

                                      final filtered = docs.where((doc) {
                                        final data = doc.data();
                                        final name = (data['name'] ?? data['nom'] ?? '').toString().toLowerCase();
                                        final specialty = (data['specialty'] ?? '').toString().toLowerCase();
                                        final city = (data['city'] ?? data['ville'] ?? '').toString().toLowerCase();

                                        if (searchQuery.isNotEmpty) {
                                          if (!name.contains(searchQuery) &&
                                              !specialty.contains(searchQuery) &&
                                              !city.contains(searchQuery)) {
                                            return false;
                                          }
                                        }
                                        return true;
                                      }).toList();

                                      if (filtered.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                            borderRadius: BorderRadius.circular(16.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context).alternate,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 56.0,
                                                height: 56.0,
                                                decoration: BoxDecoration(
                                                  color: Color(0x1B39D2C0),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.medical_services_outlined,
                                                  color: FlutterFlowTheme.of(context).primary,
                                                  size: 28.0,
                                                ),
                                              ),
                                              SizedBox(height: 12.0),
                                              Text(
                                                'Aucun médecin validé disponible',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      fontSize: 15.0,
                                                    ),
                                              ),
                                              SizedBox(height: 6.0),
                                              Text(
                                                'Les médecins validés par le super administrateur apparaîtront ici automatiquement.',
                                                textAlign: TextAlign.center,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      font: GoogleFonts.outfit(),
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      fontSize: 12.0,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: filtered.map((docSnap) {
                                          final data = docSnap.data();
                                          final docName = (data['name'] as String?)?.trim().isNotEmpty == true
                                              ? data['name'] as String
                                              : ((data['nom'] as String?)?.trim().isNotEmpty == true
                                                  ? data['nom'] as String
                                                  : 'Dr. Médecin');
                                          final specialty = (data['specialty'] as String?)?.trim().isNotEmpty == true
                                              ? data['specialty'] as String
                                              : 'Médecin Généraliste';
                                          final city = (data['city'] as String?)?.trim().isNotEmpty == true
                                              ? data['city'] as String
                                              : ((data['ville'] as String?)?.trim().isNotEmpty == true
                                                  ? data['ville'] as String
                                                  : 'Brazzaville');
                                          final phone = (data['phone'] as String?)?.trim().isNotEmpty == true
                                              ? data['phone'] as String
                                              : ((data['telephone'] as String?)?.trim().isNotEmpty == true
                                                  ? data['telephone'] as String
                                                  : '');
                                          final photoUrl = (data['photoUrl'] as String?) ?? '';
                                          final docNumber = (data['docNumber'] as String?) ?? '';

                                          return Padding(
                                            padding: EdgeInsets.only(bottom: 12.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(
                                                  DoctorViewWidget.routeName,
                                                  queryParameters: {
                                                    'doctorName': docName,
                                                    'specialty': specialty,
                                                    'city': city,
                                                    'phone': phone,
                                                    'photoUrl': photoUrl,
                                                    'docNumber': docNumber,
                                                  },
                                                );
                                              },
                                              child: Material(
                                                color: Colors.transparent,
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(10.0),
                                                            child: photoUrl.isNotEmpty
                                                                ? CachedNetworkImage(
                                                                    imageUrl: photoUrl,
                                                                    width: 50.0,
                                                                    height: 50.0,
                                                                    fit: BoxFit.cover,
                                                                  )
                                                                : Container(
                                                                    color: FlutterFlowTheme.of(context).primary,
                                                                    alignment: Alignment.center,
                                                                    child: Text(
                                                                      docName.isNotEmpty ? docName[0].toUpperCase() : 'D',
                                                                      style: GoogleFonts.outfit(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 20.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 12.0),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      docName,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                            font: GoogleFonts.outfit(
                                                                              fontWeight: FontWeight.w600,
                                                                            ),
                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    Icons.verified_rounded,
                                                                    color: Color(0xFF19BF82),
                                                                    size: 18.0,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(height: 2.0),
                                                              Text(
                                                                specialty,
                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.outfit(
                                                                        fontWeight: FontWeight.w600,
                                                                      ),
                                                                      color: Color(0xFFBF9719),
                                                                      fontSize: 11.0,
                                                                    ),
                                                              ),
                                                              SizedBox(height: 6.0),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.location_on_rounded,
                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                    size: 14.0,
                                                                  ),
                                                                  SizedBox(width: 4.0),
                                                                  Text(
                                                                    city,
                                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                          font: GoogleFonts.outfit(),
                                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                                          fontSize: 11.0,
                                                                        ),
                                                                  ),
                                                                  Spacer(),
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                                                                    decoration: BoxDecoration(
                                                                      color: Color(0x2339D2C0),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        Container(
                                                                          width: 7.0,
                                                                          height: 7.0,
                                                                          decoration: BoxDecoration(
                                                                            color: Color(0xFB39D2C0),
                                                                            shape: BoxShape.circle,
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 4.0),
                                                                        Text(
                                                                          'Validé',
                                                                          style: GoogleFonts.outfit(
                                                                            color: FlutterFlowTheme.of(context).primaryText,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 10.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                             ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ].divide(SizedBox(height: 24.0)),
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
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Container(
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navBarUserModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavBarUserWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
