import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal de paiement Mobile Money / Airtel Money
/// avec calcul automatique de l'acompte de 30% obligatoire à la réservation.
class MobilePaymentModal extends StatefulWidget {
  const MobilePaymentModal({
    super.key,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.totalPrice = 20000.0,
  });

  final String doctorName;
  final String appointmentDate;
  final String appointmentTime;
  final double totalPrice;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required String doctorName,
    required String appointmentDate,
    required String appointmentTime,
    double totalPrice = 20000.0,
  }) async {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MobilePaymentModal(
        doctorName: doctorName,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        totalPrice: totalPrice,
      ),
    );
  }

  @override
  State<MobilePaymentModal> createState() => _MobilePaymentModalState();
}

class _MobilePaymentModalState extends State<MobilePaymentModal> {
  String _selectedOperator = 'airtel'; // 'airtel', 'mtn', 'orange'
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  double get _depositAmount => widget.totalPrice * 0.30; // 30%
  double get _remainingAmount => widget.totalPrice * 0.70; // 70%

  Future<void> _processPayment() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un numéro de téléphone valide.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Simulation de l'appel API Gateway Mobile Money / Airtel Money
    await Future.delayed(const Duration(milliseconds: 1400));

    final refNumber = 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    if (mounted) {
      Navigator.pop(context, {
        'success': true,
        'operator': _selectedOperator == 'airtel' ? 'Airtel Money' : (_selectedOperator == 'orange' ? 'Orange Money' : 'MTN Mobile Money'),
        'phone': phone,
        'totalPrice': widget.totalPrice,
        'depositAmount': _depositAmount,
        'remainingAmount': _remainingAmount,
        'reference': refNumber,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre supérieure
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFE53935), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paiement Acompte RDV',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Acompte obligatoire de 30% pour valider votre réservation',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Récapitulatif tarifaire (30% acompte / 70% restant)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Médecin :', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                      Text(widget.doctorName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Date & Heure :', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                      Text('${widget.appointmentDate} à ${widget.appointmentTime}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tarif consultation :', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
                      Text('${widget.totalPrice.toInt()} FCFA', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16C583).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF16C583)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF16C583), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Acompte à payer (30%) :',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0A0E1A)),
                            ),
                          ],
                        ),
                        Text(
                          '${_depositAmount.toInt()} FCFA',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF16C583)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Solde restant au cabinet (70%) :', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500)),
                      Text('${_remainingAmount.toInt()} FCFA', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Sélection de l'opérateur Mobile Money
            Text(
              'Mode de paiement :',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildOperatorCard(
                    operatorId: 'airtel',
                    title: 'Airtel Money',
                    subtitle: 'Airtel',
                    color: const Color(0xFFE53935),
                    icon: Icons.phone_android,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOperatorCard(
                    operatorId: 'mtn',
                    title: 'MTN MoMo',
                    subtitle: 'MTN',
                    color: const Color(0xFFFFB300),
                    icon: Icons.wallet_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOperatorCard(
                    operatorId: 'orange',
                    title: 'Orange Money',
                    subtitle: 'Orange',
                    color: const Color(0xFFFF6F00),
                    icon: Icons.currency_exchange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Saisie du numéro Mobile Money
            Text(
              'Numéro de compte pour le prélèvement :',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Ex: 06 912 34 56 ou 05 ...',
                prefixIcon: const Icon(Icons.dialpad_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16C583),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Validation du versement 30%...', style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : Text(
                        'Payer l\'acompte (${_depositAmount.toInt()} FCFA)',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorCard({
    required String operatorId,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedOperator == operatorId;
    return InkWell(
      onTap: () => setState(() => _selectedOperator = operatorId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
