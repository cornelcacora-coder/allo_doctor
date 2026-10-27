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

  // NOM COMPLET / NOM ETABLISSEMENT / NOM OFFICINE
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

  // VILLE / ADRESSE
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;

  // SPECIALITE (Médecin) ou TYPE D'ETABLISSEMENT (Clinique) ou TYPE DE SERVICE (Pharmacie)
  FocusNode? specialtyFocusNode;
  TextEditingController? specialtyController;
  String? Function(BuildContext, String?)? specialtyControllerValidator;

  // NUMERO D'ORDRE (CNOM, CNOP) ou NUMERO D'AUTORISATION / RCCM (Clinique)
  FocusNode? docNumberFocusNode;
  TextEditingController? docNumberController;
  String? Function(BuildContext, String?)? docNumberControllerValidator;

  // MEDECIN : LIEU D'EXERCICE / HOPITAL DE RATTACHEMENT
  FocusNode? workplaceFocusNode;
  TextEditingController? workplaceController;

  // CLINIQUE / PHARMACIE : DIRECTEUR MEDICAL / MEDECIN CHEF / PHARMACIEN TITULAIRE
  FocusNode? directorFocusNode;
  TextEditingController? directorController;

  // CLINIQUE : SERVICES PRINCIPAUX
  FocusNode? servicesFocusNode;
  TextEditingController? servicesController;

  // CLINIQUE : CAPACITE EN LITS
  FocusNode? bedsCountFocusNode;
  TextEditingController? bedsCountController;

  // SEXE (Patients et Médecins uniquement)
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

    workplaceFocusNode?.dispose();
    workplaceController?.dispose();

    directorFocusNode?.dispose();
    directorController?.dispose();

    servicesFocusNode?.dispose();
    servicesController?.dispose();

    bedsCountFocusNode?.dispose();
    bedsCountController?.dispose();
  }

  /// Additional helper methods.
  String? get radioButtonValue => radioButtonValueController?.value;
}
