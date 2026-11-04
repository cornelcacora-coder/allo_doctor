import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/livreur/delivery_tracking/delivery_tracking_widget.dart';

class PatientDeliveryTrackingWidget extends StatelessWidget {
  const PatientDeliveryTrackingWidget({super.key});

  static const String routeName = 'PatientDeliveryTracking';
  static const String routePath = '/patientDeliveryTracking';

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF165AC5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.safePop(),
        ),
        title: Text('Mes Livraisons', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('deliveries').where('patient_uid', isEqualTo: uid).orderBy('created_at', descending: true).snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.local_shipping_outlined, size: 72, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text('Aucune livraison', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text('Vos livraisons apparaitront ici.', style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              return _PatientDeliveryCard(docId: doc.id, data: doc.data() as Map<String, dynamic>);
            },
          );
        },
      ),
    );
  }
}

class _PatientDeliveryCard extends StatelessWidget {
  const _PatientDeliveryCard({required this.docId, required this.data});
  final String docId;
  final Map<String, dynamic> data;

  Color get _sc {
    switch (data['status']) {
      case 'in_progress': return const Color(0xFF1565C0);
      case 'delivered': return const Color(0xFF16C583);
      default: return Colors.orange.shade700;
    }
  }
  String get _sl {
    switch (data['status']) {
      case 'in_progress': return 'En cours de livraison';
      case 'delivered': return 'Livree';
      default: return 'En attente de livreur';
    }
  }
  IconData get _si {
    switch (data['status']) {
      case 'in_progress': return Icons.directions_bike;
      case 'delivered': return Icons.check_circle;
      default: return Icons.hourglass_top;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ts = data['created_at'] as Timestamp?;
    final dateStr = ts != null
        ? '${ts.toDate().day.toString().padLeft(2,'0')}/${ts.toDate().month.toString().padLeft(2,'0')}/${ts.toDate().year}'
        : '';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [_sc, _sc.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            Icon(_si, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_sl, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              Text('#${docId.length > 8 ? docId.substring(0,8).toUpperCase() : docId}${dateStr.isNotEmpty ? "  -  $dateStr" : ""}', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11)),
            ])),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _InfoRow(Icons.medication_outlined, '${data['medicine_name'] ?? '-'} x${data['quantity'] ?? 1}'),
          const SizedBox(height: 6),
          _InfoRow(Icons.storefront_outlined, data['pharmacy_name'] ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(Icons.location_on_outlined, data['delivery_address'] ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(Icons.payments_outlined, '${data['total_price'] ?? '0'} FCFA'),
          if ((data['livreur_name'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(Icons.delivery_dining, 'Livreur : ${data['livreur_name']}'),
          ],
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            icon: const Icon(Icons.track_changes_outlined, size: 16),
            label: Text('Suivre ma livraison', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF165AC5), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.pushNamed(DeliveryTrackingWidget.routeName, queryParameters: {'deliveryId': docId}),
          )),
        ])),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 14, color: Colors.grey.shade500), const SizedBox(width: 8),
    Expanded(child: Text(text, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis)),
  ]);
}
