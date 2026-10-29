import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/auth/firebase_auth/auth_util.dart';

// ---------------------------------------------------------------------------
//  PHARMACY ORDERS MANAGEMENT WIDGET
//  Route: /pharmacyOrders
//  Access: pharmacien uniquement
// ---------------------------------------------------------------------------

class PharmacyOrdersWidget extends StatefulWidget {
  const PharmacyOrdersWidget({super.key});

  static const String routeName = 'PharmacyOrders';
  static const String routePath = '/pharmacyOrders';

  @override
  State<PharmacyOrdersWidget> createState() => _PharmacyOrdersWidgetState();
}

class _PharmacyOrdersWidgetState extends State<PharmacyOrdersWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _pharmacyId;
  bool _loadingPharmacy = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPharmacyId();
  }

  Future<void> _loadPharmacyId() async {
    final uid = currentUserUid;
    // Try pharmacies collection first (keyed by uid)
    final pharmaDoc = await FirebaseFirestore.instance.collection('pharmacies').doc(uid).get();
    if (pharmaDoc.exists) {
      setState(() { _pharmacyId = uid; _loadingPharmacy = false; });
      return;
    }
    // Fallback: query by owner_uid
    final query = await FirebaseFirestore.instance
        .collection('pharmacies')
        .where('owner_uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      setState(() { _pharmacyId = query.docs.first.id; _loadingPharmacy = false; });
    } else {
      setState(() { _loadingPharmacy = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FlutterFlowIconButton(
              borderRadius: 10,
              buttonSize: 38,
              fillColor: Colors.white.withOpacity(0.15),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
            Text('Gestion des Commandes',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'En attente', icon: Icon(Icons.hourglass_empty, size: 16)),
            Tab(text: 'Confirmees', icon: Icon(Icons.check_circle_outline, size: 16)),
            Tab(text: 'Terminees', icon: Icon(Icons.done_all, size: 16)),
          ],
        ),
        elevation: 0,
      ),
      body: _loadingPharmacy
          ? const Center(child: CircularProgressIndicator())
          : _pharmacyId == null
              ? _noPharmacyFound(context)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _OrdersList(pharmacyId: _pharmacyId!, status: 'pending'),
                    _OrdersList(pharmacyId: _pharmacyId!, status: 'confirmed'),
                    _OrdersList(pharmacyId: _pharmacyId!, status: 'delivered'),
                  ],
                ),
    );
  }

  Widget _noPharmacyFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 60, color: FlutterFlowTheme.of(context).secondaryText),
          const SizedBox(height: 12),
          Text('Pharmacie introuvable',
              style: GoogleFonts.outfit(fontSize: 16, color: FlutterFlowTheme.of(context).secondaryText)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Orders List
// ─────────────────────────────────────────────────────────────────────────────
class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.pharmacyId, required this.status});
  final String pharmacyId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('pharmacy_id', isEqualTo: pharmacyId)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return _EmptyState(status: status);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snap.data!.docs.length,
          itemBuilder: (_, i) {
            final doc = snap.data!.docs[i];
            final data = doc.data() as Map<String, dynamic>;
            return _OrderCard(docId: doc.id, data: data, status: status);
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final messages = {
      'pending': ('Aucune commande en attente', Icons.hourglass_empty),
      'confirmed': ('Aucune commande confirmee', Icons.check_circle_outline),
      'delivered': ('Aucune commande terminee', Icons.done_all),
    };
    final (msg, icon) = messages[status] ?? ('Aucune commande', Icons.inbox);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.secondaryText.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(msg, style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 15)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Order Card
// ─────────────────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.docId, required this.data, required this.status});
  final String docId;
  final Map<String, dynamic> data;
  final String status;

  String get _shortId => docId.length > 8 ? docId.substring(0, 8).toUpperCase() : docId.toUpperCase();

  String get _deliveryLabel => data['delivery_mode'] == 'delivery' ? 'Livraison' : 'Retrait';
  String get _paymentLabel => data['payment_mode'] == 'momo' ? 'MoMo' : 'Sur place';
  Color get _paymentColor => data['payment_mode'] == 'momo' ? const Color(0xFFFFAB00) : const Color(0xFF14563C);
  IconData get _paymentIcon => data['payment_mode'] == 'momo' ? Icons.phone_android : Icons.store_mall_directory;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ts = data['created_at'] as Timestamp?;
    final dateStr = ts != null
        ? '${ts.toDate().day.toString().padLeft(2, '0')}/${ts.toDate().month.toString().padLeft(2, '0')}/${ts.toDate().year}  ${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}'
        : '...';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: theme.primary, size: 16),
                    const SizedBox(width: 6),
                    Text('#$_shortId',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.primary, fontSize: 14)),
                  ],
                ),
                Text(dateStr, style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 11)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient info
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_outline, color: theme.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['patient_name'] ?? 'Patient',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.primaryText, fontSize: 14)),
                          if ((data['patient_phone'] as String? ?? '').isNotEmpty)
                            Text(data['patient_phone'],
                                style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Medicine info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: theme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.medication_rounded, color: theme.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['medicine_name'] ?? '',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.primaryText)),
                            Text('Qte : ${data['quantity'] ?? 1}  •  ${data['unit_price'] ?? ''} FCFA/u',
                                style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('${data['total_price'] ?? ''} FCFA',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.primary, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Mode chips
                Row(
                  children: [
                    _Chip(
                      icon: data['delivery_mode'] == 'delivery' ? Icons.delivery_dining : Icons.storefront,
                      label: _deliveryLabel,
                      color: const Color(0xFF165AC5),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      icon: _paymentIcon,
                      label: _paymentLabel,
                      color: _paymentColor,
                    ),
                    if (data['payment_mode'] == 'momo' && (data['momo_number'] as String? ?? '').isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(data['momo_number'],
                            style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),

                if ((data['delivery_address'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(data['delivery_address'],
                            style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],

                // Action buttons (only for pending)
                if (status == 'pending') ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: Text('Refuser', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _updateStatus(context, docId, 'cancelled'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text('Confirmer', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _updateStatus(context, docId, 'confirmed'),
                        ),
                      ),
                    ],
                  ),
                ],

                // Mark as delivered (for confirmed)
                if (status == 'confirmed') ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.done_all, size: 16),
                      label: Text('Marquer comme remise/livree',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16C583),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _updateStatus(context, docId, 'delivered'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String id, String newStatus) async {
    final labels = {
      'confirmed': 'Commande confirmee',
      'cancelled': 'Commande refusee',
      'delivered': 'Commande marquee comme livree',
    };
    final colors = {
      'confirmed': const Color(0xFF16C583),
      'cancelled': Colors.red,
      'delivered': Colors.blue,
    };
    try {
      await FirebaseFirestore.instance.collection('orders').doc(id).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(labels[newStatus] ?? 'Mis a jour'),
          backgroundColor: colors[newStatus] ?? Colors.grey,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
