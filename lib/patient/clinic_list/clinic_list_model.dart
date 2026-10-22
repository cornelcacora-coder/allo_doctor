import '/components/clinic_card_widget.dart';
import '/components/get_medical_appointment_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'clinic_list_widget.dart' show ClinicListWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClinicListModel extends FlutterFlowModel<ClinicListWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // Model for ClinicCard component.
  late ClinicCardModel clinicCardModel1;
  // Model for ClinicCard component.
  late ClinicCardModel clinicCardModel2;

  @override
  void initState(BuildContext context) {
    clinicCardModel1 = createModel(context, () => ClinicCardModel());
    clinicCardModel2 = createModel(context, () => ClinicCardModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    clinicCardModel1.dispose();
    clinicCardModel2.dispose();
  }
}
