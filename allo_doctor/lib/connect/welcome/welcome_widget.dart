import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'welcome_model.dart';
export 'welcome_model.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({super.key});

  static String routeName = 'Welcome';
  static String routePath = '/welcome';

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  late WelcomeModel _model;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _slides = [
    {
      'isLogo': true,
      'title': 'Bienvenue sur\nAllô Docteur',
      'subtitle': 'Votre santé connectée, partout et en toute sérénité au Congo.',
      'badge': 'Plateforme Médicale Agréée',
      'icon': Icons.medical_services_rounded,
      'accentColor': Color(0xFF0D9488),
    },
    {
      'isLogo': false,
      'title': 'Téléconsultations\n24h/24 & 7j/7',
      'subtitle': 'Consultez des médecins généralistes et spécialistes en visio sécurisée où que vous soyez.',
      'badge': 'Soins à Distance',
      'icon': Icons.video_camera_front_rounded,
      'accentColor': Color(0xFF0284C7),
    },
    {
      'isLogo': false,
      'title': 'Pharmacies &\nLaboratoires',
      'subtitle': 'Commandez vos médicaments, faites-vous livrer et planifiez vos analyses facilement.',
      'badge': 'Services Intégrés',
      'icon': Icons.local_pharmacy_rounded,
      'accentColor': Color(0xFF059669),
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => WelcomeModel());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _model.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(IntroWidget.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 500.0),
            child: Column(
              children: [
                // --- BARRE DU HAUT : LOGO & BOUTON PASSER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36.0,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Image.asset(
                              'assets/images/Logo_Mini-removebg-preview.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            'Allô Docteur',
                            style: GoogleFonts.outfit(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.goNamed(IntroWidget.routeName),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                          backgroundColor: const Color(0xFF0F766E).withOpacity(0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          'Passer',
                          style: GoogleFonts.outfit(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- SLIDES ONBOARDING ---
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      final bool isLogo = slide['isLogo'] == true;
                      final Color accent = slide['accentColor'] as Color;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 1),

                            // Halo doux et medaillon
                            Container(
                              width: 160.0,
                              height: 160.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withOpacity(0.08),
                              ),
                              child: Center(
                                child: Container(
                                  width: 120.0,
                                  height: 120.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.18),
                                        blurRadius: 20.0,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(18.0),
                                  child: isLogo
                                      ? Image.asset(
                                          'assets/images/Logo_Mini-removebg-preview.png',
                                          fit: BoxFit.contain,
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            slide['icon'] as IconData,
                                            color: accent,
                                            size: 50.0,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28.0),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                slide['badge'] as String,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16.0),

                            // Titre
                            Text(
                              slide['title'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 26.0,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                height: 1.25,
                              ),
                            ),

                            const SizedBox(height: 12.0),

                            // Sous-titre
                            Text(
                              slide['subtitle'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 14.0,
                                color: const Color(0xFF64748B),
                                height: 1.45,
                              ),
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- BAS DE PAGE : INDICATEURS & BOUTON ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dots animes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _currentPage == i ? 26.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: _currentPage == i ? const Color(0xFF0F766E) : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22.0),

                      // Bouton d'action
                      SizedBox(
                        width: double.infinity,
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1 ? 'Commencer' : 'Continuer',
                                style: GoogleFonts.outfit(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18.0),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      Text(
                        'Données de santé chiffrées & certifiées au Congo',
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
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