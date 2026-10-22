import '/components/language_option_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'setting_card_child2_model.dart';
export 'setting_card_child2_model.dart';

class SettingCardChild2Widget extends StatefulWidget {
  const SettingCardChild2Widget({super.key});

  @override
  State<SettingCardChild2Widget> createState() =>
      _SettingCardChild2WidgetState();
}

class _SettingCardChild2WidgetState extends State<SettingCardChild2Widget> {
  late SettingCardChild2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SettingCardChild2Model());

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
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.language_rounded,
              color: FlutterFlowTheme.of(context).primary,
              size: 20.0,
            ),
            Text(
              'Langue',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleMedium.fontStyle,
                    lineHeight: 1.45,
                  ),
            ),
          ].divide(SizedBox(width: 8.0)),
        ),
        wrapWithModel(
          model: _model.languageOptionModel1,
          updateCallback: () => safeSetState(() {}),
          child: LanguageOptionWidget(
            code: 'FR',
            name: 'Français',
            selected: true,
          ),
        ),
        wrapWithModel(
          model: _model.languageOptionModel2,
          updateCallback: () => safeSetState(() {}),
          child: LanguageOptionWidget(
            code: 'CD',
            name: 'Lingála',
            selected: true,
          ),
        ),
        wrapWithModel(
          model: _model.languageOptionModel3,
          updateCallback: () => safeSetState(() {}),
          child: LanguageOptionWidget(
            code: 'CG',
            name: 'Kituba',
            selected: true,
          ),
        ),
        Text(
          'L\'interface principale s\'adapte instantanément. Traduction complète en cours d\'enrichissement.',
          maxLines: 2,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.outfit(
                  fontWeight:
                      FlutterFlowTheme.of(context).labelSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).labelSmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                lineHeight: 1.3,
              ),
        ),
      ].divide(SizedBox(height: 16.0)),
    );
  }
}
