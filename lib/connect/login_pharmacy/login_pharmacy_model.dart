import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'login_pharmacy_widget.dart' show LoginPharmacyWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPharmacyModel extends FlutterFlowModel<LoginPharmacyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Email TextField widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  // State field(s) for Password TextField widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    emailFocusNode?.dispose();
    emailTextController?.dispose();
    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
