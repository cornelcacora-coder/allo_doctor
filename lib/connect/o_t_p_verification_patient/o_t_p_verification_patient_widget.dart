import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dart:async';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/role_guard.dart';
import 'o_t_p_verification_patient_model.dart';
export 'o_t_p_verification_patient_model.dart';

/// Mode de la page OTP
/// - 'verify'          : Vérification email après inscription
/// - 'forgot_password' : Réinitialisation mot de passe oublié
class OTPVerificationPatientWidget extends StatefulWidget {
  const OTPVerificationPatientWidget({
    super.key,
    this.email,
    this.mode,
    this.emailSent,
    this.role,
  });

  final String? email;
  final String? mode; // 'verify' ou 'forgot_password'

  /// Role du compte verifie : 'patient', 'medecin', 'pharmacie', 'clinique'.
  final String? role;

  /// false si l'envoi de l'email a échoué côté service d'envoi : dans ce cas
  /// l'utilisateur doit renvoyer l'email depuis l'écran.
  final bool? emailSent;

  static String routeName = 'OTPVerificationPatient';
  static String routePath = '/oTPVerificationPatient';

  @override
  State<OTPVerificationPatientWidget> createState() =>
      _OTPVerificationPatientWidgetState();
}

class _OTPVerificationPatientWidgetState
    extends State<OTPVerificationPatientWidget> {
  late OTPVerificationPatientModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  bool _isChecking = false;
  bool _emailSent = false;
  Timer? _checkTimer;
  int _cooldown = 60;
  Timer? _cooldownTimer;

  String get _email =>
      widget.email ??
      FirebaseAuth.instance.currentUser?.email ??
      '';

  bool get _isForgotPassword => widget.mode == 'forgot_password';

  /// Accueil correspondant au role du compte (patient, medecin, pharmacie,
  /// clinique). Un praticien doit retomber sur son tableau de bord.
  String get _homeRouteForRole {
    switch (widget.role) {
      case 'medecin':
        return HomeDoctorWidget.routeName;
      case 'pharmacie':
        return HomePharmacyWidget.routeName;
      case 'clinique':
        return HomeCliniqueWidget.routeName;
      default:
        return HomeHubWidget.routeName;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OTPVerificationPatientModel());

    // L'email de vérification a été envoyé lors de l'inscription, sauf si
    // l'appelant signale un échec du service d'envoi. Cette information est
    // connue dès le premier build pour ne pas afficher un avertissement
    // erroné.
    if (!_isForgotPassword) {
      _emailSent = widget.emailSent ?? true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isForgotPassword) {
        if (_emailSent) {
          _startCooldownTimer();
        }
      } else {
        // Mode mot de passe oublié : envoyer l'email de reset
        _sendPasswordResetEmail();
      }
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    _model.dispose();
    super.dispose();
  }

  void _startCooldownTimer() {
    _cooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_cooldown > 0) {
          _cooldown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      await user.sendEmailVerification();
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      _startCooldownTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email de vérification envoyé à $_email',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF14563C),
      ));
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de l\'envoi de l\'email.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_email.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
      _startCooldownTimer();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email de réinitialisation envoyé à $_email',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF14563C),
      ));
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = 'Erreur lors de l\'envoi de l\'email.';
      if (e.code == 'user-not-found') {
        message = 'Aucun compte associé à cette adresse e-mail.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  Future<void> _checkEmailVerified() async {
    setState(() => _isChecking = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        // Mettre à jour Firestore
        try {
          await _updateFirestoreVerified(user.uid);
        } catch (_) {}
        if (!mounted) return;
        // Rediriger vers l'accueil correspondant au role du compte
        context.goNamed(_homeRouteForRole);
      } else {
        setState(() => _isChecking = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Email non encore vérifié. Vérifiez votre boîte mail et cliquez sur le lien, puis revenez ici.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange.shade700,
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      setState(() => _isChecking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur de vérification.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  /// Connexion directe sans vérification d'email (mode de secours).
  /// L'utilisateur est déjà connecté via Firebase Auth (session créée lors
  /// de l'inscription). On lit son rôle dans Firestore et on le redirige.
  Future<void> _loginDirectly() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      context.goNamed(LoginPatientWidget.routeName);
      return;
    }
    if (!mounted) return;
    await redirectToOwnHome(context);
  }

  Future<void> _updateFirestoreVerified(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'emailVerified': true,
        'emailVerifie': true,
      });
    } catch (_) {}
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
        backgroundColor: Color(0xFF14563C),
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 40.0,
                fillColor: FlutterFlowTheme.of(context).onPrimary20,
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: FlutterFlowTheme.of(context).onPrimary,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.safePop();
                },
              ),
            ],
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: Stack(
          alignment: AlignmentDirectional(-1.0, -1.0),
          children: [
            Opacity(
              opacity: 0.5,
              child: Align(
                alignment: AlignmentDirectional(1.0, -1.0),
                child: Container(
                  width: 300.0,
                  height: 300.0,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Color(0xFF226A4D), Color(0xFF14563C)],
                      stops: [0.0, 1.0],
                      center: Alignment(0.0, 0.0),
                      radius: 0.5,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête logo
                Container(
                  height: 220.0,
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Container(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.asset(
                                  'assets/images/Logo_Mini-removebg-preview.png',
                                ).image,
                              ),
                              borderRadius: BorderRadius.circular(32.0),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          Text(
                            'Allô Docteur',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).onPrimary,
                                  fontSize: 28.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                  lineHeight: 1.5,
                                ),
                          ),
                        ].divide(SizedBox(height: 12.0)),
                      ),
                    ),
                  ),
                ),

                // Carte blanche principale
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).onPrimary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          24.0, 32.0, 24.0, 32.0),
                      child: SingleChildScrollView(
                        primary: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icône et titre
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72.0,
                                  height: 72.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD0E2DA),
                                    borderRadius: BorderRadius.circular(24.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Icon(
                                    _isForgotPassword
                                        ? Icons.lock_reset_rounded
                                        : Icons.mark_email_read_rounded,
                                    color: Color(0xFF14563C),
                                    size: 36.0,
                                  ),
                                ),
                                Text(
                                  _isForgotPassword
                                      ? 'Réinitialisation du mot de passe'
                                      : 'Vérification de l\'email',
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                        ),
                                        color: Color(0xFF14563C),
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.bold,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .titleMedium
                                                .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(height: 16.0)),
                            ),

                            // Description
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF0F7F4),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.email_outlined,
                                            color: Color(0xFF14563C),
                                            size: 18.0),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            'Email envoyé à :',
                                            style: FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .override(
                                                  font: GoogleFonts.outfit(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF14563C),
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .labelSmall
                                                          .fontStyle,
                                                  lineHeight: 1.3,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      _email.isNotEmpty
                                          ? _email
                                          : 'votre adresse e-mail',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w700,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF14563C),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w700,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                    SizedBox(height: 12.0),
                                    Text(
                                      _isForgotPassword
                                          ? 'Cliquez sur le lien dans l\'email pour réinitialiser votre mot de passe. Revenez ensuite pour vous connecter.'
                                          : 'Cliquez sur le lien dans l\'email pour vérifier votre compte. Ensuite, revenez ici et appuyez sur "J\'ai vérifié mon email".',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .override(
                                            font: GoogleFonts.outfit(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodySmall
                                                    .fontStyle,
                                            lineHeight: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Avertissement : l'email de verification n'a pas
                            // pu etre envoye, l'utilisateur doit le renvoyer.
                            if (!_isForgotPassword && !_emailSent)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFF4E0),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(color: Color(0xFFFFB300)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Color(0xFFB26A00), size: 20.0),
                                    SizedBox(width: 12.0),
                                    Expanded(
                                      child: Text(
                                        'L\'email de vérification n\'a pas pu être envoyé. Utilisez « Renvoyer l\'email » ci-dessous.',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodySmall
                                                        .fontStyle,
                                              ),
                                              color: Color(0xFFB26A00),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodySmall
                                                      .fontStyle,
                                              lineHeight: 1.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Bouton principal : vérification email
                            if (!_isForgotPassword)
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _isChecking ? null : _checkEmailVerified,
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        Color(0xFF16C583)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(1.0, -1.0),
                                      end: AlignmentDirectional(-1.0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  child: _isChecking
                                      ? Center(
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
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                                Icons.check_circle_outline_rounded,
                                                color: Colors.white,
                                                size: 20.0),
                                            Text(
                                              'J\'ai vérifié mon email',
                                              style: FlutterFlowTheme.of(
                                                      context)
                                                  .labelSmall
                                                  .override(
                                                    font: GoogleFonts.outfit(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontStyle:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .labelSmall
                                                              .fontStyle,
                                                    ),
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .labelSmall
                                                            .fontStyle,
                                                    lineHeight: 1.3,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                ),
                              ),

                            // Bouton secondaire : accès direct sans vérif email
                            if (!_isForgotPassword)
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: _loginDirectly,
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(24.0),
                                    border: Border.all(
                                      color: FlutterFlowTheme.of(context).primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        color: FlutterFlowTheme.of(context).primary,
                                        size: 20.0,
                                      ),
                                      SizedBox(width: 10.0),
                                      Text(
                                        'Accéder à mon compte',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w700,
                                              ),
                                              color: FlutterFlowTheme.of(context).primary,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w700,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Bouton pour le mot de passe oublié
                            if (_isForgotPassword)
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  context.safePop();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        FlutterFlowTheme.of(context).primary,
                                        Color(0xFF16C583)
                                      ],
                                      stops: [0.0, 1.0],
                                      begin: AlignmentDirectional(1.0, -1.0),
                                      end: AlignmentDirectional(-1.0, 1.0),
                                    ),
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login_rounded,
                                          color: Colors.white, size: 20.0),
                                      Text(
                                        'Retour à la connexion',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w700,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w700,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.3,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 10.0)),
                                  ),
                                ),
                              ),

                            // Renvoyer l'email
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Pas reçu ? ',
                                  style: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FlutterFlowTheme.of(
                                                  context)
                                              .labelSmall
                                              .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        letterSpacing: 0.0,
                                        fontWeight:
                                            FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontWeight,
                                        fontStyle:
                                            FlutterFlowTheme.of(context)
                                                .labelSmall
                                                .fontStyle,
                                        lineHeight: 1.3,
                                      ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: (_isLoading || _cooldown > 0)
                                      ? null
                                      : () {
                                          if (_isForgotPassword) {
                                            _sendPasswordResetEmail();
                                          } else {
                                            _sendEmailVerification();
                                          }
                                        },
                                  child: Text(
                                    _cooldown > 0
                                        ? 'Renvoyer (${_cooldown}s)'
                                        : 'Renvoyer l\'email',
                                    style: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .override(
                                          font: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w700,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .labelSmall
                                                    .fontStyle,
                                          ),
                                          color: _cooldown > 0
                                              ? FlutterFlowTheme.of(context)
                                                  .secondaryText
                                              : Color(0xFF14563C),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w700,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelSmall
                                                  .fontStyle,
                                          lineHeight: 1.3,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ].divide(SizedBox(height: 24.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
