import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'patient_card_model.dart';
export 'patient_card_model.dart';

class PatientCardWidget extends StatefulWidget {
  const PatientCardWidget({
    super.key,
    this.photo,
    this.name,
    this.sympto,
    this.iconCard,
    String? type,
    this.tagBg,
  }) : this.type = type ?? '';

  final String? photo;
  final String? name;
  final String? sympto;
  final Widget? iconCard;
  final String type;
  final Color? tagBg;

  @override
  State<PatientCardWidget> createState() => _PatientCardWidgetState();
}

class _PatientCardWidgetState extends State<PatientCardWidget> {
  late PatientCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PatientCardModel());

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
        height: 70.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: AlignmentDirectional(1.0, 1.0),
                  children: [
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 6.0, 6.0),
                      child: Container(
                        width: 42.0,
                        height: 42.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: FlutterFlowTheme.of(context).primary.withOpacity(0.15),
                        ),
                        child: (widget!.photo != null &&
                                widget!.photo!.isNotEmpty &&
                                !widget!.photo!.contains('unsplash') &&
                                !widget!.photo!.contains('flaticon'))
                            ? Image.network(
                                widget!.photo!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    (widget!.name?.isNotEmpty == true)
                                        ? widget!.name![0].toUpperCase()
                                        : 'P',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: FlutterFlowTheme.of(context).primary,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  (widget!.name?.isNotEmpty == true)
                                      ? widget!.name![0].toUpperCase()
                                      : 'P',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: widget!.type.toLowerCase().contains('domicile')
                            ? Color(0xFF16CB83)
                            : FlutterFlowTheme.of(context).tertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Icon(
                          widget!.type.toLowerCase().contains('domicile')
                              ? Icons.home_rounded
                              : (widget!.type.toLowerCase().contains('tele')
                                  ? Icons.videocam_rounded
                                  : Icons.medical_services_rounded),
                          color: Colors.white,
                          size: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: AlignmentDirectional(-0.75, -0.03),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          (widget!.name != null && widget!.name!.trim().isNotEmpty)
                              ? widget!.name!
                              : 'Patient',
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
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            widget!.sympto,
                            'Toux + Fièvre',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .labelMedium
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                      ].divide(SizedBox(width: 4.0)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional(1.0, 0.0),
                  child: Icon(
                    Icons.chevron_right,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24.0,
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
