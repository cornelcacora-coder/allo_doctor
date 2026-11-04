import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool get _isLivreur => widget.role == 'livreur';
  bool get _isPatient => widget.role == 'patient';
  bool get _isPractitioner => !_isPatient && !_isLivreur;

  String get _roleDisplay {
    switch (widget.role) {
      case 'medecin':
        return 'Médecin';
      case 'clinique':
        return 'Clinique';
      case 'pharmacie':
        return 'Pharmacie';
      case 'livreur':
        return 'Livreur';
      default:
        return 'Patient';
    }
  }

  String get _roleSubtitle {
    switch (widget.role) {
      case 'medecin':
        return 'Votre pratique médicale • Consultations & téléconsultations';
      case 'clinique':
        return 'Votre établissement • Hôpital, clinique ou laboratoire';
      case 'pharmacie':
        return 'Votre officine • Validation d\'ordonnances & dispensation';
      case 'livreur':
        return 'Courses de santé • Livraison rapide et sécurisée';
      default:
        return 'Votre santé, notre priorité • Carnet de santé et consultations';
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

    _model.radioButtonValueController ??= FormFieldController<String>('HOMME');

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

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Veuillez remplir tous les champs obligatoires (*).',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    if (_isDoctor && (specialty.isEmpty || docNumber.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Veuillez renseigner votre spécialité et votre n° d\'ordre.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    if (_isClinic && (specialty.isEmpty || docNumber.isEmpty || director.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Veuillez préciser la catégorie d\'établissement et le responsable.',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
      return;
    }

    if (_isPharmacy && docNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Veuillez renseigner le n° d\'ordre des pharmaciens.',
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
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;

      try {
        await user.updateDisplayName(name);
      } catch (_) {}

      var emailSent = false;
      try {
        await user.sendEmailVerification();
        emailSent = true;
      } catch (_) {}

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
        'specialty': specialty,
        'docNumber': docNumber,
        'workplace': workplace,
        'director': director,
        'services': services,
        'bedsCount': bedsCount,
      }, SetOptions(merge: true));

      if (_isDoctor) {
        try {
          await FirebaseFirestore.instance.collection('practitioners').doc(user.uid).set({
            'uid': user.uid,
            'id': user.uid,
            'name': name,
            'email': email,
            'phone': phone,
            'specialty': specialty,
            'docNumber': docNumber,
            'workplace': workplace,
            'city': city.isNotEmpty ? city : 'Brazzaville',
            'type': 'medecin',
            'status': 'en_attente',
            'is_available': true,
            'is_online': true,
            'rating': 5.0,
            'created_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      if (_isClinic) {
        try {
          await FirebaseFirestore.instance.collection('clinics').doc(user.uid).set({
            'id': user.uid,
            'uid': user.uid,
            'name': name,
            'email': email,
            'phone': phone,
            'city': city.isNotEmpty ? city : 'Brazzaville',
            'type': specialty,
            'director': director,
            'docNumber': docNumber,
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

      if (_isPharmacy) {
        try {
          await FirebaseFirestore.instance.collection('pharmacies').doc(user.uid).set({
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

      if (_isLivreur) {
        try {
          await FirebaseFirestore.instance.collection('livreurs').doc(user.uid).set({
            'id': user.uid,
            'uid': user.uid,
            'name': name,
            'email': email,
            'phone': phone,
            'city': city.isNotEmpty ? city : 'Brazzaville',
            'vehicle': 'Moto',
            'is_online': true,
            'rating': 5.0,
            'deliveries_count': 0,
            'created_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {}
      }

      setState(() => _isLoading = false);
      if (!mounted) return;

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
        content: Text('Erreur : $e', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  // ─── WIDGET CHAMP DE FORMULAIRE DESIGN MAQUETTE ───
  Widget _buildField({
    required String label,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF132A20),
          ),
        ),
        const SizedBox(height: 7.0),
        Container(
          height: 52.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFDFD),
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(
              color: const Color(0xFFE2EFE8),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  style: GoogleFonts.outfit(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13.5,
                      color: const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                  ),
                ),
              ),
              if (suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: suffixIcon,
                ),
            ],
          ),
        ),
      ],
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
        backgroundColor: const Color(0xFFF2FAFA),
        body: Stack(
          children: [
            // Fond avec vagues en haut et en bas
            Positioned.fill(
              child: CustomPaint(
                painter: _SignUpWavesPainter(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ══════════════════════════════════════════════════
                  // 1. EN-TÊTE SUPÉRIEUR AVEC BOUTON RETOUR & LOGO
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 12.0),

                        // Titre Allô Docteur bicolore
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Allô ',
                                style: GoogleFonts.outfit(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              TextSpan(
                                text: 'Docteur',
                                style: GoogleFonts.outfit(
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF10E891),
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Votre santé, notre priorité',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════════════
                  // 2. CORPS : CARTE DE FORMULAIRE DESIGN MAQUETTE
                  // ══════════════════════════════════════════════════
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18.0, 6.0, 18.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Titre de section : Créer un compte [Role]
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Créer un compte ',
                                  style: GoogleFonts.outfit(
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F3B2E),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                TextSpan(
                                  text: _roleDisplay,
                                  style: GoogleFonts.outfit(
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF00B96B),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _roleSubtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          // Petite ligne verte courbée décorative
                          Container(
                            width: 50.0,
                            height: 3.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B96B),
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // ─── CARTE FORMULAIRE BLANCHE ARRONDIE ───
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0E000000),
                                  blurRadius: 18.0,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Nom
                                _buildField(
                                  label: _isDoctor
                                      ? 'Nom & prénom du Médecin *'
                                      : _isClinic
                                          ? 'Nom de l\'établissement *'
                                          : _isPharmacy
                                              ? 'Nom de l\'officine *'
                                              : 'Nom complet *',
                                  controller: _model.textController1,
                                  focusNode: _model.textFieldFocusNode1,
                                  hint: _isDoctor
                                      ? 'Ex: Dr. Martin Ntsiba'
                                      : _isClinic
                                          ? 'Ex: Clinique Médico-Chirurgicale Océan'
                                          : _isPharmacy
                                              ? 'Ex: Pharmacie de la Paix'
                                              : 'Ex: BITODI Cornelca',
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 14.0),

                                // Email
                                _buildField(
                                  label: 'Adresse E-mail *',
                                  controller: _model.emailController,
                                  focusNode: _model.emailFocusNode,
                                  hint: 'votre@email.com',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14.0),

                                // Mot de passe
                                _buildField(
                                  label: 'Mot de passe *',
                                  controller: _model.passwordController,
                                  focusNode: _model.passwordFocusNode,
                                  hint: '(6 caractères min.)',
                                  obscure: !_model.passwordVisibility,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      safeSetState(() {
                                        _model.passwordVisibility = !_model.passwordVisibility;
                                      });
                                    },
                                    child: Icon(
                                      _model.passwordVisibility
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF00B96B),
                                      size: 22.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14.0),

                                // Téléphone
                                _buildField(
                                  label: 'Téléphone *',
                                  controller: _model.textController2,
                                  focusNode: _model.textFieldFocusNode2,
                                  hint: '+242 06 xxx xxxx',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14.0),

                                // Ville
                                _buildField(
                                  label: (_isClinic || _isPharmacy) ? 'Adresse exacte *' : 'Ville *',
                                  controller: _model.textController3,
                                  focusNode: _model.textFieldFocusNode3,
                                  hint: 'Ex: Brazzaville, Pointe-Noire...',
                                ),

                                // Champs professionnels spécifiques
                                if (_isDoctor) ...[
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'Spécialité médicale *',
                                    controller: _model.specialtyController,
                                    focusNode: _model.specialtyFocusNode,
                                    hint: 'Ex: Médecine Générale, Pédiatrie...',
                                  ),
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'N° d\'ordre CNOM *',
                                    controller: _model.docNumberController,
                                    focusNode: _model.docNumberFocusNode,
                                    hint: 'Ex: CNOM-CG-2024-045',
                                  ),
                                ],

                                if (_isClinic) ...[
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'Catégorie d\'établissement *',
                                    controller: _model.specialtyController,
                                    focusNode: _model.specialtyFocusNode,
                                    hint: 'Ex: Clinique Privée, Hôpital...',
                                  ),
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'N° d\'agrément Ministère / RCCM *',
                                    controller: _model.docNumberController,
                                    focusNode: _model.docNumberFocusNode,
                                    hint: 'Ex: AGR-MS-2023-889',
                                  ),
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'Directeur médical *',
                                    controller: _model.directorController,
                                    focusNode: _model.directorFocusNode,
                                    hint: 'Ex: Dr. Jean-Pierre Makosso',
                                  ),
                                ],

                                if (_isPharmacy) ...[
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'Pharmacien titulaire *',
                                    controller: _model.directorController,
                                    focusNode: _model.directorFocusNode,
                                    hint: 'Ex: Dr. Alice Moukoko',
                                  ),
                                  const SizedBox(height: 14.0),
                                  _buildField(
                                    label: 'N° d\'ordre CNOP *',
                                    controller: _model.docNumberController,
                                    focusNode: _model.docNumberFocusNode,
                                    hint: 'Ex: CNOP-CG-142',
                                  ),
                                ],

                                // Sexe (Pills design HOMME / FEMME)
                                if (_isPatient || _isDoctor) ...[
                                  const SizedBox(height: 14.0),
                                  Text(
                                    'Sexe',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF132A20),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildGenderPill(
                                          title: 'HOMME',
                                          isSelected: _model.radioButtonValue == 'HOMME',
                                          onTap: () {
                                            safeSetState(() => _model.radioButtonValueController?.value = 'HOMME');
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                      Expanded(
                                        child: _buildGenderPill(
                                          title: 'FEMME',
                                          isSelected: _model.radioButtonValue == 'FEMME',
                                          onTap: () {
                                            safeSetState(() => _model.radioButtonValueController?.value = 'FEMME');
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 22.0),

                          // ─── GRAND BOUTON VERT ARRONDIE AVEC FLÈCHE ───
                          GestureDetector(
                            onTap: _isLoading ? null : _createAccount,
                            child: Container(
                              height: 56.0,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00E676), Color(0xFF00A86B)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
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
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Spacer(),
                                          Text(
                                            'Créer mon compte',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              fontSize: 16.5,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: 32.0,
                                            height: 32.0,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.chevron_right_rounded,
                                              color: Color(0xFF00A86B),
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Lien de redirection vers connexion si déjà un compte
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Vous avez déjà un compte ? ',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.0,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.safePop(),
                                child: Text(
                                  'Se connecter',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF00A86B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
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

  // ─── WIDGET PILL POUR LE SEXE (HOMME / FEMME) ───
  Widget _buildGenderPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.0,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFFBF4) : Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFE2EFE8),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: isSelected ? const Color(0xFF0D3328) : const Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PEINTURE DES VAGUES SUPÉRIEURES ET INFÉRIEURES IDENTIQUES À LA MAQUETTE
// ════════════════════════════════════════════════════════════════════════════
class _SignUpWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── VAGUES DU HAUT (Dégradé vert profond) ──
    final topRect = Rect.fromLTWH(0, 0, w, 220);
    final topGradient = const LinearGradient(
      colors: [Color(0xFF00583A), Color(0xFF00875A), Color(0xFF00C880)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(topRect);

    final topPath = Path();
    topPath.moveTo(0, 0);
    topPath.lineTo(w, 0);
    topPath.lineTo(w, 150);
    topPath.cubicTo(w * 0.75, 195, w * 0.40, 140, 0, 180);
    topPath.close();

    final topPaint = Paint()
      ..shader = topGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, topPaint);

    // Voile vert clair décoratif en haut
    final topWave2 = Path();
    topWave2.moveTo(0, 180);
    topWave2.cubicTo(w * 0.40, 140, w * 0.75, 195, w, 150);
    topWave2.cubicTo(w * 0.70, 205, w * 0.35, 160, 0, 205);
    topWave2.close();

    final topWavePaint2 = Paint()
      ..color = const Color(0xFF00E676).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topWave2, topWavePaint2);

    // ── VAGUES DU BAS (Vert émeraude doux) ──
    final bottomPath = Path();
    bottomPath.moveTo(0, h);
    bottomPath.lineTo(w, h);
    bottomPath.lineTo(w, h - 80);
    bottomPath.cubicTo(w * 0.65, h - 50, w * 0.35, h - 110, 0, h - 70);
    bottomPath.close();

    final bottomPaint = Paint()
      ..color = const Color(0xFF00C880).withValues(alpha: 0.40)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath, bottomPaint);

    final bottomPath2 = Path();
    bottomPath2.moveTo(0, h);
    bottomPath2.lineTo(w, h);
    bottomPath2.lineTo(w, h - 45);
    bottomPath2.cubicTo(w * 0.60, h - 25, w * 0.30, h - 60, 0, h - 35);
    bottomPath2.close();

    final bottomPaint2 = Paint()
      ..color = const Color(0xFF00A86B).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(bottomPath2, bottomPaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
