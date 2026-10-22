import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'sign_up_widget.dart' show SignUpWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignUpModel extends FlutterFlowModel<SignUpWidget> {
  ///  State fields for stateful widgets in this page.

  // NOM COMPLET
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;

  // EMAIL
  FocusNode? emailFocusNode;
  TextEditingController? emailController;
  String? Function(BuildContext, String?)? emailControllerValidator;

  // MOT DE PASSE
  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;
  bool passwordVisibility = false;
  String? Function(BuildContext, String?)? passwordControllerValidator;

  // TELEPHONE
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  // VILLE
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  // SPECIALITE (praticiens uniquement : medecin, pharmacie, clinique)
  FocusNode? specialtyFocusNode;
  TextEditingController? specialtyController;
  String? Function(BuildContext, String?)? specialtyControllerValidator;

  // NUMERO D'ORDRE / LICENCE (praticiens uniquement)
  FocusNode? docNumberFocusNode;
  TextEditingController? docNumberController;
  String? Function(BuildContext, String?)? docNumberControllerValidator;

  // SEXE
  FormFieldController<String>? radioButtonValueController;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    emailFocusNode?.dispose();
    emailController?.dispose();

    passwordFocusNode?.dispose();
    passwordController?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    specialtyFocusNode?.dispose();
    specialtyController?.dispose();

    docNumberFocusNode?.dispose();
    docNumberController?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
