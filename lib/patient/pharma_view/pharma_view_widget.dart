import '/components/product_card_widget.dart';
import '/components/stateitem_widget.dart';
import '/components/pharmacy_chat_sheet.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pharma_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
export 'pharma_view_model.dart';

class PharmaViewWidget extends StatefulWidget {
  const PharmaViewWidget({
    super.key,
    this.pharmacyId,
    this.name,
    this.address,
    this.phone,
    this.hours,
    this.isGuard = false,
    this.photoUrl,
  });

  final String? pharmacyId;
  final String? name;
  final String? address;
  final String? phone;
  final String? hours;
  final bool isGuard;
  final String? photoUrl;

  static String routeName = 'PharmaView';
  static String routePath = '/pharmaView';

  @override
  State<PharmaViewWidget> createState() => _PharmaViewWidgetState();
}

class _PharmaViewWidgetState extends State<PharmaViewWidget> {
  late PharmaViewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmaViewModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ),
                  Text(
                    widget.name ?? 'Pharmacie',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleLarge.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                  Icon(
                    Icons.more_vert_sharp,
                    color: FlutterFlowTheme.of(context).alternate,
                    size: 24.0,
                  ),
                ],
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 4.0,
        ),
        body: Container(
          height: double.infinity,
          child: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: 180.0,
                      child: Stack(
                        alignment: AlignmentDirectional(0.0, -1.0),
                        children: [
                          ClipRRect(
                            child: Container(
                              height: 160.0,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    FlutterFlowTheme.of(context).primary,
                                    FlutterFlowTheme.of(context).secondary
                                  ],
                                  stops: [0.0, 1.0],
                                  begin: AlignmentDirectional(0.0, -1.0),
                                  end: AlignmentDirectional(0, 1.0),
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: Opacity(
                                opacity: 0.6,
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 0),
                                  fadeOutDuration: Duration(milliseconds: 0),
                                  imageUrl:
                                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuJd79lESiMSYUkRiR6opa4IdwozzX3xy1WKWfCEQ0j-58u2c3RFLYxqsx&s=10',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(0.0, 0.0),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 1.0),
                            child: Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Container(
                                  child: ClipOval(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(48.0),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              Duration(milliseconds: 0),
                                          fadeOutDuration:
                                              Duration(milliseconds: 0),
                                          imageUrl:
                                              'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/trendify-fashion-app-template-3i937k/assets/7ls1elfdve74/images_(2).jpg',
                                          width: 96.0,
                                          height: 96.0,
                                          fit: BoxFit.cover,
                                          alignment: Alignment(0.0, 0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(-0.75, -0.03),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.name ?? 'Pharmacie Partenaire',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineSmall
                                        .fontStyle,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: FlutterFlowTheme.of(context).info,
                                  size: 16.0,
                                ),
                                Text(
                                  'Certified Digital Pharmacy',
                                  style: FlutterFlowTheme.of(context)
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
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 40.0,
                          child: wrapWithModel(
                            model: _model.stateitemModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: StateitemWidget(
                              label: 'En attente',
                              count: '22',
                            ),
                          ),
                        ),
                        Container(
                          height: 40.0,
                          decoration: BoxDecoration(),
                          child: wrapWithModel(
                            model: _model.stateitemModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: StateitemWidget(
                              label: 'Livrer',
                              count: '10',
                            ),
                          ),
                        ),
                        Container(
                          height: 40.0,
                          decoration: BoxDecoration(),
                          child: wrapWithModel(
                            model: _model.stateitemModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: StateitemWidget(
                              label: 'En cours',
                              count: '7',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Align(
                          alignment: AlignmentDirectional(-0.08, 0.1),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 10.0, 0.0, 0.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final p = (widget.phone ?? '').replaceAll(' ', '');
                                    if (p.isNotEmpty) {
                                      final uri = Uri.parse('tel:$p');
                                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Numéro de téléphone non renseigné pour cette pharmacie'),
                                      ));
                                    }
                                  },
                                  child: Container(
                                    width: 150.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context).primary,
                                          Color(0xFF16C583)
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(1.0, -1.0),
                                        end: AlignmentDirectional(-1.0, 1.0),
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.phone_in_talk, color: Colors.white, size: 16.0),
                                        SizedBox(width: 6.0),
                                        Text(
                                          'Appeler',
                                          style: FlutterFlowTheme.of(context)
                                              .labelSmall
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                fontSize: 12.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                                lineHeight: 1.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF25D366).withOpacity(0.12),
                                  icon: FaIcon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Color(0xFF25D366),
                                    size: 26.0,
                                  ),
                                  onPressed: () async {
                                    final p = (widget.phone ?? '').replaceAll(' ', '').replaceAll('+', '');
                                    if (p.isNotEmpty) {
                                      final uri = Uri.parse('https://wa.me/$p?text=Bonjour%20${Uri.encodeComponent(widget.name ?? "Pharmacie")}%20je%20souhaite%20des%20informations%20sur%20un%20médicament');
                                      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Numéro WhatsApp non renseigné pour cette pharmacie'),
                                      ));
                                    }
                                  },
                                ),
                                // Bouton messagerie interne patient vs pharmacien
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF14563C).withOpacity(0.10),
                                  icon: Icon(
                                    Icons.chat_rounded,
                                    color: Color(0xFF14563C),
                                    size: 22.0,
                                  ),
                                  onPressed: () async {
                                    final pharmId = widget.pharmacyId ?? '';
                                    if (pharmId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Identifiant pharmacie introuvable.'),
                                      ));
                                      return;
                                    }
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => Padding(
                                        padding: MediaQuery.viewInsetsOf(ctx),
                                        child: PharmacyChatSheet(
                                          pharmacyId: pharmId,
                                          pharmacyName: widget.name ?? 'Pharmacie',
                                        ),
                                      ),
                                    );
                                  },
                                ),                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(9999.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              20.0, 6.0, 6.0, 6.0),
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
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        hintText:
                                            'Recherchez un médicament ...',
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
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        filled: true,
                                        fillColor: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                      ),
                                      style: FlutterFlowTheme.of(context)
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
                                      cursorColor: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      enableInteractiveSelection: true,
                                      validator: _model.textControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF165C40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: Icon(
                                        Icons.search_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryBackground,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                                // Bouton messagerie interne patient vs pharmacien
                                FlutterFlowIconButton(
                                  borderRadius: 8.0,
                                  buttonSize: 40.0,
                                  fillColor: Color(0xFF14563C).withOpacity(0.10),
                                  icon: Icon(
                                    Icons.chat_rounded,
                                    color: Color(0xFF14563C),
                                    size: 22.0,
                                  ),
                                  onPressed: () async {
                                    final pharmId = widget.pharmacyId ?? '';
                                    if (pharmId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Identifiant pharmacie introuvable.'),
                                      ));
                                      return;
                                    }
                                    await showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => Padding(
                                        padding: MediaQuery.viewInsetsOf(ctx),
                                        child: PharmacyChatSheet(
                                          pharmacyId: pharmId,
                                          pharmacyName: widget.name ?? 'Pharmacie',
                                        ),
                                      ),
                                    );
                                  },
                                ),                              ].divide(SizedBox(width: 16.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                      child: FlutterFlowChoiceChips(
                        options: [
                          ChipData('Tous'),
                          ChipData('Urgence'),
                          ChipData('Beauté'),
                          ChipData('Nutrition'),
                          ChipData('Hygiene intime'),
                          ChipData('Tendance')
                        ],
                        onChanged: (val) => safeSetState(
                            () => _model.choiceChipsValue = val?.firstOrNull),
                        selectedChipStyle: ChipStyle(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                          iconColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          iconSize: 16.0,
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        unselectedChipStyle: ChipStyle(
                          backgroundColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle: FlutterFlowTheme.of(context)
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
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                          iconColor: FlutterFlowTheme.of(context).secondaryText,
                          iconSize: 16.0,
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        chipSpacing: 8.0,
                        rowSpacing: 8.0,
                        multiselect: false,
                        alignment: WrapAlignment.start,
                        controller: _model.choiceChipsValueController ??=
                            FormFieldController<List<String>>(
                          [],
                        ),
                        wrapped: true,
                      ),
                    ),
                    // Grille des produits réels de la pharmacie
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('pharmacies')
                            .doc(widget.pharmacyId ?? '')
                            .collection('products')
                            .snapshots(),
                        builder: (context, snap) {
                          final docs = snap.data?.docs ?? [];
                          final searchText = _model.textController?.text.trim().toLowerCase() ?? '';
                          final filtered = searchText.isEmpty
                              ? docs
                              : docs.where((d) {
                                  final n = (d.data()['name'] as String? ?? '').toLowerCase();
                                  final c = (d.data()['category'] as String? ?? '').toLowerCase();
                                  return n.contains(searchText) || c.contains(searchText);
                                }).toList();

                          if (snap.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                              ),
                            );
                          }

                          if (filtered.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.medication_outlined, size: 56, color: Color(0xFF19BF82).withOpacity(0.4)),
                                    SizedBox(height: 12.0),
                                    Text(
                                      searchText.isEmpty
                                          ? 'Aucun produit disponible pour le moment'
                                          : 'Aucun résultat pour "$searchText"',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                    SizedBox(height: 6.0),
                                    Text(
                                      "Contactez la pharmacie pour vérifier la disponibilité d'un médicament.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.outfit(
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final data = filtered[i].data();
                              final pName = (data['name'] as String?) ?? 'Produit';
                              final pPrice = (data['price'] ?? data['prix'] ?? '0').toString();
                              final pCover = (data['image_url'] as String?) ?? (data['cover'] as String?) ?? '';
                              final pCategory = (data['category'] as String?) ?? (data['categorie'] as String?) ?? 'Pharmacie';
                              final pDescription = (data['description'] as String?) ?? (data['notice'] as String?) ?? '';
                              final pId = filtered[i].id;
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  context.pushNamed(
                                    ProductViewWidget.routeName,
                                    queryParameters: {
                                      'productId': pId,
                                      'pharmacyId': widget.pharmacyId ?? '',
                                      'name': pName,
                                      'price': pPrice,
                                      'cover': pCover,
                                      'category': pCategory,
                                    },
                                  );
                                },
                                child: ProductCardWidget(
                                  isFavorite: false,
                                  category: pCategory,
                                  name: pName,
                                  price: pPrice,
                                  cover: pCover,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 100.0,
                      decoration: BoxDecoration(),
                    ),
                  ]
                      .divide(SizedBox(height: 20.0))
                      .addToEnd(SizedBox(height: 10.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
