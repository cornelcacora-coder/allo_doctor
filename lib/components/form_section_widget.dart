import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'form_section_model.dart';
export 'form_section_model.dart';

class FormSectionWidget extends StatefulWidget {
  const FormSectionWidget({
    super.key,
    String? label,
    this.child,
  }) : this.label = label ?? 'Full Name';

  final String label;
  final Widget Function()? child;

  @override
  State<FormSectionWidget> createState() => _FormSectionWidgetState();
}

class _FormSectionWidgetState extends State<FormSectionWidget> {
  late FormSectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormSectionModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          valueOrDefault<String>(
            widget!.label,
            'Full Name',
          ),
          style: FlutterFlowTheme.of(context).labelLarge.override(
                font: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                lineHeight: 1.4,
              ),
        ),
        Builder(builder: (_) {
          return widget.child != null ? widget.child!() : SizedBox.shrink();
        }),
      ].divide(SizedBox(height: 4.0)),
    );
  }
}
