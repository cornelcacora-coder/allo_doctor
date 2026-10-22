import '/components/setting_row_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'setting_card_child4_widget.dart' show SettingCardChild4Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingCardChild4Model extends FlutterFlowModel<SettingCardChild4Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for SettingRow.
  late SettingRowModel settingRowModel1;
  // Model for SettingRow.
  late SettingRowModel settingRowModel2;
  // Model for SettingRow.
  late SettingRowModel settingRowModel3;
  // Model for SettingRow.
  late SettingRowModel settingRowModel4;
  // Model for SettingRow.
  late SettingRowModel settingRowModel5;

  @override
  void initState(BuildContext context) {
    settingRowModel1 = createModel(context, () => SettingRowModel());
    settingRowModel2 = createModel(context, () => SettingRowModel());
    settingRowModel3 = createModel(context, () => SettingRowModel());
    settingRowModel4 = createModel(context, () => SettingRowModel());
    settingRowModel5 = createModel(context, () => SettingRowModel());
  }

  @override
  void dispose() {
    settingRowModel1.dispose();
    settingRowModel2.dispose();
    settingRowModel3.dispose();
    settingRowModel4.dispose();
    settingRowModel5.dispose();
  }
}
