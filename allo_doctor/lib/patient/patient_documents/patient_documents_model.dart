import '/flutter_flow/flutter_flow_util.dart';
import 'patient_documents_widget.dart' show PatientDocumentsWidget;
import 'package:flutter/material.dart';

class PatientDocumentsModel extends FlutterFlowModel<PatientDocumentsWidget> {
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
  }
}
