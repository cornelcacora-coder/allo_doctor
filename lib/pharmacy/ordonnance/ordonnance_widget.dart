import '/auth/role_guard.dart';
import '/components/nav_bar_pharma_widget.dart';
import '/components/pharma_card_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ordonnance_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/prescription_service.dart';
import '/patient/prescription_view_modal.dart';
import '/pharmacy/pharmacy_prescription_processing_sheet.dart';
export 'ordonnance_model.dart';

class OrdonnanceWidget extends StatefulWidget {
  const OrdonnanceWidget({super.key});

  static String routeName = 'Ordonnance';
  static String routePath = '/ordonnance';

  @override
  State<OrdonnanceWidget> createState() => _OrdonnanceWidgetState();
}

class _OrdonnanceWidgetState extends State<OrdonnanceWidget> {
  late OrdonnanceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OrdonnanceModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      // Garde-fou : cet espace est reserve aux comptes pharmacies.
      await guardRole(context, 'pharmacie');
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
            backgroundColor: Color(0xFF4954F8),
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset(
                          'assets/images/5987354.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Ordonances',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).onPrimary,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                                lineHeight: 1.5,
                              ),
                        ),
                      ].divide(SizedBox(width: 10.0)),
                    ),
                    Icon(
                      Icons.more_vert_sharp,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ],
                ),
                Text(
                  'Trouver les ordonnances émises par différents médecin',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).onprimary80,
                        letterSpacing: 0.0,
                        fontWeight:
                            FlutterFlowTheme.of(context).bodySmall.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        lineHeight: 1.5,
                      ),
                ),
                Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(9999.0),
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 6.0, 6.0, 6.0),
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              width: 200.0,
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                enabled: true,
                                obscureText: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  hintText: 'Recherchez une Ordonance ...',
                                  hintStyle: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0x00000000),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                cursorColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                enableInteractiveSelection: true,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.search_rounded,
                            color: FlutterFlowTheme.of(context).primary,
                            size: 24.0,
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 10.0)),
            ),
            actions: [],
            centerTitle: false,
            toolbarHeight: double.infinity,
            elevation: 4.0,
          ),
        ),
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: SingleChildScrollView(
                      primary: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Container(
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LISTE DES ORDONNANCES',
                                      style: FlutterFlowTheme.of(context)
                                          .labelLarge
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelLarge
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelLarge
                                                    .fontStyle,
                                            lineHeight: 1.4,
                                          ),
                                    ),
                                    FlutterFlowChoiceChips(
                                      options: [
                                        ChipData('Nouvelles'),
                                        ChipData('Mes Ordonnances')
                                      ],
                                      onChanged: (val) => safeSetState(() =>
                                          _model.choiceChipsValue =
                                              val?.firstOrNull),
                                      selectedChipStyle: ChipStyle(
                                        backgroundColor: Color(0xFF165AC5),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        iconSize: 16.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      unselectedChipStyle: ChipStyle(
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                        textStyle: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                        iconColor: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        iconSize: 16.0,
                                        elevation: 0.0,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      chipSpacing: 14.0,
                                      rowSpacing: 12.0,
                                      multiselect: false,
                                      alignment: WrapAlignment.start,
                                      controller:
                                          _model.choiceChipsValueController ??=
                                              FormFieldController<List<String>>(
                                        [],
                                      ),
                                      wrapped: true,
                                    ),
                                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection('prescriptions')
                                          .orderBy('created_at', descending: true)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(24.0),
                                              child: Text(
                                                'Erreur de chargement des ordonnances',
                                                style: FlutterFlowTheme.of(context).bodyMedium,
                                              ),
                                            ),
                                          );
                                        }
                                        if (!snapshot.hasData) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(32.0),
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF165AC5)),
                                              ),
                                            ),
                                          );
                                        }

                                        final docs = snapshot.data!.docs;
                                        final currentTab = _model.choiceChipsValue ?? 'Nouvelles';
                                        final queryText = _model.textController?.text.toLowerCase().trim() ?? '';

                                        final filtered = docs.where((doc) {
                                          final data = doc.data();
                                          final status = (data['status'] as String?) ?? 'active';
                                          final pharmacyUid = (data['pharmacy_uid'] as String?) ?? '';

                                          if (currentTab == 'Nouvelles') {
                                            if (status != 'sent_to_pharmacy' && status != 'active') return false;
                                          } else {
                                            if (status == 'sent_to_pharmacy' || status == 'active') return false;
                                            if (currentUserUid.isNotEmpty &&
                                                 pharmacyUid.isNotEmpty &&
                                                 pharmacyUid != currentUserUid &&
                                                 !pharmacyUid.startsWith('pharma_') &&
                                                 pharmacyUid != 'pharmacie_partenaire' &&
                                                 pharmacyUid != 'pharmacie_centrale') {
                                               return false;
                                             }
                                          }

                                          if (queryText.isNotEmpty) {
                                            final patName = (data['patient_name'] as String? ?? '').toLowerCase();
                                            final docName = (data['doctor_name'] as String? ?? '').toLowerCase();
                                            final patId = (data['patient_id'] as String? ?? '').toLowerCase();
                                            if (!patName.contains(queryText) && !docName.contains(queryText) && !patId.contains(queryText)) {
                                              return false;
                                            }
                                          }
                                          return true;
                                        }).toList();

                                        if (filtered.isEmpty) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.receipt_long_outlined, size: 54.0, color: Color(0xFF165AC5)),
                                                  SizedBox(height: 12.0),
                                                  Text(
                                                    currentTab == 'Nouvelles'
                                                        ? 'Aucune nouvelle ordonnance'
                                                        : 'Aucune ordonnance en cours',
                                                    style: GoogleFonts.outfit(fontSize: 16.0, fontWeight: FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 6.0),
                                                  Text(
                                                    'Les ordonnances transmises apparaîtront ici automatiquement.',
                                                    textAlign: TextAlign.center,
                                                    style: FlutterFlowTheme.of(context).labelMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: filtered.map((doc) {
                                            final data = doc.data();
                                            final prescriptionId = doc.id;
                                            final docName = (data['doctor_name'] as String?) ?? 'Médecin Prescripteur';
                                            final docSpecialty = (data['doctor_specialty'] as String?) ?? 'Généraliste';
                                            final patId = (data['patient_id'] as String?) ?? '';
                                            final status = (data['status'] as String?) ?? 'sent_to_pharmacy';
                                            final meds = (data['medications'] as List<dynamic>?) ?? [];
                                            final medCount = meds.length;
                                            final firstMedName = meds.isNotEmpty && meds[0] is Map
                                                ? (meds[0]['name'] as String? ?? 'Médicament')
                                                : 'Médicaments prescrits';
                                            final deliveryType = (data['delivery_type'] as String?) ?? 'pickup';
                                             final patPhone = (data['patient_phone'] as String?)?.isNotEmpty == true
                                                 ? (data['patient_phone'] as String)
                                                 : ((data['delivery_phone'] as String?)?.isNotEmpty == true
                                                     ? (data['delivery_phone'] as String)
                                                     : '+242 06 719 9098');
                                             final riderPhone = (data['delivery_person_phone'] as String?) ?? '';

                                            String statusLabel = '1. Lire & Traiter l\'ordonnance (3 étapes) ➔';
                                            Color btnColor = Color(0xFF165AC5);
                                            if (status == 'in_preparation') {
                                              statusLabel = deliveryType == 'delivery'
                                                  ? '2. Préparation terminée : Envoyer Livreur 🚚 ➔'
                                                  : '2. Préparation terminée : Mettre en Retrait 🏪 ➔';
                                              btnColor = Color(0xFFD97706);
                                            } else if (status == 'ready' || status == 'out_for_delivery') {
                                              statusLabel = deliveryType == 'delivery'
                                                  ? '3. Livreur en route 🚚 (Gérer / Clôturer ✅)'
                                                  : '3. Prêt en pharmacie 🏪 (Gérer / Clôturer ✅)';
                                              btnColor = Color(0xFF16CB83);
                                            } else if (status == 'delivered') {
                                              statusLabel = 'Commande délivrée avec succès ✓';
                                              btnColor = Colors.grey.shade600;
                                            }

                                            return Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                borderRadius: BorderRadius.circular(12.0),
                                                border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(14.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              width: 42,
                                                              height: 42,
                                                              decoration: BoxDecoration(
                                                                color: Color(0xFFEEF2FF),
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Icon(Icons.medication, color: Color(0xFF165AC5), size: 24),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  firstMedName + (medCount > 1 ? ' + ${medCount - 1} autre(s)' : ''),
                                                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Icon(Icons.qr_code_2_rounded, size: 14, color: Color(0xFF16C583)),
                                                                    SizedBox(width: 4),
                                                                    Text(
                                                                      'Patient : ████████ (Masqué par QR) ${patId.isNotEmpty ? "• $patId" : ""}',
                                                                      style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: deliveryType == 'delivery' ? Color(0xFFFFF3E0) : Color(0xFFE8F5E9),
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Text(
                                                            deliveryType == 'delivery' ? '🚚 Livraison' : '🏪 Retrait',
                                                            style: GoogleFonts.outfit(
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              color: deliveryType == 'delivery' ? Colors.orange.shade900 : Colors.green.shade800,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 10),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Dr. $docName ($docSpecialty)', style: GoogleFonts.outfit(fontSize: 12, color: Colors.blueGrey)),
                                                        InkWell(
                                                          onTap: () {
                                                            PharmacyPrescriptionProcessingSheet.show(
                                                              context,
                                                              prescriptionData: data,
                                                              prescriptionId: prescriptionId,
                                                            );
                                                          },
                                                          child: Text(
                                                            'Traiter en 3 étapes (QR \u0026 Stock) ↗',
                                                            style: GoogleFonts.outfit(fontSize: 12, color: Color(0xFF165AC5), fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 12),
                                                    // ── BARRE DE COMMUNICATION DIRECTE DU PHARMACIEN ──
                                                     Container(
                                                       margin: EdgeInsets.only(bottom: 10.0),
                                                       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                       decoration: BoxDecoration(
                                                         color: Color(0xFFF1F5F9),
                                                         borderRadius: BorderRadius.circular(8),
                                                       ),
                                                       child: Row(
                                                         children: [
                                                           Icon(Icons.phone_in_talk, size: 14, color: Color(0xFF165AC5)),
                                                           SizedBox(width: 6),
                                                           Expanded(
                                                             child: Text(
                                                               'Patient : ' + patPhone,
                                                               style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                                                               overflow: TextOverflow.ellipsis,
                                                             ),
                                                           ),
                                                           InkWell(
                                                             onTap: () => launchURL('tel:' + patPhone),
                                                             child: Container(
                                                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                               decoration: BoxDecoration(
                                                                 color: Color(0xFF165AC5),
                                                                 borderRadius: BorderRadius.circular(6),
                                                               ),
                                                               child: Row(
                                                                 children: [
                                                                   Icon(Icons.call, size: 11, color: Colors.white),
                                                                   SizedBox(width: 4),
                                                                   Text('Appel', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                 ],
                                                               ),
                                                             ),
                                                           ),
                                                           SizedBox(width: 6),
                                                           InkWell(
                                                             onTap: () {
                                                               final clean = patPhone.replaceAll(RegExp(r'[^0-9]'), '');
                                                               launchURL('https://wa.me/' + clean);
                                                             },
                                                             child: Container(
                                                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                               decoration: BoxDecoration(
                                                                 color: Color(0xFF25D366),
                                                                 borderRadius: BorderRadius.circular(6),
                                                               ),
                                                               child: Row(
                                                                 children: [
                                                                   Icon(Icons.chat_bubble_outline, size: 11, color: Colors.white),
                                                                   SizedBox(width: 4),
                                                                   Text('WhatsApp', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                 ],
                                                               ),
                                                             ),
                                                           ),
                                                           if (riderPhone.isNotEmpty) ...[
                                                             SizedBox(width: 6),
                                                             InkWell(
                                                               onTap: () => launchURL('tel:' + riderPhone),
                                                               child: Container(
                                                                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                 decoration: BoxDecoration(
                                                                   color: Color(0xFFD97706),
                                                                   borderRadius: BorderRadius.circular(6),
                                                                 ),
                                                                 child: Row(
                                                                   children: [
                                                                     Icon(Icons.two_wheeler, size: 11, color: Colors.white),
                                                                     SizedBox(width: 4),
                                                                     Text('Livreur', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                                   ],
                                                                 ),
                                                               ),
                                                             ),
                                                           ],
                                                         ],
                                                       ),
                                                     ),
                                                     if (status != 'delivered')
                                                      InkWell(
                                                        onTap: () {
                                                          PharmacyPrescriptionProcessingSheet.show(
                                                            context,
                                                            prescriptionData: data,
                                                            prescriptionId: prescriptionId,
                                                          );
                                                        },
                                                        child: Container(
                                                          width: double.infinity,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: btnColor,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            statusLabel,
                                                            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                          ),
                                                        ),
                                                      )
                                                    else
                                                      Container(
                                                        width: double.infinity,
                                                        height: 36,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFE8F5E9),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'Délivré avec succès ✓',
                                                          style: GoogleFonts.outfit(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    )
                                  ].divide(SizedBox(height: 24.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional(0.0, 1.0),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(),
                  child: wrapWithModel(
                    model: _model.navBarPharmaModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavBarPharmaWidget(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
