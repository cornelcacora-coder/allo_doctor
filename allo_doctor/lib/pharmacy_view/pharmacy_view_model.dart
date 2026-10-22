import '/components/griditem_widget.dart';
import '/components/main_floating_navbar_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'pharmacy_view_widget.dart' show PharmacyViewWidget;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PharmacyViewModel extends FlutterFlowModel<PharmacyViewWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Griditem component.
  late GriditemModel griditemModel1;
  // Model for Griditem component.
  late GriditemModel griditemModel2;
  // Model for Griditem component.
  late GriditemModel griditemModel3;
  // Model for Griditem component.
  late GriditemModel griditemModel4;
  // Model for Griditem component.
  late GriditemModel griditemModel5;
  // Model for Griditem component.
  late GriditemModel griditemModel6;
  // Model for MainFloatingNavbar component.
  late MainFloatingNavbarModel mainFloatingNavbarModel;

  @override
  void initState(BuildContext context) {
    griditemModel1 = createModel(context, () => GriditemModel());
    griditemModel2 = createModel(context, () => GriditemModel());
    griditemModel3 = createModel(context, () => GriditemModel());
    griditemModel4 = createModel(context, () => GriditemModel());
    griditemModel5 = createModel(context, () => GriditemModel());
    griditemModel6 = createModel(context, () => GriditemModel());
    mainFloatingNavbarModel =
        createModel(context, () => MainFloatingNavbarModel());
  }

  @override
  void dispose() {
    griditemModel1.dispose();
    griditemModel2.dispose();
    griditemModel3.dispose();
    griditemModel4.dispose();
    griditemModel5.dispose();
    griditemModel6.dispose();
    mainFloatingNavbarModel.dispose();
  }
}
