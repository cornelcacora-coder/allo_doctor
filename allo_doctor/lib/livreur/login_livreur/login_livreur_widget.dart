import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/livreur/home_livreur/home_livreur_widget.dart';

/// Page d'authentification complète pour les livreurs (Connexion & Inscription).
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
            backgroundColor: Color(0xFF10B981),
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

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Veuillez saisir votre email pour réinitialiser le mot de passe.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email de réinitialisation envoyé à $email'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } catch (e) {
      _showError('Erreur : $e');
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
    const primary = Color(0xFF0D47A1);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A2E6B), Color(0xFF0D47A1), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'ESPACE LIVREUR',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      // Header Icon & Title
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/Logo_Mini-removebg-preview.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.delivery_dining_rounded,
                            color: Color(0xFF0D47A1),
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isSignUp ? 'Rejoindre l\'équipe' : 'Bon retour parmi nous',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isSignUp
                            ? 'Créez votre compte livreur en 1 minute'
                            : 'Gérez et livrez vos commandes en direct',
                        style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Segmented Switch : Connexion / Inscription
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isSignUp = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: !_isSignUp ? primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Connexion',
                                          style: GoogleFonts.outfit(
                                            color: !_isSignUp ? Colors.white : Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _isSignUp = true),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: _isSignUp ? primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Inscription',
                                          style: GoogleFonts.outfit(
                                            color: _isSignUp ? Colors.white : Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Fields for Sign Up only
                            if (_isSignUp) ...[
                              _buildLabel('Nom complet *'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _nameCtrl,
                                hint: 'ex: Jean Makosso',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),

                              _buildLabel('Numéro de téléphone *'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _phoneCtrl,
                                hint: '+242 06 123 45 67',
                                icon: Icons.phone_outlined,
                                keyboard: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),

                              _buildLabel('Ville d\'activité'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _cityCtrl,
                                hint: 'Brazzaville, Pointe-Noire...',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 14),

                              _buildLabel('Moyen de transport'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _vehicles.map((v) {
                                  final isSel = _selectedVehicle == v['id'];
                                  return ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          v['icon'] as IconData,
                                          size: 16,
                                          color: isSel ? Colors.white : Colors.grey.shade800,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          v['label'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSel ? Colors.white : Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selected: isSel,
                                    selectedColor: primary,
                                    backgroundColor: const Color(0xFFF1F4F9),
                                    showCheckmark: false,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedVehicle = v['id'] as String);
                                    },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Common fields: Email & Password
                            _buildLabel('Adresse email *'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _emailCtrl,
                              hint: 'livreur@example.com',
                              icon: Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            _buildLabel('Mot de passe *'),
                            const SizedBox(height: 6),
                            _buildTextField(
                              controller: _passCtrl,
                              hint: 'Au moins 6 caractères',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: Colors.grey.shade500,
                                  size: 20,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            if (_isSignUp) ...[
                              const SizedBox(height: 14),
                              _buildLabel('Confirmer le mot de passe *'),
                              const SizedBox(height: 6),
                              _buildTextField(
                                controller: _confirmPassCtrl,
                                hint: 'Retapez votre mot de passe',
                                icon: Icons.lock_clock_outlined,
                                obscure: _obscureConfirm,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                            ],

                            if (!_isSignUp) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _forgotPassword,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: GoogleFonts.outfit(
                                      color: primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : (_isSignUp ? _signUp : _signIn),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        _isSignUp ? 'Créer mon compte livreur' : 'Se connecter',
                                        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),

                            // Switch helper text
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = !_isSignUp),
                                child: RichText(
                                  text: TextSpan(
                                    text: _isSignUp ? 'Vous avez déjà un compte ? ' : 'Pas encore de compte ? ',
                                    style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13),
                                    children: [
                                      TextSpan(
                                        text: _isSignUp ? 'Se connecter' : 'S\'inscrire ici',
                                        style: GoogleFonts.outfit(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
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

                      const SizedBox(height: 20),

                      // Demo Quick Access Button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: TextButton.icon(
                          onPressed: _loading ? null : _demoLogin,
                          icon: const Icon(Icons.flash_on_rounded, color: Color(0xFFFFD54F), size: 20),
                          label: Text(
                            'Connexion Démo Rapide (1 clic)',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Retour à l\'accueil',
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: GoogleFonts.outfit(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF0D47A1), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF1F4F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D47A1), width: 1.5),
        ),
      ),
    );
  }
}
