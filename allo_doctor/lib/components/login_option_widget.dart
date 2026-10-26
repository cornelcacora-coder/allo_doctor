import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_option_model.dart';
export 'login_option_model.dart';

class LoginOptionWidget extends StatefulWidget {
  const LoginOptionWidget({
    super.key,
    Color? tone,
    this.icon,
    String? title,
    String? subtitle,
  })  : this.tone = tone ?? const Color(0x00000000),
        this.title = title ?? 'I\'m a Patient',
        this.subtitle = subtitle ?? 'Book appointments and consult doctors';

  final Color tone;
  final Widget? icon;
  final String title;
  final String subtitle;

  @override
  State<LoginOptionWidget> createState() => _LoginOptionWidgetState();
}

class _LoginOptionWidgetState extends State<LoginOptionWidget> {
  late LoginOptionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginOptionModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final toneColor = valueOrDefault<Color>(
      widget.tone,
      theme.primary,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: theme.alternate.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    toneColor,
                    toneColor.withOpacity(0.82),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: toneColor.withOpacity(0.28),
                    blurRadius: 10.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(child: widget.icon ?? Icon(Icons.person, color: Colors.white, size: 24)),
            ),
            SizedBox(width: 14.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDefault<String>(
                      widget.title,
                      'I\'m a Patient',
                    ),
                    style: theme.titleMedium.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                      ),
                      color: theme.primaryText,
                    ),
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    valueOrDefault<String>(
                      widget.subtitle,
                      'Book appointments and consult doctors',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.bodySmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.5,
                      ),
                      color: theme.secondaryText,
                      lineHeight: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.0),
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: theme.primaryBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: theme.secondaryText,
                size: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
