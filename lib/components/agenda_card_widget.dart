import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'agenda_card_model.dart';
export 'agenda_card_model.dart';

class AgendaCardWidget extends StatefulWidget {
  const AgendaCardWidget({
    super.key,
    this.photo,
    this.time,
    this.sympto,
    this.onClick,
    this.iconCard,
    this.patientName,
    String? type,
  }) : this.type = type ?? '';

  final String? photo;
  final DateTime? time;
  final String? sympto;
  final Future Function()? onClick;
  final Widget? iconCard;
  final String? patientName;
  final String type;

  @override
  State<AgendaCardWidget> createState() => _AgendaCardWidgetState();
}

class _AgendaCardWidgetState extends State<AgendaCardWidget> {
  late AgendaCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AgendaCardModel());

    _model.switchValue = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        await widget.onClick?.call();
      },
      child: Material(
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
                        color: FlutterFlowTheme.of(context).tertiary,
                        size: 20.0,
                      ),
                      Text(
                        valueOrDefault<String>(
                          dateTimeFormat("Hm", widget!.time),
                          ' 18:49',
                        ),
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
                          widget.patientName,
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
                              color:
                                  FlutterFlowTheme.of(context).primaryText,
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              lineHeight: 1.4,
                            ),
                      ),
                      Text(
                        valueOrDefault<String>(
                          widget!.sympto,
                          'Consultation',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context)
                            .labelMedium
                            .override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context)
                                  .secondaryText,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              lineHeight: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _model.switchValue!,
                  onChanged: (newValue) async {
                    safeSetState(() => _model.switchValue = newValue!);
                  },
                  activeColor: FlutterFlowTheme.of(context).primary,
                  activeTrackColor: FlutterFlowTheme.of(context).accent2,
                  inactiveTrackColor:
                      FlutterFlowTheme.of(context).alternate,
                  inactiveThumbColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                ),
              ].divide(SizedBox(width: 14.0)),
            ),
          ),
        ),
      ),
    );
  }
}
