import '/components/log_out_widget.dart';
import '/components/stateitem_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '/auth/firebase_auth/auth_util.dart';
import '/components/avatar_image_widget.dart';
export 'home_doctor_model.dart';

class HomeDoctorWidget extends StatefulWidget {
  const HomeDoctorWidget({super.key});

  static String routeName = 'HomeDoctor';
  static String routePath = '/homeDoctor';

  @override
  State<HomeDoctorWidget> createState() => _HomeDoctorWidgetState();
}

class _HomeDoctorWidgetState extends State<HomeDoctorWidget> {
  late HomeDoctorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _appointmentsStream;
  String? _lastLoadedUid;

  void _initStreams() {
    final uid = currentUserUid;
    if (uid.isNotEmpty && uid != _lastLoadedUid) {
      _lastLoadedUid = uid;
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots();
      _appointmentsStream = FirebaseFirestore.instance
          .collection('appointments')
          .snapshots();
    } else if (uid.isEmpty) {
      _lastLoadedUid = null;
      _userStream = null;
      _appointmentsStream = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeDoctorModel());

    _model.switchValue = true;
    _initStreams();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Garde-fou : cet espace est reserve aux comptes medecins.
      await guardRole(context, 'medecin');
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  
  Future<void> _changeDoctorPhoto(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 800,
      );
      if (pickedFile == null) return;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FlutterFlowTheme.of(context).primary,
                  ),
                ),
                SizedBox(height: 16),
                Text('Envoi de la photo en cours...', style: GoogleFonts.outfit(fontSize: 14)),
              ],
            ),
          ),
        ),
      );

      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final photoDataUri = 'data:image/jpeg;base64,$base64String';

      // Use set+merge so it works even if the doc doesn't exist yet
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).set({
        'photo_url': photoDataUri,
        'photoUrl': photoDataUri,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Force the user stream to re-init so the StreamBuilder picks up the new photo
      _lastLoadedUid = null;
      _initStreams();

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo mise a jour avec succes !'),
            backgroundColor: Color(0xFF16CB83),
          ),
        );
      }
      safeSetState(() {});
    } catch (e) {
      if (context.mounted) {
        // Dismiss the loading dialog if it's showing
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du changement de photo : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  Future<void> _editDoctorInfoDialog(BuildContext context, Map<String, dynamic>? data) async {
    final currentName = (data?['displayName'] as String?)?.trim().isNotEmpty == true
        ? data!['displayName'] as String
        : ((data?['display_name'] as String?)?.trim().isNotEmpty == true
            ? data!['display_name'] as String
            : currentUserDisplayName);
    final nameController = TextEditingController(text: currentName);
    final specialtyController = TextEditingController(
      text: (data?['specialty'] as String?) ?? 'Medecin Praticien',
    );
    final bioController = TextEditingController(
      text: (data?['bio'] as String?) ?? 'Praticien medical certifie sur Allo Docteur.',
    );
    final feeTeleconsultController = TextEditingController(
      text: (data?['feeTeleconsult'] as String?) ?? '2000',
    );
    final feeHomeController = TextEditingController(
      text: (data?['feeHome'] as String?) ?? '2000',
    );
    final languagesController = TextEditingController(
      text: (data?['languages'] as String?) ?? 'Francais, Lingala',
    );
    final slotsController = TextEditingController(
      text: (data?['slots'] as String?) ?? '8h - 14h',
    );

    final rawStatus = ((data?['status'] as String?) ?? '').toLowerCase().trim();
    bool isValidatedChoice = rawStatus == 'valide' ||
        rawStatus == 'validé' ||
        rawStatus == 'active' ||
        rawStatus == 'approuve' ||
        rawStatus == 'approuvé' ||
        rawStatus == 'approved' ||
        data?['isValidated'] == true;

    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(ctx).secondaryBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Modifier mes informations',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FlutterFlowTheme.of(ctx).primaryText,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom et Prénom',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: specialtyController,
                  decoration: InputDecoration(
                    labelText: 'Spécialité médicale',
                    prefixIcon: Icon(Icons.medical_services_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'À propos de vous (Bio)',
                    prefixIcon: Icon(Icons.info_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: feeTeleconsultController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Téléconsultation (F CFA)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: feeHomeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'À domicile (F CFA)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TextField(
                  controller: languagesController,
                  decoration: InputDecoration(
                    labelText: 'Langues parlées',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: slotsController,
                  decoration: InputDecoration(
                    labelText: 'Créneaux & Horaires (ex: 8h - 14h)',
                    prefixIcon: Icon(Icons.schedule),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 14),
                // Statut de validation (géré uniquement par l'administrateur)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isValidatedChoice ? Color(0xFFE8F8F0) : Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isValidatedChoice ? Color(0xFF16CB83) : Color(0xFFE67E22),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isValidatedChoice ? Icons.verified_rounded : Icons.pending_outlined,
                        color: isValidatedChoice ? Color(0xFF16CB83) : Color(0xFFE67E22),
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isValidatedChoice ? 'Compte validé par l\'administrateur' : 'Compte en attente de validation',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isValidatedChoice ? Color(0xFF16CB83) : Color(0xFFE67E22),
                              ),
                            ),
                            Text(
                              isValidatedChoice
                                  ? 'Votre compte médecin est actif et visible pour les patients.'
                                  : 'La validation est réservée à l\'administrateur pour des raisons de conformité.',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: FlutterFlowTheme.of(ctx).secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Icon(Icons.check, color: Colors.white),
                    label: Text(
                      isSaving ? 'Enregistrement...' : 'Enregistrer les modifications',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(ctx).tertiary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final uid = currentUserUid.isNotEmpty ? currentUserUid : (currentUser?.uid ?? '');
                            if (uid.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: utilisateur non connecté')),
                              );
                              return;
                            }
                            setModalState(() => isSaving = true);
                            try {
                              final existingStatus = (data?['status'] as String?) ?? 'en_attente';
                              final existingIsValidated = data?['isValidated'] ?? (existingStatus == 'valide' || existingStatus == 'validé' || existingStatus == 'active');

                              final updatePayload = {
                                'displayName': nameController.text.trim(),
                                'display_name': nameController.text.trim(),
                                'specialty': specialtyController.text.trim(),
                                'bio': bioController.text.trim(),
                                'feeTeleconsult': feeTeleconsultController.text.trim(),
                                'feeHome': feeHomeController.text.trim(),
                                'languages': languagesController.text.trim(),
                                'slots': slotsController.text.trim(),
                                'status': existingStatus,
                                'isValidated': existingIsValidated,
                                'updated_at': FieldValue.serverTimestamp(),
                              };

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .set(updatePayload, SetOptions(merge: true));

                              await FirebaseFirestore.instance
                                  .collection('User')
                                  .doc(uid)
                                  .set(updatePayload, SetOptions(merge: true));

                              try {
                                await currentUser?.updateDisplayName(nameController.text.trim());
                              } catch (_) {}

                              _lastLoadedUid = null;
                              _initStreams();

                              if (ctx.mounted) Navigator.pop(modalCtx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Informations enregistrées avec succès !'),
                                    backgroundColor: Color(0xFF16CB83),
                                  ),
                                );
                              }
                              safeSetState(() {});
                            } catch (err) {
                              setModalState(() => isSaving = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur lors de l\'enregistrement : $err'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initStreams();

    if (currentUserUid.isEmpty) {
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).tertiary,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 45.0,
                        height: 45.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).surface15,
                          borderRadius: BorderRadius.circular(12.0),
                          shape: BoxShape.rectangle,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 5.0, 0.0, 0.0),
                                child: Container(
                                  width: 25.0,
                                  height: 25.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 2.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0.0),
                                child: Image.asset(
                                  'assets/images/Logo_Mini-removebg-preview.png',
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Allô Docteur',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .fontStyle,
                              ),
                              color: Colors.white,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .titleLarge
                                  .fontStyle,
                              lineHeight: 1.4,
                            ),
                      ),
                    ].divide(SizedBox(width: 10.0)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FlutterFlowIconButton(
                        borderRadius: 10.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).surface15,
                        icon: Icon(
                          Icons.settings_outlined,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          context.pushNamed(SettingsWidget.routeName);
                        },
                      ),
                      FlutterFlowIconButton(
                        borderRadius: 10.0,
                        buttonSize: 40.0,
                        fillColor: FlutterFlowTheme.of(context).surface15,
                        icon: Icon(
                          Icons.logout_rounded,
                          color: FlutterFlowTheme.of(context).onPrimary,
                          size: 24.0,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                child: Padding(
                                  padding: MediaQuery.viewInsetsOf(context),
                                  child: LogOutWidget(),
                                ),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        },
                      ),
                    ].divide(SizedBox(width: 8.0)),
                  ),
                ],
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 4.0,
        ),
        body: Container(
          height: double.infinity,
          child: Stack(
            alignment: AlignmentDirectional(0.0, -1.0),
            children: [
              SingleChildScrollView(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _userStream,
                  builder: (context, userSnap) {
                    final data = userSnap.data?.data();
                    final displayName = (data?['displayName'] as String?)?.trim().isNotEmpty == true
                        ? data!['displayName'] as String
                        : ((data?['display_name'] as String?)?.trim().isNotEmpty == true
                            ? data!['display_name'] as String
                            : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Docteur'));
                    final photoUrl = (data?['photoUrl'] as String?) ?? (data?['photo_url'] as String?) ?? currentUserPhoto;
                    final specialty = (data?['specialty'] as String?)?.trim().isNotEmpty == true
                        ? data!['specialty'] as String
                        : 'Medecin Praticien';
                    final rawStatus = ((data?['status'] as String?) ?? '').toLowerCase().trim();
                    final isValidated = rawStatus == 'valide' ||
                        rawStatus == 'validé' ||
                        rawStatus == 'active' ||
                        rawStatus == 'approuve' ||
                        rawStatus == 'approuvé' ||
                        rawStatus == 'approved' ||
                        rawStatus == 'confirme' ||
                        rawStatus == 'confirmé' ||
                        data?['isValidated'] == true ||
                        data?['is_validated'] == true;
                    final bio = (data?['bio'] as String?)?.trim().isNotEmpty == true
                        ? data!['bio'] as String
                        : 'Praticien medical certifie sur Allo Docteur.';
                    final feeTeleconsult = (data?['feeTeleconsult'] as String?)?.trim().isNotEmpty == true
                        ? data!['feeTeleconsult'] as String
                        : '2000';
                    final feeHome = (data?['feeHome'] as String?)?.trim().isNotEmpty == true
                        ? data!['feeHome'] as String
                        : '2000';
                    final languages = (data?['languages'] as String?)?.trim().isNotEmpty == true
                        ? data!['languages'] as String
                        : 'Francais, Lingala';
                    final slots = (data?['slots'] as String?)?.trim().isNotEmpty == true
                        ? data!['slots'] as String
                        : '8h - 14h';

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _appointmentsStream,
                      builder: (context, aptSnap) {
                        final allApts = aptSnap.data?.docs ?? [];
                        // Filtrer les rendez-vous du medecin
                        final doctorApts = allApts.where((doc) {
                          final a = doc.data();
                          final docId = (a['doctor_id'] as String?) ?? '';
                          final docName = (a['doctor_name'] as String?) ?? '';
                          if (docId.isNotEmpty && currentUserUid.isNotEmpty && docId == currentUserUid) return true;
                          if (docName.isNotEmpty && displayName.isNotEmpty && docName.toLowerCase() == displayName.toLowerCase()) return true;
                          return docId.isEmpty && docName.isEmpty;
                        }).toList();

                        // Trier par created_at descendant
                        doctorApts.sort((a, b) {
                          final tA = a.data()['created_at'];
                          final tB = b.data()['created_at'];
                          if (tA is Timestamp && tB is Timestamp) return tB.compareTo(tA);
                          return 0;
                        });

                        final rdvCount = doctorApts.where((d) => d.data()['status'] != 'cancelled').length;
                        final domicileCount = doctorApts.where((d) => d.data()['consult_mode'] == 'domicile').length;

                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // ─── AVATAR CLICABLE (GALERIE) & BADGE CAMERA ───
                            Align(
                              alignment: AlignmentDirectional(0.0, 1.0),
                              child: InkWell(
                                onTap: () => _changeDoctorPhoto(context),
                                borderRadius: BorderRadius.circular(50.0),
                                child: Stack(
                                  alignment: AlignmentDirectional(1.0, 1.0),
                                  children: [
                                    Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: ClipOval(
                                          child: AvatarImageWidget(
                                            imageUrl: photoUrl,
                                            width: 96.0,
                                            height: 96.0,
                                            fit: BoxFit.cover,
                                            placeholder: Container(
                                              width: 96.0,
                                              height: 96.0,
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primary,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'D',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontSize: 38.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 32.0,
                                      height: 32.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).secondaryBackground,
                                          width: 2.0,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ─── NOM, SPECIALITE ET BOUTON EDITER ───
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    displayName,
                                    style: FlutterFlowTheme.of(context).headlineSmall.override(
                                          font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                          color: FlutterFlowTheme.of(context).primaryText,
                                          fontSize: 22.0,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.0),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isValidated ? Icons.verified_rounded : Icons.pending_outlined,
                                        color: isValidated ? Color(0xFF16CB83) : Color(0xFFE67E22),
                                        size: 16.0,
                                      ),
                                      Text(
                                        isValidated
                                            ? '$specialty • Compte Validé'
                                            : '$specialty • En attente de validation',
                                        style: FlutterFlowTheme.of(context).labelMedium.override(
                                              font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                              color: isValidated ? Color(0xFF16CB83) : Color(0xFFE67E22),
                                              fontSize: 13.0,
                                            ),
                                      ),
                                    ].divide(SizedBox(width: 4.0)),
                                  ),
                                  SizedBox(height: 8.0),
                                  InkWell(
                                    onTap: () => _editDoctorInfoDialog(context, data),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).tertiary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20.0),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).tertiary.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 16.0,
                                            color: FlutterFlowTheme.of(context).tertiary,
                                          ),
                                          SizedBox(width: 6.0),
                                          Text(
                                            'Modifier mon profil',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w600,
                                              color: FlutterFlowTheme.of(context).tertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ─── STATISTIQUES EN TEMPS REEL ───
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40.0,
                                  child: wrapWithModel(
                                    model: _model.stateitemModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StateitemWidget(
                                      label: 'RDV',
                                      count: '$rdvCount',
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 40.0,
                                  decoration: BoxDecoration(),
                                  child: wrapWithModel(
                                    model: _model.stateitemModel2,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StateitemWidget(
                                      label: 'Horaire',
                                      count: slots.isNotEmpty ? slots : '8h - 14h',
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 40.0,
                                  decoration: BoxDecoration(),
                                  child: wrapWithModel(
                                    model: _model.stateitemModel3,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StateitemWidget(
                                      label: 'Domicile',
                                      count: '$domicileCount',
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 32.0)),
                            ),

                            // ─── DISPONIBILITE SWITCH ───
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(14.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.perm_contact_cal,
                                                    color: FlutterFlowTheme.of(context).tertiary,
                                                    size: 22.0,
                                                  ),
                                                  Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Disponibilite',
                                                        style: FlutterFlowTheme.of(context).bodySmall.override(
                                                              font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                              color: FlutterFlowTheme.of(context).tertiary,
                                                              fontSize: 12.0,
                                                            ),
                                                      ),
                                                      Text(
                                                        _model.switchValue! ? 'Actuellement disponible' : 'Actuellement indisponible',
                                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                                              font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                              color: FlutterFlowTheme.of(context).secondaryText,
                                                              fontSize: 10.0,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ].divide(SizedBox(width: 8.0)),
                                              ),
                                              Switch.adaptive(
                                                value: _model.switchValue!,
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model.switchValue = newValue);
                                                  if (currentUserUid.isNotEmpty) {
                                                    await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
                                                      'is_available': newValue,
                                                    });
                                                  }
                                                },
                                                activeColor: FlutterFlowTheme.of(context).primary,
                                                activeTrackColor: FlutterFlowTheme.of(context).accent2,
                                                inactiveTrackColor: FlutterFlowTheme.of(context).alternate,
                                                inactiveThumbColor: FlutterFlowTheme.of(context).secondaryBackground,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ─── A PROPOS DE VOUS (DYNAMIQUE) ───
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'A propos de vous',
                                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                  font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                  fontSize: 14.0,
                                                ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                            onPressed: () => _editDoctorInfoDialog(context, data),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        bio,
                                        style: FlutterFlowTheme.of(context).labelSmall.override(
                                              font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                              fontSize: 12.0,
                                            ),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 6,
                                        children: languages.split(',').map((lang) => Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.translate, color: Color(0xFF8A0DCE), size: 16.0),
                                            SizedBox(width: 4),
                                            Text(
                                              lang.trim(),
                                              style: FlutterFlowTheme.of(context).bodySmall.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                    color: Color(0xFF8A0DCE),
                                                    fontSize: 12.0,
                                                  ),
                                            ),
                                          ],
                                        )).toList(),
                                      ),
                                    ].divide(SizedBox(height: 6.0)),
                                  ),
                                ),
                              ),
                            ),

                            // ─── TARIFS (DYNAMIQUES) ───
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tarif',
                                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                  font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                  fontSize: 14.0,
                                                ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                            onPressed: () => _editDoctorInfoDialog(context, data),
                                          ),
                                        ],
                                      ),
                                      // Teleconsultation
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(14.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.local_hospital_outlined, color: FlutterFlowTheme.of(context).tertiary, size: 22.0),
                                                  SizedBox(width: 6),
                                                  Text('TELECONSULTATION', style: FlutterFlowTheme.of(context).bodySmall.override(font: GoogleFonts.outfit(fontWeight: FontWeight.w500), color: FlutterFlowTheme.of(context).tertiary, fontSize: 12.0)),
                                                ],
                                              ),
                                              Container(
                                                decoration: BoxDecoration(color: FlutterFlowTheme.of(context).accent2, borderRadius: BorderRadius.circular(6.0)),
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text('$feeTeleconsult F CFA', style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.outfit(fontWeight: FontWeight.w600), color: FlutterFlowTheme.of(context).success, fontSize: 12.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      // A domicile
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(14.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.home_outlined, color: FlutterFlowTheme.of(context).tertiary, size: 22.0),
                                                  SizedBox(width: 6),
                                                  Text('A DOMICILE', style: FlutterFlowTheme.of(context).bodySmall.override(font: GoogleFonts.outfit(fontWeight: FontWeight.w500), color: FlutterFlowTheme.of(context).tertiary, fontSize: 12.0)),
                                                ],
                                              ),
                                              Container(
                                                decoration: BoxDecoration(color: FlutterFlowTheme.of(context).accent2, borderRadius: BorderRadius.circular(6.0)),
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Text('$feeHome F CFA', style: FlutterFlowTheme.of(context).bodyMedium.override(font: GoogleFonts.outfit(fontWeight: FontWeight.w600), color: FlutterFlowTheme.of(context).success, fontSize: 12.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // ─── CRENEAUX & HORAIRES (DYNAMIQUES) ───
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Creneau & Disponibilites',
                                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                  font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                  fontSize: 14.0,
                                                ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, size: 16, color: FlutterFlowTheme.of(context).secondaryText),
                                            onPressed: () => _editDoctorInfoDialog(context, data),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).primaryBackground,
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        padding: EdgeInsets.all(14.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_month_rounded, color: Color(0xFF8A0DCE), size: 20.0),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                slots,
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: FlutterFlowTheme.of(context).primaryText,
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
                            ),

                            // ─── NOUVEAU: DEMANDES DE RENDEZ-VOUS REÇUES DU PATIENT ───
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context).alternate,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.assignment_ind_outlined, color: FlutterFlowTheme.of(context).primary, size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                'Demandes des Patients',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: FlutterFlowTheme.of(context).primaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: FlutterFlowTheme.of(context).primary.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${doctorApts.length} total',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: FlutterFlowTheme.of(context).primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                      if (doctorApts.isEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Icon(Icons.event_available, size: 40, color: FlutterFlowTheme.of(context).secondaryText),
                                              SizedBox(height: 8),
                                              Text(
                                                'Aucun rendez-vous pour le moment',
                                                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Les rendez-vous pris par vos patients apparaitront ici en temps reel.',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.outfit(fontSize: 12, color: FlutterFlowTheme.of(context).secondaryText),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          primary: false,
                                          itemCount: doctorApts.length > 5 ? 5 : doctorApts.length,
                                          separatorBuilder: (_, __) => SizedBox(height: 10),
                                          itemBuilder: (ctx, idx) {
                                            final aptDoc = doctorApts[idx];
                                            final apt = aptDoc.data();
                                            final patientName = (apt['patient_name'] as String?)?.trim().isNotEmpty == true
                                                ? apt['patient_name'] as String
                                                : 'Patient';
                                            final consultMode = (apt['consult_mode'] as String?) ?? 'cabinet';
                                            final day = (apt['day'] as String?) ?? 'Date a definir';
                                            final timeSlot = (apt['time_slot'] as String?) ?? '';
                                            final aptStatus = (apt['status'] as String?) ?? 'pending';

                                            Color statusColor;
                                            String statusLabel;
                                            if (aptStatus == 'confirmed') {
                                              statusColor = Color(0xFF16CB83);
                                              statusLabel = 'Confirme';
                                            } else if (aptStatus == 'cancelled') {
                                              statusColor = Colors.red;
                                              statusLabel = 'Refuse';
                                            } else if (aptStatus == 'completed') {
                                              statusColor = Color(0xFF8A0DCE);
                                              statusLabel = 'Termine';
                                            } else {
                                              statusColor = Color(0xFFBF9719);
                                              statusLabel = 'En attente';
                                            }

                                            return Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: FlutterFlowTheme.of(context).primaryBackground,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: FlutterFlowTheme.of(context).alternate,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor: FlutterFlowTheme.of(context).primary,
                                                            child: Text(
                                                              patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                patientName,
                                                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                                                              ),
                                                              Text(
                                                                consultMode == 'domicile'
                                                                    ? 'A Domicile'
                                                                    : (consultMode == 'teleconsultation' ? 'Teleconsultation' : 'Au Cabinet'),
                                                                style: GoogleFonts.outfit(fontSize: 11, color: FlutterFlowTheme.of(context).secondaryText),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: statusColor.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Text(
                                                          statusLabel,
                                                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.calendar_today, size: 12, color: FlutterFlowTheme.of(context).secondaryText),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        timeSlot.isNotEmpty ? '$day • $timeSlot' : day,
                                                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                  if (aptStatus == 'pending') ...[
                                                    SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: ElevatedButton.icon(
                                                            icon: Icon(Icons.check, size: 14, color: Colors.white),
                                                            label: Text('Accepter', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Color(0xFF16CB83),
                                                              padding: EdgeInsets.symmetric(vertical: 6),
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                            ),
                                                            onPressed: () async {
                                                              await aptDoc.reference.update({'status': 'confirmed', 'updated_at': FieldValue.serverTimestamp()});
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Rendez-vous confirme !'), backgroundColor: Color(0xFF16CB83)),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: OutlinedButton.icon(
                                                            icon: Icon(Icons.close, size: 14, color: Colors.red),
                                                            label: Text('Refuser', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                                            style: OutlinedButton.styleFrom(
                                                              side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                                              padding: EdgeInsets.symmetric(vertical: 6),
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                            ),
                                                            onPressed: () async {
                                                              await aptDoc.reference.update({'status': 'cancelled', 'updated_at': FieldValue.serverTimestamp()});
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Rendez-vous refuse.'), backgroundColor: Colors.red),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              height: 100.0,
                              decoration: BoxDecoration(),
                            ),
                          ]
                              .divide(SizedBox(height: 16.0))
                              .addToStart(SizedBox(height: 24.0))
                              .addToEnd(SizedBox(height: 10.0)),
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(),
                    child: Container(
                      height: 72.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(9999.0),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 1.0,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        child: Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context
                                        .pushNamed(HomeDoctorWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.home_rounded,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Accueil',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                        ConsultationWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.personal_video,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Consultation',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: 0.0 * (math.pi / 180),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(
                                      ProfileEditWidget.routeName,
                                      queryParameters: {
                                        'role': serializeParam(
                                          'Doctor',
                                          ParamType.String,
                                        ),
                                      }.withoutNulls,
                                    );
                                  },
                                  child: Container(
                                    width: 56.0,
                                    height: 56.0,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        FlutterFlowTheme.of(context)
                                            .designToken
                                            .shadow
                                            .lg
                                      ],
                                      gradient: LinearGradient(
                                        colors: [
                                          FlutterFlowTheme.of(context).primary,
                                          Color(0xFF0EE796)
                                        ],
                                        stops: [0.0, 1.0],
                                        begin: AlignmentDirectional(1.0, -1.0),
                                        end: AlignmentDirectional(-1.0, 1.0),
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(9999.0),
                                      shape: BoxShape.rectangle,
                                    ),
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Icon(
                                      Icons.edit_calendar_rounded,
                                      color: FlutterFlowTheme.of(context)
                                          .onPrimary,
                                      size: 28.0,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(VisiteWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.store_rounded,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Visite',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    context.pushNamed(AgendaWidget.routeName);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bookmarks_outlined,
                                        size: 24.0,
                                      ),
                                      Text(
                                        'Agenda',
                                        style: FlutterFlowTheme.of(context)
                                            .labelSmall
                                            .override(
                                              font: GoogleFonts.outfit(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelSmall
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelSmall
                                                      .fontStyle,
                                              lineHeight: 1.4,
                                            ),
                                      ),
                                    ].divide(SizedBox(height: 4.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
