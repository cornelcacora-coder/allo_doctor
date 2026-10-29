import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Page de suivi de livraison en temps reel.
/// Accessible au patient et au livreur.
class DeliveryTrackingWidget extends StatelessWidget {
  const DeliveryTrackingWidget({super.key, required this.deliveryId});

  static const String routeName = 'DeliveryTracking';
  static const String routePath = '/deliveryTracking';

  final String deliveryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.safePop(),
        ),
        title: Text('Suivi de Livraison', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('deliveries').doc(deliveryId).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.search_off_rounded, size: 72, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Livraison introuvable', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
            ]));
          }
          final data = snap.data!.data() as Map<String, dynamic>;
          return _buildTracking(context, data);
        },
      ),
    );
  }

  Widget _buildTracking(BuildContext context, Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'pending_pickup';
    final steps = [
      _TrackStep('Commande confirmee', 'La pharmacie a prepare votre commande', Icons.inventory_2_outlined, 'pending_pickup', true),
      _TrackStep('Livreur assigne', 'Un livreur a accepte votre livraison', Icons.person_pin_circle_outlined, 'in_progress', status == 'in_progress' || status == 'delivered'),
      _TrackStep('En route', 'Votre commande est en chemin', Icons.directions_bike_outlined, 'in_progress', status == 'in_progress' || status == 'delivered'),
      _TrackStep('Livree', 'Votre commande a ete livree', Icons.check_circle_outline, 'delivered', status == 'delivered'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status banner
        _StatusBanner(status: status),
        const SizedBox(height: 20),

        // Order info card
        _buildInfoCard(data),
        const SizedBox(height: 20),

        // Timeline
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Etapes de livraison', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((entry) => _buildStep(entry.key, entry.value, steps.length)),
          ]),
        ),
        const SizedBox(height: 20),

        // Livreur info
        if (data['livreur_name'] != null) _buildLivreurCard(data),
      ]),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.receipt_long_outlined, color: Color(0xFF0D47A1), size: 18),
          const SizedBox(width: 8),
          Text('Commande', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0D47A1))),
        ]),
        const Divider(height: 20),
        _Row('Medicament', data['medicine_name'] ?? '-'),
        const SizedBox(height: 6),
        _Row('Quantite', '${data['quantity'] ?? 1}'),
        const SizedBox(height: 6),
        _Row('Total', '${data['total_price'] ?? '0'} FCFA'),
        const SizedBox(height: 6),
        _Row('Pharmacie', data['pharmacy_name'] ?? '-'),
        const SizedBox(height: 6),
        _Row('Adresse livraison', data['delivery_address'] ?? '-'),
      ]),
    );
  }

  Widget _buildLivreurCard(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE3F2FD), shape: BoxShape.circle),
          child: const Icon(Icons.delivery_dining, color: Color(0xFF0D47A1), size: 26)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Votre livreur', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
          Text(data['livreur_name'] ?? 'Livreur', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E))),
          if ((data['livreur_phone'] as String? ?? '').isNotEmpty)
            Text(data['livreur_phone'], style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF0D47A1))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
            const SizedBox(width: 4),
            Text('Livreur', style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStep(int index, _TrackStep step, int total) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: step.done ? const Color(0xFF0D47A1) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, color: step.done ? Colors.white : Colors.grey.shade400, size: 18),
          ),
          if (index < total - 1) Expanded(child: Container(width: 2, color: step.done ? const Color(0xFF0D47A1) : Colors.grey.shade200)),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Padding(padding: EdgeInsets.only(bottom: index < total - 1 ? 20 : 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(step.title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: step.done ? const Color(0xFF0D47A1) : Colors.grey.shade400)),
          const SizedBox(height: 2),
          Text(step.subtitle, style: GoogleFonts.outfit(fontSize: 11, color: step.done ? Colors.grey.shade700 : Colors.grey.shade400)),
        ]))),
      ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color; IconData icon; String label;
    switch (status) {
      case 'in_progress': color = const Color(0xFF1565C0); icon = Icons.directions_bike; label = 'En cours de livraison'; break;
      case 'delivered': color = const Color(0xFF16C583); icon = Icons.check_circle; label = 'Livraison effectuee !'; break;
      default: color = Colors.orange.shade700; icon = Icons.hourglass_top; label = 'En attente de prise en charge';
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Statut de livraison', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
      ]),
    );
  }
}

class _TrackStep {
  const _TrackStep(this.title, this.subtitle, this.icon, this.status, this.done);
  final String title, subtitle, status; final IconData icon; final bool done;
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
    Flexible(child: Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
  ]);
}
