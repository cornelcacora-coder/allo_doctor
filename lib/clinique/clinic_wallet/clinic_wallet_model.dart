import '/components/nav_bar_clinic_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'clinic_wallet_widget.dart' show ClinicWalletWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClinicWalletModel extends FlutterFlowModel<ClinicWalletWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NavBarClinic component.
  late NavBarClinicModel navBarClinicModel;

  @override
  void initState(BuildContext context) {
    navBarClinicModel = createModel(context, () => NavBarClinicModel());
  }

  @override
  void dispose() {
    navBarClinicModel.dispose();
  }
}
