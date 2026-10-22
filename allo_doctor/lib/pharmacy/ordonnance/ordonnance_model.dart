import '/components/nav_bar_pharma_widget.dart';
import '/components/pharma_card_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'ordonnance_widget.dart' show OrdonnanceWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrdonnanceModel extends FlutterFlowModel<OrdonnanceWidget> {
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
  // Model for pharmaCard component.
  late PharmaCardModel pharmaCardModel1;
  // Model for pharmaCard component.
  late PharmaCardModel pharmaCardModel2;
  // Model for pharmaCard component.
  late PharmaCardModel pharmaCardModel3;
  // Model for NavBarPharma component.
  late NavBarPharmaModel navBarPharmaModel;

  @override
  void initState(BuildContext context) {
    pharmaCardModel1 = createModel(context, () => PharmaCardModel());
    pharmaCardModel2 = createModel(context, () => PharmaCardModel());
    pharmaCardModel3 = createModel(context, () => PharmaCardModel());
    navBarPharmaModel = createModel(context, () => NavBarPharmaModel());
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();

    pharmaCardModel1.dispose();
    pharmaCardModel2.dispose();
    pharmaCardModel3.dispose();
    navBarPharmaModel.dispose();
  }
}
