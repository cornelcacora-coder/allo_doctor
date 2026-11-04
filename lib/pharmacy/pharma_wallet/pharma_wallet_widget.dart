import '/auth/firebase_auth/auth_util.dart';
import '/auth/role_guard.dart';
import '/components/nav_bar_pharma_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pharma_wallet_model.dart';
export 'pharma_wallet_model.dart';

class PharmaWalletWidget extends StatefulWidget {
  const PharmaWalletWidget({super.key});

  static String routeName = 'pharmaWallet';
  static String routePath = '/pharmaWallet';

  @override
  State<PharmaWalletWidget> createState() => _PharmaWalletWidgetState();
}

class _PharmaWalletWidgetState extends State<PharmaWalletWidget> {
  late PharmaWalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PharmaWalletModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'pharmacie');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget _statBadge(String value, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).accent2,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                color: FlutterFlowTheme.of(context).success,
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  Widget _statRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool currencyF = false,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22.0),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                        color: iconColor,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).accent2,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                child: Text(
                  currencyF ? '$value F' : value,
                  textAlign: TextAlign.end,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).success,
                        fontSize: 12.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        // ─── AppBar avec solde total en temps réel ─────────────────────────
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150.0),
          child: AppBar(
            backgroundColor: const Color(0xFF4954F8),
            automaticallyImplyLeading: false,
            title: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Ma Caisse ',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).onPrimary,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.5,
                              ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ],
                ),
                // Solde = somme des total_price des commandes 'delivered'
                uid.isEmpty
                    ? Text('0F', style: _balanceTextStyle(context))
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('orders')
                            .where('pharmacy_id', isEqualTo: uid)
                            .where('status', isEqualTo: 'delivered')
                            .snapshots(),
                        builder: (ctx, snap) {
                          double total = 0;
                          if (snap.hasData) {
                            for (final doc in snap.data!.docs) {
                              final d = doc.data();
                              final price = _toDouble(d['total_price']);
                              total += price;
                            }
                          }
                          return Text(
                            '${total.toStringAsFixed(0)}F',
                            style: _balanceTextStyle(context),
                          );
                        },
                      ),
                Text(
                  'Solde Total',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(),
                        color: FlutterFlowTheme.of(context).onprimary80,
                        letterSpacing: 0.0,
                        lineHeight: 1.5,
                      ),
                ),
              ].divide(const SizedBox(height: 10.0)),
            ),
            actions: const [],
            centerTitle: false,
            toolbarHeight: double.infinity,
            elevation: 4.0,
          ),
        ),
        // ─── Body ──────────────────────────────────────────────────────────
        body: uid.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('pharmacy_id', isEqualTo: uid)
                    .snapshots(),
                builder: (ctx, ordersSnap) {
                  // Calculs en temps réel
                  int commandesEnCours = 0;
                  int produitVendu = 0;
                  double recette = 0;

                  if (ordersSnap.hasData) {
                    for (final doc in ordersSnap.data!.docs) {
                      final d = doc.data();
                      final status = (d['status'] as String?) ?? '';
                      final qty = _toInt(d['quantity']);
                      final price = _toDouble(d['total_price']);

                      if (status == 'pending' || status == 'confirmed') {
                        commandesEnCours++;
                      }
                      if (status == 'delivered') {
                        produitVendu += qty;
                        recette += price;
                      }
                    }
                  }

                  return Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        child: SingleChildScrollView(
                          primary: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  child: SingleChildScrollView(
                                    primary: false,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Bouton retrait
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFF142858), Color(0xFF4954F8)],
                                                stops: [0.0, 1.0],
                                                begin: AlignmentDirectional(1.0, -1.0),
                                                end: AlignmentDirectional(-1.0, 1.0),
                                              ),
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Effectuer un retrait',
                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight: FontWeight.w600,
                                                        lineHeight: 1.3,
                                                      ),
                                                ),
                                                const Icon(Icons.arrow_downward_outlined, color: Colors.white, size: 14.0),
                                              ].divide(const SizedBox(width: 10.0)),
                                            ),
                                          ),
                                        ),
                                        // Titre section
                                        Text(
                                          'TABLEAU DE BORD',
                                          style: FlutterFlowTheme.of(context).labelLarge.override(
                                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                        // ── Mes Ventes ──────────────────────────
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Mes Ventes',
                                                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                _statRow(
                                                  icon: Icons.shopping_cart_checkout,
                                                  iconColor: FlutterFlowTheme.of(context).tertiary,
                                                  label: 'COMMANDE EN COURS',
                                                  value: '$commandesEnCours',
                                                  context: context,
                                                ),
                                                _statRow(
                                                  icon: Icons.shopping_bag_outlined,
                                                  iconColor: FlutterFlowTheme.of(context).tertiary,
                                                  label: 'PRODUIT VENDU',
                                                  value: '$produitVendu',
                                                  context: context,
                                                ),
                                                // Ordonnances reçues — stream séparé
                                                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                  stream: FirebaseFirestore.instance
                                                      .collection('prescriptions')
                                                      .where('pharmacy_uid', isEqualTo: uid)
                                                      .snapshots(),
                                                  builder: (ctx2, presSnap) {
                                                    final count = presSnap.data?.docs.length ?? 0;
                                                    return _statRow(
                                                      icon: Icons.file_open_outlined,
                                                      iconColor: FlutterFlowTheme.of(context).tertiary,
                                                      label: 'ORDONNANCES RECU',
                                                      value: '$count',
                                                      context: context,
                                                    );
                                                  },
                                                ),
                                              ].divide(const SizedBox(height: 10.0)),
                                            ),
                                          ),
                                        ),
                                        // ── Cashflow ────────────────────────────
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Cashflow',
                                                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                        fontSize: 14.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                _statRow(
                                                  icon: Icons.repeat_one,
                                                  iconColor: const Color(0xFF8A0DCE),
                                                  label: 'RECETTE',
                                                  value: recette.toStringAsFixed(0),
                                                  currencyF: true,
                                                  context: context,
                                                ),
                                                // RETRAIT — pour l'instant 0F (pas de table de retraits)
                                                _statRow(
                                                  icon: Icons.task_alt_sharp,
                                                  iconColor: const Color(0xFF8A0DCE),
                                                  label: 'RETRAIT',
                                                  value: '0',
                                                  currencyF: true,
                                                  context: context,
                                                ),
                                              ].divide(const SizedBox(height: 10.0)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 100.0),
                                      ].divide(const SizedBox(height: 24.0)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: const BoxDecoration(),
                            child: wrapWithModel(
                              model: _model.navBarPharmaModel,
                              updateCallback: () => safeSetState(() {}),
                              child: const NavBarPharmaWidget(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  TextStyle _balanceTextStyle(BuildContext context) {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          color: Colors.white,
          fontSize: 32.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.bold,
          lineHeight: 1.4,
        );
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
