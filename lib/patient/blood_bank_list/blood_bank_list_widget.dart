import '/components/clinic_blood_card_widget.dart';
import '/components/get_blood_widget.dart';
import '/components/nav_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blood_bank_list_model.dart';
export 'blood_bank_list_model.dart';

class BloodBankListWidget extends StatefulWidget {
  const BloodBankListWidget({super.key});

  static String routeName = 'BloodBankList';
  static String routePath = '/bloodBankList';

  @override
  State<BloodBankListWidget> createState() => _BloodBankListWidgetState();
}

class _BloodBankListWidgetState extends State<BloodBankListWidget> {
  late BloodBankListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BloodBankListModel());

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
            backgroundColor: Color(0xFFCC0F0F),
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
                          'assets/images/4243258.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Banque de sang',
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
                    FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      fillColor: Colors.transparent,
                      icon: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 24.0,
                      ),
                      onPressed: () {
                        print('IconButton pressed ...');
                      },
                    ),
                  ],
                ),
                Text(
                  'Disponibilité en direct par hôpital',
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
                    gradient: LinearGradient(
                      colors: [Color(0x2B381313), Color(0x8D8E5B5D)],
                      stops: [0.0, 1.0],
                      begin: AlignmentDirectional(1.0, 0.0),
                      end: AlignmentDirectional(-1.0, 0),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Color(0x86E0E5E3),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/images__6_-removebg-preview.png',
                            width: 35.0,
                            height: 35.0,
                            fit: BoxFit.contain,
                          ),
                          Text(
                            'Donnez votre sang, sauvez des vies · Merci aux donneurs !',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).onprimary80,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .fontStyle,
                                  lineHeight: 1.5,
                                ),
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
                                    'GROUPES SANGUINS',
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
                                      ChipData('Tous'),
                                      ChipData('A +'),
                                      ChipData('A -'),
                                      ChipData('B +'),
                                      ChipData('B -'),
                                      ChipData('AB +'),
                                      ChipData('AB -'),
                                      ChipData('O +'),
                                      ChipData('O -')
                                    ],
                                    onChanged: (val) => safeSetState(() =>
                                        _model.choiceChipsValue =
                                            val?.firstOrNull),
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor: Color(0xFECC0F0F),
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
                                      iconColor: Colors.white,
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
                                    stream: FirebaseFirestore.instance.collection('blood_banks').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bloodtype_outlined, size: 56.0, color: Color(0xFFCC0F0F)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune banque de sang disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les banques de sang partenaires s\'afficheront ici dès qu\'elles seront ajoutées.',
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
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC0F0F)),
                                            ),
                                          ),
                                        );
                                      }
                                      var docs = snapshot.data!.docs;
                                      final selectedFilter = _model.choiceChipsValue;
                                      if (selectedFilter != null && selectedFilter != 'Tous') {
                                        docs = docs.where((d) {
                                          final groups = (d.data()['groups'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                                          return groups.contains(selectedFilter);
                                        }).toList();
                                      }
                                      if (docs.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bloodtype_outlined, size: 56.0, color: Color(0xFFCC0F0F)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune banque de sang disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les banques de sang partenaires s\'afficheront ici dès qu\'elles seront ajoutées.',
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
                                          final name = (data['name'] as String?)?.trim() ?? 'Banque de Sang';
                                          final location = (data['location'] as String?) ?? (data['address'] as String?) ?? (data['city'] as String?) ?? 'Brazzaville';
                                          final distance = (data['distance'] as String?) ?? '';
                                          final cover = (data['cover'] as String?) ?? (data['photo_url'] as String?);
                                          final phone = (data['phone'] as String?) ?? (data['phoneNumber'] as String?) ?? '';
                                          // ─── Groupes sanguins depuis Firestore ───
                                          final groups = (data['groups'] as List<dynamic>?)
                                                ?.map((e) => e.toString())
                                                .toList() ?? [];

                                          return ClinicBloodCardWidget(
                                            name: name,
                                            location: location,
                                            distance: distance,
                                            cover: cover,
                                            groups: groups,
                                            buyBlood: () async {
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
                                                      child: GetBloodWidget(),
                                                    ),
                                                  );
                                                },
                                              );
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
