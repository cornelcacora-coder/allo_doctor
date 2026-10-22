import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'get_medical_appointment_widget.dart' show GetMedicalAppointmentWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GetMedicalAppointmentModel
    extends FlutterFlowModel<GetMedicalAppointmentWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Type widget.
  FormFieldController<List<String>>? typeValueController;
  String? get typeValue => typeValueController?.value?.firstOrNull;
  set typeValue(String? val) =>
      typeValueController?.value = val != null ? [val] : [];
  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for SelectedCreneau widget.
  bool? selectedCreneauValue;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for Ktb widget.
  bool? ktbValue1;
  // State field(s) for DropDown widget.
  String? dropDownValue3;
  FormFieldController<String>? dropDownValueController3;
  // State field(s) for Ktb widget.
  bool? ktbValue2;
  // State field(s) for DropDown widget.
  String? dropDownValue4;
  FormFieldController<String>? dropDownValueController4;
  // State field(s) for Ktb widget.
  bool? ktbValue3;
  // State field(s) for DropDown widget.
  String? dropDownValue5;
  FormFieldController<String>? dropDownValueController5;
  // State field(s) for Ktb widget.
  bool? ktbValue4;
  // State field(s) for DropDown widget.
  String? dropDownValue6;
  FormFieldController<String>? dropDownValueController6;
  // State field(s) for Ktb widget.
  bool? ktbValue5;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue1;
  // State field(s) for domicile widget.
  bool? domicileValue;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue2;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue3;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue4;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue5;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue6;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue7;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue8;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue9;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue10;
  // State field(s) for teleconsult widget.
  bool? teleconsultValue11;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
