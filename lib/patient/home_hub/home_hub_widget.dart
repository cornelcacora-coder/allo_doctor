import 'package:cloud_firestore/cloud_firestore.dart';
import '/components/emergency_call_widget.dart';
import '/components/log_out_widget.dart';
import '/components/nav_bar_user_widget.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/auth/role_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_hub_model.dart';
import '/auth/firebase_auth/auth_util.dart' show currentUserDisplayName;
import '/components/notification_bell_widget.dart';
export 'home_hub_model.dart';

class HomeHubWidget extends StatefulWidget {
  const HomeHubWidget({super.key});

  static String routeName = 'HomeHub';
  static String routePath = '/homeHub';

  @override
  State<HomeHubWidget> createState() => _HomeHubWidgetState();
}

class _HomeHubWidgetState extends State<HomeHubWidget>
    with TickerProviderStateMixin {
  late HomeHubModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeHubModel());
    _model.searchController ??= TextEditingController();

    animationsMap.addAll({
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(curve: Curves.easeInOut, delay: 0.0.ms, duration: 600.0.ms, begin: 0.0, end: 1.0),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(curve: Curves.easeInOut, delay: 0.0.ms, duration: 600.0.ms, begin: 0.0, end: 1.0),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'patient');
    });
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
        backgroundColor: const Color(0xFFF2FAFA),
        // ═══════════════════════════════════════════════════════════
        // APP BAR — Vert profond avec courbes
        // ═══════════════════════════════════════════════════════════
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(74.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF005A3A), Color(0xFF00754B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo + Titre bicolore + Sous-titre
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 46.0,
                          height: 46.0,
                          child: Image.asset(
                            'assets/images/Logo_Mini-removebg-preview.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                color: Colors.white,
                                size: 28.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Allô ',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Docteur',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF10E891),
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Votre santé, notre priorité',
                              style: GoogleFonts.outfit(
                                color: const Color(0xCCFFFFFF),
                                fontSize: 11.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Boutons circulaires blancs à droite
                    Row(
                      children: [
                        _buildCircleBtn(
                          child: const NotificationBellWidget(iconColor: Color(0xFF1A382C), size: 19.0),
                          onTap: () {},
                        ),
                        const SizedBox(width: 8.0),
                        _buildCircleBtn(
                          child: const Icon(Icons.settings_outlined, color: Color(0xFF1A382C), size: 19.0),
                          onTap: () async => context.pushNamed(SettingsWidget.routeName),
                        ),
                        const SizedBox(width: 8.0),
                        _buildCircleBtn(
                          child: const Icon(Icons.exit_to_app_rounded, color: Color(0xFF1A382C), size: 19.0),
                          onTap: () async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              enableDrag: false,
                              context: context,
                              builder: (context) => GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: const LogOutWidget(),
                                ),
                              ),
                            ).then((_) => safeSetState(() {}));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ═══════════════════════════════════════════════════════════
        // BODY
        // ═══════════════════════════════════════════════════════════
        body: Stack(
          alignment: const AlignmentDirectional(0.0, 1.0),
          children: [
            SingleChildScrollView(
              primary: false,
              padding: const EdgeInsets.only(bottom: 110.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ══════════════════════════════════════════════════
                  // 1. HERO SECTION — VAGUES VERTES FLUIDES + SANS PHOTO
                  // ══════════════════════════════════════════════════
                  SizedBox(
                    height: 200.0,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Fond général
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFF2FAFA),
                          ),
                        ),

                        // Grandes vagues organiques bien visibles en haut et à droite
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _WavesBackgroundPainter(),
                          ),
                        ),

                        // Badge vert cœur ECG stylisé en haut à droite
                        Positioned(
                          right: 20.0,
                          top: 18.0,
                          child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFF00B96B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00B96B).withValues(alpha: 0.4),
                                  blurRadius: 14.0,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: CustomPaint(
                                size: Size(32.0, 16.0),
                                painter: _PulseLinePainter(color: Colors.white),
                              ),
                            ),
                          ),
                        ),

                        // Contenu textuel à gauche
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 14.0, 90.0, 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Sélecteur Localisation "Brazzaville"
                              Container(
                                height: 32.0,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  border: Border.all(color: const Color(0xFFCBEFD9), width: 1.0),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x0C000000), blurRadius: 6.0, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _model.dropdownValue ?? 'Brazzaville',
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00875A), size: 16.0),
                                    elevation: 2,
                                    isDense: true,
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF0D3328),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                    onChanged: (val) {
                                      if (val != null) safeSetState(() => _model.dropdownValue = val);
                                    },
                                    items: ['Brazzaville', 'Pointe-Noire'].map((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.location_on_rounded, color: Color(0xFF00875A), size: 14.0),
                                            const SizedBox(width: 4.0),
                                            Text(value),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10.0),

                              // Greeting — point vert + nom utilisateur
                              Row(
                                children: [
                                  Container(
                                    width: 7.0,
                                    height: 7.0,
                                    decoration: const BoxDecoration(color: Color(0xFF00C853), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 5.0),
                                  Flexible(
                                    child: Text(
                                      currentUserDisplayName.isNotEmpty
                                          ? 'Bonjour, $currentUserDisplayName'
                                          : 'Bonjour !',
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D6A4F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6.0),

                              // Titre principal
                              Text(
                                'Comment allez-vous\naujourd\'hui ?',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF0D3328),
                                  fontSize: 23.0,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 6.0),

                              // Sous-titre avec sourire vert
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Prenez soin de vous,\nnous sommes là pour vous !',
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFF4A6B5F),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      const CustomPaint(
                                        size: Size(50.0, 5.0),
                                        painter: _SmileCurvePainter(color: Color(0xFF00A86B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════════════
                  // 2. BARRE DE RECHERCHE
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                    child: Container(
                      height: 52.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: const Color(0xFFE2EFE8), width: 1.0),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10000000), blurRadius: 14.0, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14.0),
                          const Icon(Icons.search_rounded, color: Color(0xFF00875A), size: 22.0),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _model.searchController,
                              autofocus: false,
                              decoration: InputDecoration(
                                hintText: 'Rechercher : médicament, médecin, clinique...',
                                hintStyle: GoogleFonts.outfit(color: const Color(0xFF8A9E98), fontSize: 12.5),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                              ),
                              style: GoogleFonts.outfit(color: const Color(0xFF14382B), fontSize: 13.5),
                              onSubmitted: (query) {
                                final text = query.trim();
                                context.pushNamed(
                                  DoctorListWidget.routeName,
                                  queryParameters: text.isNotEmpty ? {'initialQuery': text} : <String, dynamic>{},
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final query = _model.searchController?.text.trim() ?? '';
                              context.pushNamed(
                                DoctorListWidget.routeName,
                                queryParameters: query.isNotEmpty ? {'initialQuery': query} : <String, dynamic>{},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 5.0),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B96B),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_rounded, color: Colors.white, size: 15.0),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    'Rechercher',
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),



                  // ══════════════════════════════════════════════════
                  // 4. GRILLE 2×2 DE SERVICES
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildServiceCard(title: 'Médicaments', subtitle: 'Commander en ligne', icon: Icons.medication_rounded, primaryColor: const Color(0xFF00B96B), bgColor: const Color(0xFFEAF8F1), borderColor: const Color(0xFFCBEFD9), onTap: () => context.pushNamed(PharmaListWidget.routeName))),
                            const SizedBox(width: 10.0),
                            Expanded(child: _buildServiceCard(title: 'Médecin', subtitle: 'Consultation à domicile', icon: Icons.person_pin_rounded, primaryColor: const Color(0xFFFF851B), bgColor: const Color(0xFFFFF3E8), borderColor: const Color(0xFFFFE2C8), onTap: () => context.pushNamed(DoctorListWidget.routeName))),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Expanded(child: _buildServiceCard(title: 'Banque de sang', subtitle: 'Disponibilité en direct', icon: Icons.water_drop_rounded, primaryColor: const Color(0xFFF52235), bgColor: const Color(0xFFFFEAEA), borderColor: const Color(0xFFFFD2D2), onTap: () => context.pushNamed(BloodBankListWidget.routeName))),
                            const SizedBox(width: 10.0),
                            Expanded(child: _buildServiceCard(title: 'Cliniques', subtitle: 'Examens & cliniques', icon: Icons.local_hospital_rounded, primaryColor: const Color(0xFF087BE5), bgColor: const Color(0xFFEBF5FF), borderColor: const Color(0xFFC8E2FF), onTap: () => context.pushNamed(ClinicListWidget.routeName))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14.0),

                  // ══════════════════════════════════════════════════
                  // 5. STATISTIQUES EN TEMPS RÉEL (FIRESTORE)
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(color: const Color(0xFFCBEFD9), width: 1.0),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8.0, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, color: Color(0xFF00B96B), size: 30.0),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').snapshots(),
                              builder: (context, userSnap) {
                                final userCount = userSnap.hasData ? userSnap.data!.docs.length : 0;
                                final displayUserCount = userCount > 0 ? '$userCount' : '...';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      displayUserCount,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15.0,
                                        color: const Color(0xFF0D382B),
                                      ),
                                    ),
                                    Text(
                                      'Personnes utilisent l\'app',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10.5,
                                        color: const Color(0xFF4A6B5F),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Container(width: 1.0, height: 36.0, color: const Color(0xFFBFE9D2)),
                          const SizedBox(width: 14.0),
                          Container(
                            width: 28.0,
                            height: 28.0,
                            decoration: const BoxDecoration(color: Color(0xFF00B96B), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 18.0),
                          ),
                          const SizedBox(width: 8.0),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('practitioners')
                                .where('type', isEqualTo: 'medecin')
                                .snapshots(),
                            builder: (context, docSnap) {
                              int docCount = 0;
                              if (docSnap.hasData) {
                                // Compter les medecins disponibles/actifs
                                docCount = docSnap.data!.docs.where((d) {
                                  final map = d.data() as Map<String, dynamic>?;
                                  return map?['is_available'] == true || map?['is_online'] == true;
                                }).length;
                                // Si aucun filtre n'est activé, afficher le total des médecins
                                if (docCount == 0) {
                                  docCount = docSnap.data!.docs.length;
                                }
                              }
                              final displayDocCount = docSnap.hasData ? '$docCount' : '...';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    displayDocCount,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15.0,
                                      color: const Color(0xFF0D382B),
                                    ),
                                  ),
                                  Text(
                                    'Médecins en ligne',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10.5,
                                      color: const Color(0xFF4A6B5F),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14.0),

                  // ══════════════════════════════════════════════════
                  // 6. BANNIÈRE PROMOTIONNELLE — VAGUES VERTES SANS PHOTO
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 120.0,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006B43), Color(0xFF00B96B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18.0),
                        boxShadow: const [BoxShadow(color: Color(0x20006754), blurRadius: 12.0, offset: Offset(0, 4))],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          // Motifs de vagues décoratifs dans la bannière
                          Positioned(
                            right: -20,
                            bottom: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 40,
                            top: -40,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          // Contenu
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 52.0,
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  child: const Icon(
                                    Icons.medical_services_rounded,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Trouver votre médecin en un clic',
                                        style: GoogleFonts.outfit(fontSize: 15.0, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Rapide • Fiable • Proche de vous',
                                        style: GoogleFonts.outfit(fontSize: 10.5, color: const Color(0xCCFFFFFF), fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.pushNamed(DoctorListWidget.routeName),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                                    child: Text(
                                      'Accéder →',
                                      style: GoogleFonts.outfit(color: const Color(0xFF006B43), fontWeight: FontWeight.bold, fontSize: 12.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14.0),

                  // ══════════════════════════════════════════════════
                  // 7. SAMU (rouge) + MES ORDONNANCES (bleu)
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // SAMU rouge
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFF52235), Color(0xFFFF5252)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [BoxShadow(color: Color(0x22F52235), blurRadius: 8.0, offset: Offset(0, 3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 22.0),
                                    const SizedBox(width: 6.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('SAMU – Urgences', style: GoogleFonts.outfit(fontSize: 12.0, fontWeight: FontWeight.w800, color: Colors.white)),
                                          const SizedBox(height: 2.0),
                                          Text('Appelez en cas d\'urgence vitale', style: GoogleFonts.outfit(fontSize: 8.5, color: const Color(0xE5FFFFFF))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) => GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(context),
                                            child: const EmergencyCallWidget(),
                                          ),
                                        ),
                                      ).then((_) => safeSetState(() {}));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.call_rounded, color: Color(0xFFF52235), size: 12.0),
                                          const SizedBox(width: 4.0),
                                          Text('Appeler', style: GoogleFonts.outfit(color: const Color(0xFFF52235), fontWeight: FontWeight.bold, fontSize: 11.0)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10.0),

                        // Mes Ordonnances — bleu
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF087BE5), Color(0xFF0091FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: const [BoxShadow(color: Color(0x22087BE5), blurRadius: 8.0, offset: Offset(0, 3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22.0),
                                    const SizedBox(width: 6.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Mes Ordonnances\n& Documents', style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
                                          const SizedBox(height: 2.0),
                                          Text('QR Code et comptes-rendus certifiés', style: GoogleFonts.outfit(fontSize: 8.0, color: const Color(0xE5FFFFFF))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10.0),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => context.pushNamed(PatientDocumentsWidget.routeName),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
                                      child: Text('Consulter >', style: GoogleFonts.outfit(color: const Color(0xFF087BE5), fontWeight: FontWeight.bold, fontSize: 11.0)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  // ══════════════════════════════════════════════════
                  // 8. SOS — URGENCE VITALE (violet)
                  // ══════════════════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () async => launchURL('tel:+242067199098'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF7915D8), Color(0xFF9C27B0)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [BoxShadow(color: Color(0x287915D8), blurRadius: 8.0, offset: Offset(0, 3))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46.0,
                              height: 46.0,
                              decoration: const BoxDecoration(color: Color(0x33FFFFFF), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text('SOS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SOS – URGENCE VITALE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 13.5)),
                                  const SizedBox(height: 2.0),
                                  Text('Appelez les secours en 1 seconde', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xE5FFFFFF), fontSize: 11.0)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),
                ],
              ),
            ),

            // ─── BARRE DE NAVIGATION BAS ─────────────────────────────────
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navBarUserModel,
                updateCallback: () => safeSetState(() {}),
                child: const NavBarUserWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  static Widget _buildCircleBtn({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.0,
        height: 36.0,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 4.0, offset: Offset(0, 2))],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }



  static Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10.0)),
              child: Icon(icon, color: Colors.white, size: 20.0),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 12.0, fontWeight: FontWeight.bold, color: const Color(0xFF0D382B))),
                  const SizedBox(height: 1.0),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 9.5, color: const Color(0xFF6B877E))),
                ],
              ),
            ),
            Container(
              width: 22.0,
              height: 22.0,
              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 15.0),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PAINTERS — VAGUES ORGANIQUES VISIBLES & BIEN DÉFINIES
// ════════════════════════════════════════════════════════════════════════════

/// Vagues décoratives vertes fluides et bien visibles
class _WavesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Grande vague 1 : vert très clair (#D9F8E9)
    final path1 = Path();
    path1.moveTo(w * 0.45, 0);
    path1.cubicTo(w * 0.55, h * 0.35, w * 0.70, h * 0.20, w, h * 0.65);
    path1.lineTo(w, 0);
    path1.close();

    final paint1 = Paint()
      ..color = const Color(0xFFD9F8E9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path1, paint1);

    // Grande vague 2 : vert doux (#BCEFD6)
    final path2 = Path();
    path2.moveTo(w * 0.60, 0);
    path2.cubicTo(w * 0.68, h * 0.45, w * 0.82, h * 0.30, w, h * 0.85);
    path2.lineTo(w, 0);
    path2.close();

    final paint2 = Paint()
      ..color = const Color(0xFFBCEFD6).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path2, paint2);

    // Vague 3 : courbe verte fraîche (#A0E6C2)
    final path3 = Path();
    path3.moveTo(w * 0.75, 0);
    path3.cubicTo(w * 0.80, h * 0.30, w * 0.90, h * 0.25, w, h * 0.50);
    path3.lineTo(w, 0);
    path3.close();

    final paint3 = Paint()
      ..color = const Color(0xFFA0E6C2).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pulsation ECG pour le badge cœur
class _PulseLinePainter extends CustomPainter {
  final Color color;
  const _PulseLinePainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.28, size.height * 0.5);
    path.lineTo(size.width * 0.40, size.height * 0.95);
    path.lineTo(size.width * 0.52, size.height * 0.05);
    path.lineTo(size.width * 0.63, size.height * 0.90);
    path.lineTo(size.width * 0.73, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Courbe décorative sous le sous-titre
class _SmileCurvePainter extends CustomPainter {
  final Color color;
  const _SmileCurvePainter({this.color = const Color(0xFF00A86B)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.1)
        ..quadraticBezierTo(size.width * 0.5, size.height * 1.0, size.width, size.height * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
