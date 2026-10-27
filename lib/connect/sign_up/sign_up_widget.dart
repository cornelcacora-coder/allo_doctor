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

  /// Rôle du compte : 'patient', 'medecin', 'pharmacie' ou 'clinique'.
  final String role;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  late SignUpModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  bool get _isDoctor => widget.role == 'medecin';
  bool get _isClinic => widget.role == 'clinique';
  bool get _isPharmacy => widget.role == 'pharmacie';
  bool get _isPatient => widget.role == 'patient';
  bool get _isPractitioner => !_isPatient;

  String get _roleTitle {
    switch (widget.role) {
      case 'medecin':
        return 'Inscription Médecin Praticien';
      case 'clinique':
        return 'Inscription Établissement de Santé';
      case 'pharmacie':
        return 'Inscription Pharmacie / Officine';
      default:
        return 'Créer un compte Patient';
    }
  }

  String get _roleSubtitle {
    switch (widget.role) {
      case 'medecin':
        return 'Rejoignez le réseau Allô Docteur pour vos consultations et ordonnances';
      case 'clinique':
        return 'Enregistrez votre clinique, hôpital, centre médical ou laboratoire';
      case 'pharmacie':
        return 'Officine partenaire pour la validation et préparation d\'ordonnances';
      default:
        return 'Votre santé, notre priorité · Carnet de santé et consultations';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case 'medecin':
        return const Color(0xFF0284C7);
      case 'clinique':
        return const Color(0xFFD97706);
      case 'pharmacie':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF14563C);
    }
  }

  IconData get _roleIcon {
    switch (widget.role) {
      case 'medecin':
        return Icons.medical_services_rounded;
      case 'clinique':
        return Icons.local_hospital_rounded;
      case 'pharmacie':
        return Icons.medication_rounded;
      default:
        return Icons.person_rounded;
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

    _model.workplaceController ??= TextEditingController();
    _model.workplaceFocusNode ??= FocusNode();

    _model.directorController ??= TextEditingController();
    _model.directorFocusNode ??= FocusNode();

    _model.servicesController ??= TextEditingController();
    _model.servicesFocusNode ??= FocusNode();

    _model.bedsCountController ??= TextEditingController();
    _model.bedsCountFocusNode ??= FocusNode();

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
    final specialty = _model.specialtyController?.text.trim() ?? '';
    final docNumber = _model.docNumberController?.text.trim() ?? '';
    final workplace = _model.workplaceController?.text.trim() ?? '';
    final director = _model.directorController?.text.trim() ?? '';
    final services = _model.servicesController?.text.trim() ?? '';
    final bedsCount = _model.bedsCountController?.text.trim() ?? '';
    final gender = (_isClinic || _isPharmacy) ? '' : (_model.radioButtonValue ?? '');

    // 1. Validation de base
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Veuillez remplir tous les champs obligatoires (*).',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    // 2. Validation spécifique Médecin
    if (_isDoctor && (specialty.isEmpty || docNumber.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Veuillez renseigner votre spécialité médicale et votre n° d\'ordre (CNOM).',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    // 3. Validation spécifique Établissement de Santé
    if (_isClinic && (specialty.isEmpty || docNumber.isEmpty || director.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Veuillez préciser la catégorie d\'établissement, le n° d\'agrément et le médecin chef/directeur.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    // 4. Validation spécifique Pharmacie
    if (_isPharmacy && docNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            'Veuillez renseigner le n° d\'ordre des pharmaciens (CNOP).',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Le mot de passe doit contenir au moins 6 caractères.',
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

      // 2. Mettre à jour le nom d'affichage
      try {
        await user.updateDisplayName(name);
      } catch (_) {}

      // 3. Envoyer l'email de vérification (non bloquant)
      var emailSent = false;
      try {
        await user.sendEmailVerification();
        emailSent = true;
      } catch (_) {}

      // 4. Sauvegarder dans 'users'
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'nom': name,
        'email': email,
        'phone': phone,
        'telephone': phone,
        'city': city,
        'ville': city,
        'gender': gender,
        'sexe': gender,
        'role': widget.role,
        'status': _isPractitioner ? 'en_attente' : 'actif',
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        // Données enrichies selon le rôle
        'specialty': specialty,
        'docNumber': docNumber,
        'workplace': workplace,
        'director': director,
        'services': services,
        'bedsCount': bedsCount,
      });

      // 5. Sauvegarder le dossier praticien pour validation
      if (_isPractitioner) {
        try {
          await FirebaseFirestore.instance
              .collection('practitioners')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'uid': user.uid,
            'name': name,
            'type': widget.role,
            'specialty': specialty,
            'city': city,
            'docNumber': docNumber,
            'phone': phone,
            'email': email,
            'workplace': workplace,
            'director': director,
            'services': services,
            'bedsCount': bedsCount,
            'address': city,
            'status': 'en_attente',
            'date': DateTime.now().toIso8601String(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }

      // 6. Établissement de Santé : enregistrer directement dans 'cliniques'
      if (_isClinic) {
        try {
          await FirebaseFirestore.instance
              .collection('cliniques')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'uid': user.uid,
            'name': name,
            'clinic_name': name,
            'type': specialty.isNotEmpty ? specialty : 'Clinique Médicale',
            'director': director,
            'docNumber': docNumber,
            'phone': phone,
            'phone_number': phone,
            'email': email,
            'city': city.isNotEmpty ? city : 'Brazzaville',
            'address': city.isNotEmpty ? city : 'Brazzaville',
            'services': services,
            'beds_count': bedsCount,
            'is_open': true,
            'is_available': true,
            'status': 'en_attente',
            'rating': 5.0,
            'created_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      // 7. Pharmacie : enregistrer directement dans 'pharmacies'
      if (_isPharmacy) {
        try {
          await FirebaseFirestore.instance
              .collection('pharmacies')
              .doc(user.uid)
              .set({
            'id': user.uid,
            'uid': user.uid,
            'name': name,
            'pharmacy_name': name,
            'phone': phone,
            'phone_number': phone,
            'city': city.isNotEmpty ? city : 'Brazzaville',
            'address': city.isNotEmpty ? city : 'Brazzaville',
            'email': email,
            'pharmacist': director,
            'docNumber': docNumber,
            'is_open': true,
            'is_available': true,
            'is_guard': false,
            'rating': 5.0,
            'status': 'actif',
            'guard_hours': '08h00 - 20h00',
            'hours': '08h00 - 20h00',
            'created_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      // 8. Redirection vers la vérification
      context.pushNamed(
        OTPVerificationPatientWidget.routeName,
        queryParameters: {
          'email': email,
          'emailSent': '$emailSent',
          'role': widget.role,
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur lors de la création du compte : $e',
            style: const TextStyle(color: Colors.white)),
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
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
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
                  fontStyle: FlutterFlowTheme.of(context).labelSmall.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
                lineHeight: 1.3,
              ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            isDense: false,
            hintText: hint,
            hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.outfit(),
                  color: FlutterFlowTheme.of(context).accent3,
                ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).lightGray,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _roleColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).primaryBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            prefixIcon: Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20.0,
            ),
            suffixIcon: suffixIcon,
          ),
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.outfit(),
                color: FlutterFlowTheme.of(context).primaryText,
              ),
        ),
      ].divide(const SizedBox(height: 6.0)),
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
        backgroundColor: _roleColor,
        appBar: AppBar(
          backgroundColor: _roleColor,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowIconButton(
                borderRadius: 12.0,
                buttonSize: 40.0,
                fillColor: Colors.white.withOpacity(0.2),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 24.0,
                ),
                onPressed: () async {
                  context.safePop();
                },
              ),
            ],
          ),
          actions: const [],
          centerTitle: false,
          elevation: 0.0,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header dynamique avec badge du rôle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(_roleIcon, size: 38.0, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    _roleTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    _roleSubtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: GoogleFonts.outfit(
                      fontSize: 13.0,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu du formulaire
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 32.0),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Onglets Connexion / Inscription
                        Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).divider,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () async {
                                      context.safePop();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Text(
                                          'Connexion',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            color: FlutterFlowTheme.of(context).secondaryText,
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
                                      color: FlutterFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: Text(
                                          'Inscription',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            color: _roleColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // ─── 1. CHAMP NOM (PERSONNALISÉ) ───
                        _buildField(
                          label: _isDoctor
                              ? 'NOM & PRÉNOM DU MÉDECIN *'
                              : _isClinic
                                  ? 'NOM DE L\'ÉTABLISSEMENT / CLINIQUE *'
                                  : _isPharmacy
                                      ? 'NOM DE L\'OFFICINE / PHARMACIE *'
                                      : 'NOM COMPLET *',
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          hint: _isDoctor
                              ? 'Ex: Dr. Martin Ntsiba'
                              : _isClinic
                                  ? 'Ex: Clinique Médico-Chirurgicale Océan'
                                  : _isPharmacy
                                      ? 'Ex: Pharmacie de la Paix'
                                      : 'Ex: BITODI Cornelca Cora',
                          icon: _roleIcon,
                          keyboardType: TextInputType.name,
                        ),

                        // ─── 2. CHAMP EMAIL ───
                        _buildField(
                          label: _isClinic
                              ? 'ADRESSE E-MAIL DE L\'ÉTABLISSEMENT *'
                              : _isPharmacy
                                  ? 'ADRESSE E-MAIL DE L\'OFFICINE *'
                                  : _isDoctor
                                      ? 'ADRESSE E-MAIL PROFESSIONNELLE *'
                                      : 'ADRESSE E-MAIL *',
                          controller: _model.emailController,
                          focusNode: _model.emailFocusNode,
                          hint: _isClinic
                              ? 'contact@clinique.cg'
                              : _isPharmacy
                                  ? 'contact@pharmacie.cg'
                                  : 'votre@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        // ─── 3. MOT DE PASSE ───
                        _buildField(
                          label: 'MOT DE PASSE *',
                          controller: _model.passwordController,
                          focusNode: _model.passwordFocusNode,
                          hint: '•••••••• (6 caractères min.)',
                          icon: Icons.lock_outline,
                          obscure: !_model.passwordVisibility,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _model.passwordVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 20.0,
                            ),
                            onPressed: () {
                              safeSetState(() {
                                _model.passwordVisibility = !_model.passwordVisibility;
                              });
                            },
                          ),
                        ),

                        // ─── 4. TÉLÉPHONE ───
                        _buildField(
                          label: _isClinic
                              ? 'TÉLÉPHONE STANDARD / URGENCES *'
                              : _isPharmacy
                                  ? 'TÉLÉPHONE DE L\'OFFICINE / WHATSAPP *'
                                  : _isDoctor
                                      ? 'TÉLÉPHONE PROFESSIONNEL DU CABINET *'
                                      : 'TÉLÉPHONE *',
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          hint: '+242 06 xxx xxxx',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        // ─── 5. ADRESSE / VILLE ───
                        _buildField(
                          label: (_isClinic || _isPharmacy)
                              ? 'ADRESSE & LOCALISATION EXACTE *'
                              : 'VILLE *',
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          hint: (_isClinic || _isPharmacy)
                              ? 'Ex: Avenue des 3 Martyrs, Moungali, Brazzaville'
                              : 'Ex: Brazzaville, Pointe-Noire...',
                          icon: Icons.location_on_outlined,
                        ),

                        // ─── 6. CHAMPS SPÉCIFIQUES MÉDECIN ───
                        if (_isDoctor) ...[
                          _buildField(
                            label: 'SPÉCIALITÉ MÉDICALE *',
                            controller: _model.specialtyController,
                            focusNode: _model.specialtyFocusNode,
                            hint: 'Ex: Médecine Générale, Pédiatrie, Cardiologie, Gynécologie...',
                            icon: Icons.medical_services_outlined,
                          ),
                          _buildField(
                            label: 'N° D\'ORDRE DES MÉDECINS (CNOM) *',
                            controller: _model.docNumberController,
                            focusNode: _model.docNumberFocusNode,
                            hint: 'Ex: CNOM-CG-2024-045',
                            icon: Icons.badge_outlined,
                          ),
                          _buildField(
                            label: 'LIEU D\'EXERCICE / HÔPITAL DE RATTACHEMENT',
                            controller: _model.workplaceController,
                            focusNode: _model.workplaceFocusNode,
                            hint: 'Ex: CHU de Brazzaville / Cabinet Privé',
                            icon: Icons.business_outlined,
                          ),
                        ],

                        // ─── 7. CHAMPS SPÉCIFIQUES ÉTABLISSEMENT / CLINIQUE ───
                        if (_isClinic) ...[
                          _buildField(
                            label: 'CATÉGORIE D\'ÉTABLISSEMENT *',
                            controller: _model.specialtyController,
                            focusNode: _model.specialtyFocusNode,
                            hint: 'Ex: Clinique Privée, Hôpital, Polyclinique, Centre de Santé...',
                            icon: Icons.category_outlined,
                          ),
                          _buildField(
                            label: 'N° D\'AGRÉMENT MINISTÈRE DE LA SANTÉ / RCCM *',
                            controller: _model.docNumberController,
                            focusNode: _model.docNumberFocusNode,
                            hint: 'Ex: AGR-MS-2023-889',
                            icon: Icons.verified_user_outlined,
                          ),
                          _buildField(
                            label: 'MÉDECIN CHEF / DIRECTEUR MÉDICAL *',
                            controller: _model.directorController,
                            focusNode: _model.directorFocusNode,
                            hint: 'Ex: Dr. Jean-Pierre Makosso',
                            icon: Icons.person_pin_outlined,
                          ),
                          _buildField(
                            label: 'SERVICES & PLATEAU TECHNIQUE',
                            controller: _model.servicesController,
                            focusNode: _model.servicesFocusNode,
                            hint: 'Ex: Urgences 24h, Maternité, Bloc Opératoire, Banque de Sang',
                            icon: Icons.medical_information_outlined,
                          ),
                          _buildField(
                            label: 'CAPACITÉ D\'ACCUEIL (NOMBRE DE LITS)',
                            controller: _model.bedsCountController,
                            focusNode: _model.bedsCountFocusNode,
                            hint: 'Ex: 35',
                            icon: Icons.bed_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],

                        // ─── 8. CHAMPS SPÉCIFIQUES PHARMACIE ───
                        if (_isPharmacy) ...[
                          _buildField(
                            label: 'PHARMACIEN TITULAIRE RESPONSABLE *',
                            controller: _model.directorController,
                            focusNode: _model.directorFocusNode,
                            hint: 'Ex: Dr. Alice Moukoko',
                            icon: Icons.person_pin_outlined,
                          ),
                          _buildField(
                            label: 'N° D\'INSCRIPTION À L\'ORDRE (CNOP) *',
                            controller: _model.docNumberController,
                            focusNode: _model.docNumberFocusNode,
                            hint: 'Ex: CNOP-CG-142',
                            icon: Icons.badge_outlined,
                          ),
                          _buildField(
                            label: 'SERVICE DE GARDE / HORAIRES',
                            controller: _model.specialtyController,
                            focusNode: _model.specialtyFocusNode,
                            hint: 'Ex: De Garde 24h/24, ou 08h00 - 20h00',
                            icon: Icons.access_time_rounded,
                          ),
                        ],

                        // ─── 9. SEXE (UNIQUEMENT PATIENTS & MÉDECINS) ───
                        if (_isPatient || _isDoctor) ...[
                          const SizedBox(height: 6.0),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEXE',
                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                              ),
                              const SizedBox(height: 4.0),
                              FlutterFlowRadioButton(
                                options: ['HOMME', 'FEMME'].toList(),
                                onChanged: (val) => safeSetState(() {}),
                                controller: _model.radioButtonValueController ??=
                                    FormFieldController<String>(null),
                                optionHeight: 32.0,
                                optionSpacing: 40.0,
                                textStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.outfit(),
                                    ),
                                selectedTextStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      color: _roleColor,
                                    ),
                                buttonPosition: RadioButtonPosition.left,
                                direction: Axis.horizontal,
                                radioButtonColor: _roleColor,
                                inactiveRadioButtonColor: FlutterFlowTheme.of(context).accent3,
                                toggleable: false,
                                horizontalAlignment: WrapAlignment.start,
                                verticalAlignment: WrapCrossAlignment.start,
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 20.0),

                        // Bouton d'action Créer un compte
                        InkWell(
                          onTap: _isLoading ? null : _createAccount,
                          child: Container(
                            width: double.infinity,
                            height: 52.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _roleColor,
                                  _roleColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24.0),
                              boxShadow: [
                                BoxShadow(
                                  color: _roleColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                                      const Icon(Icons.person_add_outlined,
                                          color: Colors.white, size: 20.0),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        _isDoctor
                                            ? 'Inscrire mon profil Médecin'
                                            : _isClinic
                                                ? 'Inscrire l\'établissement'
                                                : _isPharmacy
                                                    ? 'Inscrire l\'officine'
                                                    : 'Créer mon compte',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          fontSize: 15.0,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ].divide(const SizedBox(height: 14.0)),
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
