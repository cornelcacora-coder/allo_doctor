import '/components/feature_slide_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'intro_copy_widget.dart' show IntroCopyWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IntroCopyModel extends FlutterFlowModel<IntroCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FeatureSlide.
  late FeatureSlideModel featureSlideModel;

  @override
  void initState(BuildContext context) {
    featureSlideModel = createModel(context, () => FeatureSlideModel());
  }

  @override
  void dispose() {
    featureSlideModel.dispose();
  }
}
