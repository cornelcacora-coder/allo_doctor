import '/components/agenda_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'agenda_widget.dart' show AgendaWidget;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AgendaModel extends FlutterFlowModel<AgendaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // Model for agendaCard component.
  late AgendaCardModel agendaCardModel1;
  // Model for agendaCard component.
  late AgendaCardModel agendaCardModel2;
  // Model for agendaCard component.
  late AgendaCardModel agendaCardModel3;
  // Model for agendaCard component.
  late AgendaCardModel agendaCardModel4;

  @override
  void initState(BuildContext context) {
    agendaCardModel1 = createModel(context, () => AgendaCardModel());
    agendaCardModel2 = createModel(context, () => AgendaCardModel());
    agendaCardModel3 = createModel(context, () => AgendaCardModel());
    agendaCardModel4 = createModel(context, () => AgendaCardModel());
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    agendaCardModel1.dispose();
    agendaCardModel2.dispose();
    agendaCardModel3.dispose();
    agendaCardModel4.dispose();
  }
}
