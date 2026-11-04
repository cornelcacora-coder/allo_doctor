import '/components/admin_user_card_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'admin_user_liste_model.dart';
export 'admin_user_liste_model.dart';

class AdminUserListeWidget extends StatefulWidget {
  const AdminUserListeWidget({super.key});

  static String routeName = 'AdminUserListe';
  static String routePath = '/adminUserListe';

  @override
  State<AdminUserListeWidget> createState() => _AdminUserListeWidgetState();
}

class _AdminUserListeWidgetState extends State<AdminUserListeWidget> {
  late AdminUserListeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminUserListeModel());

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
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F766E),
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
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 24.0,
                    ),
                  ),
                  Text(
                    'Utilisateurs Listé',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                          ),
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
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
                    color: FlutterFlowTheme.of(context).secondaryBackground,
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
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              wrapWithModel(
                model: _model.adminUserCardModel1,
                updateCallback: () => safeSetState(() {}),
                child: AdminUserCardWidget(
                  photo:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlVk55czOxAiN71OE3QJuNhyqr1D5Iu4ZVdqhqqNne4bmWOEbCrCODPvvN&s=10',
                  isNotVerified: false,
                  onClick: () async {},
                ),
              ),
              wrapWithModel(
                model: _model.adminUserCardModel2,
                updateCallback: () => safeSetState(() {}),
                child: AdminUserCardWidget(
                  photo:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlVk55czOxAiN71OE3QJuNhyqr1D5Iu4ZVdqhqqNne4bmWOEbCrCODPvvN&s=10',
                  isNotVerified: false,
                  onClick: () async {},
                ),
              ),
              wrapWithModel(
                model: _model.adminUserCardModel3,
                updateCallback: () => safeSetState(() {}),
                child: AdminUserCardWidget(
                  photo:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlVk55czOxAiN71OE3QJuNhyqr1D5Iu4ZVdqhqqNne4bmWOEbCrCODPvvN&s=10',
                  isNotVerified: false,
                  onClick: () async {},
                ),
              ),
            ].divide(SizedBox(height: 14.0)),
          ),
        ),
      ),
    );
  }
}
