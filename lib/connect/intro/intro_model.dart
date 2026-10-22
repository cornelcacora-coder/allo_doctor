import '/components/login_option_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'intro_widget.dart' show IntroWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class IntroModel extends FlutterFlowModel<IntroWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for LoginOption.
  late LoginOptionModel loginOptionModel1;
  // Model for LoginOption.
  late LoginOptionModel loginOptionModel2;
  // Model for LoginOption.
  late LoginOptionModel loginOptionModel3;
  // Model for LoginOption.
  late LoginOptionModel loginOptionModel4;

  @override
  void initState(BuildContext context) {
    loginOptionModel1 = createModel(context, () => LoginOptionModel());
    loginOptionModel2 = createModel(context, () => LoginOptionModel());
    loginOptionModel3 = createModel(context, () => LoginOptionModel());
    loginOptionModel4 = createModel(context, () => LoginOptionModel());
  }

  @override
  void dispose() {
    loginOptionModel1.dispose();
    loginOptionModel2.dispose();
    loginOptionModel3.dispose();
    loginOptionModel4.dispose();
  }
}
