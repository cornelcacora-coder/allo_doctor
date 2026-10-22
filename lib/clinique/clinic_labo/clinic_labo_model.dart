import '/components/labo_card_widget.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/components/suivie_card_widget.dart';
import '/components/track_card_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'clinic_labo_widget.dart' show ClinicLaboWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClinicLaboModel extends FlutterFlowModel<ClinicLaboWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController1;
  String? get choiceChipsValue1 =>
      choiceChipsValueController1?.value?.firstOrNull;
  set choiceChipsValue1(String? val) =>
      choiceChipsValueController1?.value = val != null ? [val] : [];
  // Model for LaboCard component.
  late LaboCardModel laboCardModel1;
  // Model for LaboCard component.
  late LaboCardModel laboCardModel2;
  // Model for LaboCard component.
  late LaboCardModel laboCardModel3;
  // Model for LaboCard component.
  late LaboCardModel laboCardModel4;
  // Model for LaboCard component.
  late LaboCardModel laboCardModel5;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController2;
  String? get choiceChipsValue2 =>
      choiceChipsValueController2?.value?.firstOrNull;
  set choiceChipsValue2(String? val) =>
      choiceChipsValueController2?.value = val != null ? [val] : [];
  // Model for LaboCard component.
  late LaboCardModel laboCardModel6;
  // Model for LaboCard component.
  late LaboCardModel laboCardModel7;
  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController3;
  String? get choiceChipsValue3 =>
      choiceChipsValueController3?.value?.firstOrNull;
  set choiceChipsValue3(String? val) =>
      choiceChipsValueController3?.value = val != null ? [val] : [];
  // Model for suivieCard component.
  late SuivieCardModel suivieCardModel1;
  // Model for suivieCard component.
  late SuivieCardModel suivieCardModel2;
  // Model for NavBarClinic component.
  late NavBarClinicModel navBarClinicModel;

  @override
  void initState(BuildContext context) {
    laboCardModel1 = createModel(context, () => LaboCardModel());
    laboCardModel2 = createModel(context, () => LaboCardModel());
    laboCardModel3 = createModel(context, () => LaboCardModel());
    laboCardModel4 = createModel(context, () => LaboCardModel());
    laboCardModel5 = createModel(context, () => LaboCardModel());
    laboCardModel6 = createModel(context, () => LaboCardModel());
    laboCardModel7 = createModel(context, () => LaboCardModel());
    suivieCardModel1 = createModel(context, () => SuivieCardModel());
    suivieCardModel2 = createModel(context, () => SuivieCardModel());
    navBarClinicModel = createModel(context, () => NavBarClinicModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    laboCardModel1.dispose();
    laboCardModel2.dispose();
    laboCardModel3.dispose();
    laboCardModel4.dispose();
    laboCardModel5.dispose();
    laboCardModel6.dispose();
    laboCardModel7.dispose();
    suivieCardModel1.dispose();
    suivieCardModel2.dispose();
    navBarClinicModel.dispose();
  }
}
