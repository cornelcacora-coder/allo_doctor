import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'suivie_card_model.dart';
export 'suivie_card_model.dart';

class SuivieCardWidget extends StatefulWidget {
  const SuivieCardWidget({
    super.key,
    this.time,
    this.exameType,
    String? patient,
    this.statu,
  }) : this.patient = patient ?? '';

  final DateTime? time;
  final String? exameType;
  final String patient;
  final String? statu;

  @override
  State<SuivieCardWidget> createState() => _SuivieCardWidgetState();
}

class _SuivieCardWidgetState extends State<SuivieCardWidget> {
  late SuivieCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SuivieCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        width: double.infinity,
        height: 65.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(-0.75, -0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: FlutterFlowTheme.of(context).warning,
                      size: 20.0,
                    ),
                    Text(
                      valueOrDefault<String>(
                        dateTimeFormat("Hm", widget!.time),
                        ' 18:49',
                      ),
                      style: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 100.0,
                child: VerticalDivider(
                  thickness: 2.0,
                  color: FlutterFlowTheme.of(context).alternate,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        widget.patient.trim().isNotEmpty ? widget.patient : null,
                        'Patient',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context)
                          .labelMedium
                          .override(
                            font: GoogleFonts.outfit(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            lineHeight: 1.4,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(
                        widget!.exameType,
                        'Examen',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).warning,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                lineHeight: 1.4,
                              ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: valueOrDefault<Color>(
                        widget!.statu == 'En attente'
                            ? FlutterFlowTheme.of(context).accent5
                            : FlutterFlowTheme.of(context).accent2,
                        FlutterFlowTheme.of(context).accent2,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      shape: BoxShape.rectangle,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(8.0, 4.0, 8.0, 4.0),
                      child: Text(
                        valueOrDefault<String>(
                          widget!.statu,
                          'En attente',
                        ),
                        style: FlutterFlowTheme.of(context).labelSmall.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                              ),
                              color: valueOrDefault<Color>(
                                widget!.statu == 'En attente'
                                    ? FlutterFlowTheme.of(context).warning
                                    : Color(0xF11138D4),
                                Color(0xF11138D4),
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .fontStyle,
                              lineHeight: 1.3,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ].divide(SizedBox(width: 14.0)),
          ),
        ),
      ),
    );
  }
}
