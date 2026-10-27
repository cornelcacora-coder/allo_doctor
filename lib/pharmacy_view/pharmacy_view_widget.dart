import '/components/griditem_widget.dart';
import '/components/main_floating_navbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pharmacy_view_model.dart';
export 'pharmacy_view_model.dart';

class PharmacyViewWidget extends StatefulWidget {
  const PharmacyViewWidget({super.key});

  static String routeName = 'PharmacyView';
  static String routePath = '/pharmacyView';

  @override
  State<PharmacyViewWidget> createState() => _PharmacyViewWidgetState();
}

class _PharmacyViewWidgetState extends State<PharmacyViewWidget> {
  late PharmacyViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmacyViewModel());

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
        body: SafeArea(
          top: true,
          child: Stack(
            alignment: AlignmentDirectional(0.0, 1.0),
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).alternate,
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(48.0),
                                      child: CachedNetworkImage(
                                        fadeInDuration:
                                            Duration(milliseconds: 0),
                                        fadeOutDuration:
                                            Duration(milliseconds: 0),
                                        imageUrl:
                                            'https://placehold.co/96x96/1a6b3c/ffffff?text=Ph',
                                        width: 96.0,
                                        height: 96.0,
                                        fit: BoxFit.cover,
                                        alignment: Alignment(0.0, 0.0),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Pharmacie',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyLarge
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyLarge
                                                          .fontStyle,
                                                ),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyLarge
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        Text(
                                          'Informations pharmacie',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
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
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 4.0)),
                                    ),
                                  ].divide(SizedBox(height: 16.0)),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FFButtonWidget(
                                      onPressed: () {
                                        print('Button pressed ...');
                                      },
                                      text: 'Suivre',
                                      options: FFButtonOptions(
                                        width: 150.0,
                                        height: 40.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16.0, 0.0, 16.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: Color(0x4D39D0D2),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .titleSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    FlutterFlowIconButton(
                                      borderRadius: 8.0,
                                      buttonSize: 40.0,
                                      fillColor: Colors.transparent,
                                      icon: Icon(
                                        Icons.bookmark_border_rounded,
                                        size: 22.0,
                                      ),
                                      onPressed: () {
                                        print('IconButton pressed ...');
                                      },
                                    ),
                                  ].divide(SizedBox(width: 16.0)),
                                ),
                              ].divide(SizedBox(height: 24.0)),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  height: 1.0,
                                  decoration: BoxDecoration(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 8.0, 0.0, 8.0),
                                        child: Container(
                                          child: Container(
                                            width: 0.0,
                                            height: 0.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: Container(
                                        child: GridView(
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 5.0,
                                            mainAxisSpacing: 5.0,
                                            childAspectRatio: 1.0,
                                          ),
                                          primary: false,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          children: [
                                            wrapWithModel(
                                              model: _model.griditemModel1,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.griditemModel2,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.griditemModel3,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.griditemModel4,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.griditemModel5,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                            wrapWithModel(
                                              model: _model.griditemModel6,
                                              updateCallback: () =>
                                                  safeSetState(() {}),
                                              child: GriditemWidget(),
                                            ),
                                          ],
                                        ),
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
                  Align(
                    alignment: AlignmentDirectional(0.0, 1.0),
                    child: Container(
                      child: Container(
                        width: 0.0,
                        height: 0.0,
                      ),
                    ),
                  ),
                ],
              ),
              wrapWithModel(
                model: _model.mainFloatingNavbarModel,
                updateCallback: () => safeSetState(() {}),
                child: MainFloatingNavbarWidget(
                  label1: 'Accueil',
                  label2: 'Pharma',
                  label3: 'Sang',
                  label4: 'Profile',
                  action1: () async {},
                  action2: () async {},
                  action3: () async {},
                  action4: () async {},
                  action5: () async {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
