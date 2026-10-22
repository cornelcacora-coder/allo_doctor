import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'blood_chip_model.dart';
export 'blood_chip_model.dart';

class BloodChipWidget extends StatefulWidget {
  const BloodChipWidget({
    super.key,
    String? group,
    bool? active,
  })  : this.group = group ?? 'A+',
        this.active = active ?? true;

  final String group;
  final bool active;

  @override
  State<BloodChipWidget> createState() => _BloodChipWidgetState();
}

class _BloodChipWidgetState extends State<BloodChipWidget> {
  late BloodChipModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => BloodChipModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: valueOrDefault<Color>(
          valueOrDefault<bool>(
            widget!.active,
            true,
          )
              ? FlutterFlowTheme.of(context).error
              : FlutterFlowTheme.of(context).surfaceVariant,
          FlutterFlowTheme.of(context).error,
        ),
        borderRadius: BorderRadius.circular(16.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: valueOrDefault<Color>(
            valueOrDefault<bool>(
              widget!.active,
              true,
            )
                ? FlutterFlowTheme.of(context).error
                : FlutterFlowTheme.of(context).alternate,
            FlutterFlowTheme.of(context).error,
          ),
          width: valueOrDefault<double>(
            valueOrDefault<bool>(
              widget!.active,
              true,
            )
                ? 1.0
                : 1.0,
            1.0,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
        child: Container(
          child: Text(
            valueOrDefault<String>(
              widget!.group,
              'A+',
            ),
            style: FlutterFlowTheme.of(context).labelLarge.override(
                  font: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  ),
                  color: valueOrDefault<Color>(
                    valueOrDefault<bool>(
                      widget!.active,
                      true,
                    )
                        ? FlutterFlowTheme.of(context).onError
                        : FlutterFlowTheme.of(context).secondaryText,
                    FlutterFlowTheme.of(context).onError,
                  ),
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                  lineHeight: 1.4,
                ),
          ),
        ),
      ),
    );
  }
}
