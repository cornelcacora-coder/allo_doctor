import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_up_model.dart';
export 'sign_up_model.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key, this.role = 'patient'});

  static String routeName = 'SignUp';
  static String routePath = '/signUp';

  /// Role du compte cree : 'patient', 'medecin', 'pharmacie' ou 'clinique'.
  /// Les praticiens generent en plus un dossier d'agrement dans la
  /// collection 'practitioners', que la console admin doit valider.
  final String role;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late SignUpModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  /// Un praticien (medecin, pharmacie, clinique) doit faire valider son
  /// dossier par la console administrateur.
  bool get _isPractitioner => widget.role != 'patient';

  String get _roleLabel {
    switch (widget.role) {
      case 'medecin':
        return 'médecin';
      case 'pharmacie':
        return 'pharmacie';
      case 'clinique':
        return 'clinique';
      default:
        return 'patient';
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignUpModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.emailController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();

    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.specialtyController ??= TextEditingController();
    _model.specialtyFocusNode ??= FocusNode();

    _model.docNumberController ??= TextEditingController();
    _model.docNumberFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final name = _model.textController1?.text.trim() ?? '';
    final email = _model.emailController?.text.trim() ?? '';
    final password = _model.passwordController?.text ?? '';
    final phone = _model.textController2?.text.trim() ?? '';
    final city = _model.textController3?.text.trim() ?? '';
    final gender = _model.radioButtonValue ?? '';
    final specialty = _model.specialtyController?.text.trim() ?? '';
    final docNumber = _model.docNumberController?.text.trim() ?? '';

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez remplir tous les champs obligatoires.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    // Un praticien doit fournir sa specialite et son numero d'ordre/licence :
    // ce sont les donnees que la console admin verifie pour valider le dossier.
    if (_isPractitioner && (specialty.isEmpty || docNumber.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Veuillez renseigner votre spécialité et votre numéro d\'ordre / licence.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Le mot de passe doit contenir au moins 6 caractères.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Créer le compte Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user!;

      // 2. Mettre à jour le nom d'affichage (non bloquant)
      try {
        await user.updateDisplayName(name);
      } on FirebaseAuthException catch (e) {
        debugPrint('Nom d\'affichage non mis à jour : ${e.code}');
      }

      // 3. Envoyer l'email de vérification (non bloquant).
      // Un échec du service d'envoi (503, quota, SMTP en panne...) ne doit
      // jamais empêcher la création du compte : sinon l'utilisateur est
      // bloqué, car le compte existe déjà côté Auth et la réinscription
      // échoue avec 'email-already-in-use'.
      var emailSent = false;
      try {
        await user.sendEmailVerification();
        emailSent = true;
      } on FirebaseAuthException catch (e) {
        debugPrint('Email de vérification non envoyé : ${e.code}');
      }

      // 4. Sauvegarder les données dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // Schéma canonique (partagé avec la console admin)
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'city': city,
        'gender': gender,
        'role': widget.role,
        'status': 'actif',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        // Alias français (conservés pour la compatibilité des écrans mobiles)
        'nom': name,
        'telephone': phone,
        'ville': city,
        'sexe': gender,
        'emailVerifie': false,
      });

      // 4 bis. Praticien : on crée son dossier d'agrément, que la console
      // admin doit valider avant activation sur le réseau.
      if (_isPractitioner) {
        try {
          await FirebaseFirestore.instance
              .collection('practitioners')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'name': name,
            'type': widget.role,
            'specialty': specialty,
            'city': city,
            'docNumber': docNumber,
            'phone': phone,
            'address': '',
            'documentsCount': 0,
            'status': 'en_attente',
            'date': DateTime.now().toIso8601String(),
            'createdAt': FieldValue.serverTimestamp(),
            'email': email,
            'uid': user.uid,
          });
        } catch (e) {
          debugPrint('Dossier d\'agrément non créé : $e');
        }
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      // 5. Rediriger vers la page OTP (vérification email)
      context.pushNamed(
        OTPVerificationPatientWidget.routeName,
        queryParameters: {
          'email': email,
          'emailSent': '$emailSent',
          'role': widget.role,
        },
      );

      if (_isPractitioner) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Compte $_roleLabel créé. Votre dossier d\'agrément est en attente de validation par l\'administration.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF14563C),
          duration: Duration(seconds: 6),
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = 'Erreur lors de la création du compte.';
      if (e.code == 'email-already-in-use') {
        message = 'Cette adresse e-mail est déjà utilisée.';
      } else if (e.code == 'invalid-email') {
        message = 'Adresse e-mail invalide.';
      } else if (e.code == 'weak-password') {
        message = 'Mot de passe trop faible (min. 6 caractères).';
      } else if (e.code == 'too-many-requests') {
        message = 'Trop de tentatives. Réessayez dans quelques minutes.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'La connexion par e-mail n\'est pas activée sur ce projet.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).labelSmall.override(
                font: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontStyle:
                      FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                fontStyle:
                    FlutterFlowTheme.of(context).labelSmall.fontStyle,
                lineHeight: 1.3,
              ),
        ),
        Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 4.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    keyboardType: keyboardType,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hint,
                      hintStyle: FlutterFlowTheme.of(context)
                          .labelMedium
                          .override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .fontStyle,
                          ),
                      prefixIcon: Icon(icon,
                          color: FlutterFlowTheme.of(context).secondaryText,
                          size: 18.0),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).error,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight:
                              FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                    cursorColor: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                if (suffixIcon != null) suffixIcon,
              ],
            ),
          ),
        ),
      ].divide(SizedBox(height: 6.0)),
    );
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250.0,
              child: Stack(
                alignment: AlignmentDirectional(-1.0, -1.0),
                children: [
                  Align(
                    alignment: AlignmentDirectional(-1.5, -1.2),
                    child: Container(
                      width: 300.0,
                      height: 300.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).onprimary5,
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(1.8, 0.5),
                    child: Container(
                      width: 200.0,
                      height: 200.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).onprimary5,
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional(0.0, -1.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),
                            child: Container(
                              width: 100.0,
                              height: 100.0,
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
                              alignment: AlignmentDirectional(0.0, 0.0),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                    fontSize: 32.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                    lineHeight: 1.5,
                                  ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6.0,
                                  height: 6.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).success,
                                    borderRadius: BorderRadius.circular(9999.0),
                                    shape: BoxShape.rectangle,
                                  ),
                                ),
                                Text(
                                  'Votre santé, notre priorité · Congo CG',
                                  style: FlutterFlowTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.outfit(
                                          fontWeight:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        color: FlutterFlowTheme.of(context)
                                            .onPrimary90,
                                        letterSpacing: 0.0,
                                        fontWeight: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          ].divide(SizedBox(height: 4.0)),
                        ),
                      ].divide(SizedBox(height: 16.0)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Onglets Connexion / Inscription
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).divider,
                            borderRadius: BorderRadius.circular(24.0),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      context.safePop();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Container(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Connexion',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(
                                                        context)
                                                    .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius:
                                          BorderRadius.circular(16.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Container(
                                        alignment:
                                            AlignmentDirectional(0.0, 0.0),
                                        child: Text(
                                          'Inscription',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF14563C),
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.5,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 4.0)),
                            ),
                          ),
                        ),

                        Text(
                          _isPractitioner
                              ? 'Créer un compte $_roleLabel'
                              : 'Créer un compte',
                          textAlign: TextAlign.start,
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w800,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .fontStyle,
                                lineHeight: 1.45,
                              ),
                        ),

                        // Champ Nom complet
                        _buildField(
                          label: 'NOM COMPLET *',
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          hint: 'Ex: BITODI Cornelca Cora',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                        ),

                        // Champ Email
                        _buildField(
                          label: 'ADRESSE E-MAIL *',
                          controller: _model.emailController,
                          focusNode: _model.emailFocusNode,
                          hint: 'votre@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        // Champ Mot de passe
                        _buildField(
                          label: 'MOT DE PASSE *',
                          controller: _model.passwordController,
                          focusNode: _model.passwordFocusNode,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: !_model.passwordVisibility,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color:
                                  FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0,
                            ),
                            onPressed: () {
                              safeSetState(() {
                                _model.passwordVisibility =
                                    !_model.passwordVisibility;
                              });
                            },
                          ),
                        ),

                        // Champ Téléphone
                        _buildField(
                          label: 'TÉLÉPHONE *',
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          hint: '+242 06 xxx xxxx',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // Champ Ville
                        _buildField(
                          label: 'VILLE',
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          hint: 'Ex: Brazzaville',
                          icon: Icons.location_on_outlined,
                        ),

                        // Champs reserves aux praticiens (dossier d'agrement)
                        if (_isPractitioner) ...[
                          _buildField(
                            label: 'SPÉCIALITÉ *',
                            controller: _model.specialtyController,
                            focusNode: _model.specialtyFocusNode,
                            hint: widget.role == 'pharmacie'
                                ? 'Ex: Officine & Garde'
                                : 'Ex: Ophtalmologie',
                            icon: Icons.medical_services_outlined,
                          ),
                          _buildField(
                            label: 'N° D\'ORDRE / LICENCE *',
                            controller: _model.docNumberController,
                            focusNode: _model.docNumberFocusNode,
                            hint: 'Ex: ORD-MED-1249',
                            icon: Icons.badge_outlined,
                          ),
                        ],

                        // Sexe
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SEXE',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelSmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelSmall
                                        .fontStyle,
                                    lineHeight: 1.3,
                                  ),
                            ),
                            FlutterFlowRadioButton(
                              options: ['HOMME', 'FEMME'].toList(),
                              onChanged: (val) => safeSetState(() {}),
                              controller:
                                  _model.radioButtonValueController ??=
                                      FormFieldController<String>(null),
                              optionHeight: 32.0,
                              optionSpacing: 40.0,
                              textStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
                                  ),
                              selectedTextStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    color:
                                        FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                              buttonPosition: RadioButtonPosition.left,
                              direction: Axis.horizontal,
                              radioButtonColor:
                                  FlutterFlowTheme.of(context).primary,
                              inactiveRadioButtonColor:
                                  FlutterFlowTheme.of(context).accent3,
                              toggleable: false,
                              horizontalAlignment: WrapAlignment.start,
                              verticalAlignment: WrapCrossAlignment.start,
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),

                        // Bouton Créer un compte
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: _isLoading ? null : _createAccount,
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
                            child: _isLoading
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_add_outlined,
                                          color: Colors.white, size: 18.0),
                                      Text(
                                        'Créer un compte',
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

                        // Note légale
                        Text(
                          'En créant un compte, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                                lineHeight: 1.3,
                              ),
                        ),
                      ].divide(SizedBox(height: 20.0)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
