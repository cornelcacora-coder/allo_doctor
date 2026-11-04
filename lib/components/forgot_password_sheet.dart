import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/connect/o_t_p_verification_patient/o_t_p_verification_patient_widget.dart';

/// Boîte modale moderne pour la réinitialisation du mot de passe oublié
/// Utilisable pour tous les rôles : patient, médecin, pharmacie, clinique, livreur.
void showForgotPasswordBottomSheet(
  BuildContext context, {
  String? initialEmail,
  required String role,
  required String roleLabel,
}) {
  final emailCtrl = TextEditingController(text: initialEmail?.trim() ?? '');
  bool isSubmitting = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (bottomSheetContext) {
      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x25000000),
                    blurRadius: 20.0,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Barre grise indicatrice
                  Center(
                    child: Container(
                      width: 44.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Icône et titre
                  Row(
                    children: [
                      Container(
                        width: 48.0,
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Color(0xFF00875A),
                          size: 26.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mot de passe oublié ?',
                              style: GoogleFonts.outfit(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF132A20),
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              'Espace $roleLabel • Réinitialisation par email',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  Text(
                    'Saisissez l\'adresse email associée à votre compte $roleLabel. Nous vous enverrons immédiatement un lien sécurisé pour créer un nouveau mot de passe.',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  // Champ Email
                  Container(
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color(0xFFD6EAE0),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline_rounded,
                            color: Color(0xFF00A86B), size: 20.0),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: emailCtrl.text.isEmpty,
                            style: GoogleFonts.outfit(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: 'exemple@domaine.com',
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

                  const SizedBox(height: 22.0),

                  // Bouton Envoyer
                  GestureDetector(
                    onTap: isSubmitting
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Veuillez saisir une adresse email valide.'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSubmitting = true);

                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email);

                              if (!modalContext.mounted) return;
                              Navigator.pop(bottomSheetContext);

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lien de réinitialisation envoyé à $email. Vérifiez vos emails.',
                                  ),
                                  backgroundColor: const Color(0xFF00875A),
                                  duration: const Duration(seconds: 5),
                                ),
                              );

                              // Ouvrir la page de statut OTP / Réinitialisation
                              context.pushNamed(
                                OTPVerificationPatientWidget.routeName,
                                queryParameters: {
                                  'email': email,
                                  'mode': 'forgot_password',
                                  'emailSent': 'true',
                                  'role': role,
                                },
                              );
                            } on FirebaseAuthException catch (e) {
                              if (!modalContext.mounted) return;
                              setModalState(() => isSubmitting = false);
                              String msg = 'Erreur lors de l\'envoi de l\'email.';
                              if (e.code == 'user-not-found') {
                                msg = 'Aucun compte trouvé avec cette adresse email.';
                              } else if (e.code == 'invalid-email') {
                                msg = 'Adresse email invalide.';
                              } else if (e.code == 'too-many-requests') {
                                msg = 'Trop de tentatives. Veuillez patienter.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            } catch (e) {
                              if (!modalContext.mounted) return;
                              setModalState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: ${e.toString()}'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            }
                          },
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00875A)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(26.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3500B96B),
                            blurRadius: 12.0,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isSubmitting
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send_rounded,
                                    color: Colors.white, size: 18.0),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Envoyer le lien de réinitialisation',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

