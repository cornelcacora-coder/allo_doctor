import '/auth/role_guard.dart';
import '/components/kpi_card_widget.dart';
import '/components/module_row_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pharmacy_management_dashboard_model.dart';
export 'pharmacy_management_dashboard_model.dart';

class PharmacyManagementDashboardWidget extends StatefulWidget {
  const PharmacyManagementDashboardWidget({super.key});

  static String routeName = 'PharmacyManagementDashboard';
  static String routePath = '/pharmacyManagementDashboard';

  @override
  State<PharmacyManagementDashboardWidget> createState() =>
      _PharmacyManagementDashboardWidgetState();
}

class _PharmacyManagementDashboardWidgetState
    extends State<PharmacyManagementDashboardWidget> {
  late PharmacyManagementDashboardModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmacyManagementDashboardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      // Garde-fou : cet espace est reserve aux comptes pharmacies.
      await guardRole(context, 'pharmacie');
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF175FA9), Color(0xFF1E88E5)],
                  stops: [0.0, 1.0],
                  begin: AlignmentDirectional(-1.0, 0.0),
                  end: AlignmentDirectional(1.0, 0),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                  bottomRight: Radius.circular(32.0),
                ),
                shape: BoxShape.rectangle,
              ),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 24.0, 20.0, 40.0),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 44.0,
                                height: 44.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).success,
                                  borderRadius: BorderRadius.circular(16.0),
                                  shape: BoxShape.rectangle,
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  'DC',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .onSuccess,
                                        fontSize: 16.72,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pharmacie du Centre',
                                    style: FlutterFlowTheme.of(context)
                                        .titleLarge
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .titleLarge
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .onBackground,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleLarge
                                                  .fontStyle,
                                          lineHeight: 1.4,
                                        ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Brazzaville · Centre-ville ·',
                                        style: FlutterFlowTheme.of(context)
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
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onbackground80,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                      Icon(
                                        Icons.star_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .onBackground,
                                        size: 14.0,
                                      ),
                                      Text(
                                        '4.8',
                                        style: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .onBackground,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 4.0)),
                                  ),
                                ].divide(SizedBox(height: 4.0)),
                              ),
                            ].divide(SizedBox(width: 16.0)),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).onPrimary20,
                              borderRadius: BorderRadius.circular(9999.0),
                              shape: BoxShape.rectangle,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                child: Icon(
                                  Icons.logout_rounded,
                                  color: FlutterFlowTheme.of(context).onSurface,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
              child: Container(
                child: Transform.rotate(
                  angle: 0.0 * (math.pi / 180),
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Container(
                    child: Container(
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.kpiCardModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: KpiCardWidget(
                                  emoji: '📑',
                                  label: 'Ordonnances',
                                  tone: FlutterFlowTheme.of(context).primary,
                                  value: '2',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.kpiCardModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: KpiCardWidget(
                                  emoji: '💰',
                                  label: 'CA du jour',
                                  tone: FlutterFlowTheme.of(context).primary,
                                  value: '86k',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: wrapWithModel(
                                model: _model.kpiCardModel3,
                                updateCallback: () => safeSetState(() {}),
                                child: KpiCardWidget(
                                  emoji: '🛵',
                                  label: 'À livrer',
                                  tone: FlutterFlowTheme.of(context).primary,
                                  value: '3',
                                ),
                              ),
                            ),
                          ].divide(SizedBox(width: 16.0)),
                        ),
                      ),
                    ),
                  ),
                ),
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
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Modules de la pharmacie',
                              style: FlutterFlowTheme.of(context)
                                  .titleMedium
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                    lineHeight: 1.45,
                                  ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel1,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '📑',
                                subtitle: '2 nouvelles ordonnances 🔔',
                                title: 'Ordonnances & Commandes',
                                badge: '2',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel2,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '📦',
                                subtitle: '3 ruptures · 2 péremptions proches',
                                title: 'Stocks & Catalogue',
                                badge: 'option_2',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel3,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '💰',
                                subtitle: 'CA 86 400 F aujourd\'hui · MoMo',
                                title: 'Caisse & Paiements',
                                badge: 'option_2',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel4,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '🚚',
                                subtitle: '3 commandes · 1 retrait QR attendu',
                                title: 'Préparation & Livraisons',
                                badge: 'option_2',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel5,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '📊',
                                subtitle: 'Top ventes, relances, promotions',
                                title: 'Statistiques & Marketing',
                                badge: 'option_2',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel6,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '🤝',
                                subtitle: '1 alerte rappel de lot 🚨',
                                title: 'Réseau & Santé Publique',
                                badge: '1',
                              ),
                            ),
                            wrapWithModel(
                              model: _model.moduleRowModel7,
                              updateCallback: () => safeSetState(() {}),
                              child: ModuleRowWidget(
                                iconEmoji: '🔐',
                                subtitle: '6 employés · rayons · Tableaux A/B',
                                title: 'Équipe & Officine',
                                badge: 'option_2',
                              ),
                            ),
                          ].divide(SizedBox(height: 16.0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
