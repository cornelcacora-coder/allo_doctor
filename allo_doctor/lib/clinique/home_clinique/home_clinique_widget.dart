import '/auth/firebase_auth/auth_util.dart';
import '/auth/role_guard.dart';
import '/components/clinic_member_card_widget.dart';
import '/components/log_out_widget.dart';
import '/components/nav_bar_clinic_widget.dart';
import '/flutter_flow/flutter_flow_choice_chips.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_clinique_model.dart';
export 'home_clinique_model.dart';

class HomeCliniqueWidget extends StatefulWidget {
  const HomeCliniqueWidget({super.key});

  static String routeName = 'HomeClinique';
  static String routePath = '/homeClinique';

  @override
  State<HomeCliniqueWidget> createState() => _HomeCliniqueWidgetState();
}

class _HomeCliniqueWidgetState extends State<HomeCliniqueWidget> {
  late HomeCliniqueModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeCliniqueModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'clinique');
      // Synchronise le doc clinics/{uid} pour la liste patient.
      _syncClinicDocument();
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Crée ou met à jour le document clinics/{uid} dans Firestore
  /// afin que la clinique apparaisse dans la liste patient.
  Future<void> _syncClinicDocument() async {
    final uid = currentUserUid;
    if (uid.isEmpty) return;
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      final userData = userSnap.data() ?? {};
      final practSnap = await FirebaseFirestore.instance
          .collection('practitioners').doc(uid).get();
      final practData = practSnap.data() ?? {};

      final name = ((userData['display_name'] as String?) ??
          (userData['displayName'] as String?) ??
          (userData['name'] as String?) ??
          (practData['name'] as String?) ??
          currentUserDisplayName).trim();
      final address = ((practData['address'] as String?) ??
          (userData['address'] as String?) ?? '').trim();
      final city = ((practData['city'] as String?) ??
          (userData['city'] as String?) ?? 'Brazzaville').trim();
      final phone = ((practData['phone_number'] as String?) ??
          (userData['phone_number'] as String?) ?? '').trim();
      final photoUrl = ((practData['photo_url'] as String?) ??
          (userData['photo_url'] as String?) ?? '').trim();
      final rawServices = practData['services'] ?? userData['services'] ?? practData['specialty'] ?? userData['specialty'];
      final List<dynamic> services = rawServices is List
          ? rawServices
          : (rawServices is String && rawServices.trim().isNotEmpty
              ? [rawServices.trim()]
              : []);

      await FirebaseFirestore.instance
          .collection('clinics').doc(uid).set({
        'name': name.isNotEmpty ? name : 'Clinique',
        'address': address,
        'city': city,
        'phone_number': phone,
        'photo_url': photoUrl,
        'services': services,
        'uid': uid,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('_syncClinicDocument error: $e');
    }
  }


  /// Boîte de dialogue pour ajouter un membre au personnel
  Future<void> _showAddStaffDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedSpec = 'Médecine générale';
    final specs = [
      'Médecine générale',
      'Cardiologie',
      'Pédiatrie',
      'Gynécologie',
      'Urgence',
      'Chirurgie',
      'Ophtalmologie',
      'Biologie / Labo',
      'Radiologie',
      'Administration',
    ];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).warning.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_add_alt_1, color: FlutterFlowTheme.of(context).warning, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                'Nouveau Collaborateur',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nom et Prénom *',
                    hintText: 'Dr. Jean Dupont',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSpec,
                  decoration: InputDecoration(
                    labelText: 'Spécialité *',
                    prefixIcon: const Icon(Icons.medical_services_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: specs.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedSpec = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone (optionnel)',
                    hintText: '+242 06 ...',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler', style: GoogleFonts.outfit(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez renseigner le nom du praticien.')),
                  );
                  return;
                }
                final uid = currentUserUid.isNotEmpty ? currentUserUid : 'current_clinic';
                final clinicName = currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Clinique';

                await FirebaseFirestore.instance
                    .collection('clinics')
                    .doc(uid)
                    .collection('staff')
                    .add({
                  'name': name,
                  'specialty': selectedSpec,
                  'phone': phoneCtrl.text.trim(),
                  'clinic_uid': uid,
                  'clinic_name': clinicName,
                  'is_active': true,
                  'created_at': FieldValue.serverTimestamp(),
                });

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('$name ajouté avec succès au personnel ✓'),
                    backgroundColor: const Color(0xFF16CB83),
                  ));
                }
              },
              child: Text('Enregistrer', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
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
        backgroundColor: const Color(0xFFF7F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F766E),
          automaticallyImplyLeading: false,
          elevation: 2.0,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── LOGO OFFICIEL DE L'APPLICATION + NOM ───
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22.0),
                      child: Image.asset(
                        'assets/images/Logo_Mini-removebg-preview.png',
                        width: 36.0,
                        height: 36.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allô Docteur',
                        style: GoogleFonts.outfit(
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          'ESPACE CLINIQUE',
                          style: GoogleFonts.outfit(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ─── BOUTONS ACTIONS (PARAMÈTRES & DÉCONNEXION) ───
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => context.pushNamed(SettingsWidget.routeName),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(Icons.settings_outlined, color: Colors.white, size: 21.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  InkWell(
                    onTap: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: LogOutWidget(),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38.0,
                      height: 38.0,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.white, size: 21.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ─── HERO BANNER CLINIQUE (Design Médical Moderne) ───
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: currentUserUid.isNotEmpty
                        ? FirebaseFirestore.instance.collection('users').doc(currentUserUid).snapshots()
                        : null,
                    builder: (context, userSnapshot) {
                      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: currentUserUid.isNotEmpty
                            ? FirebaseFirestore.instance.collection('practitioners').doc(currentUserUid).snapshots()
                            : null,
                        builder: (context, practSnapshot) {
                          final userData = userSnapshot.data?.data();
                          final practData = practSnapshot.data?.data();

                          final userStatus = ((userData?['status'] as String?) ?? '').toLowerCase().trim();
                          final practStatus = ((practData?['status'] as String?) ?? '').toLowerCase().trim();

                          final isValidated = userStatus == 'validé' ||
                              userStatus == 'valide' ||
                              userStatus == 'active' ||
                              userData?['isValidated'] == true ||
                              userData?['is_validated'] == true ||
                              practStatus == 'validé' ||
                              practStatus == 'valide' ||
                              practStatus == 'active' ||
                              practData?['isValidated'] == true ||
                              practData?['is_validated'] == true;

                          final rawName = (practData?['name'] as String?) ??
                              (userData?['displayName'] as String?) ??
                              (userData?['name'] as String?) ??
                              (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Clinique Partenaire');
                          final displayName = rawName.trim().isNotEmpty ? rawName.trim() : 'Clinique Partenaire';

                          final photoUrl = (practData?['photo_url'] as String?) ??
                              (userData?['photoUrl'] as String?) ??
                              (userData?['photo_url'] as String?) ??
                              currentUserPhoto;

                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  FlutterFlowTheme.of(context).primary,
                                  const Color(0xFF1E6B52),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 24.0),
                            child: Row(
                              children: [
                                // Avatar / Logo de la clinique
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8.0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30.0),
                                    child: photoUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: photoUrl,
                                            width: 60.0,
                                            height: 60.0,
                                            fit: BoxFit.cover,
                                            errorWidget: (context, url, error) => const Icon(
                                              Icons.local_hospital_rounded,
                                              color: Color(0xFF165C40),
                                              size: 32,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.local_hospital_rounded,
                                            color: Color(0xFF165C40),
                                            size: 32,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                // Nom et Statut
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: isValidated
                                              ? const Color(0xFF16CB83).withOpacity(0.22)
                                              : Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12.0),
                                          border: Border.all(
                                            color: isValidated ? const Color(0xFF16CB83) : Colors.white70,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isValidated ? Icons.verified_rounded : Icons.pending_outlined,
                                              color: isValidated ? const Color(0xFF16CB83) : Colors.white,
                                              size: 14.0,
                                            ),
                                            const SizedBox(width: 5.0),
                                            Text(
                                              isValidated ? 'Clinique Validée' : 'En attente de validation',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 18.0),

                  // ─── STATS CARDS MODERNES (Temps Réel) ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
                      builder: (context, aptSnap) {
                        final docs = aptSnap.data?.docs.where((d) {
                          final data = d.data();
                          final cId = data['clinic_uid'] as String?;
                          final dId = data['doctor_uid'] as String?;
                          return (cId != null && cId == currentUserUid) ||
                              (dId != null && dId == currentUserUid);
                        }).toList() ?? [];
                        final rdvCount = docs.length;
                        final patientIds = docs.map((d) => (d.data()['patient_uid'] ?? d.data()['patient_id'] ?? d.id).toString()).toSet();
                        final patientsCount = patientIds.length;

                        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance.collection('lab_orders').snapshots(),
                          builder: (context, labSnap) {
                            final labDocs = labSnap.data?.docs.where((d) {
                              final data = d.data();
                              final cId = data['clinic_uid'] as String?;
                              return cId != null && cId == currentUserUid;
                            }).toList() ?? [];
                            final analysesCount = labDocs.length;

                            return Row(
                              children: [
                                Expanded(
                                  child: _buildModernStatCard(
                                    context,
                                    label: 'RDV',
                                    count: '$rdvCount',
                                    icon: Icons.calendar_month_rounded,
                                    iconColor: const Color(0xFFE58B00),
                                    bgColor: const Color(0xFFFFF6E6),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildModernStatCard(
                                    context,
                                    label: 'Patients',
                                    count: '$patientsCount',
                                    icon: Icons.people_alt_rounded,
                                    iconColor: const Color(0xFF1B72E8),
                                    bgColor: const Color(0xFFE8F1FC),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildModernStatCard(
                                    context,
                                    label: 'Analyses',
                                    count: '$analysesCount',
                                    icon: Icons.biotech_rounded,
                                    iconColor: const Color(0xFF16CB83),
                                    bgColor: const Color(0xFFE8F8F0),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // ─── CARTE ACTION : AJOUTER UN COLLABORATEUR ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () => _showAddStaffDialog(context),
                      borderRadius: BorderRadius.circular(14.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(color: FlutterFlowTheme.of(context).warning.withOpacity(0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 44.0,
                              height: 44.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).warning.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Icon(
                                Icons.person_add_alt_1_rounded,
                                color: FlutterFlowTheme.of(context).warning,
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 14.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nouveau Collaborateur',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: FlutterFlowTheme.of(context).primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    'Ajouter un médecin ou praticien à votre clinique',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12.0,
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 16.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // ─── BARRE DE RECHERCHE ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: FlutterFlowTheme.of(context).secondaryText, size: 22.0),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextFormField(
                              controller: _model.textController,
                              focusNode: _model.textFieldFocusNode,
                              onChanged: (_) => safeSetState(() {}),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Rechercher un praticien, spécialité...',
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              style: GoogleFonts.outfit(fontSize: 14.0),
                            ),
                          ),
                          if (_model.textController?.text.isNotEmpty == true)
                            InkWell(
                              onTap: () {
                                _model.textController?.clear();
                                safeSetState(() {});
                              },
                              child: const Icon(Icons.close_rounded, size: 18.0, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12.0),

                  // ─── CHIPS FILTRES SPÉCIALITÉS ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FlutterFlowChoiceChips(
                      options: const [
                        ChipData('Personnel'),
                        ChipData('Cardiologie'),
                        ChipData('Gynécologie'),
                        ChipData('Urgence'),
                        ChipData('Pédiatrie'),
                        ChipData('Médecine générale'),
                        ChipData('Ophtalmologie'),
                        ChipData('Chirurgie'),
                      ],
                      onChanged: (val) => safeSetState(() => _model.choiceChipsValue = val?.firstOrNull),
                      selectedChipStyle: ChipStyle(
                        backgroundColor: const Color(0xFF0F766E),
                        textStyle: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                        iconColor: Colors.white,
                        iconSize: 14.0,
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      unselectedChipStyle: ChipStyle(
                        backgroundColor: Colors.white,
                        textStyle: GoogleFonts.outfit(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                        iconColor: FlutterFlowTheme.of(context).secondaryText,
                        iconSize: 14.0,
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      chipSpacing: 8.0,
                      rowSpacing: 8.0,
                      multiselect: false,
                      alignment: WrapAlignment.start,
                      controller: _model.choiceChipsValueController ??= FormFieldController<List<String>>([]),
                      wrapped: true,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // ─── TITRE SECTION : ÉQUIPE MÉDICALE ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ÉQUIPE DU PERSONNEL',
                          style: GoogleFonts.outfit(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10.0),

                  // ─── LISTE DYNAMIQUE DU PERSONNEL ───
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: currentUserUid.isNotEmpty
                          ? FirebaseFirestore.instance
                              .collection('clinics')
                              .doc(currentUserUid)
                              .collection('staff')
                              .snapshots()
                          : Stream.empty(),
                      builder: (context, staffSnap) {
                        if (staffSnap.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(color: FlutterFlowTheme.of(context).warning),
                            ),
                          );
                        }

                        final docs = staffSnap.data?.docs ?? [];
                        final searchQ = _model.textController?.text.trim().toLowerCase() ?? '';
                        final selectedCategory = _model.choiceChipsValue;

                        final filtered = docs.where((d) {
                          final data = d.data();
                          final name = (data['name'] as String? ?? '').toLowerCase();
                          final spec = (data['specialty'] as String? ?? '').toLowerCase();
                          if (searchQ.isNotEmpty && !name.contains(searchQ) && !spec.contains(searchQ)) {
                            return false;
                          }
                          if (selectedCategory != null &&
                              selectedCategory.isNotEmpty &&
                              selectedCategory != 'Personnel') {
                            if (!spec.contains(selectedCategory.toLowerCase())) {
                              return false;
                            }
                          }
                          return true;
                        }).toList();

                        if (filtered.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                            ),
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.group_outlined, size: 48, color: FlutterFlowTheme.of(context).secondaryText),
                                const SizedBox(height: 12.0),
                                Text(
                                  docs.isEmpty
                                      ? 'Aucun membre enregistré dans votre personnel'
                                      : 'Aucun collaborateur ne correspond à votre recherche',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.0,
                                    color: FlutterFlowTheme.of(context).secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F766E),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  onPressed: () => _showAddStaffDialog(context),
                                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                                  label: Text(
                                    'Ajouter un collaborateur',
                                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10.0),
                          itemBuilder: (context, index) {
                            final staffDoc = filtered[index];
                            final data = staffDoc.data();
                            final staffId = staffDoc.id;
                            final name = (data['name'] as String?) ?? 'Praticien';
                            final specialty = (data['specialty'] as String?) ?? 'Médecine générale';
                            final photo = (data['photo_url'] as String?);
                            final phone = (data['phone'] as String?) ?? '';
                            final isActive = (data['is_active'] as bool?) ?? true;

                            return ClinicMemberCardWidget(
                              name: name,
                              specialty: specialty,
                              photoProfile: photo,
                              isActive: isActive,
                              onDelete: () async {
                                if (currentUserUid.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('clinics')
                                      .doc(currentUserUid)
                                      .collection('staff')
                                      .doc(staffId)
                                      .delete();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$name a été retiré.')),
                                    );
                                  }
                                }
                              },
                              onToggleActive: (newVal) async {
                                if (currentUserUid.isNotEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('clinics')
                                      .doc(currentUserUid)
                                      .collection('staff')
                                      .doc(staffId)
                                      .update({'is_active': newVal});
                                }
                              },
                              contactClinic: () async {
                                if (phone.isNotEmpty) {
                                  await launchURL('tel:$phone');
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 110.0), // Marge pour la barre de navigation
                ],
              ),
            ),

            // ─── NAVBAR FLOTTANTE ───
            Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: wrapWithModel(
                  model: _model.navBarClinicModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarClinicWidget(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard(
    BuildContext context, {
    required String label,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            count,
            style: GoogleFonts.outfit(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
