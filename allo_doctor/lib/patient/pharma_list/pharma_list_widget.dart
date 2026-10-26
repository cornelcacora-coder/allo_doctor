import '/components/nav_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pharma_list_model.dart';
export 'pharma_list_model.dart';

class PharmaListWidget extends StatefulWidget {
  const PharmaListWidget({super.key});

  static String routeName = 'PharmaList';
  static String routePath = '/pharmaList';

  @override
  State<PharmaListWidget> createState() => _PharmaListWidgetState();
}

class _PharmaListWidgetState extends State<PharmaListWidget> {
  late PharmaListModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmaListModel());

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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(150.0),
          child: AppBar(
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
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset(
                          'assets/images/science.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Pharmacies',
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
                  'Recherchez parmi les différentes pharmacies référencés',
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
                                onChanged: (_) => safeSetState(() {}),
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  safeSetState(() {});
                                },
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixIcon: (_model.textController?.text.isNotEmpty ?? false)
                                      ? IconButton(
                                          icon: Icon(Icons.clear_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 20),
                                          onPressed: () {
                                            _model.textController?.clear();
                                            safeSetState(() {});
                                          },
                                        )
                                      : null,
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
                                  hintText: 'Recherchez un médicament ...',
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
                            padding: EdgeInsets.all(24.0),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PHARMACIES DISPONIBLES',
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
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance.collection('pharmacies').snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_pharmacy_outlined, size: 56.0, color: Color(0xFF19BF82)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune pharmacie disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les pharmacies enregistrées apparaîtront ici dès leur configuration.',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19BF82)),
                                            ),
                                          ),
                                        );
                                      }
                                      final docs = snapshot.data!.docs;
                                      final searchText = _model.textController?.text.trim().toLowerCase() ?? '';
                                      final filteredDocs = searchText.isEmpty
                                          ? docs
                                          : docs.where((d) {
                                              final name = (d.data()['name'] as String? ?? '').toLowerCase();
                                              final city = (d.data()['city'] as String? ?? '').toLowerCase();
                                              final address = (d.data()['address'] as String? ?? '').toLowerCase();
                                              return name.contains(searchText) || city.contains(searchText) || address.contains(searchText);
                                            }).toList();

                                      if (filteredDocs.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_pharmacy_outlined, size: 56.0, color: Color(0xFF19BF82)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune pharmacie disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les pharmacies enregistrées apparaîtront ici dès leur configuration.',
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
                                        children: filteredDocs.map((doc) {
                                          final data = doc.data();
                                          final name = (data['name'] as String?)?.trim() ?? 'Pharmacie';
                                          final address = (data['address'] as String?) ?? (data['city'] as String?) ?? 'Brazzaville';
                                          final hours = (data['guard_hours'] as String?) ?? (data['hours'] as String?) ?? '08h - 20h';
                                          final isGuard = (data['is_guard'] as bool?) ?? false;
                                          final photoUrl = (data['photo_url'] as String?) ?? (data['cover'] as String?) ?? '';
                                          final phone = (data['phone_number'] as String?) ?? (data['phone'] as String?) ?? '';

                                          return Align(
                                            alignment: AlignmentDirectional(0.0, -1.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(PharmaViewWidget.routeName);
                                              },
                                              child: Material(
                                                color: Colors.transparent,
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 80.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          decoration: BoxDecoration(
                                                            color: Color(0x22FFE500),
                                                            borderRadius: BorderRadius.circular(12.0),
                                                          ),
                                                          child: photoUrl.isNotEmpty
                                                              ? ClipRRect(
                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                  child: Image.network(photoUrl, fit: BoxFit.cover),
                                                                )
                                                              : Icon(Icons.local_pharmacy_rounded, color: Color(0xFF19BF82), size: 28.0),
                                                        ),
                                                        SizedBox(width: 12.0),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      name,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Icon(Icons.verified_rounded, color: Color(0xFF19BF82), size: 16.0),
                                                                ],
                                                              ),
                                                              SizedBox(height: 4.0),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: isGuard ? Color(0x2319BF82) : Color(0x23D2BB39),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                                                    child: Text(
                                                                      isGuard ? 'De Garde' : address,
                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: isGuard ? Color(0xFF19BF82) : Color(0xFFB8A600),
                                                                        fontSize: 10.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8.0),
                                                                  Text('•', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
                                                                  SizedBox(width: 8.0),
                                                                  Text(
                                                                    hours,
                                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                      font: GoogleFonts.outfit(),
                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                      fontSize: 11.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (phone.isNotEmpty)
                                                          IconButton(
                                                            icon: Icon(Icons.phone_outlined, color: Color(0xFF19BF82), size: 20.0),
                                                            onPressed: () async {
                                                              await launchURL('tel:' + phone);
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList().divide(SizedBox(height: 16.0)),
                                      );
                                    },
                                  ),
                                ].divide(SizedBox(height: 24.0)),
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
              child: Container(
                width: double.infinity,
                height: 100.0,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navBarUserModel,
                    updateCallback: () => safeSetState(() {}),
                    child: NavBarUserWidget(),
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
