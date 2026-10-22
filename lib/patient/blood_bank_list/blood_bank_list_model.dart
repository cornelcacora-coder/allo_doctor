import '/components/clinic_blood_card_widget.dart';
import '/components/get_blood_widget.dart';
import '/components/nav_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'blood_bank_list_widget.dart' show BloodBankListWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BloodBankListModel extends FlutterFlowModel<BloodBankListWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // Model for ClinicCard.
  late ClinicBloodCardModel clinicCardModel1;
  // Model for ClinicCard.
  late ClinicBloodCardModel clinicCardModel2;
  // Model for ClinicCard.
  late ClinicBloodCardModel clinicCardModel3;
  // Model for NavBarUser component.
  late NavBarUserModel navBarUserModel;

  @override
  void initState(BuildContext context) {
    clinicCardModel1 = createModel(context, () => ClinicBloodCardModel());
    clinicCardModel2 = createModel(context, () => ClinicBloodCardModel());
    clinicCardModel3 = createModel(context, () => ClinicBloodCardModel());
    navBarUserModel = createModel(context, () => NavBarUserModel());
  }

  @override
  void dispose() {
    clinicCardModel1.dispose();
    clinicCardModel2.dispose();
    clinicCardModel3.dispose();
    navBarUserModel.dispose();
  }
}
