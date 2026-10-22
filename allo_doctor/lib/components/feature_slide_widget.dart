import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'feature_slide_model.dart';
export 'feature_slide_model.dart';

class FeatureSlideWidget extends StatefulWidget {
  const FeatureSlideWidget({
    super.key,
    String? lottieDesc,
    String? title,
    String? desc,
  })  : this.lottieDesc = lottieDesc ??
            'https://dimg.dreamflow.cloud/v1/lottie/3D+animation+of+a+friendly+doctor+waving+and+holding+a+stethoscope',
        this.title = title ?? 'Consult Top Doctors',
        this.desc = desc ??
            'Access specialized healthcare from the comfort of your home with secure video calls.';

  final String lottieDesc;
  final String title;
  final String desc;

  @override
  State<FeatureSlideWidget> createState() => _FeatureSlideWidgetState();
}

class _FeatureSlideWidgetState extends State<FeatureSlideWidget> {
  late FeatureSlideModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeatureSlideModel());

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.asset(
                'assets/images/Logo_Mini-removebg-preview.png',
              ).image,
            ),
            borderRadius: BorderRadius.circular(32.0),
            shape: BoxShape.rectangle,
          ),
          alignment: AlignmentDirectional(0.0, 0.0),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                valueOrDefault<String>(
                  widget!.title,
                  'Consult Top Doctors',
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context)
                            .headlineMedium
                            .fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                      lineHeight: 1.4,
                    ),
              ),
              Text(
                valueOrDefault<String>(
                  widget!.desc,
                  'Access specialized healthcare from the comfort of your home with secure video calls.',
                ),
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.outfit(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                      fontWeight:
                          FlutterFlowTheme.of(context).bodyLarge.fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyLarge.fontStyle,
                      lineHeight: 1.4,
                    ),
              ),
            ].divide(SizedBox(height: 16.0)),
          ),
        ),
        Container(
          height: 100.0,
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Lottie.network(
            widget.lottieDesc.contains('dreamflow.cloud')
                ? 'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/Mobilo/A.json'
                : widget.lottieDesc,
            width: 100.0,
            height: 280.0,
            fit: BoxFit.contain,
            animate: true,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.medical_services_rounded,
                color: FlutterFlowTheme.of(context).primary,
                size: 64.0,
              );
            },
          ),
        ),
      ].divide(SizedBox(height: 24.0)),
    );
  }
}
