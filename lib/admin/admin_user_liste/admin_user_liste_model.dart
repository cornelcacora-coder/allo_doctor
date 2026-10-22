import '/components/admin_user_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'admin_user_liste_widget.dart' show AdminUserListeWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AdminUserListeModel extends FlutterFlowModel<AdminUserListeWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for adminUserCard component.
  late AdminUserCardModel adminUserCardModel1;
  // Model for adminUserCard component.
  late AdminUserCardModel adminUserCardModel2;
  // Model for adminUserCard component.
  late AdminUserCardModel adminUserCardModel3;

  @override
  void initState(BuildContext context) {
    adminUserCardModel1 = createModel(context, () => AdminUserCardModel());
    adminUserCardModel2 = createModel(context, () => AdminUserCardModel());
    adminUserCardModel3 = createModel(context, () => AdminUserCardModel());
  }

  @override
  void dispose() {
    adminUserCardModel1.dispose();
    adminUserCardModel2.dispose();
    adminUserCardModel3.dispose();
  }
}
