import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'login_patient_model.dart';
export 'login_patient_model.dart';

class LoginPatientWidget extends StatefulWidget {
  const LoginPatientWidget({super.key});

  static String routeName = 'LoginPatient';
  static String routePath = '/loginPatient';

  @override
  State<LoginPatientWidget> createState() => _LoginPatientWidgetState();
}

class _LoginPatientWidgetState extends State<LoginPatientWidget> {
  late LoginPatientModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPatientModel());

    _model.emailTextController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
          content: Text('Veuillez renseigner votre email et mot de passe.'),
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

      // Contrôle du rôle : l'espace patient est réservé aux comptes patients.
      if (await hasRole('patient')) {
        if (!mounted) return;
        context.goNamed(HomeHubWidget.routeName);
      } else {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ce compte n\'est pas un compte patient.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Erreur de connexion. Vérifiez vos identifiants.';
      if (e.code == 'user-not-found') {
        msg = 'Aucun compte patient trouvé avec cet email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Email ou mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        msg = 'Adresse email invalide.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Trop de tentatives infructueuses. Veuillez patienter.';
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
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: theme.primaryBackground,
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: BoxConstraints(maxWidth: 500.0),
            decoration: BoxDecoration(
              color: theme.primaryBackground,
            ),
            child: Column(
              children: [
                // ─── HERO HEADER AVEC RETOUR ───
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0F766E),
                        Color(0xFF14B8A6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                      bottomRight: Radius.circular(32.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F766E).withOpacity(0.25),
                        blurRadius: 16.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barre supérieure : Bouton retour & titre discret
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => context.safePop(),
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.30),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_rounded, color: Colors.white, size: 14.0),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Espace Patient',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),

                          // Médaillon Logo Blanc lumineux
                          Container(
                            width: 72.0,
                            height: 72.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 12.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              'assets/images/Logo_Mini-removebg-preview.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.medical_services_rounded,
                                color: Color(0xFF0F766E),
                                size: 32.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'Bon retour parmi nous',
                            style: GoogleFonts.outfit(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            'Connectez-vous pour gérer vos consultations et soins',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── FORMULAIRE ET ONGLETS ───
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sélecteur d'onglets Connexion / Inscription
                        Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: theme.alternate.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Row(
                            children: [
                              // Onglet Connexion (Actif)
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: theme.secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Connexion',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.5,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ),
                              // Onglet Inscription (Lien rapide)
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.pushNamed(
                                      SignUpWidget.routeName,
                                      queryParameters: {'role': 'patient'},
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Inscription',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.5,
                                        color: theme.secondaryText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.0),

                        // ─── CHAMP EMAIL ───
                        Text(
                          'ADRESSE EMAIL',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: theme.secondaryText,
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: theme.alternate.withOpacity(0.85),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.0),
                                child: Icon(
                                  Icons.mail_outline_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20.0,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _model.emailTextController,
                                  focusNode: _model.emailFocusNode,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    color: theme.primaryText,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'exemple@domaine.com',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 14.0,
                                      color: theme.secondaryText.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.0),

                        // ─── CHAMP MOT DE PASSE ───
                        Text(
                          'MOT DE PASSE',
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: theme.secondaryText,
                          ),
                        ),
                        SizedBox(height: 6.0),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.secondaryBackground,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: theme.alternate.withOpacity(0.85),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.0),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20.0,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _model.passwordTextController,
                                  focusNode: _model.passwordFocusNode,
                                  obscureText: !_model.passwordVisibility,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    color: theme.primaryText,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 14.0,
                                      color: theme.secondaryText.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14.0),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _model.passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: theme.secondaryText,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _model.passwordVisibility = !_model.passwordVisibility;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),

                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              final email = _model.emailTextController?.text.trim() ?? '';
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Veuillez saisir votre adresse email pour réinitialiser votre mot de passe.'),
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                );
                                return;
                              }
                              context.pushNamed(
                                OTPVerificationPatientWidget.routeName,
                                queryParameters: {
                                  'email': email,
                                  'mode': 'forgot_password',
                                },
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Mot de passe oublié ?',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.0),

                        // ─── BOUTON DE CONNEXION ───
                        InkWell(
                          onTap: _isLoading ? null : _handleLogin,
                          borderRadius: BorderRadius.circular(16.0),
                          child: Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF10B981)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF10B981).withOpacity(0.35),
                                  blurRadius: 14.0,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Se connecter à mon espace',
                                          style: GoogleFonts.outfit(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.0),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 26.0),

                        // ─── BASCULE VERS ESPACE MEDECIN ───
                        Container(
                          padding: EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF0284C7).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Color(0xFF0284C7).withOpacity(0.20),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38.0,
                                height: 38.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0284C7).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.medical_services_rounded, color: Color(0xFF0284C7), size: 20.0),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vous êtes professionnel de santé ?',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                        color: theme.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    InkWell(
                                      onTap: () => context.pushNamed(LoginDoctorWidget.routeName),
                                      child: Text(
                                        'Accéder au portail Médecin →',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Sécurité & conformité
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user_rounded, size: 15.0, color: Color(0xFF10B981)),
                              SizedBox(width: 6.0),
                              Text(
                                'Connexion sécurisée · Données médicales chiffrées',
                                style: GoogleFonts.outfit(
                                  fontSize: 11.5,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.0),
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
}
