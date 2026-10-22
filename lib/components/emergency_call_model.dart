import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'emergency_call_widget.dart' show EmergencyCallWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EmergencyCallModel extends FlutterFlowModel<EmergencyCallWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Type widget.
  String? typeValue;
  FormFieldController<String>? typeValueController;
  // State field(s) for Zone widget.
  String? zoneValue;
  FormFieldController<String>? zoneValueController;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for isInConscious widget.
  bool? isInConsciousValue;
  // State field(s) for isOxygen widget.
  bool? isOxygenValue;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
