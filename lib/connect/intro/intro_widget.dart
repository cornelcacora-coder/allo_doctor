import '/components/login_option_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'intro_model.dart';
export 'intro_model.dart';

/// create medical App intro page (with multiple categori of login)
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
                // ─── HERO HEADER ───
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF09392D),
                        Color(0xFF0C5241),
                        Color(0xFF107058),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36.0),
                      bottomRight: Radius.circular(36.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF09392D).withOpacity(0.25),
                        blurRadius: 20.0,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo avec halo doux
                          Container(
                            width: 76.0,
                            height: 76.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(22.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 16.0,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Image.asset(
                                'assets/images/Logo_Mini-removebg-preview.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.medical_services_rounded,
                                  color: Colors.white,
                                  size: 38.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 14.0),
                          Text(
                            'Allô Docteur',
                            style: GoogleFonts.outfit(
                              fontSize: 28.0,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Votre santé connectée, partout & en toute sérénité',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.88),
                            ),
                          ),
                          SizedBox(height: 18.0),
                          // Badges de réassurance
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8.0,
                            runSpacing: 6.0,
                            children: [
                              _buildTrustBadge('🔒 100% Sécurisé'),
                              _buildTrustBadge('🩺 Praticiens Agréés'),
                              _buildTrustBadge('⚡ Service 24/7'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── LISTE DES PROFILS ───
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choisissez votre profil',
                                style: GoogleFonts.outfit(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primaryText,
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Text(
                                'Accédez à votre espace dédié en un clic',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.0,
                                  color: theme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 1. PATIENT
                        _buildRoleCard(
                          context: context,
                          title: 'Je suis un Patient',
                          subtitle: 'Consultez des médecins, prenez RDV et suivez vos soins',
                          badge: 'Particulier',
                          badgeColor: Color(0xFF10B981),
                          gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                          icon: Icons.person_rounded,
                          onTap: () => context.pushNamed(LoginPatientWidget.routeName),
                        ),
                        SizedBox(height: 12.0),

                        // 2. MEDECIN
                        _buildRoleCard(
                          context: context,
                          title: 'Je suis Médecin',
                          subtitle: 'Cabinet virtuel, téléconsultations et prescriptions médicales',
                          badge: 'Espace Pro',
                          badgeColor: Color(0xFF0284C7),
                          gradientColors: [Color(0xFF0369A1), Color(0xFF38BDF8)],
                          icon: Icons.medical_services_rounded,
                          onTap: () => context.pushNamed(LoginDoctorWidget.routeName),
                        ),
                        SizedBox(height: 12.0),

                        // 3. PHARMACIE
                        _buildRoleCard(
                          context: context,
                          title: 'Je suis Pharmacien',
                          subtitle: 'Réception, validation d\'ordonnances et vente de produits',
                          badge: 'Officine',
                          badgeColor: Color(0xFF6366F1),
                          gradientColors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
                          icon: Icons.medication_rounded,
                          onTap: () => context.pushNamed(LoginPharmacyWidget.routeName),
                        ),
                        SizedBox(height: 12.0),

                        // 4. CLINIQUE / ETABLISSEMENT
                        _buildRoleCard(
                          context: context,
                          title: 'Établissement de Santé',
                          subtitle: 'Hôpital, clinique médicale, centre de santé ou laboratoire',
                          badge: 'Structure',
                          badgeColor: Color(0xFFF59E0B),
                          gradientColors: [Color(0xFFD97706), Color(0xFFFBBF24)],
                          icon: Icons.local_hospital_rounded,
                          onTap: () => context.pushNamed(LoginClinicWidget.routeName),
                        ),
                        SizedBox(height: 24.0),

                        // ─── FOOTER ACTIONS ───
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
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Contact : support@allodoctor.com')),
                                  );
                                }
                              },
                            ),
                            SizedBox(width: 16.0),
                            _buildFooterButton(
                              icon: Icons.info_outline_rounded,
                              label: 'À propos',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Allô Docteur',
                                  applicationVersion: '2.0.0',
                                  applicationIcon: Icon(
                                    Icons.medical_services_rounded,
                                    color: Color(0xFF10B981),
                                    size: 40,
                                  ),
                                  children: [
                                    Text(
                                      'Allô Docteur est la plateforme de télémédecine et de santé numérique '
                                      'dédiée à faciliter l\'accès aux soins de santé de qualité.\n\n'
                                      'Patients, médecins et pharmaciens réunis dans un écosystème sécurisé.',
                                      style: GoogleFonts.outfit(fontSize: 13.5),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16.0),

                        // Note légale
                        Text(
                          '🔒 Données de santé chiffrées de bout en bout et protégées selon les normes médicales en vigueur.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            color: theme.secondaryText.withOpacity(0.8),
                            height: 1.4,
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

  Widget _buildTrustBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.20),
          width: 1.0,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
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
    final theme = FlutterFlowTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        splashColor: gradientColors.first.withOpacity(0.08),
        highlightColor: gradientColors.first.withOpacity(0.04),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: theme.alternate.withOpacity(0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icône avec dégradé et ombre
              Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors.first.withOpacity(0.30),
                      blurRadius: 10.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 26.0),
                ),
              ),
              SizedBox(width: 14.0),
              // Textes
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
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryText,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10.0),
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
                    SizedBox(height: 3.5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        color: theme.secondaryText,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.0),
              // Flèche moderne
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.secondaryText,
                  size: 16.0,
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
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.0, color: Color(0xFF10B981)),
            SizedBox(width: 6.0),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

