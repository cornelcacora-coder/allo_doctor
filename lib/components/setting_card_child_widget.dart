import '/components/switch_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'setting_card_child_model.dart';
export 'setting_card_child_model.dart';

class SettingCardChildWidget extends StatefulWidget {
  const SettingCardChildWidget({super.key});

  @override
  State<SettingCardChildWidget> createState() => _SettingCardChildWidgetState();
}

class _SettingCardChildWidgetState extends State<SettingCardChildWidget> {
  late SettingCardChildModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingCardChildModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).warning10,
            borderRadius: BorderRadius.circular(16.0),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Icon(
            Icons.light_mode_rounded,
            color: FlutterFlowTheme.of(context).onWarning,
            size: 24.0,
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Mode sombre',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      ),
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      lineHeight: 1.5,
                    ),
              ),
              Text(
                'Confort la nuit, économise la batterie',
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight:
                            FlutterFlowTheme.of(context).labelSmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).labelSmall.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).labelSmall.fontStyle,
                      lineHeight: 1.3,
                    ),
              ),
            ].divide(SizedBox(height: 4.0)),
          ),
        ),
        wrapWithModel(
          model: _model.switchModel,
          updateCallback: () => safeSetState(() {}),
          child: SwitchComponentWidget(
            label: '',
            labelPresent: false,
            variant: 'iOS',
            active: false,
          ),
        ),
      ].divide(SizedBox(width: 16.0)),
    );
  }
}
