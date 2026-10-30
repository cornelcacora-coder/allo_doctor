import '/components/log_out_widget.dart';
import '/components/nav_bar_pharma_widget.dart';
import '/components/product_card_widget.dart';
import '/components/stateitem_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_pharmacy_model.dart';
import '/pharmacy/pharma_chat_inbox_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/notification_bell_widget.dart';
export 'home_pharmacy_model.dart';

class HomePharmacyWidget extends StatefulWidget {
  const HomePharmacyWidget({super.key});

  static String routeName = 'HomePharmacy';
  static String routePath = '/homePharmacy';

  @override
  State<HomePharmacyWidget> createState() => _HomePharmacyWidgetState();
}

class _HomePharmacyWidgetState extends State<HomePharmacyWidget> {
  late HomePharmacyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePharmacyModel());

    _model.switchValue = true;
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      // Garde-fou : cet espace est reserve aux comptes pharmacies.
      await guardRole(context, 'pharmacie');
      if (currentUserUid.isNotEmpty) {
        try {
          final pharmaRef = FirebaseFirestore.instance.collection('pharmacies').doc(currentUserUid);
          final pharmaSnap = await pharmaRef.get();
          if (!pharmaSnap.exists) {
            final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();
            final ud = userDoc.data() ?? {};
            final pName = (ud['name'] ?? ud['nom'] ?? currentUserDisplayName ?? 'Pharmacie').toString();
            final pPhone = (ud['phone'] ?? ud['telephone'] ?? '').toString();
            final pCity = (ud['city'] ?? ud['ville'] ?? 'Brazzaville').toString();
            await pharmaRef.set({
              'id': currentUserUid,
              'uid': currentUserUid,
              'name': pName.isNotEmpty ? pName : 'Pharmacie Partenaire',
              'pharmacy_name': pName.isNotEmpty ? pName : 'Pharmacie Partenaire',
              'phone': pPhone,
              'phone_number': pPhone,
              'city': pCity,
              'address': pCity,
              'email': currentUserEmail,
              'is_open': true,
              'is_available': true,
              'is_guard': false,
              'rating': 5.0,
              'status': 'actif',
              'guard_hours': '08h00 - 20h00',
              'hours': '08h00 - 20h00',
              'created_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (_) {}
      }
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
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45.0,
                        height: 45.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).surface15,
                          borderRadius: BorderRadius.circular(12.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 5.0, 0.0, 0.0),
                                child: Container(
                                  width: 25.0,
                                  height: 25.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 2.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/Logo_Mini-removebg-preview.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Allô Docteur',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                              lineHeight: 1.4,
                            ),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 10.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).surface15,
                        icon: Icon(
                          Icons.delivery_dining_rounded,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(AssignDeliveryWidget.routeName);
                        },
                      ),
                      NotificationBellWidget(iconColor: FlutterFlowTheme.of(context).onPrimary, size: 24.0),
                      FlutterFlowIconButton(
                        borderRadius: 10.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).surface15,
                        icon: Icon(
                          Icons.settings_outlined,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(SettingsWidget.routeName);
                        },
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 10.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).surface15,
                        icon: Icon(
                          Icons.logout_rounded,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: LogOutWidget(),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        },
                      ),
                    ].divide(SizedBox(width: 8.0)),
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
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: currentUserUid.isNotEmpty
                          ? FirebaseFirestore.instance.collection('users').doc(currentUserUid).snapshots()
                          : null,
                      builder: (context, userSnapshot) {
                        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: currentUserUid.isNotEmpty
                              ? FirebaseFirestore.instance.collection('practitioners').doc(currentUserUid).snapshots()
                              : null,
                          builder: (context, practSnapshot) {
                            final userData = userSnapshot.data?.data();
                            final practData = practSnapshot.data?.data();

                            final userStatus = ((userData?['status'] as String?) ?? '').toLowerCase().trim();
                            final practStatus = ((practData?['status'] as String?) ?? '').toLowerCase().trim();

                            final isValidated = userStatus == 'validé' ||
                                userStatus == 'valide' ||
                                userStatus == 'active' ||
                                userData?['isValidated'] == true ||
                                userData?['is_validated'] == true ||
                                practStatus == 'validé' ||
                                practStatus == 'valide' ||
                                practStatus == 'active' ||
                                practData?['isValidated'] == true ||
                                practData?['is_validated'] == true;

                            final rawName = (practData?['name'] as String?) ??
                                (userData?['displayName'] as String?) ??
                                (userData?['name'] as String?) ??
                                (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Pharmacie Partenaire');
                            final displayName = rawName.trim().isNotEmpty ? rawName.trim() : 'Pharmacie Partenaire';

                            final photoUrl = (practData?['photo_url'] as String?) ??
                                (userData?['photoUrl'] as String?) ??
                                (userData?['photo_url'] as String?) ??
                                currentUserPhoto;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
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
                                              'https://placehold.co/800x400/1a6b3c/ffffff?text=Pharmacie',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          alignment: Alignment(0.0, 0.0),
                                          errorWidget: (_, __, ___) => Container(color: const Color(0xFF1a6b3c), child: const Icon(Icons.local_pharmacy, color: Colors.white, size: 48)),
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
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: ClipOval(
                                          child: photoUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  fadeInDuration: Duration(milliseconds: 0),
                                                  fadeOutDuration: Duration(milliseconds: 0),
                                                  imageUrl: photoUrl,
                                                  width: 96.0,
                                                  height: 96.0,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 96.0,
                                                  height: 96.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontSize: 38.0,
                                                      fontWeight: FontWeight.bold,
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
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      displayName,
                                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isValidated ? Icons.verified_rounded : Icons.pending_outlined,
                                          color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).secondary,
                                          size: 16.0,
                                        ),
                                        Text(
                                          isValidated ? 'Pharmacie Partenaire Validée' : 'En attente de validation par l\'administrateur',
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).secondary,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                          },
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('prescriptions').snapshots(),
                      builder: (context, presSnapshot) {
                        int pendingCount = 0;
                        int inProgressCount = 0;
                        int deliveredCount = 0;

                        if (presSnapshot.hasData) {
                          for (final doc in presSnapshot.data!.docs) {
                            final d = doc.data();
                            final pUid = (d['pharmacy_uid'] as String?) ?? '';
                            final st = (d['status'] as String?) ?? 'sent_to_pharmacy';
                            if (pUid.isEmpty || currentUserUid.isEmpty || pUid == currentUserUid) {
                              if (st == 'sent_to_pharmacy' || st == 'active') {
                                pendingCount++;
                              } else if (st == 'in_preparation') {
                                inProgressCount++;
                              } else if (st == 'ready' || st == 'out_for_delivery' || st == 'delivered') {
                                deliveredCount++;
                              }
                            }
                          }
                        }

                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 56.0,
                              child: wrapWithModel(
                                model: _model.stateitemModel1,
                                updateCallback: () => safeSetState(() {}),
                                child: StateitemWidget(
                                  label: 'En attente',
                                  count: '$pendingCount',
                                ),
                              ),
                            ),
                            Container(
                              height: 56.0,
                              decoration: BoxDecoration(),
                              child: wrapWithModel(
                                model: _model.stateitemModel2,
                                updateCallback: () => safeSetState(() {}),
                                child: StateitemWidget(
                                  label: 'Livrées',
                                  count: '$deliveredCount',
                                ),
                              ),
                            ),
                            Container(
                              height: 56.0,
                              decoration: BoxDecoration(),
                              child: wrapWithModel(
                                model: _model.stateitemModel3,
                                updateCallback: () => safeSetState(() {}),
                                child: StateitemWidget(
                                  label: 'En cours',
                                  count: '$inProgressCount',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(14.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.perm_contact_cal,
                                            color: FlutterFlowTheme.of(context)
                                                .tertiary,
                                            size: 22.0,
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Disponibilité ',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .bodySmall
                                                    .override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodySmall
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .bodySmall
                                                              .fontStyle,
                                                    ),
                                              ),
                                              Text(
                                                'Actuellement disponible ',
                                                style: FlutterFlowTheme.of(
                                                        context)
                                                    .labelSmall
                                                    .override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .labelSmall
                                                                .fontStyle,
                                                      ),
                                                      color:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .secondaryText,
                                                      fontSize: 12.0,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                      lineHeight: 1.4,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ].divide(SizedBox(width: 6.0)),
                                      ),
                                      Switch.adaptive(
                                        value: _model.switchValue!,
                                        onChanged: (newValue) async {
                                          safeSetState(() => _model.switchValue = newValue);
                                          if (currentUserUid.isNotEmpty) {
                                            try {
                                              await FirebaseFirestore.instance.collection('users').doc(currentUserUid).set({
                                                'is_open': newValue,
                                                'is_available': newValue,
                                              }, SetOptions(merge: true));
                                              await FirebaseFirestore.instance.collection('pharmacies').doc(currentUserUid).set({
                                                'is_open': newValue,
                                                'is_available': newValue,
                                                'is_guard': newValue,
                                              }, SetOptions(merge: true));
                                            } catch (_) {}
                                          }
                                        },
                                        activeColor:
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                        activeTrackColor:
                                            FlutterFlowTheme.of(context)
                                                .accent2,
                                        inactiveTrackColor:
                                            FlutterFlowTheme.of(context)
                                                .alternate,
                                        inactiveThumbColor:
                                            FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                      ),
                                    ].divide(SizedBox(width: 20.0)),
                                  ),
                                ),
                              ),
                            ].divide(SizedBox(height: 10.0)),
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
                              ].divide(SizedBox(width: 16.0)),
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
                          backgroundColor: Color(0xFF4954F8),
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
                    // Section Messagerie Patients
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_rounded, color: Color(0xFF4954F8), size: 18.0),
                              SizedBox(width: 8.0),
                              Text(
                                'MESSAGES PATIENTS',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('chats')
                                .where('pharmacyId', isEqualTo: currentUserUid)
                                .snapshots(),
                            builder: (ctx, snap) {
                              final totalUnread = (snap.data?.docs ?? []).fold<int>(
                                  0, (acc, doc) => acc + ((doc.data()['unreadByPharmacy'] as int?) ?? 0));
                              if (totalUnread == 0) return const SizedBox();
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4954F8),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  ' non lu',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      height: 260.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: const PharmaChatInboxWidget(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CATALOGUE PHARMACIE',
                            style: GoogleFonts.outfit(
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(AddProductToWidget.routeName);
                            },
                            text: '+ Nouveau Produit',
                            options: FFButtonOptions(
                              height: 32.0,
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              color: Color(0xFF4954F8),
                              textStyle: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: currentUserUid.isEmpty
                          ? Stream.value([])
                          : FirebaseFirestore.instance
                              .collection('pharmacies')
                              .doc(currentUserUid)
                              .collection('products')
                              .snapshots()
                              .asyncMap((subSnap) async {
                                final subList = subSnap.docs
                                    .map((d) => {...d.data(), '_docId': d.id})
                                    .toList();
                                final medSnap = await FirebaseFirestore.instance
                                    .collection('medicines')
                                    .where('pharmacy_uid', isEqualTo: currentUserUid)
                                    .get();
                                final medList = medSnap.docs
                                    .map((d) => {...d.data(), '_docId': d.id})
                                    .toList();
                                final seen = <String>{};
                                final merged = <Map<String, dynamic>>[];
                                for (final item in [...subList, ...medList]) {
                                  final n = ((item['name'] as String?) ?? '').toLowerCase();
                                  if (seen.add(n)) merged.add(item);
                                }
                                return merged;
                              }),
                      builder: (context, medSnapshot) {
                        if (!medSnapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(color: Color(0xFF4954F8)),
                            ),
                          );
                        }
                        final allDocs = medSnapshot.data!;
                        final selectedCat = _model.choiceChipsValue;
                        final searchQ = _model.textController?.text.toLowerCase().trim() ?? '';

                        final filtered = allDocs.where((data) {
                          if (selectedCat != null && selectedCat.isNotEmpty && selectedCat != 'Tous') {
                            final cat = (data['category'] as String?) ?? '';
                            if (cat.toLowerCase() != selectedCat.toLowerCase()) return false;
                          }
                          if (searchQ.isNotEmpty) {
                            final name = (data['name'] as String? ?? '').toLowerCase();
                            if (!name.contains(searchQ)) return false;
                          }
                          return true;
                        }).toList();

                        if (filtered.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48.0, color: Color(0xFF4954F8)),
                                  SizedBox(height: 12.0),
                                  Text(
                                    'Aucun médicament dans le catalogue',
                                    style: GoogleFonts.outfit(fontSize: 16.0, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    'Ajoutez vos produits en stock pour que vos clients puissent les commander.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).labelMedium,
                                  ),
                                  SizedBox(height: 16.0),
                                  FFButtonWidget(
                                    onPressed: () async {
                                      context.pushNamed(AddProductToWidget.routeName);
                                    },
                                    text: 'Ajouter mon premier médicament',
                                    options: FFButtonOptions(
                                      width: 240.0,
                                      height: 40.0,
                                      color: Color(0xFF4954F8),
                                      textStyle: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 0.8,
                            ),
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final data = filtered[index];
                              final name = (data['name'] as String?) ?? 'Médicament';
                              final price = (data['price'] as String?) ?? '1000';
                              final category = (data['category'] as String?) ?? 'En Stock';
                              final cover = (data['cover'] as String?) ??
                                  (data['photo_url'] as String?) ??
                                  'https://placehold.co/500x500/e8f5e9/1a6b3c?text=M%C3%A9dicament';
                              final description = (data['description'] as String?) ?? (data['notice'] as String?) ?? '';

                              return InkWell(
                                onTap: () async {
                                  context.pushNamed(
                                    ProductViewWidget.routeName,
                                    queryParameters: {
                                      'name': name,
                                      'price': price,
                                      'cover': cover,
                                      'category': category,
                                       'description': description,
                                    },
                                  );
                                },
                                child: ProductCardWidget(
                                  isFavorite: false,
                                  category: category,
                                  name: name,
                                  price: price,
                                  cover: cover,
                                ),
                              );
                            },
                          ),
                        );
                      },
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
      ),
    );
  }
}

