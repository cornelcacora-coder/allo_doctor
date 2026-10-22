import '/components/clinic_member_card_widget.dart';
import '/components/log_out_widget.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/components/stateitem_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'home_clinique_widget.dart' show HomeCliniqueWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeCliniqueModel extends FlutterFlowModel<HomeCliniqueWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Stateitem component.
  late StateitemModel stateitemModel1;
  // Model for Stateitem component.
  late StateitemModel stateitemModel2;
  // Model for Stateitem component.
  late StateitemModel stateitemModel3;
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
  // Model for clinicMemberCard component.
  late ClinicMemberCardModel clinicMemberCardModel1;
  // Model for clinicMemberCard component.
  late ClinicMemberCardModel clinicMemberCardModel2;
  // Model for NavBarClinic component.
  late NavBarClinicModel navBarClinicModel;

  @override
  void initState(BuildContext context) {
    stateitemModel1 = createModel(context, () => StateitemModel());
    stateitemModel2 = createModel(context, () => StateitemModel());
    stateitemModel3 = createModel(context, () => StateitemModel());
    clinicMemberCardModel1 =
        createModel(context, () => ClinicMemberCardModel());
    clinicMemberCardModel2 =
        createModel(context, () => ClinicMemberCardModel());
    navBarClinicModel = createModel(context, () => NavBarClinicModel());
  }

  @override
  void dispose() {
    stateitemModel1.dispose();
    stateitemModel2.dispose();
    stateitemModel3.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();

    clinicMemberCardModel1.dispose();
    clinicMemberCardModel2.dispose();
    navBarClinicModel.dispose();
  }
}
