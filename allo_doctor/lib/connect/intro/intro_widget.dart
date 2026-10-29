import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
        backgroundColor: const Color(0xFFF8FAF9),
        body: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Column(
              children: [
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
                        blurRadius: 18.0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 26.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 76.0,
                            height: 76.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.16),
                                  blurRadius: 16.0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              'assets/images/Logo_Mini-removebg-preview.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.medical_services_rounded,
                                color: Color(0xFF0F766E),
                                size: 36.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Allô Docteur',
                            style: GoogleFonts.outfit(
                              fontSize: 27.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Votre santé connectée, partout & en toute sérénité',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.92),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8.0,
                            runSpacing: 6.0,
                            children: [
                              _buildTrustBadge(Icons.lock_outline_rounded, '100% Sécurisé'),
                              _buildTrustBadge(Icons.verified_user_outlined, 'Praticiens Agréés'),
                              _buildTrustBadge(Icons.bolt_rounded, 'Service 24/7'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choisissez votre profil',
                                style: GoogleFonts.outfit(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2.0),
                              Text(
                                'Accédez à votre espace dédié en un clic',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.0,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildRoleCard(
                          context: context,
                          title: 'Je suis un Patient',
                          subtitle: 'Consultez des médecins, prenez RDV et suivez vos soins',
                          badge: 'Particulier',
                          badgeColor: const Color(0xFF0F766E),
                          gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          icon: Icons.person_rounded,
                          onTap: () => context.pushNamed(LoginPatientWidget.routeName),
                        ),
                        const SizedBox(height: 12.0),

                        _buildRoleCard(
                          context: context,
                          title: 'Je suis Médecin',
                          subtitle: 'Cabinet virtuel, téléconsultations et prescriptions médicales',
                          badge: 'Espace Pro',
                          badgeColor: const Color(0xFF0284C7),
                          gradientColors: const [Color(0xFF0369A1), Color(0xFF38BDF8)],
                          icon: Icons.medical_services_rounded,
                          onTap: () => context.pushNamed(LoginDoctorWidget.routeName),
                        ),
                        const SizedBox(height: 12.0),

                        _buildRoleCard(
                          context: context,
                          title: 'Je suis Pharmacien',
                          subtitle: 'Réception, validation d\'ordonnances et vente de produits',
                          badge: 'Officine',
                          badgeColor: const Color(0xFF6366F1),
                          gradientColors: const [Color(0xFF4F46E5), Color(0xFF818CF8)],
                          icon: Icons.medication_rounded,
                          onTap: () => context.pushNamed(LoginPharmacyWidget.routeName),
                        ),
                        const SizedBox(height: 12.0),

                        _buildRoleCard(
                          context: context,
                          title: 'Établissement de Santé',
                          subtitle: 'Clinique médicale, centre de santé ou laboratoire',
                          badge: 'Clinique',
                          badgeColor: const Color(0xFFD97706),
                          gradientColors: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                          icon: Icons.local_hospital_rounded,
                          onTap: () => context.pushNamed(LoginClinicWidget.routeName),
                        ),
                        const SizedBox(height: 12.0),

                        _buildRoleCard(
                          context: context,
                          title: 'Je suis Livreur',
                          subtitle: 'Livraison express de médicaments et courses santé',
                          badge: 'Livraison',
                          badgeColor: const Color(0xFF2563EB),
                          gradientColors: const [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
                          icon: Icons.delivery_dining_rounded,
                          onTap: () => context.pushNamed(LoginLivreurWidget.routeName),
                        ),
                        const SizedBox(height: 22.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFooterButton(
                              icon: Icons.help_outline_rounded,
                              label: 'Assistance',
                              onTap: () async {
                                final Uri supportUrl = Uri.parse('mailto:support@allodoctor.com?subject=Support');
                                if (await canLaunchUrl(supportUrl)) {
                                  await launchUrl(supportUrl);
                                }
                              },
                            ),
                            const SizedBox(width: 18.0),
                            _buildFooterButton(
                              icon: Icons.info_outline_rounded,
                              label: 'À propos',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Allô Docteur',
                                  applicationVersion: '2.0.0',
                                  applicationIcon: Image.asset(
                                    'assets/images/Logo_Mini-removebg-preview.png',
                                    width: 36,
                                    height: 36,
                                  ),
                                  children: [
                                    Text(
                                      'Allô Docteur est la plateforme de télémédecine et de santé connectée au Congo.',
                                      style: GoogleFonts.outfit(fontSize: 13.5),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14.0),

                        Text(
                          'Données de santé chiffrées de bout en bout et protégées selon les normes médicales.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16.0),
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

  Widget _buildTrustBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13.0),
          const SizedBox(width: 5.0),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 10.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.25),
                      blurRadius: 8.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 24.0),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.outfit(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.0,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                width: 30.0,
                height: 30.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.0,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.0, color: const Color(0xFF0F766E)),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F766E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}