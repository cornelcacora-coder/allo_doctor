import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'social_button_model.dart';
export 'social_button_model.dart';

class SocialButtonWidget extends StatefulWidget {
  const SocialButtonWidget({
    super.key,
    Color? iconColor,
    String? iconSlug,
    String? label,
  })  : this.iconColor = iconColor ?? const Color(0xFF4285F4),
        this.iconSlug = iconSlug ?? 'https://cdn.simpleicons.org/google.svg',
        this.label = label ?? 'Google';

  final Color iconColor;
  final String iconSlug;
  final String label;

  @override
  State<SocialButtonWidget> createState() => _SocialButtonWidgetState();
}

class _SocialButtonWidgetState extends State<SocialButtonWidget> {
  late SocialButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SocialButtonModel());

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
      height: 45.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        shape: BoxShape.rectangle,
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.network(
                  widget!.iconSlug,
                ).image,
              ),
              shape: BoxShape.circle,
            ),
            alignment: AlignmentDirectional(0.0, 0.0),
          ),
          Text(
            valueOrDefault<String>(
              widget!.label,
              'Google',
            ),
            style: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  lineHeight: 1.5,
                ),
          ),
        ].divide(SizedBox(width: 8.0)),
      ),
    );
  }
}
