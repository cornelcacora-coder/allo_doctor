import '/auth/firebase_auth/auth_util.dart';
import '/auth/role_guard.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'clinic_wallet_model.dart';
export 'clinic_wallet_model.dart';

class ClinicWalletWidget extends StatefulWidget {
  const ClinicWalletWidget({super.key});

  static String routeName = 'ClinicWallet';
  static String routePath = '/clinicWallet';

  @override
  State<ClinicWalletWidget> createState() => _ClinicWalletWidgetState();
}

class _ClinicWalletWidgetState extends State<ClinicWalletWidget> {
  late ClinicWalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ClinicWalletModel());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'clinique');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  /// Boîte de dialogue pour effectuer une demande de retrait
  void _showWithdrawDialog(BuildContext context, double currentBalance) {
    final amountController = TextEditingController();
    final phoneController = TextEditingController();
    String operator = 'Airtel Money';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Effectuer un retrait',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Solde disponible : ${currentBalance.toStringAsFixed(0)} F CFA',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: FlutterFlowTheme.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant à retirer (F CFA)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: operator,
                decoration: InputDecoration(
                  labelText: 'Opérateur',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Airtel Money', child: Text('Airtel Money')),
                  DropdownMenuItem(value: 'MTN Mobile Money', child: Text('MTN Mobile Money')),
                  DropdownMenuItem(value: 'Virement Bancaire', child: Text('Virement Bancaire')),
                ],
                onChanged: (val) {
                  if (val != null) setModalState(() => operator = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone / Compte',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                    final phone = phoneController.text.trim();
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez entrer un montant valide.')),
                      );
                      return;
                    }
                    if (amount > currentBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Montant supérieur au solde disponible.')),
                      );
                      return;
                    }
                    if (phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez renseigner votre numéro.')),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('withdrawals').add({
                      'clinic_uid': currentUserUid,
                      'amount': amount,
                      'operator': operator,
                      'phone': phone,
                      'status': 'pending',
                      'created_at': FieldValue.serverTimestamp(),
                    });

                    if (ctx.mounted) Navigator.pop(ctx);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demande de retrait enregistrée avec succès.')),
                      );
                    }
                  },
                  child: Text(
                    'Confirmer le retrait',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
          preferredSize: const Size.fromHeight(150.0),
          child: AppBar(
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
                    Text(
                      'Ma Caisse',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).onPrimary,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                            lineHeight: 1.5,
                          ),
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      size: 24.0,
                    ),
                  ],
                ),
                Text(
                  'Solde Total',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.outfit(
                          fontWeight:
                              FlutterFlowTheme.of(context).bodySmall.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodySmall.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).onprimary80,
                        letterSpacing: 0.0,
                        lineHeight: 1.5,
                      ),
                ),
                // ─── Solde Total dynamique ───
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('appointments')
                      .where('clinic_uid', isEqualTo: uid)
                      .snapshots(),
                  builder: (context, aptSnap) {
                    double totalRecettes = 0.0;
                    if (aptSnap.hasData) {
                      for (final doc in aptSnap.data!.docs) {
                        final data = doc.data();
                        final status = (data['status'] as String? ?? '').toLowerCase();
                        if (status == 'completed' || status == 'terminé' || status == 'done') {
                          totalRecettes += _toDouble(data['price'] ?? data['prix'] ?? 3000);
                        }
                      }
                    }

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('withdrawals')
                          .where('clinic_uid', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, withSnap) {
                        double totalRetraits = 0.0;
                        if (withSnap.hasData) {
                          for (final doc in withSnap.data!.docs) {
                            final data = doc.data();
                            final status = (data['status'] as String? ?? '').toLowerCase();
                            if (status == 'approved' || status == 'completed' || status == 'pending') {
                              totalRetraits += _toDouble(data['amount']);
                            }
                          }
                        }

                        final solde = (totalRecettes - totalRetraits) > 0 ? (totalRecettes - totalRetraits) : 0.0;

                        return Text(
                          '${solde.toStringAsFixed(0)}F',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                fontSize: 32.0,
                                letterSpacing: 0.0,
                                lineHeight: 1.4,
                              ),
                        );
                      },
                    );
                  },
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
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Bouton Effectuer un retrait ───
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('clinic_uid', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snap) {
                      double currentBalance = 0;
                      if (snap.hasData) {
                        for (final d in snap.data!.docs) {
                          final status = (d.data()['status'] as String? ?? '').toLowerCase();
                          if (status == 'completed' || status == 'terminé' || status == 'done') {
                            currentBalance += _toDouble(d.data()['price'] ?? d.data()['prix'] ?? 3000);
                          }
                        }
                      }

                      return InkWell(
                        onTap: () => _showWithdrawDialog(context, currentBalance),
                        child: Container(
                          width: double.infinity,
                          height: 44.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF584814),
                                FlutterFlowTheme.of(context).warning,
                              ],
                              stops: const [0.0, 1.0],
                              begin: AlignmentDirectional.topEnd,
                              end: AlignmentDirectional.bottomStart,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Effectuer un retrait',
                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      fontSize: 13.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_downward_outlined,
                                color: Colors.white,
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24.0),

                  // ─── TABLEAU DE BORD : Mon Personnel ───
                  Text(
                    'TABLEAU DE BORD',
                    style: FlutterFlowTheme.of(context).labelLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 12.0),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    padding: const EdgeInsets.all(14.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: uid.isNotEmpty
                          ? FirebaseFirestore.instance
                              .collection('clinics')
                              .doc(uid)
                              .collection('staff')
                              .snapshots()
                          : null,
                      builder: (context, staffSnap) {
                        int medecinCount = 0;
                        int laboCount = 0;
                        int adminCount = 0;

                        if (staffSnap.hasData) {
                          for (final doc in staffSnap.data!.docs) {
                            final spec = (doc.data()['specialty'] as String? ?? '').toLowerCase();
                            if (spec.contains('medecin') || spec.contains('généraliste') || spec.contains('docteur')) {
                              medecinCount++;
                            } else if (spec.contains('labo') || spec.contains('biologiste')) {
                              laboCount++;
                            } else {
                              adminCount++;
                            }
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon Personnel',
                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 14.0,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildCountRow(
                              context,
                              icon: Icons.medical_services_outlined,
                              label: 'MÉDECINS',
                              count: '$medecinCount',
                            ),
                            const SizedBox(height: 10),
                            _buildCountRow(
                              context,
                              icon: Icons.biotech,
                              label: 'LABORANTINS',
                              count: '$laboCount',
                            ),
                            const SizedBox(height: 10),
                            _buildCountRow(
                              context,
                              icon: Icons.security_outlined,
                              label: 'ADMINISTRATEURS',
                              count: '$adminCount',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // ─── Opérations : Consultations, Examens, Ordonnances ───
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    padding: const EdgeInsets.all(14.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('clinic_uid', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, aptSnap) {
                        final aptDocs = aptSnap.data?.docs ?? [];
                        final consultCount = aptDocs.length;
                        final prescriptCount = aptDocs.where((d) => d.data()['prescription'] != null).length;

                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('lab_orders')
                              .where('clinic_uid', isEqualTo: uid)
                              .snapshots(),
                          builder: (context, labSnap) {
                            final labCount = labSnap.data?.docs.length ?? 0;

                            return Column(
                              children: [
                                _buildCountRow(
                                  context,
                                  icon: Icons.calendar_today,
                                  label: 'CONSULTATIONS',
                                  count: '$consultCount',
                                ),
                                const SizedBox(height: 10),
                                _buildCountRow(
                                  context,
                                  icon: Icons.science_outlined,
                                  label: 'EXAMENS & ANALYSES',
                                  count: '$labCount',
                                ),
                                const SizedBox(height: 10),
                                _buildCountRow(
                                  context,
                                  icon: Icons.assignment_outlined,
                                  label: 'ORDONNANCES ÉMISES',
                                  count: '$prescriptCount',
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // ─── Cashflow : Recette et Retrait ───
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                    ),
                    padding: const EdgeInsets.all(14.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('appointments')
                          .where('clinic_uid', isEqualTo: uid)
                          .snapshots(),
                      builder: (context, aptSnap) {
                        double recette = 0.0;
                        if (aptSnap.hasData) {
                          for (final d in aptSnap.data!.docs) {
                            final status = (d.data()['status'] as String? ?? '').toLowerCase();
                            if (status == 'completed' || status == 'terminé' || status == 'done') {
                              recette += _toDouble(d.data()['price'] ?? d.data()['prix'] ?? 3000);
                            }
                          }
                        }

                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('withdrawals')
                              .where('clinic_uid', isEqualTo: uid)
                              .snapshots(),
                          builder: (context, withSnap) {
                            double retrait = 0.0;
                            if (withSnap.hasData) {
                              for (final d in withSnap.data!.docs) {
                                retrait += _toDouble(d.data()['amount']);
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cashflow',
                                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        fontSize: 14.0,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                _buildCashflowRow(
                                  context,
                                  icon: Icons.sync_alt,
                                  label: 'RECETTE',
                                  amount: '${recette.toStringAsFixed(0)}F',
                                ),
                                const SizedBox(height: 10),
                                _buildCashflowRow(
                                  context,
                                  icon: Icons.check_circle_outline,
                                  label: 'RETRAIT',
                                  amount: '${retrait.toStringAsFixed(0)}F',
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 100.0), // Marge pour la barre de navigation
                ],
              ),
            ),

            // ─── NavBar Flottante ───
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: wrapWithModel(
                  model: _model.navBarClinicModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarClinicWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String count,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: FlutterFlowTheme.of(context).tertiary, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: FlutterFlowTheme.of(context).tertiary,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).accent2,
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Text(
              count,
              style: GoogleFonts.outfit(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashflowRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String amount,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8A0DCE), size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A0DCE),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).accent2,
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Text(
              amount,
              style: GoogleFonts.outfit(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
