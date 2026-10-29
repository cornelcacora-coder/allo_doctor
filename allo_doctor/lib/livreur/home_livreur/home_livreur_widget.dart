import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/auth/role_guard.dart';
import '/livreur/delivery_tracking/delivery_tracking_widget.dart';

class HomeLivreurWidget extends StatefulWidget {
  const HomeLivreurWidget({super.key});

  static const String routeName = 'HomeLivreur';
  static const String routePath = '/homeLivreur';

  @override
  State<HomeLivreurWidget> createState() => _HomeLivreurWidgetState();
}

class _HomeLivreurWidgetState extends State<HomeLivreurWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _livreurId;
  String _livreurName = '';
  bool _isOnline = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLivreur();
  }

  Future<void> _loadLivreur() async {
    final uid = currentUserUid;
    try {
      await guardRole(context, 'livreur');
      final doc = await FirebaseFirestore.instance
          .collection('livreurs')
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _livreurId = uid;
          _livreurName = doc.data()?['name'] ?? currentUserDisplayName ?? 'Livreur';
          _isOnline = doc.data()?['is_online'] ?? true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _livreurId = uid; _loading = false; });
    }
  }

  Future<void> _toggleOnline(bool val) async {
    setState(() => _isOnline = val);
    await FirebaseFirestore.instance
        .collection('livreurs')
        .doc(_livreurId)
        .update({'is_online': val, 'updated_at': FieldValue.serverTimestamp()});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(child: _buildTabViews()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 2),
                    ),
                    child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bonjour,', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                        Text(_livreurName, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        _isOnline ? 'En ligne' : 'Hors ligne',
                        style: GoogleFonts.outfit(
                          color: _isOnline ? const Color(0xFF69F0AE) : Colors.white54,
                          fontSize: 11, fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: _isOnline, onChanged: _toggleOnline,
                        activeThumbColor: const Color(0xFF69F0AE),
                        inactiveThumbColor: Colors.white38,
                        inactiveTrackColor: Colors.white12,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('deliveries').where('livreur_id', isEqualTo: _livreurId).snapshots(),
                builder: (ctx, snap) {
                  final docs = snap.data?.docs ?? [];
                  final enCours = docs.where((d) => (d.data() as Map)['status'] == 'in_progress').length;
                  final terminees = docs.where((d) => (d.data() as Map)['status'] == 'delivered').length;
                  return Row(
                    children: [
                      _StatCard('En cours', enCours.toString(), Icons.directions_bike),
                      const SizedBox(width: 10),
                      _StatCard('Livr\u00e9es', terminees.toString(), Icons.check_circle_outline),
                      const SizedBox(width: 10),
                      _StatCard('Total', docs.length.toString(), Icons.bar_chart_rounded),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF0D47A1),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const [Tab(text: 'Disponibles'), Tab(text: 'En cours'), Tab(text: 'Historique')],
      ),
    );
  }

  Widget _buildTabViews() {
    return TabBarView(
      controller: _tabController,
      children: [
        _DeliveryList(livreurId: _livreurId ?? '', statusFilter: 'pending_pickup', showAcceptButton: true, emptyMessage: 'Aucune livraison disponible', emptyIcon: Icons.inbox_outlined),
        _DeliveryList(livreurId: _livreurId ?? '', statusFilter: 'in_progress', emptyMessage: 'Aucune livraison en cours', emptyIcon: Icons.directions_bike_outlined),
        _DeliveryList(livreurId: _livreurId ?? '', statusFilter: 'delivered', emptyMessage: 'Aucune livraison termin\u00e9e', emptyIcon: Icons.done_all),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.icon);
  final String label; final String value; final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
      ]),
    ),
  );
}

class _DeliveryList extends StatelessWidget {
  const _DeliveryList({required this.livreurId, required this.statusFilter, this.showAcceptButton = false, required this.emptyMessage, required this.emptyIcon});
  final String livreurId; final String statusFilter; final bool showAcceptButton; final String emptyMessage; final IconData emptyIcon;

  Stream<QuerySnapshot> get _stream {
    if (statusFilter == 'pending_pickup') {
      return FirebaseFirestore.instance.collection('deliveries').where('status', isEqualTo: 'pending_pickup').orderBy('created_at', descending: true).snapshots();
    }
    return FirebaseFirestore.instance.collection('deliveries').where('livreur_id', isEqualTo: livreurId).where('status', isEqualTo: statusFilter).orderBy('created_at', descending: true).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final rawDocs = snap.data?.docs ?? [];
        final docs = rawDocs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          if (statusFilter == 'pending_pickup') {
            final lId = data['livreur_id'] as String?;
            return lId == null || lId.isEmpty || lId == livreurId;
          }
          return true;
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(emptyMessage, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            return _DeliveryCard(
              docId: doc.id,
              data: doc.data() as Map<String, dynamic>,
              livreurId: livreurId,
              showAcceptButton: showAcceptButton,
            );
          },
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.docId, required this.data, required this.livreurId, this.showAcceptButton = false});
  final String docId; final Map<String, dynamic> data; final String livreurId; final bool showAcceptButton;

  Color get _sc { switch(data['status']) { case 'in_progress': return const Color(0xFF1565C0); case 'delivered': return const Color(0xFF16C583); default: return Colors.orange.shade700; } }
  String get _sl { switch(data['status']) { case 'in_progress': return 'En cours'; case 'delivered': return 'Livr\u00e9e'; default: return '\u00c0 r\u00e9cup\u00e9rer'; } }

  @override
  Widget build(BuildContext context) {
    final ts = data['created_at'] as Timestamp?;
    final dateStr = ts != null ? '${ts.toDate().day.toString().padLeft(2,'0')}/${ts.toDate().month.toString().padLeft(2,'0')}/${ts.toDate().year}' : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: _sc.withValues(alpha: 0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.local_shipping_outlined, color: _sc, size: 16),
              const SizedBox(width: 6),
              Text('#${docId.length > 8 ? docId.substring(0,8).toUpperCase() : docId}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: _sc, fontSize: 14)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: _sc.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _sc.withValues(alpha: 0.3))),
              child: Text(_sl, style: GoogleFonts.outfit(color: _sc, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (data['livreur_id'] == livreurId) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Text(
                    'Assignée spécialement à vous par la pharmacie',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _InfoRow(icon: Icons.person_outline, label: 'Patient', value: data['patient_name'] ?? 'Patient'),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.medication_outlined, label: 'Produit', value: '${data['medicine_name'] ?? ''} \u00d7 ${data['quantity'] ?? 1}'),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Adresse', value: data['delivery_address'] ?? 'N/A'),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.storefront_outlined, label: 'Pharmacie', value: data['pharmacy_name'] ?? ''),
          if (dateStr.isNotEmpty) ...[const SizedBox(height: 6), _InfoRow(icon: Icons.access_time, label: 'Date', value: dateStr)],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Total', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
              Text('${data['total_price'] ?? '0'} FCFA', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
            ]),
          ),
          if (showAcceptButton) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text('Accepter la livraison', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => _acceptDelivery(context),
            )),
          ],
          if (data['status'] == 'in_progress') ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text('Voir suivi', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0D47A1), side: const BorderSide(color: Color(0xFF0D47A1)), padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => context.pushNamed(DeliveryTrackingWidget.routeName, queryParameters: {'deliveryId': docId}),
              )),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: ElevatedButton.icon(
                icon: const Icon(Icons.done_all, size: 16),
                label: Text('Marquer livr\u00e9e', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16C583), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _markDelivered(context),
              )),
            ]),
          ],
        ])),
      ]),
    );
  }

  Future<void> _acceptDelivery(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('deliveries').doc(docId).update({'livreur_id': livreurId, 'status': 'in_progress', 'accepted_at': FieldValue.serverTimestamp()});
      final orderId = data['order_id'] as String?;
      if (orderId != null && orderId.isNotEmpty) await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'delivery_status': 'in_progress'});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livraison accept\u00e9e !'), backgroundColor: Color(0xFF0D47A1)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _markDelivered(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('deliveries').doc(docId).update({'status': 'delivered', 'delivered_at': FieldValue.serverTimestamp()});
      final orderId = data['order_id'] as String?;
      if (orderId != null && orderId.isNotEmpty) await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': 'delivered', 'delivery_status': 'delivered', 'updated_at': FieldValue.serverTimestamp()});
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livraison marqu\u00e9e comme effectu\u00e9e !'), backgroundColor: Color(0xFF16C583)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon; final String label; final String value;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 14, color: Colors.grey.shade500), const SizedBox(width: 6),
    Text('$label : ', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
    Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
  ]);
}
