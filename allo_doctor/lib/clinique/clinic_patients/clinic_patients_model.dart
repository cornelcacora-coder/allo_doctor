import '/components/patient_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'clinic_patients_widget.dart' show ClinicPatientsWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ClinicPatientsModel extends FlutterFlowModel<ClinicPatientsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for patientCard component.
  late PatientCardModel patientCardModel1;
  // Model for patientCard component.
  late PatientCardModel patientCardModel2;

  @override
  void initState(BuildContext context) {
    patientCardModel1 = createModel(context, () => PatientCardModel());
    patientCardModel2 = createModel(context, () => PatientCardModel());
  }

  @override
  void dispose() {
    patientCardModel1.dispose();
    patientCardModel2.dispose();
  }
}
