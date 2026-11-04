import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/forgot_password_sheet.dart';
import '/livreur/home_livreur/home_livreur_widget.dart';

/// Page d'authentification complète pour les livreurs (Connexion & Inscription)
/// Repensée avec le design unifié de l'application (Vagues vertes, typographie Outfit).
class LoginLivreurWidget extends StatefulWidget {
  const LoginLivreurWidget({super.key});

  static const String routeName = 'LoginLivreur';
  static const String routePath = '/loginLivreur';

  @override
  State<LoginLivreurWidget> createState() => _LoginLivreurWidgetState();
}

class _LoginLivreurWidgetState extends State<LoginLivreurWidget> {
  bool _isSignUp = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Brazzaville');

  String _selectedVehicle = 'Moto';
  final List<Map<String, dynamic>> _vehicles = [
    {'id': 'Moto', 'label': 'Moto', 'icon': Icons.two_wheeler_rounded},
    {'id': 'Voiture', 'label': 'Voiture', 'icon': Icons.directions_car_rounded},
    {'id': 'Vélo', 'label': 'Vélo', 'icon': Icons.pedal_bike_rounded},
    {'id': 'À pied', 'label': 'À pied', 'icon': Icons.directions_walk_rounded},
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      _showError('Veuillez remplir tous les champs.');
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        // Vérifier ou attribuer le rôle livreur
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final currentRole = userDoc.data()?['role'] ?? userDoc.data()?['userCategory'];

        if (currentRole == null || currentRole.toString().isEmpty) {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'role': 'livreur',
            'userCategory': 'livreur',
            'name': cred.user?.displayName ?? 'Livreur',
          }, SetOptions(merge: true));
          await FirebaseFirestore.instance.collection('livreurs').doc(uid).set({
            'id': uid,
            'uid': uid,
            'name': cred.user?.displayName ?? 'Livreur',
            'email': email,
            'is_online': true,
            'created_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else if (currentRole != 'livreur' && currentRole != 'admin') {
          await FirebaseAuth.instance.signOut();
          _showError('Ce compte est enregistré en tant que $currentRole. Veuillez créer un compte livreur.');
          return;
        }

        if (mounted) context.goNamed(HomeLivreurWidget.routeName);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authError(e.code));
    } catch (e) {
      _showError('Erreur de connexion : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (name.isEmpty || phone.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError('Veuillez remplir tous les champs obligatoires.');
      return;
    }
    if (pass.length < 6) {
      _showError('Le mot de passe doit contenir au moins 6 caractères.');
      return;
    }
    if (pass != confirm) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        await cred.user?.updateDisplayName(name);

        final now = FieldValue.serverTimestamp();
        // 1. Enregistrement dans users avec rôle livreur
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': email,
          'name': name,
          'displayName': name,
          'nom': name,
          'phone': phone,
          'telephone': phone,
          'city': city.isNotEmpty ? city : 'Brazzaville',
          'vehicle': _selectedVehicle,
          'role': 'livreur',
          'userCategory': 'livreur',
          'status': 'actif',
          'created_at': now,
          'created_time': now,
        }, SetOptions(merge: true));

        // 2. Enregistrement dans la collection livreurs
        await FirebaseFirestore.instance.collection('livreurs').doc(uid).set({
          'id': uid,
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'city': city.isNotEmpty ? city : 'Brazzaville',
          'vehicle': _selectedVehicle,
          'is_online': true,
          'rating': 5.0,
          'deliveries_count': 0,
          'created_at': now,
        }, SetOptions(merge: true));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte livreur créé avec succès ! Bienvenue.'),
            backgroundColor: Color(0xFF00A86B),
          ),
        );
        context.goNamed(HomeLivreurWidget.routeName);
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authError(e.code));
    } catch (e) {
      _showError('Erreur lors de l\'inscription : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _demoLogin() async {
    setState(() => _loading = true);
    const demoEmail = 'livreur.demo@allodoctor.com';
    const demoPass = 'demo123456';
    try {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: demoEmail, password: demoPass);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
          final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: demoEmail, password: demoPass);
          final uid = cred.user?.uid;
          if (uid != null) {
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'uid': uid,
              'email': demoEmail,
              'name': 'Livreur Démo Express',
              'displayName': 'Livreur Démo Express',
              'phone': '+242 06 999 88 77',
              'city': 'Brazzaville',
              'vehicle': 'Moto',
              'role': 'livreur',
              'userCategory': 'livreur',
              'status': 'actif',
              'created_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance.collection('livreurs').doc(uid).set({
              'id': uid,
              'uid': uid,
              'name': 'Livreur Démo Express',
              'email': demoEmail,
              'phone': '+242 06 999 88 77',
              'vehicle': 'Moto',
              'is_online': true,
              'rating': 4.9,
              'deliveries_count': 18,
              'created_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } else {
          rethrow;
        }
      }
      if (mounted) context.goNamed(HomeLivreurWidget.routeName);
    } catch (e) {
      _showError('Session démo : $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte livreur trouvé avec cet email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe ou email incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé. Connectez-vous.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Le mot de passe doit comporter au moins 6 caractères.';
      default:
        return 'Erreur d\'authentification ($code). Réessayez.';
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
        backgroundColor: const Color(0xFFF2FAFA),
        body: Stack(
          children: [
            // Fond avec vagues en haut et en bas
            Positioned.fill(
              child: CustomPaint(
                painter: _LoginLivreurWavesPainter(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ══════════════════════════════════════════════════
                  // 1. EN-TÊTE : BOUTON RETOUR + BADGE "Espace Livreur"
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

                        // Pill "Espace Livreur"
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
                              const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 17.0),
                              const SizedBox(width: 6.0),
                              Text(
                                'Espace Livreur',
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
                              Icons.delivery_dining_rounded,
                              color: Color(0xFF00A86B),
                              size: 38.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),

                        // Titre dynamique
                        Text(
                          _isSignUp ? 'Devenir Livreur' : 'Bon retour Livreur',
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
                          _isSignUp
                              ? 'Rejoignez le réseau de livraison express AlloDoctor'
                              : 'Connectez-vous pour accéder à vos courses et livraisons',
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
                                // Onglet Connexion
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isSignUp = false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: !_isSignUp
                                            ? const LinearGradient(
                                                colors: [Color(0xFF00C853), Color(0xFF00965E)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(24.0),
                                        boxShadow: !_isSignUp
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x2800965E),
                                                  blurRadius: 8.0,
                                                  offset: Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_rounded,
                                            color: !_isSignUp ? Colors.white : const Color(0xFF4A6B5F),
                                            size: 18.0,
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            'Connexion',
                                            style: GoogleFonts.outfit(
                                              color: !_isSignUp ? Colors.white : const Color(0xFF4A6B5F),
                                              fontWeight: !_isSignUp ? FontWeight.w800 : FontWeight.bold,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Onglet Inscription
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isSignUp = true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: _isSignUp
                                            ? const LinearGradient(
                                                colors: [Color(0xFF00C853), Color(0xFF00965E)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        borderRadius: BorderRadius.circular(24.0),
                                        boxShadow: _isSignUp
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x2800965E),
                                                  blurRadius: 8.0,
                                                  offset: Offset(0, 3),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            color: _isSignUp ? Colors.white : const Color(0xFF4A6B5F),
                                            size: 20.0,
                                          ),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            'Inscription',
                                            style: GoogleFonts.outfit(
                                              color: _isSignUp ? Colors.white : const Color(0xFF4A6B5F),
                                              fontWeight: _isSignUp ? FontWeight.w800 : FontWeight.bold,
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

                          if (_isSignUp) ...[
                            // ── FORMULAIRE D'INSCRIPTION LIVREUR ──
                            _buildLabel('Nom & Prénom *', Icons.person_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _nameCtrl,
                              hint: 'Ex: Jean Moundélé',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Téléphone *', Icons.phone_outlined),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _phoneCtrl,
                              hint: '+242 06 123 45 67',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Ville *', Icons.location_on_outlined),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _cityCtrl,
                              hint: 'Brazzaville, Pointe-Noire...',
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Moyen de transport *', Icons.delivery_dining_rounded),
                            const SizedBox(height: 8.0),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _vehicles.map((v) {
                                final sel = _selectedVehicle == v['id'];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedVehicle = v['id'] as String),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: sel ? const Color(0xFF00A86B) : Colors.white,
                                      borderRadius: BorderRadius.circular(16.0),
                                      border: Border.all(
                                        color: sel ? const Color(0xFF00A86B) : const Color(0xFFD6EAE0),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          v['icon'] as IconData,
                                          size: 16.0,
                                          color: sel ? Colors.white : const Color(0xFF4A6B5F),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Text(
                                          v['label'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                            color: sel ? Colors.white : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Adresse Email *', Icons.mail_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _emailCtrl,
                              hint: 'livreur@exemple.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Mot de passe *', Icons.lock_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _passCtrl,
                              hint: 'Minimum 6 caractères',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF00A86B),
                                  size: 20.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            _buildLabel('Confirmer mot de passe *', Icons.lock_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _confirmPassCtrl,
                              hint: 'Confirmez votre mot de passe',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscureConfirm,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                child: Icon(
                                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF00A86B),
                                  size: 20.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24.0),

                            // Bouton Inscription
                            _buildActionButton(
                              text: 'Créer mon compte livreur',
                              onTap: _signUp,
                            ),
                          ] else ...[
                            // ── FORMULAIRE DE CONNEXION LIVREUR ──
                            _buildLabel('Adresse Email', Icons.mail_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _emailCtrl,
                              hint: 'livreur@exemple.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 18.0),

                            _buildLabel('Mot de passe', Icons.lock_outline_rounded),
                            const SizedBox(height: 8.0),
                            _buildInputBox(
                              controller: _passCtrl,
                              hint: 'Entrez votre mot de passe',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: const Color(0xFF00A86B),
                                  size: 20.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),

                            // Mot de passe oublié (active la boîte de réinitialisation)
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => showForgotPasswordBottomSheet(
                                  context,
                                  initialEmail: _emailCtrl.text.trim(),
                                  role: 'livreur',
                                  roleLabel: 'Livreur',
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

                            // Bouton Connexion
                            _buildActionButton(
                              text: 'Se connecter',
                              onTap: _signIn,
                            ),

                            const SizedBox(height: 12.0),

                            // Bouton Démo Rapide
                            OutlinedButton.icon(
                              onPressed: _loading ? null : _demoLogin,
                              icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF00875A), size: 18.0),
                              label: Text(
                                'Tester en mode Démo Livreur',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF00875A),
                                  fontSize: 13.5,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF00A86B), width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
                                padding: const EdgeInsets.symmetric(vertical: 13.0),
                              ),
                            ),
                          ],

                          const SizedBox(height: 18.0),

                          // ── CARTE BANNIÈRE : BASCULE CONNEXION / INSCRIPTION ──
                          GestureDetector(
                            onTap: () => setState(() => _isSignUp = !_isSignUp),
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
                                    child: Icon(
                                      _isSignUp ? Icons.login_rounded : Icons.delivery_dining_rounded,
                                      color: const Color(0xFF00875A),
                                      size: 22.0,
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isSignUp ? 'Vous avez déjà un compte ?' : 'Vous n\'êtes pas encore livreur ?',
                                          style: GoogleFonts.outfit(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF132A20),
                                          ),
                                        ),
                                        const SizedBox(height: 2.0),
                                        Text(
                                          _isSignUp ? 'Se connecter maintenant →' : 'Créer un compte livreur →',
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

  // ─── HELPERS DESIGN ───
  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF132A20), size: 18.0),
        const SizedBox(width: 6.0),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF132A20),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
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
          Icon(icon, color: const Color(0xFF00A86B), size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextField(
              controller: controller,
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
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Future<void> Function() onTap,
  }) {
    return GestureDetector(
      onTap: _loading ? null : onTap,
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
        child: _loading
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
                    text,
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
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PEINTURE DES VAGUES SUPÉRIEURES ET INFÉRIEURES (DESIGN FIDÈLE)
// ════════════════════════════════════════════════════════════════════════════
class _LoginLivreurWavesPainter extends CustomPainter {
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
