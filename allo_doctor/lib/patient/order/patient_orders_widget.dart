import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/safe_product_image.dart';
import '/index.dart';

class PatientOrdersWidget extends StatefulWidget {
  const PatientOrdersWidget({super.key});

  static const String routeName = 'PatientOrders';
  static const String routePath = '/patientOrders';

  @override
  State<PatientOrdersWidget> createState() => _PatientOrdersWidgetState();
}

class _PatientOrdersWidgetState extends State<PatientOrdersWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Toutes', 'En attente', 'Confirmées', 'Livrées'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF165AC5),
        elevation: 2.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.safePop(),
        ),
        title: Text(
          'Mes Commandes',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delivery_dining_rounded, color: Colors.white),
            tooltip: 'Suivre mes livraisons',
            onPressed: () => context.pushNamed(PatientDeliveryTrackingWidget.routeName),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(uid, null),
          _buildOrdersList(uid, 'pending'),
          _buildOrdersList(uid, 'confirmed'),
          _buildOrdersList(uid, 'delivered'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(String uid, String? filterStatus) {
    Query query = FirebaseFirestore.instance.collection('orders');

    if (uid.isNotEmpty) {
      query = query.where('patient_uid', isEqualTo: uid);
    }
    if (filterStatus != null) {
      query = query.where('status', isEqualTo: filterStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Impossible de charger les commandes: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.red),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune commande',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filterStatus == null
                        ? 'Vous n\'avez passé aucune commande pour le moment.'
                        : 'Aucune commande avec ce statut.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14.0),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final orderId = docs[index].id;
            return _buildOrderCard(context, orderId, data);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, String orderId, Map<String, dynamic> data) {
    final status = (data['status'] as String?) ?? 'pending';
    final medicineName = (data['medicine_name'] as String?) ?? 'Médicament';
    final medicineCover = (data['medicine_cover'] as String?) ?? '';
    final pharmacyName = (data['pharmacy_name'] as String?) ?? 'Pharmacie';
    final pharmacyPhone = (data['pharmacy_phone'] as String?) ?? '';
    final qty = data['quantity'] ?? 1;
    final totalPrice = data['total_price'] ?? data['unit_price'] ?? '0';
    final deliveryMode = (data['delivery_mode'] as String?) ?? 'pickup';
    final deliveryAddress = (data['delivery_address'] as String?) ?? '';
    final createdAt = data['created_at'];

    String dateStr = '';
    if (createdAt is Timestamp) {
      final dt = createdAt.toDate();
      dateStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    Color statusColor;
    Color statusBg;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = const Color(0xFF165AC5);
        statusBg = const Color(0xFFE8F0FE);
        statusLabel = 'Confirmée / En préparation';
        statusIcon = Icons.autorenew;
        break;
      case 'delivered':
        statusColor = const Color(0xFF16C583);
        statusBg = const Color(0xFFE8F8F1);
        statusLabel = 'Livrée / Prête';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusColor = Colors.red.shade700;
        statusBg = Colors.red.shade50;
        statusLabel = 'Annulée';
        statusIcon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange.shade800;
        statusBg = Colors.orange.shade50;
        statusLabel = 'En attente de validation';
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cmd #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Product details
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafeProductImage(
                imageUrl: medicineCover,
                width: 60.0,
                height: 60.0,
                borderRadius: BorderRadius.circular(10.0),
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1458),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pharmacie: $pharmacyName',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantité: $qty  •  Total: $totalPrice FCFA',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF165AC5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Mode livraison & date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  deliveryMode == 'delivery' ? Icons.delivery_dining : Icons.storefront,
                  size: 16,
                  color: const Color(0xFF165AC5),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deliveryMode == 'delivery'
                        ? 'Livraison : ${deliveryAddress.isNotEmpty ? deliveryAddress : 'À domicile'}'
                        : 'Retrait sur place en pharmacie',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),

          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (pharmacyPhone.isNotEmpty)
                  Text(
                    'Tél: $pharmacyPhone',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF165AC5),
                    ),
                  ),
              ],
            ),
          ],

          if (deliveryMode == 'delivery') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.location_searching_rounded, size: 16),
                label: Text(
                  'Suivre la livraison',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  final delId = (data['delivery_id'] as String?) ?? '';
                  if (delId.isNotEmpty) {
                    context.pushNamed(
                      DeliveryTrackingWidget.routeName,
                      queryParameters: {'deliveryId': delId},
                    );
                  } else {
                    context.pushNamed(PatientDeliveryTrackingWidget.routeName);
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
