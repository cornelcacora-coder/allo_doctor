import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'login_patient_widget.dart' show LoginPatientWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginPatientModel extends FlutterFlowModel<LoginPatientWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Email and Password.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  // State field(s) for TextField widget (kept for compatibility).
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

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
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
