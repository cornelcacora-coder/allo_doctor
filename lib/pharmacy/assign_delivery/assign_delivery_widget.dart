import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/livreur/delivery_tracking/delivery_tracking_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Page de gestion des livraisons côté pharmacie.
/// Permet la sélection et l'assignation de livreurs (disponibles vs grisés).
class AssignDeliveryWidget extends StatefulWidget {
  const AssignDeliveryWidget({super.key});

  static const String routeName = 'AssignDelivery';
  static const String routePath = '/assignDelivery';

  @override
  State<AssignDeliveryWidget> createState() => _AssignDeliveryWidgetState();
}

class _AssignDeliveryWidgetState extends State<AssignDeliveryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _pharmacyId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPharmacy();
  }

  Future<void> _loadPharmacy() async {
    final uid = currentUserUid;
    final doc = await FirebaseFirestore.instance.collection('pharmacies').doc(uid).get();
    if (mounted) {
      setState(() {
        _pharmacyId = doc.exists ? uid : (uid.isNotEmpty ? uid : null);
        _loading = false;
      });
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
        elevation: 1,
        title: Row(
          children: [
            FlutterFlowIconButton(
              borderRadius: 10,
              buttonSize: 38,
              fillColor: Colors.white.withValues(alpha: 0.15),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 12),
            Text(
              'Gestion des Livraisons',
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(text: 'À assigner', icon: Icon(Icons.assignment_outlined, size: 16)),
            Tab(text: 'En cours', icon: Icon(Icons.delivery_dining_rounded, size: 16)),
            Tab(text: 'Livrées', icon: Icon(Icons.done_all_rounded, size: 16)),
            Tab(text: 'Livreurs', icon: Icon(Icons.groups_outlined, size: 16)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pharmacyId == null
              ? _noPharmacy()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _AssignList(pharmacyId: _pharmacyId!, status: 'confirmed', showAssign: true),
                    _AssignList(pharmacyId: _pharmacyId!, status: 'in_progress'),
                    _AssignList(pharmacyId: _pharmacyId!, status: 'delivered'),
                    const _LivreursDirectoryView(),
                  ],
                ),
    );
  }

  Widget _noPharmacy() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Pharmacie introuvable', style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
}

/// Liste des commandes par statut
class _AssignList extends StatelessWidget {
  const _AssignList({required this.pharmacyId, required this.status, this.showAssign = false});
  final String pharmacyId;
  final String status;
  final bool showAssign;

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('pharmacy_id', isEqualTo: pharmacyId)
        .where('delivery_mode', isEqualTo: 'delivery');

    if (status == 'in_progress') {
      query = query.where('delivery_status', isEqualTo: 'in_progress');
    } else if (status == 'delivered') {
      query = query.where('status', isEqualTo: 'delivered');
    } else {
      query = query.where('status', isEqualTo: 'confirmed');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('created_at', descending: true).snapshots(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return _Empty(status: status);

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            return _OrderDeliveryCard(
              docId: doc.id,
              data: doc.data() as Map<String, dynamic>,
              pharmacyId: pharmacyId,
              showAssign: showAssign,
            );
          },
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final msgs = {
      'confirmed': ('Aucune commande en attente d\'assignation', Icons.inbox_outlined),
      'in_progress': ('Aucune livraison en cours', Icons.delivery_dining_outlined),
      'delivered': ('Aucune livraison terminée', Icons.done_all_rounded),
    };
    final (msg, icon) = msgs[status] ?? ('Aucune commande', Icons.inbox);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(msg, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 15)),
        ],
      ),
    );
  }
}

/// Carte représentant une commande à livrer
class _OrderDeliveryCard extends StatelessWidget {
  const _OrderDeliveryCard({
    required this.docId,
    required this.data,
    required this.pharmacyId,
    this.showAssign = false,
  });

  final String docId;
  final Map<String, dynamic> data;
  final String pharmacyId;
  final bool showAssign;

  void _openLivreurSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LivreurSelectionModal(
        orderId: docId,
        orderData: data,
        pharmacyId: pharmacyId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final ts = data['created_at'] as Timestamp?;
    final dateStr = ts != null
        ? '${ts.toDate().day.toString().padLeft(2, '0')}/${ts.toDate().month.toString().padLeft(2, '0')}/${ts.toDate().year}'
        : '';
    final deliveryStatus = data['delivery_status'] as String? ?? '';
    final isPendingPickup = deliveryStatus == 'pending_pickup';
    final isInProgress = deliveryStatus == 'in_progress';
    final livreurName = data['livreur_name'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header commande
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, color: theme.primary, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '#${docId.length > 8 ? docId.substring(0, 8).toUpperCase() : docId}',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (dateStr.isNotEmpty)
                  Text(dateStr, style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 11)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info patient
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_outline, color: theme.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['patient_name'] ?? 'Patient',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          if ((data['patient_phone'] as String? ?? '').isNotEmpty)
                            Text(
                              data['patient_phone'],
                              style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Produit & Total
                Row(
                  children: [
                    Icon(Icons.medication_outlined, size: 14, color: theme.secondaryText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${data['medicine_name'] ?? ''} x${data['quantity'] ?? 1}',
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${data['total_price'] ?? '0'} FCFA',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Adresse de livraison
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: theme.secondaryText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        data['delivery_address'] ?? 'Adresse non renseignée',
                        style: GoogleFonts.outfit(fontSize: 12, color: theme.secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Si déjà assigné ou en attente
                if (isPendingPickup && livreurName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 16, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Assigné à : $livreurName',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isPendingPickup) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hourglass_top, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'Diffusé • En attente d\'un livreur...',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (isInProgress && livreurName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.two_wheeler_rounded, size: 16, color: Color(0xFF1565C0)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Course en cours par : $livreurName',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: const Color(0xFF0D47A1),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Bouton d'assignation
                if (showAssign && !isInProgress) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_search_rounded, size: 18),
                      label: Text(
                        isPendingPickup ? 'Changer de livreur' : 'Assigner un livreur',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: () => _openLivreurSelector(context),
                    ),
                  ),
                ],

                // Bouton suivi si livraison créée
                if ((data['delivery_id'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: Text(
                        'Voir le suivi en direct',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primary,
                        side: BorderSide(color: theme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.pushNamed(
                        DeliveryTrackingWidget.routeName,
                        queryParameters: {'deliveryId': data['delivery_id']},
                      ),
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
}

/// MODAL DE SÉLECTION D'UN LIVREUR
/// Met en avant les livreurs disponibles (sélectionnables) et grise les indisponibles.
class _LivreurSelectionModal extends StatefulWidget {
  const _LivreurSelectionModal({
    required this.orderId,
    required this.orderData,
    required this.pharmacyId,
  });

  final String orderId;
  final Map<String, dynamic> orderData;
  final String pharmacyId;

  @override
  State<_LivreurSelectionModal> createState() => _LivreurSelectionModalState();
}

class _LivreurSelectionModalState extends State<_LivreurSelectionModal> {
  bool _assigning = false;

  IconData _vehicleIcon(String? vehicle) {
    switch ((vehicle ?? '').toLowerCase()) {
      case 'voiture':
        return Icons.directions_car_rounded;
      case 'vélo':
      case 'velo':
        return Icons.pedal_bike_rounded;
      case 'à pied':
      case 'a pied':
        return Icons.directions_walk_rounded;
      case 'moto':
      default:
        return Icons.two_wheeler_rounded;
    }
  }

  Future<void> _assign({
    String? livreurId,
    String? livreurName,
    String? livreurPhone,
    String? livreurVehicle,
  }) async {
    setState(() => _assigning = true);
    final isBroadcast = (livreurId == null);

    try {
      final now = FieldValue.serverTimestamp();
      final deliveryPayload = {
        'order_id': widget.orderId,
        'patient_name': widget.orderData['patient_name'] ?? '',
        'patient_phone': widget.orderData['patient_phone'] ?? '',
        'patient_uid': widget.orderData['patient_uid'] ?? '',
        'medicine_name': widget.orderData['medicine_name'] ?? '',
        'quantity': widget.orderData['quantity'] ?? 1,
        'total_price': widget.orderData['total_price'] ?? 0,
        'pharmacy_id': widget.pharmacyId,
        'pharmacy_name': widget.orderData['pharmacy_name'] ?? '',
        'delivery_address': widget.orderData['delivery_address'] ?? '',
        'status': 'pending_pickup',
        'delivery_status': 'pending_pickup',
        'livreur_id': livreurId,
        'livreur_name': livreurName,
        'livreur_phone': livreurPhone,
        'livreur_vehicle': livreurVehicle,
        'created_at': now,
        'assigned_at': now,
      };

      String deliveryDocId = (widget.orderData['delivery_id'] as String? ?? '');

      if (deliveryDocId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('deliveries')
            .doc(deliveryDocId)
            .set(deliveryPayload, SetOptions(merge: true));
      } else {
        final ref = await FirebaseFirestore.instance.collection('deliveries').add(deliveryPayload);
        deliveryDocId = ref.id;
      }

      // Mise à jour de la commande
      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'delivery_status': 'pending_pickup',
        'delivery_id': deliveryDocId,
        'livreur_id': livreurId,
        'livreur_name': livreurName,
        'livreur_phone': livreurPhone,
      });

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBroadcast
                      ? 'Offre diffusée à tous les livreurs disponibles !'
                      : 'Commande assignée avec succès à $livreurName !',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  // Crée un livreur de démonstration si la liste est vide
  Future<void> _createDemoLivreur() async {
    setState(() => _assigning = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('livreurs').doc();
      await docRef.set({
        'id': docRef.id,
        'uid': docRef.id,
        'name': 'Michel Ondongo (Livreur Pro)',
        'phone': '+242 06 888 77 66',
        'city': 'Brazzaville',
        'vehicle': 'Moto',
        'is_online': true,
        'rating': 4.9,
        'deliveries_count': 32,
        'created_at': FieldValue.serverTimestamp(),
      });
      // Et un livreur hors-ligne pour la démonstration du grisé
      final docRefOff = FirebaseFirestore.instance.collection('livreurs').doc();
      await docRefOff.set({
        'id': docRefOff.id,
        'uid': docRefOff.id,
        'name': 'Alain Mbemba',
        'phone': '+242 05 555 44 33',
        'city': 'Brazzaville',
        'vehicle': 'Voiture',
        'is_online': false,
        'rating': 4.7,
        'deliveries_count': 14,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
    if (mounted) setState(() => _assigning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sélectionner un Livreur',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D47A1),
                        ),
                      ),
                      Text(
                        'Les livreurs disponibles sont sélectionnables, les indisponibles sont grisés',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stream list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('livreurs').snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delivery_dining_outlined, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            'Aucun livreur enregistré',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Créez des livreurs de test pour visualiser les statuts disponibles et grisés.',
                            style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Générer des livreurs de test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _assigning ? null : _createDemoLivreur,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Trier : Disponibles (is_online == true) en premier, Non disponibles ensuite
                final sortedDocs = List<QueryDocumentSnapshot>.from(docs)
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aOnline = (aData['is_online'] == true) ? 1 : 0;
                    final bOnline = (bData['is_online'] == true) ? 1 : 0;
                    return bOnline.compareTo(aOnline);
                  });

                final onlineCount = sortedDocs.where((d) => (d.data() as Map)['is_online'] == true).length;
                final offlineCount = sortedDocs.length - onlineCount;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Résumé Disponibilité
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF10B981),
                          label: '$onlineCount Disponible(s)',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.remove_circle_outline_rounded,
                          color: Colors.grey.shade600,
                          label: '$offlineCount Non disponible(s)',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Option : Diffusion générale
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D47A1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.podcasts_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diffuser à tous les livreurs',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: const Color(0xFF0D47A1),
                                  ),
                                ),
                                Text(
                                  'Le 1er livreur disponible qui accepte prend la course',
                                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D47A1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 0,
                            ),
                            onPressed: _assigning ? null : () => _assign(),
                            child: Text(
                              'Diffuser',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'LIVREURS PARTENAIRES',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Liste de chaque livreur
                    ...sortedDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final isOnline = (data['is_online'] == true);
                      final name = (data['name'] as String? ?? 'Livreur').trim();
                      final phone = (data['phone'] as String? ?? '').trim();
                      final vehicle = (data['vehicle'] as String? ?? 'Moto').trim();
                      final city = (data['city'] as String? ?? '').trim();
                      final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;

                      if (isOnline) {
                        // ─── LIVREUR DISPONIBLE (SÉLECTIONNABLE) ───
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _assigning
                                ? null
                                : () => _assign(
                                      livreurId: doc.id,
                                      livreurName: name,
                                      livreurPhone: phone,
                                      livreurVehicle: vehicle,
                                    ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icône véhicule
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFA5D6A7)),
                                    ),
                                    child: Icon(
                                      _vehicleIcon(vehicle),
                                      color: const Color(0xFF2E7D32),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Infos
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1A1A2E),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Badge Disponible
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: const Color(0xFFA5D6A7)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF10B981),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Disponible',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF1B5E20),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            if (phone.isNotEmpty) ...[
                                              Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade600),
                                              const SizedBox(width: 4),
                                              Text(phone, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade700)),
                                              const SizedBox(width: 8),
                                            ],
                                            Text('• $vehicle', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
                                            if (city.isNotEmpty) ...[
                                              const SizedBox(width: 4),
                                              Text('• $city', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$rating',
                                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Bouton Sélectionner
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D47A1),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    onPressed: _assigning
                                        ? null
                                        : () => _assign(
                                              livreurId: doc.id,
                                              livreurName: name,
                                              livreurPhone: phone,
                                              livreurVehicle: vehicle,
                                            ),
                                    child: Text(
                                      'Assigner',
                                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        // ─── LIVREUR NON DISPONIBLE (GRISÉ / NON SÉLECTIONNABLE) ───
                        return Opacity(
                          opacity: 0.55,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEFF1),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Icône véhicule grisée
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _vehicleIcon(vehicle),
                                      color: Colors.grey.shade600,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Infos grisées
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            // Badge Non disponible (Grisé)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade600,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Non disponible',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Livreur hors ligne • $vehicle',
                                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Bouton Grisé inactif
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey.shade500,
                                      side: BorderSide(color: Colors.grey.shade400),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$name est actuellement hors ligne et ne peut pas recevoir de course.'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Indisponible',
                                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

/// 4ème ONGLET : Annuaire en direct des livreurs pour la pharmacie
class _LivreursDirectoryView extends StatelessWidget {
  const _LivreursDirectoryView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('livreurs').snapshots(),
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
                Icon(Icons.delivery_dining_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'Aucun livreur inscrit pour le moment',
                  style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 15),
                ),
              ],
            ),
          );
        }

        final sorted = List<QueryDocumentSnapshot>.from(docs)
          ..sort((a, b) {
            final aOnline = ((a.data() as Map)['is_online'] == true) ? 1 : 0;
            final bOnline = ((b.data() as Map)['is_online'] == true) ? 1 : 0;
            return bOnline.compareTo(aOnline);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final data = sorted[i].data() as Map<String, dynamic>;
            final isOnline = (data['is_online'] == true);
            final name = data['name'] ?? 'Livreur';
            final phone = data['phone'] ?? '';
            final vehicle = data['vehicle'] ?? 'Moto';
            final city = data['city'] ?? 'Brazzaville';
            final rating = (data['rating'] as num?)?.toDouble() ?? 5.0;

            if (isOnline) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.two_wheeler_rounded, color: Color(0xFF2E7D32), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '🟢 En ligne',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B5E20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$vehicle • $city ${phone.isNotEmpty ? '• Tél: $phone' : ''}',
                            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                              const SizedBox(width: 2),
                              Text('$rating/5', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Grisé
              return Opacity(
                opacity: 0.5,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.two_wheeler_rounded, color: Colors.grey.shade600, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '⚪ Hors ligne',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$vehicle • $city (Indisponible)',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
