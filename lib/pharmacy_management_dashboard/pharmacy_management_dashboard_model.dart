import '/components/kpi_card_widget.dart';
import '/components/module_row_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'pharmacy_management_dashboard_widget.dart'
    show PharmacyManagementDashboardWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PharmacyManagementDashboardModel
    extends FlutterFlowModel<PharmacyManagementDashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for KpiCard.
  late KpiCardModel kpiCardModel1;
  // Model for KpiCard.
  late KpiCardModel kpiCardModel2;
  // Model for KpiCard.
  late KpiCardModel kpiCardModel3;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel1;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel2;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel3;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel4;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel5;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel6;
  // Model for ModuleRow.
  late ModuleRowModel moduleRowModel7;

  @override
  void initState(BuildContext context) {
    kpiCardModel1 = createModel(context, () => KpiCardModel());
    kpiCardModel2 = createModel(context, () => KpiCardModel());
    kpiCardModel3 = createModel(context, () => KpiCardModel());
    moduleRowModel1 = createModel(context, () => ModuleRowModel());
    moduleRowModel2 = createModel(context, () => ModuleRowModel());
    moduleRowModel3 = createModel(context, () => ModuleRowModel());
    moduleRowModel4 = createModel(context, () => ModuleRowModel());
    moduleRowModel5 = createModel(context, () => ModuleRowModel());
    moduleRowModel6 = createModel(context, () => ModuleRowModel());
    moduleRowModel7 = createModel(context, () => ModuleRowModel());
  }

  @override
  void dispose() {
    kpiCardModel1.dispose();
    kpiCardModel2.dispose();
    kpiCardModel3.dispose();
    moduleRowModel1.dispose();
    moduleRowModel2.dispose();
    moduleRowModel3.dispose();
    moduleRowModel4.dispose();
    moduleRowModel5.dispose();
    moduleRowModel6.dispose();
    moduleRowModel7.dispose();
  }
}
