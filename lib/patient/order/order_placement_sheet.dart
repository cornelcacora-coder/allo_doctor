import '/backend/pharmacy_directory_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/auth/firebase_auth/auth_util.dart';

// ---------------------------------------------------------------------------
//  ORDER PLACEMENT BOTTOM-SHEET
//  Usage: showOrderPlacementSheet(context, ...)
// ---------------------------------------------------------------------------

Future<void> showOrderPlacementSheet(
  BuildContext context, {
  required String productName,
  required String price,
  required String cover,
  required String category,
  required String medicineId,
  String? pharmacyId,
  String? pharmacyName,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _OrderSheet(
          productName: productName,
          price: price,
          cover: cover,
          category: category,
          medicineId: medicineId,
          preselectedPharmacyId: pharmacyId,
          preselectedPharmacyName: pharmacyName,
        ),
      ),
    ),
  );
}

class _OrderSheet extends StatefulWidget {
  const _OrderSheet({
    required this.productName,
    required this.price,
    required this.cover,
    required this.category,
    required this.medicineId,
    this.preselectedPharmacyId,
    this.preselectedPharmacyName,
  });

  final String productName;
  final String price;
  final String cover;
  final String category;
  final String medicineId;
  final String? preselectedPharmacyId;
  final String? preselectedPharmacyName;

  @override
  State<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends State<_OrderSheet> {
  int _qty = 1;
  String _deliveryMode = 'pickup';  // 'pickup' | 'delivery'
  String _paymentMode = 'onsite';   // 'onsite' | 'momo'
  String? _selectedPharmacyId;
  String? _selectedPharmacyName;
  String? _selectedPharmacyPhone;
  bool _loading = false;
  final TextEditingController _momoCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPharmacyId = widget.preselectedPharmacyId;
    _selectedPharmacyName = widget.preselectedPharmacyName;
  }

  @override
  void dispose() {
    _momoCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  int get _totalPrice {
    final p = int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return p * _qty;
  }

  Future<void> _placeOrder(BuildContext ctx) async {
    if (_selectedPharmacyId == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Veuillez choisir une pharmacie'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (_deliveryMode == 'delivery' && _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text("Veuillez entrer votre adresse de livraison"),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    if (_paymentMode == 'momo' && _momoCtrl.text.trim().length < 9) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text("Veuillez entrer un numero MoMo valide"),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = currentUserUid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final patientName = (userDoc.data()?['display_name'] as String?) ?? 'Patient';
      final patientPhone = (userDoc.data()?['phone'] as String?) ?? '';

      final orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'patient_uid': uid,
        'patient_name': patientName,
        'patient_phone': patientPhone,
        'pharmacy_id': _selectedPharmacyId,
        'pharmacy_name': _selectedPharmacyName ?? '',
        'pharmacy_phone': _selectedPharmacyPhone ?? '',
        'medicine_id': widget.medicineId,
        'medicine_name': widget.productName,
        'medicine_cover': widget.cover,
        'medicine_category': widget.category,
        'unit_price': widget.price,
        'quantity': _qty,
        'total_price': _totalPrice,
        'delivery_mode': _deliveryMode,
        'payment_mode': _paymentMode,
        'momo_number': _paymentMode == 'momo' ? _momoCtrl.text.trim() : '',
        'delivery_address': _deliveryMode == 'delivery' ? _addressCtrl.text.trim() : '',
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      setState(() => _loading = false);
      if (!mounted) return;
      Navigator.pop(ctx);

      await _showReceipt(ctx, orderRef.id);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _showReceipt(BuildContext ctx, String orderId) async {
    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => OrderReceiptDialog(
        orderId: orderId,
        productName: widget.productName,
        pharmacyName: _selectedPharmacyName ?? '',
        totalPrice: _totalPrice,
        quantity: _qty,
        deliveryMode: _deliveryMode,
        paymentMode: _paymentMode,
        momoNumber: _paymentMode == 'momo' ? _momoCtrl.text.trim() : null,
        deliveryAddress: _deliveryMode == 'delivery' ? _addressCtrl.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Commander ${widget.productName}',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.secondaryText),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Price badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.primary, const Color(0xFF16C583)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('Prix unitaire', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                        ),
                        Text('${widget.price} FCFA',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pharmacy selection
                  _sectionLabel(context, Icons.local_pharmacy, 'Choisir la pharmacie'),
                  const SizedBox(height: 8),
                  if (_selectedPharmacyId != null) _selectedPharmaChip(context) else _PharmacyPicker(
                    onSelected: (id, name, phone) => setState(() {
                      _selectedPharmacyId = id;
                      _selectedPharmacyName = name;
                      _selectedPharmacyPhone = phone;
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Quantity
                  _sectionLabel(context, Icons.production_quantity_limits, 'Quantite'),
                  const SizedBox(height: 8),
                  _QuantitySelector(qty: _qty, onChanged: (v) => setState(() => _qty = v)),
                  const SizedBox(height: 20),

                  // Delivery mode
                  _sectionLabel(context, Icons.local_shipping_outlined, 'Mode de recuperation'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          icon: Icons.storefront,
                          label: 'Retrait en officine',
                          selected: _deliveryMode == 'pickup',
                          onTap: () => setState(() => _deliveryMode = 'pickup'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeCard(
                          icon: Icons.delivery_dining,
                          label: 'Livraison a domicile',
                          selected: _deliveryMode == 'delivery',
                          onTap: () => setState(() => _deliveryMode = 'delivery'),
                        ),
                      ),
                    ],
                  ),
                  if (_deliveryMode == 'delivery') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressCtrl,
                      style: TextStyle(color: theme.primaryText),
                      decoration: InputDecoration(
                        hintText: 'Adresse de livraison...',
                        hintStyle: TextStyle(color: theme.secondaryText),
                        prefixIcon: Icon(Icons.location_on_outlined, color: theme.primary),
                        filled: true,
                        fillColor: theme.secondaryBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Payment mode
                  _sectionLabel(context, Icons.payment, 'Mode de paiement'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          icon: Icons.store_mall_directory,
                          label: 'Sur place / livreur',
                          selected: _paymentMode == 'onsite',
                          onTap: () => setState(() => _paymentMode = 'onsite'),
                          activeColor: const Color(0xFF14563C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeCard(
                          icon: Icons.phone_android,
                          label: 'Mobile Money (MoMo)',
                          selected: _paymentMode == 'momo',
                          onTap: () => setState(() => _paymentMode = 'momo'),
                          activeColor: const Color(0xFFFFAB00),
                        ),
                      ),
                    ],
                  ),
                  if (_paymentMode == 'momo') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _momoCtrl,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: theme.primaryText),
                      decoration: InputDecoration(
                        hintText: 'Numero MoMo (ex: 06XXXXXXXX)',
                        hintStyle: TextStyle(color: theme.secondaryText),
                        prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFFFAB00)),
                        filled: true,
                        fillColor: const Color(0x15FFAB00),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x44FFAB00)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x44FFAB00)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Le montant sera debite apres confirmation du pharmacien.',
                      style: GoogleFonts.outfit(fontSize: 11, color: theme.secondaryText, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Total summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.secondaryBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('Sous-total ($_qty article${_qty > 1 ? 's' : ''})',
                                  style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 13),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 8),
                            Text('$_totalPrice FCFA',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.primaryText)),
                          ],
                        ),
                        Divider(height: 20, color: theme.alternate),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TOTAL', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: theme.primaryText, fontSize: 15)),
                            Text('$_totalPrice FCFA',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: theme.primary, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _paymentMode == 'momo' ? Icons.phone_android : Icons.store_mall_directory,
                              size: 14,
                              color: _paymentMode == 'momo' ? const Color(0xFFFFAB00) : theme.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _paymentMode == 'momo' ? 'Paiement via Mobile Money' : 'Paiement sur place / chez le livreur',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: _paymentMode == 'momo' ? const Color(0xFFFFAB00) : theme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _loading ? 'Envoi en cours...' : 'Envoyer la commande',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      onPressed: _loading ? null : () => _placeOrder(context),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, IconData icon, String label) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primary),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: theme.primaryText)),
      ],
    );
  }

  Widget _selectedPharmaChip(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: theme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedPharmacyName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.primaryText),
            ),
          ),
          TextButton(
            onPressed: () => setState(() { _selectedPharmacyId = null; _selectedPharmacyName = null; }),
            child: Text('Changer', style: GoogleFonts.outfit(color: theme.primary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mode Card
// ─────────────────────────────────────────────────────────────────────────────
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.activeColor,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = activeColor ?? theme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : theme.alternate, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : theme.secondaryText, size: 24),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: selected ? color : theme.secondaryText)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pharmacy Picker
// ─────────────────────────────────────────────────────────────────────────────
class _PharmacyPicker extends StatefulWidget {
  const _PharmacyPicker({required this.onSelected});
  final void Function(String id, String name, String phone) onSelected;

  @override
  State<_PharmacyPicker> createState() => _PharmacyPickerState();
}

class _PharmacyPickerState extends State<_PharmacyPicker> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        TextField(
          style: TextStyle(color: theme.primaryText),
          onChanged: (v) => setState(() => _search = v.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Rechercher une pharmacie...',
            hintStyle: TextStyle(color: theme.secondaryText),
            prefixIcon: Icon(Icons.search, color: theme.secondaryText),
            filled: true,
            fillColor: theme.secondaryBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pharmacies').limit(30).snapshots(),
          builder: (ctx, snap) {
            final List<Map<String, dynamic>> pharmaList = [];
            if (snap.hasData && snap.data!.docs.isNotEmpty) {
              for (final d in snap.data!.docs) {
                if (d.id.startsWith('pharma_')) continue;
                final data = Map<String, dynamic>.from(d.data() as Map<String, dynamic>);
                data['id'] = d.id;
                pharmaList.add(data);
              }
            }
            // Pas de faux exemples statiques

            final docs = pharmaList.where((data) {
              final name = (data['name'] as String? ?? '').toLowerCase();
              final addr = (data['address'] as String? ?? '').toLowerCase();
              return _search.isEmpty || name.contains(_search) || addr.contains(_search);
            }).toList();

            return Column(
              children: docs.map((data) {
                final id = data['id'] as String? ?? 'pharma_centrale';
                final name = data['name'] as String? ?? 'Pharmacie';
                final address = data['address'] as String? ?? '';
                final phone = (data['phone'] as String?) ?? (data['phone_number'] as String?) ?? '+242 06 719 9098';
                final isGuard = (data['is_guard'] as bool?) ?? (data['is_garde'] as bool?) ?? false;
                return _PharmaOption(
                  name: name, address: address, isGuard: isGuard,
                  onTap: () => widget.onSelected(id, name, phone),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PharmaOption extends StatelessWidget {
  const _PharmaOption({required this.name, required this.address, required this.isGuard, required this.onTap});
  final String name;
  final String address;
  final bool isGuard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.alternate),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: theme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.local_pharmacy_rounded, color: theme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.primaryText, fontSize: 14)),
                  if (address.isNotEmpty)
                    Text(address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 12)),
                ],
              ),
            ),
            if (isGuard) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Text('Garde', style: GoogleFonts.outfit(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: theme.secondaryText, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Quantity Selector
// ─────────────────────────────────────────────────────────────────────────────
class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.qty, required this.onChanged});
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text('Quantite', style: GoogleFonts.outfit(color: theme.primaryText)),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline_rounded,
                    color: qty <= 1 ? theme.secondaryText : theme.primary, size: 28),
                onPressed: qty <= 1 ? null : () => onChanged(qty - 1),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$qty', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: theme.primaryText)),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_rounded, color: theme.primary, size: 28),
                onPressed: () => onChanged(qty + 1),
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ORDER RECEIPT DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class OrderReceiptDialog extends StatelessWidget {
  const OrderReceiptDialog({
    super.key,
    required this.orderId,
    required this.productName,
    required this.pharmacyName,
    required this.totalPrice,
    required this.quantity,
    required this.deliveryMode,
    required this.paymentMode,
    this.momoNumber,
    this.deliveryAddress,
  });

  final String orderId;
  final String productName;
  final String pharmacyName;
  final int totalPrice;
  final int quantity;
  final String deliveryMode;
  final String paymentMode;
  final String? momoNumber;
  final String? deliveryAddress;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final shortId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}  ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(color: theme.primaryBackground, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14563C), Color(0xFF16C583)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text('Commande envoyee !',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('En attente de confirmation du pharmacien',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text('RECU DE COMMANDE',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.5, color: theme.secondaryText)),
                          Text('#$shortId',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: theme.primaryText)),
                          Text(dateStr, style: GoogleFonts.outfit(fontSize: 11, color: theme.secondaryText)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: theme.alternate),
                    _Row('Medicament', productName),
                    _Row('Pharmacie', pharmacyName),
                    _Row('Quantite', '$quantity unite${quantity > 1 ? 's' : ''}'),
                    _Row('Livraison', deliveryMode == 'delivery' ? 'Livraison a domicile' : 'Retrait en officine'),
                    if (deliveryAddress != null && deliveryAddress!.isNotEmpty)
                      _Row('Adresse', deliveryAddress!),
                    Divider(color: theme.alternate),

                    // Payment mode highlighted block
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: paymentMode == 'momo'
                            ? const Color(0xFFFFAB00).withOpacity(0.1)
                            : const Color(0xFF14563C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: paymentMode == 'momo'
                              ? const Color(0xFFFFAB00).withOpacity(0.4)
                              : const Color(0xFF14563C).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            paymentMode == 'momo' ? Icons.phone_android : Icons.store_mall_directory,
                            color: paymentMode == 'momo' ? const Color(0xFFFFAB00) : const Color(0xFF14563C),
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('MODE DE PAIEMENT',
                                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: theme.secondaryText)),
                                Text(
                                  paymentMode == 'momo' ? 'Mobile Money (MoMo)' : 'Sur place / chez le livreur',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: paymentMode == 'momo' ? const Color(0xFFFFAB00) : const Color(0xFF14563C)),
                                ),
                                if (momoNumber != null && momoNumber!.isNotEmpty)
                                  Text('Numero : $momoNumber',
                                      style: GoogleFonts.outfit(fontSize: 12, color: theme.secondaryText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: theme.alternate),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL A PAYER',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: theme.primaryText)),
                        Text('$totalPrice FCFA',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 20, color: theme.primary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text('Fermer', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: GoogleFonts.outfit(color: theme.secondaryText, fontSize: 13))),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.primaryText, fontSize: 13))),
        ],
      ),
    );
  }
}
