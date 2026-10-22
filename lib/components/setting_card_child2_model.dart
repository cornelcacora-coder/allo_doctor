import '/components/language_option_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'setting_card_child2_widget.dart' show SettingCardChild2Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingCardChild2Model extends FlutterFlowModel<SettingCardChild2Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for LanguageOption.
  late LanguageOptionModel languageOptionModel1;
  // Model for LanguageOption.
  late LanguageOptionModel languageOptionModel2;
  // Model for LanguageOption.
  late LanguageOptionModel languageOptionModel3;

  @override
  void initState(BuildContext context) {
    languageOptionModel1 = createModel(context, () => LanguageOptionModel());
    languageOptionModel2 = createModel(context, () => LanguageOptionModel());
    languageOptionModel3 = createModel(context, () => LanguageOptionModel());
  }

  @override
  void dispose() {
    languageOptionModel1.dispose();
    languageOptionModel2.dispose();
    languageOptionModel3.dispose();
  }
}
