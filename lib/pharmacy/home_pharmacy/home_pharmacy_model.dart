import '/components/log_out_widget.dart';
import '/components/nav_bar_pharma_widget.dart';
import '/components/product_card_widget.dart';
import '/components/stateitem_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'home_pharmacy_widget.dart' show HomePharmacyWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePharmacyModel extends FlutterFlowModel<HomePharmacyWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Stateitem component.
  late StateitemModel stateitemModel1;
  // Model for Stateitem component.
  late StateitemModel stateitemModel2;
  // Model for Stateitem component.
  late StateitemModel stateitemModel3;
  // State field(s) for Switch widget.
  bool? switchValue;
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
  // Model for ProductCard component.
  late ProductCardModel productCardModel1;
  // Model for ProductCard component.
  late ProductCardModel productCardModel2;
  // Model for ProductCard component.
  late ProductCardModel productCardModel3;
  // Model for ProductCard component.
  late ProductCardModel productCardModel4;
  // Model for NavBarPharma component.
  late NavBarPharmaModel navBarPharmaModel;

  @override
  void initState(BuildContext context) {
    stateitemModel1 = createModel(context, () => StateitemModel());
    stateitemModel2 = createModel(context, () => StateitemModel());
    stateitemModel3 = createModel(context, () => StateitemModel());
    productCardModel1 = createModel(context, () => ProductCardModel());
    productCardModel2 = createModel(context, () => ProductCardModel());
    productCardModel3 = createModel(context, () => ProductCardModel());
    productCardModel4 = createModel(context, () => ProductCardModel());
    navBarPharmaModel = createModel(context, () => NavBarPharmaModel());
  }

  @override
  void dispose() {
    stateitemModel1.dispose();
    stateitemModel2.dispose();
    stateitemModel3.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    productCardModel1.dispose();
    productCardModel2.dispose();
    productCardModel3.dispose();
    productCardModel4.dispose();
    navBarPharmaModel.dispose();
  }
}
