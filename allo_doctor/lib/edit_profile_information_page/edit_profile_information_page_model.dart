import '/components/form_section_child2_widget.dart';
import '/components/form_section_child3_widget.dart';
import '/components/form_section_child4_widget.dart';
import '/components/form_section_child5_widget.dart';
import '/components/form_section_child_widget.dart';
import '/components/form_section_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'edit_profile_information_page_widget.dart'
    show EditProfileInformationPageWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditProfileInformationPageModel
    extends FlutterFlowModel<EditProfileInformationPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FormSection.
  late FormSectionModel formSectionModel1;
  // Model for FormSection.
  late FormSectionModel formSectionModel2;
  // Model for FormSection.
  late FormSectionModel formSectionModel3;
  // Model for FormSection.
  late FormSectionModel formSectionModel4;
  // Model for FormSection.
  late FormSectionModel formSectionModel5;

  @override
  void initState(BuildContext context) {
    formSectionModel1 = createModel(context, () => FormSectionModel());
    formSectionModel2 = createModel(context, () => FormSectionModel());
    formSectionModel3 = createModel(context, () => FormSectionModel());
    formSectionModel4 = createModel(context, () => FormSectionModel());
    formSectionModel5 = createModel(context, () => FormSectionModel());
  }

  @override
  void dispose() {
    formSectionModel1.dispose();
    formSectionModel2.dispose();
    formSectionModel3.dispose();
    formSectionModel4.dispose();
    formSectionModel5.dispose();
  }
}
