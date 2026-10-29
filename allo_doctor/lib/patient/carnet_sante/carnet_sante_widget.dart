import '/components/patient_appointments_widget.dart';
import '/components/patient_prescriptions_widget.dart';
import '/components/notification_bell_widget.dart';
import '/components/offline_banner_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'dart:ui';
import '/components/avatar_image_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/patient/patient_documents/patient_documents_widget.dart';
import 'carnet_sante_model.dart';
export 'carnet_sante_model.dart';

class CarnetSanteWidget extends StatefulWidget {
  const CarnetSanteWidget({super.key});

  static String routeName = 'CarnetSante';
  static String routePath = '/carnetSante';

  @override
  State<CarnetSanteWidget> createState() => _CarnetSanteWidgetState();
}

class _CarnetSanteWidgetState extends State<CarnetSanteWidget> {
  late CarnetSanteModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CarnetSanteModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  
  Future<void> _changePhotoDialog(BuildContext context) async {
    final controller = TextEditingController(text: currentUserPhoto);
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Modifier ma photo', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entrez le lien d\'une image ou choisissez un avatar :', style: GoogleFonts.outfit(fontSize: 13)),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://...',
                labelText: 'URL de votre photo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            SizedBox(height: 14),
            Text('Avatars disponibles :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                'https://ui-avatars.com/api/?name=Patient+A&background=1a6b3c&color=fff&size=200',
                'https://ui-avatars.com/api/?name=Patient+B&background=0d47a1&color=fff&size=200',
                'https://ui-avatars.com/api/?name=Patient+C&background=6a1b9a&color=fff&size=200',
                'https://ui-avatars.com/api/?name=Patient+D&background=c62828&color=fff&size=200',
              ].map((url) => InkWell(
                onTap: () {
                  controller.text = url;
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(url),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (chosen != null && chosen.isNotEmpty && currentUserUid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'photoUrl': chosen,
        'photo_url': chosen,
      });
      try {
        await currentUser?.updatePhotoURL(chosen);
      } catch (_) {}
      safeSetState(() {});
    }
  }

  Future<void> _updateBloodGroup(String bg) async {
    if (currentUserUid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).set({
        'bloodGroup': bg,
        'blood_group': bg,
        'groupe_sanguin': bg,
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Groupe sanguin mis à jour : $bg'),
            backgroundColor: const Color(0xFF165AC5),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addMedicalItem(String fieldName, TextEditingController? controller, String title) async {
    final text = controller?.text.trim() ?? '';
    if (text.isEmpty) return;
    if (currentUserUid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).set({
        fieldName: FieldValue.arrayUnion([text]),
      }, SetOptions(merge: true));
      controller?.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title ajouté avec succès !'),
            backgroundColor: const Color(0xFF16C583),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _removeMedicalItem(String fieldName, String item, String label) async {
    if (currentUserUid.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer "$item" de vos $label ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(currentUserUid).set({
          fieldName: FieldValue.arrayRemove([item]),
        }, SetOptions(merge: true));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildEditableMedicalSection({
    required BuildContext context,
    required String title,
    required String emptyLabel,
    required String fieldName,
    required List<String> items,
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String hintText,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                    ),
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10.0),
            if (items.isNotEmpty)
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: items.map((item) {
                  return Container(
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).accent2,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: const EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 8.0, 5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).success,
                                fontSize: 12.0,
                              ),
                        ),
                        const SizedBox(width: 6.0),
                        InkWell(
                          onTap: () => _removeMedicalItem(fieldName, item, title),
                          child: Icon(
                            Icons.close,
                            size: 14.0,
                            color: FlutterFlowTheme.of(context).success.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text(
                emptyLabel,
                style: FlutterFlowTheme.of(context).labelSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                      ),
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            const SizedBox(height: 10.0),
            Divider(
              height: 16.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).alternate,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: false,
                    obscureText: false,
                    onFieldSubmitted: (_) => _addMedicalItem(fieldName, controller, title),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: hintText,
                      hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                          ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF165AC5),
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF165AC5),
                          width: 2.0,
                        ),
                      ),
                      filled: true,
                      fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium,
                  ),
                ),
                const SizedBox(width: 10.0),
                InkWell(
                  onTap: () => _addMedicalItem(fieldName, controller, title),
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    width: 85.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1458), Color(0xFF165AC5)],
                        begin: AlignmentDirectional(1.0, -1.0),
                        end: AlignmentDirectional(-1.0, 1.0),
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Ajouter',
                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                        ),
                        const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Color(0xFF165AC5),
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.safePop();
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: FlutterFlowTheme.of(context).alternate,
                      size: 24.0,
                    ),
                  ),
                  Text(
                    'Mon Carnet Sante',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .titleLarge
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).alternate,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleLarge.fontStyle,
                          lineHeight: 1.4,
                        ),
                  ),
                  Icon(
                    Icons.more_vert_sharp,
                    color: FlutterFlowTheme.of(context).alternate,
                    size: 24.0,
                  ),
                ],
              ),
            ].divide(SizedBox(height: 10.0)),
          ),
          actions: [],
          centerTitle: false,
          elevation: 4.0,
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: currentUserUid.isNotEmpty
              ? FirebaseFirestore.instance.collection('users').doc(currentUserUid).snapshots()
              : null,
          builder: (context, userSnap) {
            final userData = userSnap.data?.data();
            final displayName = (userData?['displayName'] as String?)?.trim().isNotEmpty == true
                ? userData!['displayName'] as String
                : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'BITODI Cornelca Cora');
            final photoUrl = (userData?['photoUrl'] as String?) ?? currentUserPhoto;
            final allergies = (userData?['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
            final antecedents = (userData?['antecedents'] as List<dynamic>?)?.cast<String>() ??
                (userData?['maladies'] as List<dynamic>?)?.cast<String>() ?? [];
            final traitements = (userData?['traitements'] as List<dynamic>?)?.cast<String>() ?? [];
            final bloodGroup = ((userData?['bloodGroup'] as String?)?.isNotEmpty == true
                ? userData!['bloodGroup'] as String
                : ((userData?['blood_group'] as String?)?.isNotEmpty == true
                    ? userData!['blood_group'] as String
                    : (userData?['groupe_sanguin'] as String?) ?? '')) ;

            return Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // ── Carte accès hors-ligne ────────────────────────────
                    const OfflineAccessCard(),
                    Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () => _changePhotoDialog(context),
                      child: Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Container(
                        width: 58.0,
                        height: 60.0,
                        decoration: BoxDecoration(),
                        child: Stack(
                          children: [
                            Container(
                              width: 55.0,
                              height: 55.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: AvatarImageWidget(
                                imageUrl: photoUrl,
                                width: 55.0,
                                height: 55.0,
                                fit: BoxFit.cover,
                                placeholder: Container(
                                  color: FlutterFlowTheme.of(context).primary,
                                  alignment: Alignment.center,
                                  child: Text(
                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 2.0,
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 13.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: FlutterFlowTheme.of(context)
                              .headlineSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 12.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .headlineSmall
                                    .fontStyle,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Carnet Santé',
                          style: FlutterFlowTheme.of(context)
                              .labelSmall
                              .override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .labelSmall
                                      .fontStyle,
                                ),
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                fontSize: 11.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .labelSmall
                                    .fontStyle,
                                lineHeight: 1.4,
                              ),
                        ),
                      ].divide(SizedBox(height: 5.0)),
                    ),
                  ].divide(SizedBox(width: 20.0)),
                ),
                // ── Banner Mes Rendez-vous & Consultations ──
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (bCtx) => PatientAppointmentsWidget(),
                    );
                  },
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF165AC5), Color(0xFF1E1458)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF165AC5).withOpacity(0.25),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Rendez-vous Médicaux',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Suivez en direct l'état de vos demandes (Validé, Reporté, Refusé)",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Consulter',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF165AC5),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF165AC5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                InkWell(
                  onTap: () {
                    context.pushNamed(PatientDocumentsWidget.routeName);
                  },
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16C583), Color(0xFF0F9D58)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF16C583).withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Ordonnances & Dossiers Reçus',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Ordonnances avec QR Code, comptes-rendus SOAP et historiques envoyés par vos médecins",
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Ouvrir',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16C583),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF16C583)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                const PatientPrescriptionsWidget(),
                const SizedBox(height: 14.0),
                Container(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Groupe Sanguin',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (bloodGroup.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF165AC5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.bloodtype_outlined, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      bloodGroup,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (bloodGroup.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Groupe sanguin non renseigné. Mettez à jour votre profil.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['A +', 'A -', 'B +', 'B -', 'AB +', 'AB -', 'O +', 'O -'].map((g) {
                            final normalized = g.replaceAll(' ', '');
                            final userNorm = bloodGroup.replaceAll(' ', '').toUpperCase();
                            final isSelected = userNorm == normalized.toUpperCase();
                            return InkWell(
                              onTap: () => _updateBloodGroup(g),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF165AC5)
                                      : FlutterFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF165AC5)
                                        : const Color(0x4D14583D),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                                  child: Text(
                                    g,
                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.outfit(
                                        fontWeight: isSelected ? FontWeight.bold : FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      ),
                                      color: isSelected
                                          ? Colors.white
                                          : FlutterFlowTheme.of(context).primaryText,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                      ].divide(SizedBox(height: 0)),
                    ),
                  ),
                ),
                _buildEditableMedicalSection(
                  context: context,
                  title: 'Allergies',
                  emptyLabel: 'Aucune allergie répertoriée',
                  fieldName: 'allergies',
                  items: allergies,
                  controller: _model.textController1,
                  focusNode: _model.textFieldFocusNode1,
                  hintText: 'Ex: Pénicilline, Arachides ...',
                ),
                _buildEditableMedicalSection(
                  context: context,
                  title: 'Maladies / antécédents',
                  emptyLabel: 'Aucune maladie ou antécédent répertorié',
                  fieldName: 'antecedents',
                  items: antecedents,
                  controller: _model.textController2,
                  focusNode: _model.textFieldFocusNode2,
                  hintText: 'Ex: Hypertension, Asthme ...',
                ),
                _buildEditableMedicalSection(
                  context: context,
                  title: 'Traitements en cours',
                  emptyLabel: 'Aucun traitement en cours répertorié',
                  fieldName: 'traitements',
                  items: traitements,
                  controller: _model.textController3,
                  focusNode: _model.textFieldFocusNode3,
                  hintText: 'Ex: Amlodipine 5mg, Paracétamol ...',
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).accent2,
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
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF165AC5),
                              size: 18.0,
                            ),
                            Text(
                              'Vos informations sont chiffrées et ne sont partagées qu\'avec \nvotre accord',
                              maxLines: 2,
                              style: FlutterFlowTheme.of(context)
                                  .bodySmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodySmall
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    fontSize: 10.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ].divide(SizedBox(width: 6.0)),
                        ),
                      ].divide(SizedBox(width: 20.0)),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 20.0)),
            ),
          ),
        );
      },
    ),
  ),
);
  }
}
