import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'intro_model.dart';
export 'intro_model.dart';

class IntroWidget extends StatefulWidget {
  const IntroWidget({super.key});

  static String routeName = 'Intro';
  static String routePath = '/intro';

  @override
  State<IntroWidget> createState() => _IntroWidgetState();
}

class _IntroWidgetState extends State<IntroWidget> {
  late IntroModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IntroModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Column(
              children: [
                // ═════════════════════════════════════════════════════════
                // EN-TÊTE SUPÉRIEUR AVEC VAGUES ET DÉGRADÉ VERT
                // ═════════════════════════════════════════════════════════
                SizedBox(
                  height: 250.0,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Vagues vertes organiques
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _IntroHeaderWavePainter(),
                        ),
                      ),

                      // Reflets et cercles décoratifs
                      Positioned(
                        right: 15.0,
                        top: 45.0,
                        child: Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          child: Center(
                            child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E676).withValues(alpha: 0.25),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 36.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Mascotte / icône médicale en haut à gauche
                      Positioned(
                        left: 24.0,
                        top: 36.0,
                        child: Row(
                          children: [
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              child: const Icon(
                                Icons.health_and_safety_rounded,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Contenu titre en-tête
                      Positioned(
                        left: 20.0,
                        top: 76.0,
                        right: 100.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Allo ',
                                    style: GoogleFonts.outfit(
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Doctor',
                                    style: GoogleFonts.outfit(
                                      fontSize: 32.0,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF10E891),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              'Healthcare at your fingertips',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 14.0),
                            // Badges: Rapide • Fiable • Pour votre santé
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTag(Icons.bolt_rounded, 'Rapide'),
                                  const SizedBox(width: 6.0),
                                  _buildTag(Icons.verified_user_rounded, 'Fiable'),
                                  const SizedBox(width: 6.0),
                                  _buildTag(Icons.favorite_rounded, 'Pour votre santé'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ═════════════════════════════════════════════════════════
                // LISTE DES RÔLES ET CHOIX DU COMPTE
                // ═════════════════════════════════════════════════════════
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre : Content de te revoir
                        Text(
                          'Content de te revoir',
                          style: GoogleFonts.outfit(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0D3328),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Veuillez sélectionner votre type de compte\npour continuer',
                          style: GoogleFonts.outfit(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18.0),

                        // 1. CARTE PATIENT (Orange / Jaune)
                        _buildAccountTypeCard(
                          title: 'Je suis un patient',
                          subtitle: 'Je cherche des soins',
                          icon: Icons.person_rounded,
                          iconBgColor: const Color(0xFFFF9E00),
                          cardBgColor: const Color(0xFFFFFBF2),
                          borderColor: const Color(0xFFFFE8B2),
                          arrowColor: const Color(0xFFFF9E00),
                          onTap: () => context.pushNamed(LoginPatientWidget.routeName),
                        ),
                        const SizedBox(height: 14.0),

                        // 2. CARTE MÉDECIN (Rouge / Corail)
                        _buildAccountTypeCard(
                          title: 'Je suis médecin',
                          subtitle: 'Je propose des consultations',
                          icon: Icons.medical_services_rounded,
                          iconBgColor: const Color(0xFFFF4D4D),
                          cardBgColor: const Color(0xFFFFF3F3),
                          borderColor: const Color(0xFFFFD1D1),
                          arrowColor: const Color(0xFFFF4D4D),
                          onTap: () => context.pushNamed(LoginDoctorWidget.routeName),
                        ),
                        const SizedBox(height: 14.0),

                        // 3. CARTE PHARMACIEN (Bleu)
                        _buildAccountTypeCard(
                          title: 'Je suis pharmacien',
                          subtitle: 'Je gère une pharmacie',
                          icon: Icons.medication_rounded,
                          iconBgColor: const Color(0xFF0084FF),
                          cardBgColor: const Color(0xFFF0F7FF),
                          borderColor: const Color(0xFFCCE4FF),
                          arrowColor: const Color(0xFF0084FF),
                          onTap: () => context.pushNamed(LoginPharmacyWidget.routeName),
                        ),
                        const SizedBox(height: 14.0),

                        // 4. CARTE ÉTABLISSEMENT DE SANTÉ (Vert)
                        _buildAccountTypeCard(
                          title: 'Etablissement de Santé',
                          subtitle: 'Hôpital, clinique ou Laboratoire',
                          icon: Icons.local_hospital_rounded,
                          iconBgColor: const Color(0xFF00C853),
                          cardBgColor: const Color(0xFFEFFBF3),
                          borderColor: const Color(0xFFC7F3D6),
                          arrowColor: const Color(0xFF00C853),
                          onTap: () => context.pushNamed(LoginClinicWidget.routeName),
                        ),
                        const SizedBox(height: 14.0),

                        // 5. CARTE LIVREUR (Bleu foncé - existant conservé)
                        _buildAccountTypeCard(
                          title: 'Je suis livreur',
                          subtitle: 'Courses santé & livraisons express',
                          icon: Icons.delivery_dining_rounded,
                          iconBgColor: const Color(0xFF4338CA),
                          cardBgColor: const Color(0xFFF5F3FF),
                          borderColor: const Color(0xFFDDD6FE),
                          arrowColor: const Color(0xFF4338CA),
                          onTap: () => context.pushNamed(LoginLivreurWidget.routeName),
                        ),
                        const SizedBox(height: 24.0),

                        // ═════════════════════════════════════════════════
                        // PIED DE PAGE : CŒUR + CONDITIONS D'UTILISATION
                        // ═════════════════════════════════════════════════
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36.0,
                                    height: 1.5,
                                    color: const Color(0xFF00C853).withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    width: 28.0,
                                    height: 28.0,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00C853),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.white,
                                      size: 15.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Container(
                                    width: 36.0,
                                    height: 1.5,
                                    color: const Color(0xFF00C853).withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                'En continuant, vous acceptez nos Conditions d\'utilisation\net notre Politique de confidentialité',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12.0),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color cardBgColor,
    required Color borderColor,
    required Color arrowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: arrowColor.withValues(alpha: 0.08),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône squircle 3D avec reflet et ombre
            Container(
              width: 58.0,
              height: 58.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconBgColor,
                    iconBgColor.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.0),
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withValues(alpha: 0.38),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
            const SizedBox(width: 16.0),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F261C),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Bouton flèche circulaire
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: arrowColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22.0,
                color: arrowColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// DESSIN DES VAGUES D'EN-TÊTE
// ════════════════════════════════════════════════════════════════════════════
class _IntroHeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fond vert dégradé avec vagues courbées
    final rect = Rect.fromLTWH(0, 0, w, h);
    final bgGradient = const LinearGradient(
      colors: [Color(0xFF004D30), Color(0xFF00754A), Color(0xFF00A86B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w, h * 0.76);
    path.cubicTo(
      w * 0.75,
      h * 0.98,
      w * 0.35,
      h * 0.70,
      0,
      h * 0.95,
    );
    path.close();

    final paint = Paint()
      ..shader = bgGradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Vague décorative vert clair subtile en bas
    final wavePath = Path();
    wavePath.moveTo(0, h * 0.95);
    wavePath.cubicTo(
      w * 0.35,
      h * 0.70,
      w * 0.75,
      h * 0.98,
      w,
      h * 0.76,
    );
    wavePath.cubicTo(
      w * 0.70,
      h * 0.88,
      w * 0.30,
      h * 0.82,
      0,
      h,
    );
    wavePath.close();

    final wavePaint = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
