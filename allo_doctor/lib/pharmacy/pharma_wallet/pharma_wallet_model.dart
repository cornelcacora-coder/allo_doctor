import '/components/nav_bar_pharma_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'pharma_wallet_widget.dart' show PharmaWalletWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PharmaWalletModel extends FlutterFlowModel<PharmaWalletWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NavBarPharma component.
  late NavBarPharmaModel navBarPharmaModel;

  @override
  void initState(BuildContext context) {
    navBarPharmaModel = createModel(context, () => NavBarPharmaModel());
  }

  @override
  void dispose() {
    navBarPharmaModel.dispose();
  }
}
