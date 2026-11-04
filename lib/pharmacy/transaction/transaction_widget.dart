import '/auth/firebase_auth/auth_util.dart';
import '/auth/role_guard.dart';
import '/components/nav_bar_pharma_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'transaction_model.dart';
export 'transaction_model.dart';

class TransactionWidget extends StatefulWidget {
  const TransactionWidget({super.key});

  static String routeName = 'Transaction';
  static String routePath = '/transaction';

  @override
  State<TransactionWidget> createState() => _TransactionWidgetState();
}

class _TransactionWidgetState extends State<TransactionWidget> {
  late TransactionModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TransactionModel());

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

  /// Retourne le stream d'ordres selon le filtre temporel.
  Stream<QuerySnapshot<Map<String, dynamic>>> _ordersStream(String uid) {
    final filter = _model.choiceChipsValue ?? 'Toutes';
    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection('orders')
        .where('pharmacy_id', isEqualTo: uid)
        .orderBy('created_at', descending: true);

    final now = DateTime.now();
    if (filter == 'Aujourd\'hui') {
      final startOfDay = DateTime(now.year, now.month, now.day);
      q = q.where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
    } else if (filter == 'Ce mois') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      q = q.where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
    }
    return q.snapshots();
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: AppBar(
            backgroundColor: const Color(0xFF165AC5),
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
                        Image.asset(
                          'assets/images/5987354.png',
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          'Mes Transactions',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).onPrimary,
                                fontSize: 18.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.5,
                              ),
                        ),
                      ].divide(const SizedBox(width: 10.0)),
                    ),
                    Icon(
                      Icons.more_vert_sharp,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ],
                ),
                Text(
                  'Suivez toutes vos transactions en un seul endroit',
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
        body: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HISTORIQUE DES TRANSACTIONS',
                          style: FlutterFlowTheme.of(context).labelLarge.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                                lineHeight: 1.4,
                              ),
                        ),
                        const SizedBox(height: 12),
                        // Filtre période
                        FlutterFlowChoiceChips(
                          options: const [
                            ChipData("Aujourd'hui"),
                            ChipData('Ce mois'),
                            ChipData('Toutes'),
                          ],
                          onChanged: (val) => safeSetState(
                              () => _model.choiceChipsValue = val?.firstOrNull),
                          selectedChipStyle: ChipStyle(
                            backgroundColor: const Color(0xFF165AC5),
                            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.outfit(),
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  letterSpacing: 0.0,
                                ),
                            iconColor: FlutterFlowTheme.of(context).secondaryBackground,
                            iconSize: 16.0,
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          unselectedChipStyle: ChipStyle(
                            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.outfit(),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  letterSpacing: 0.0,
                                ),
                            iconColor: FlutterFlowTheme.of(context).secondaryText,
                            iconSize: 16.0,
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          chipSpacing: 14.0,
                          rowSpacing: 12.0,
                          multiselect: false,
                          alignment: WrapAlignment.start,
                          controller: _model.choiceChipsValueController ??=
                              FormFieldController<List<String>>(['Toutes']),
                          wrapped: true,
                        ),
                        const SizedBox(height: 12),
                        // Liste des transactions depuis Firestore
                        Expanded(
                          child: uid.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                  stream: _ordersStream(uid),
                                  builder: (ctx, snap) {
                                    if (snap.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final docs = snap.data?.docs ?? [];
                                    if (docs.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.receipt_long_outlined,
                                              size: 60,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Aucune transaction pour cette période',
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: docs.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                                      itemBuilder: (ctx2, i) {
                                        final data = docs[i].data();
                                        final orderId = docs[i].id;
                                        final shortId = '#${orderId.substring(0, 8).toUpperCase()}';
                                        final patient = (data['patient_name'] as String?) ?? 'Patient';
                                        final paymentMethod = (data['payment_mode'] as String?) ?? 'MoMo';
                                        final status = (data['status'] as String?) ?? 'pending';
                                        final totalPrice = data['total_price']?.toString() ?? '0';
                                        final medicineName = (data['medicine_name'] as String?) ?? '';
                                        final createdAt = data['created_at'];
                                        String dateStr = '';
                                        if (createdAt is Timestamp) {
                                          final dt = createdAt.toDate();
                                          dateStr = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
                                        }

                                        final statusColor = _statusColor(status);
                                        final statusLabel = _statusLabel(status);

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                            borderRadius: BorderRadius.circular(12.0),
                                            border: Border.all(
                                              color: FlutterFlowTheme.of(context).alternate,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          shortId,
                                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                fontSize: 14.0,
                                                                letterSpacing: 0.0,
                                                                fontWeight: FontWeight.bold,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.payments_outlined, color: Color(0xFF165AC5), size: 14.0),
                                                            const SizedBox(width: 4),
                                                            Text(
                                                              paymentMethod.toUpperCase(),
                                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                    font: GoogleFonts.outfit(),
                                                                    color: const Color(0xFF165AC5),
                                                                    letterSpacing: 0.0,
                                                                    lineHeight: 1.4,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        if (medicineName.isNotEmpty) ...[
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            medicineName,
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                  font: GoogleFonts.outfit(),
                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                  letterSpacing: 0.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ].divide(const SizedBox(height: 4)),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          patient,
                                                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                fontSize: 14.0,
                                                                letterSpacing: 0.0,
                                                                fontWeight: FontWeight.w600,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: statusColor.withValues(alpha: 0.12),
                                                            borderRadius: BorderRadius.circular(8.0),
                                                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 3.0),
                                                            child: Text(
                                                              statusLabel,
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    font: GoogleFonts.outfit(),
                                                                    color: statusColor,
                                                                    fontSize: 12.0,
                                                                    letterSpacing: 0.0,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ].divide(const SizedBox(height: 4)),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  height: 16.0,
                                                  thickness: 1.0,
                                                  color: FlutterFlowTheme.of(context).alternate,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          totalPrice,
                                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                                color: const Color(0xFF165AC5),
                                                                letterSpacing: 0.0,
                                                                fontWeight: FontWeight.bold,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                        Text(
                                                          ' FCFA',
                                                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                                                color: const Color(0xFF165AC5),
                                                                letterSpacing: 0.0,
                                                                fontWeight: FontWeight.bold,
                                                                lineHeight: 1.4,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (dateStr.isNotEmpty)
                                                      Text(
                                                        dateStr,
                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                              font: GoogleFonts.outfit(),
                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                              letterSpacing: 0.0,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // NavBar
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
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF16CB83);
      case 'confirmed':
        return const Color(0xFF4954F8);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'delivered':
        return 'Livré';
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}
