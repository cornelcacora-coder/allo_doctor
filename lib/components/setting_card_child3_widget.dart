import '/components/switch_component_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'setting_card_child3_model.dart';
export 'setting_card_child3_model.dart';

class SettingCardChild3Widget extends StatefulWidget {
  const SettingCardChild3Widget({super.key});

  @override
  State<SettingCardChild3Widget> createState() =>
      _SettingCardChild3WidgetState();
}

class _SettingCardChild3WidgetState extends State<SettingCardChild3Widget> {
  late SettingCardChild3Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingCardChild3Model());

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
            color: FlutterFlowTheme.of(context).primary10,
            borderRadius: BorderRadius.circular(16.0),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Icon(
            Icons.signal_cellular_alt_rounded,
            color: FlutterFlowTheme.of(context).onPrimary,
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
                'Mode économie de données',
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
                'Coupe les animations - idéal petite connexion & batterie faible',
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
