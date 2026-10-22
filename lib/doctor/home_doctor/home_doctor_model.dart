import '/components/log_out_widget.dart';
import '/components/stateitem_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'dart:math' as math;
import 'home_doctor_widget.dart' show HomeDoctorWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeDoctorModel extends FlutterFlowModel<HomeDoctorWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Stateitem component.
  late StateitemModel stateitemModel1;
  // Model for Stateitem component.
  late StateitemModel stateitemModel2;
  // Model for Stateitem component.
  late StateitemModel stateitemModel3;
  // State field(s) for Switch widget.
  bool? switchValue;

  @override
  void initState(BuildContext context) {
    stateitemModel1 = createModel(context, () => StateitemModel());
    stateitemModel2 = createModel(context, () => StateitemModel());
    stateitemModel3 = createModel(context, () => StateitemModel());
  }

  @override
  void dispose() {
    stateitemModel1.dispose();
    stateitemModel2.dispose();
    stateitemModel3.dispose();
  }
}
