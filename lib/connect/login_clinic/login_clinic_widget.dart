import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/auth/role_guard.dart';
import '/components/forgot_password_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_clinic_model.dart';
export 'login_clinic_model.dart';

class LoginClinicWidget extends StatefulWidget {
  const LoginClinicWidget({super.key});

  static String routeName = 'LoginClinic';
  static String routePath = '/loginClinic';

  @override
  State<LoginClinicWidget> createState() => _LoginClinicWidgetState();
}

class _LoginClinicWidgetState extends State<LoginClinicWidget> {
  late LoginClinicModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginClinicModel());

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _model.emailTextController?.text.trim() ?? '';
    final password = _model.passwordTextController?.text ?? '';

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez renseigner votre email et mot de passe.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Contrôle du rôle : seul un compte établissement/clinique accède à cet espace.
      if (await hasRole('clinique')) {
        if (!mounted) return;
        context.pushNamed(HomeCliniqueWidget.routeName);
      } else {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ce compte n\'est pas un compte établissement / clinique.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Erreur de connexion. Vérifiez vos identifiants.';
      if (e.code == 'user-not-found') {
        msg = 'Aucun établissement trouvé avec cet email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Email ou mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        msg = 'Adresse email invalide.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Trop de tentatives. Veuillez patienter.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        backgroundColor: const Color(0xFFF2FAFA),
        body: Stack(
          children: [
            // Fond avec vagues en haut et en bas
            Positioned.fill(
              child: CustomPaint(
                painter: _LoginClinicWavesPainter(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ══════════════════════════════════════════════════
                  // 1. EN-TÊTE : BOUTON RETOUR + BADGE "Établissement"
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bouton circulaire blanc de retour
                        GestureDetector(
                          onTap: () => context.safePop(),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF1E3A2F),
                              size: 20.0,
                            ),
                          ),
                        ),

                        // Pill "Établissement de Santé"
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 16.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'Établissement',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════════════
                  // 2. MÉDAILLON CENTRAL + TEXTES DE BIENVENUE
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      children: [
                        // Médaillon circulaire blanc avec logo
                        Container(
                          width: 80.0,
                          height: 80.0,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 14.0,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/images/Logo_Mini-removebg-preview.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_hospital_rounded,
                              color: Color(0xFF00A86B),
                              size: 38.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Titre
                        Text(
                          'Espace Établissement',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          'Hôpital, clinique ou laboratoire d\'analyses médicales',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  // ══════════════════════════════════════════════════
                  // 3. FORMULAIRE : ONGLETS, CHAMPS ET ACTIONS
                  // ══════════════════════════════════════════════════
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── SÉLECTEUR D'ONGLETS (Connexion / Inscription) ──
                          Container(
                            height: 52.0,
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F3ED),
                              borderRadius: BorderRadius.circular(28.0),
                            ),
                            child: Row(
                              children: [
                                // Onglet Connexion (Actif - Vert)
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF00C853), Color(0xFF00965E)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x2800965E),
                                          blurRadius: 8.0,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.person_rounded, color: Colors.white, size: 18.0),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Connexion',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Onglet Inscription (Lien)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      context.pushNamed(
                                        SignUpWidget.routeName,
                                        queryParameters: {'role': 'clinique'},
                                      );
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.edit_note_rounded, color: Color(0xFF4A6B5F), size: 20.0),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            'Inscription',
                                            style: GoogleFonts.outfit(
                                              color: const Color(0xFF4A6B5F),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // ── CHAMP 1 : ADRESSE EMAIL ──
                          Row(
                            children: [
                              const Icon(Icons.mail_outline_rounded, color: Color(0xFF132A20), size: 18.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'Adresse Email de l\'Établissement',
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF132A20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: const Color(0xFFD6EAE0),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.mail_outline_rounded, color: Color(0xFF00A86B), size: 20.0),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: TextField(
                                    controller: _model.emailTextController,
                                    focusNode: _model.emailFocusNode,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'contact@etablissement.com',
                                      hintStyle: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // ── CHAMP 2 : MOT DE PASSE ──
                          Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, color: Color(0xFF132A20), size: 18.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'Mot de passe',
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF132A20),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: const Color(0xFFD6EAE0),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x06000000),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_outline_rounded, color: Color(0xFF00A86B), size: 20.0),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: TextField(
                                    controller: _model.passwordTextController,
                                    focusNode: _model.passwordFocusNode,
                                    obscureText: !_model.passwordVisibility,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Entrez votre mot de passe',
                                      hintStyle: GoogleFonts.outfit(
                                        fontSize: 13.5,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    safeSetState(() {
                                      _model.passwordVisibility = !_model.passwordVisibility;
                                    });
                                  },
                                  child: Icon(
                                    _model.passwordVisibility
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF00A86B),
                                    size: 20.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10.0),

                          // ── LIEN : MOT DE PASSE OUBLIÉ ? ──
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => showForgotPasswordBottomSheet(
                                context,
                                initialEmail: _model.emailTextController?.text.trim(),
                                role: 'clinique',
                                roleLabel: 'Établissement',
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  'Mot de passe oublié ? →',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00965E),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22.0),

                          // ── BOUTON : SE CONNECTER ──
                          GestureDetector(
                            onTap: _isLoading ? null : _handleLogin,
                            child: Container(
                              height: 54.0,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00C853), Color(0xFF00875A)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(28.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3500B96B),
                                    blurRadius: 14.0,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Se connecter',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 19.0,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // ── CARTE BANNIÈRE : VOUS N'AVEZ PAS DE COMPTE ? ──
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                SignUpWidget.routeName,
                                queryParameters: {'role': 'clinique'},
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F6EE),
                                borderRadius: BorderRadius.circular(20.0),
                                border: Border.all(
                                  color: const Color(0xFFC7ECDA),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.0,
                                    height: 44.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00B96B).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital_rounded,
                                      color: Color(0xFF00875A),
                                      size: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vous n\'avez pas de compte ?',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF132A20),
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          'Inscrire un établissement de santé →',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF00965E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PEINTURE DES VAGUES SUPÉRIEURES ET INFÉRIEURES (DESIGN FIDÈLE)
// ════════════════════════════════════════════════════════════════════════════
class _LoginClinicWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── VAGUES DU HAUT (Dégradé vert émeraude courbé) ──
    final topRect = Rect.fromLTWH(0, 0, w, 280);
    final topGradient = const LinearGradient(
      colors: [Color(0xFF00583A), Color(0xFF00875A), Color(0xFF00A86B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(topRect);

    final topPath = Path();
    topPath.moveTo(0, 0);
    topPath.lineTo(w, 0);
    topPath.lineTo(w, 200);
    topPath.cubicTo(w * 0.70, 260, w * 0.35, 205, 0, 245);
    topPath.close();

    final topPaint = Paint()
      ..shader = topGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Voile vert clair décoratif en haut
    final topWave2 = Path();
    topWave2.moveTo(0, 245);
    topWave2.cubicTo(w * 0.35, 205, w * 0.70, 260, w, 200);
    topWave2.cubicTo(w * 0.65, 275, w * 0.30, 225, 0, 270);
    topWave2.close();

    final topWavePaint2 = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topWave2, topWavePaint2);

    // ── VAGUES DU BAS (Vert émeraude doux) ──
    final bottomPath = Path();
    bottomPath.moveTo(0, h);
    bottomPath.lineTo(w, h);
    bottomPath.lineTo(w, h - 85);
    bottomPath.cubicTo(w * 0.65, h - 55, w * 0.35, h - 110, 0, h - 70);
    bottomPath.close();

    final bottomPaint = Paint()
      ..color = const Color(0xFF00C880).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath, bottomPaint);

    final bottomPath2 = Path();
    bottomPath2.moveTo(0, h);
    bottomPath2.lineTo(w, h);
    bottomPath2.lineTo(w, h - 45);
    bottomPath2.cubicTo(w * 0.60, h - 25, w * 0.30, h - 60, 0, h - 35);
    bottomPath2.close();

    final bottomPaint2 = Paint()
      ..color = const Color(0xFF00A86B).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath2, bottomPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
