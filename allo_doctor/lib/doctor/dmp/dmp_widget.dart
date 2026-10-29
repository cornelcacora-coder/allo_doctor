import '/flutter_flow/flutter_flow_button_tabbar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import '/auth/role_guard.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/patient/prescription_view_modal.dart';
import '/doctor/dmp/prescription_creation_dialog.dart';
import '/components/avatar_image_widget.dart';
import 'dmp_model.dart';
export 'dmp_model.dart';

class DmpWidget extends StatefulWidget {
  const DmpWidget({
    super.key,
    this.patientUid,
    this.patientName,
    this.patientPhoto,
    this.symptoms,
  });

  static String routeName = 'DMP';
  static String routePath = '/dmp';

  final String? patientUid;
  final String? patientName;
  final String? patientPhoto;
  final String? symptoms;

  @override
  State<DmpWidget> createState() => _DmpWidgetState();
}

class _DmpWidgetState extends State<DmpWidget> with TickerProviderStateMixin {
  late DmpModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String get defaultPatientUid => (widget.patientUid != null && widget.patientUid!.trim().isNotEmpty)
      ? widget.patientUid!.trim()
      : 'patient_cora';

  String get defaultPatientName => (widget.patientName != null && widget.patientName!.trim().isNotEmpty)
      ? widget.patientName!.trim()
      : 'Patient';

  String get defaultPatientPhoto => (widget.patientPhoto != null && widget.patientPhoto!.trim().isNotEmpty)
      ? widget.patientPhoto!.trim()
      : '';

  String get defaultSymptoms => (widget.symptoms != null && widget.symptoms!.trim().isNotEmpty)
      ? widget.symptoms!.trim()
      : 'Dossier Médical';

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DmpModel());

    _model.tabBarController = TabController(
      vsync: this,
      length: 3,
      initialIndex: 0,
    )..addListener(() => safeSetState(() {}));

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textController6 ??= TextEditingController();
    _model.textFieldFocusNode6 ??= FocusNode();

    _model.textController7 ??= TextEditingController();
    _model.textFieldFocusNode7 ??= FocusNode();

    _model.textController8 ??= TextEditingController();
    _model.textFieldFocusNode8 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
      await guardRole(context, 'medecin');
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _showAddMedicalItemDialog(BuildContext context, String title, String fieldName, String patientId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ajouter : $title', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Ex: $title...',
            hintStyle: GoogleFonts.outfit(fontSize: 13),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
            ),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(patientId).set({
          fieldName: FieldValue.arrayUnion([result]),
        }, SetOptions(merge: true));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title ajouté avec succès !'), backgroundColor: const Color(0xFF16C583)),
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
  }

  Future<void> _removeMedicalItem(String fieldName, String item, String patientId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer "$item" du dossier patient ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('users').doc(patientId).set({
        fieldName: FieldValue.arrayRemove([item]),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _editPatientPhoto(BuildContext context, String patientId, String currentPhoto) async {
    final controller = TextEditingController(text: currentPhoto.startsWith('http') ? currentPhoto : '');
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          "Modifier la photo du patient",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: false,
                decoration: InputDecoration(
                  labelText: "URL de la photo ou image base64",
                  hintText: "https://... ou data:image/...",
                  labelStyle: GoogleFonts.outfit(fontSize: 13),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                "Ou choisissez un avatar rapide :",
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  'https://ui-avatars.com/api/?name=Dr+A&background=1a6b3c&color=fff&size=150',
                  'https://ui-avatars.com/api/?name=Dr+B&background=0d47a1&color=fff&size=150',
                  'https://ui-avatars.com/api/?name=Dr+C&background=6a1b9a&color=fff&size=150',
                  'https://ui-avatars.com/api/?name=Dr+D&background=c62828&color=fff&size=150',
                  'https://ui-avatars.com/api/?name=Dr+E&background=e65100&color=fff&size=150',
                ].map((url) => InkWell(
                  onTap: () => Navigator.pop(dialogCtx, url),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).tertiary,
            ),
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (chosen != null && chosen.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(patientId).set({
          'photoUrl': chosen,
          'photo_url': chosen,
        }, SetOptions(merge: true));
        if (mounted) {
          safeSetState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Photo du patient mise à jour avec succès !"),
              backgroundColor: Color(0xFF16C583),
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
  }

  Widget _buildMedicalSection({
    required BuildContext context,
    required String title,
    required String emptyLabel,
    required String fieldName,
    required List<String> items,
    required String patientId,
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
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                InkWell(
                  onTap: () => _showAddMedicalItemDialog(context, title, fieldName, patientId),
                  borderRadius: BorderRadius.circular(6.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: const Color(0x4DD29139),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14.0, color: FlutterFlowTheme.of(context).tertiary),
                        const SizedBox(width: 4.0),
                        Text(
                          'Ajouter',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                color: FlutterFlowTheme.of(context).tertiary,
                                fontSize: 11.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Text(
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
              )
            else
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 8.0,
                  children: items.map((item) {
                    return InkWell(
                      onLongPress: () => _removeMedicalItem(fieldName, item, patientId),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0x4DD29139),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        padding: const EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item,
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).tertiary,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 6.0),
                            InkWell(
                              onTap: () => _removeMedicalItem(fieldName, item, patientId),
                              child: Icon(
                                Icons.close,
                                size: 13.0,
                                color: FlutterFlowTheme.of(context).tertiary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientId = defaultPatientUid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(patientId).snapshots(),
      builder: (context, userSnap) {
        final userData = userSnap.data?.data();
        final currentPatientName = (userData?['displayName'] as String?)?.trim().isNotEmpty == true
            ? (userData!['displayName'] as String).trim()
            : ((userData?['name'] as String?)?.trim().isNotEmpty == true
                ? (userData!['name'] as String).trim()
                : defaultPatientName);

        final currentPhoto = (userData?['photoUrl'] as String?)?.trim().isNotEmpty == true
            ? (userData!['photoUrl'] as String).trim()
            : ((userData?['photo_url'] as String?)?.trim().isNotEmpty == true
                ? (userData!['photo_url'] as String).trim()
                : ((userData?['avatar_url'] as String?)?.trim().isNotEmpty == true
                    ? (userData!['avatar_url'] as String).trim()
                    : defaultPatientPhoto));

        final currentSymptoms = (widget.symptoms != null && widget.symptoms!.trim().isNotEmpty)
            ? widget.symptoms!.trim()
            : ((userData?['symptoms'] as String?)?.trim().isNotEmpty == true
                ? (userData!['symptoms'] as String).trim()
                : defaultSymptoms);
        final allergies = (userData?['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final antecedents = (userData?['antecedents'] as List<dynamic>?)?.map((e) => e.toString()).toList()
            ?? (userData?['maladies'] as List<dynamic>?)?.map((e) => e.toString()).toList()
            ?? [];
        final traitements = (userData?['traitements'] as List<dynamic>?)?.map((e) => e.toString()).toList()
            ?? (userData?['treatments'] as List<dynamic>?)?.map((e) => e.toString()).toList()
            ?? [];

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
                        'Mon Patient',
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              font: GoogleFonts.outfit(
                                fontWeight: FontWeight.w500,
                              ),
                              color: FlutterFlowTheme.of(context).alternate,
                              fontSize: 14.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
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
                ].divide(const SizedBox(height: 10.0)),
              ),
              actions: [],
              centerTitle: false,
              elevation: 4.0,
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── En-tête Patient Dynamique ──
                  Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.12,
                    decoration: const BoxDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(0.0, -1.0),
                            child: InkWell(
                              onTap: () => _editPatientPhoto(context, patientId, currentPhoto),
                              borderRadius: BorderRadius.circular(30.0),
                              child: SizedBox(
                                width: 58.0,
                                height: 60.0,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 55.0,
                                      height: 55.0,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0x4DD29139),
                                        border: Border.all(
                                          color: FlutterFlowTheme.of(context).tertiary,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: AvatarImageWidget(
                                          imageUrl: currentPhoto,
                                          width: 55.0,
                                          height: 55.0,
                                          fit: BoxFit.cover,
                                          placeholder: Container(
                                            width: 55.0,
                                            height: 55.0,
                                            color: FlutterFlowTheme.of(context).tertiary,
                                            alignment: Alignment.center,
                                            child: Text(
                                              currentPatientName.trim().isNotEmpty
                                                  ? currentPatientName.trim()[0].toUpperCase()
                                                  : 'P',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: const AlignmentDirectional(1.0, 1.0),
                                      child: Container(
                                        width: 22.0,
                                        height: 22.0,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context).tertiary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: FlutterFlowTheme.of(context).secondaryBackground,
                                            width: 2.0,
                                          ),
                                        ),
                                        alignment: const AlignmentDirectional(0.0, 0.0),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPatientName,
                                  style: FlutterFlowTheme.of(context).headlineSmall.override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        color: FlutterFlowTheme.of(context).primaryText,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  currentSymptoms,
                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                        font: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        color: FlutterFlowTheme.of(context).secondaryText,
                                        fontSize: 11.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              context.pushNamed(
                                TeleconsultationWidget.routeName,
                                queryParameters: {
                                  'channelName': 'allo_doctor_channel_$patientId',
                                  'patientName': currentPatientName,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).error,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: const Color(0x4DD23D39),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(5.0, 6.0, 5.0, 6.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
                                      child: Text(
                                        'Démarrer',
                                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              color: Colors.white,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.video_call_rounded,
                                      color: Colors.white,
                                      size: 24.0,
                                    ),
                                  ].divide(const SizedBox(width: 5.0)),
                                ),
                              ),
                            ),
                          ),
                        ].divide(const SizedBox(width: 20.0)),
                      ),
                    ),
                  ),

                  // ── Contenu des 3 Onglets (SOAP, Ordonnance, Histoire) ──
                  Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.8,
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: [
                        Align(
                          alignment: const Alignment(-1.0, 0),
                          child: FlutterFlowButtonTabBar(
                            useToggleButtonStyle: false,
                            isScrollable: true,
                            labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                            unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                ),
                            labelColor: FlutterFlowTheme.of(context).secondaryBackground,
                            unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
                            backgroundColor: FlutterFlowTheme.of(context).accent1,
                            unselectedBackgroundColor: FlutterFlowTheme.of(context).alternate,
                            borderColor: FlutterFlowTheme.of(context).primary,
                            unselectedBorderColor: FlutterFlowTheme.of(context).alternate,
                            borderWidth: 2.0,
                            borderRadius: 8.0,
                            elevation: 0.0,
                            labelPadding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
                            buttonMargin: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                            padding: const EdgeInsets.all(10.0),
                            tabs: const [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                    child: Icon(Icons.edit_note_outlined),
                                  ),
                                  Tab(text: 'SOAP'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                    child: Icon(Icons.medication_liquid_sharp),
                                  ),
                                  Tab(text: 'Ordonance'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                                    child: Icon(Icons.medical_information_outlined),
                                  ),
                                  Tab(text: 'Histoire'),
                                ],
                              ),
                            ],
                            controller: _model.tabBarController,
                            onTap: (i) async {
                              [() async {}, () async {}, () async {}][i]();
                            },
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _model.tabBarController,
                            children: [
                              // ════════════════════════════════════════════════════════════
                              // ONGLET 1 : SOAP DYNAMIQUE
                              // ════════════════════════════════════════════════════════════
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  primary: false,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      // Bandeau Secret Médical
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: const Color(0x4DD29139),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.verified_user_outlined,
                                                color: FlutterFlowTheme.of(context).tertiary,
                                                size: 18.0,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Acces Sécurisé - secret médical',
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          font: GoogleFonts.outfit(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Chaque dossier patient est sécurisé dans le secret médical',
                                                    maxLines: 2,
                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                          font: GoogleFonts.outfit(
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                          fontSize: 10.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ].divide(const SizedBox(width: 10.0)),
                                          ),
                                        ),
                                      ),

                                      // 1. Allergies Dynamiques
                                      _buildMedicalSection(
                                        context: context,
                                        title: 'Allergies',
                                        emptyLabel: 'Aucune allergie répertoriée',
                                        fieldName: 'allergies',
                                        items: allergies,
                                        patientId: patientId,
                                      ),

                                      // 2. Maladies / antécédents Dynamiques
                                      _buildMedicalSection(
                                        context: context,
                                        title: 'Maladies / antécédents',
                                        emptyLabel: 'Aucune maladie ou antécédent répertorié',
                                        fieldName: 'antecedents',
                                        items: antecedents,
                                        patientId: patientId,
                                      ),

                                      // 3. Traitements en cours Dynamiques
                                      _buildMedicalSection(
                                        context: context,
                                        title: 'Traitements en cours',
                                        emptyLabel: 'Aucun traitement en cours répertorié',
                                        fieldName: 'traitements',
                                        items: traitements,
                                        patientId: patientId,
                                      ),

                                      // 4. Formulaire S.O.A.P
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
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'S.O.A.P',
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
                                              Divider(
                                                height: 16.0,
                                                thickness: 1.0,
                                                color: FlutterFlowTheme.of(context).alternate,
                                              ),
                                              // Subjectif
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                                child: TextFormField(
                                                  controller: _model.textController1,
                                                  focusNode: _model.textFieldFocusNode1,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Subjectif — symptômes décrits par le patient',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                          font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                        ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                  maxLines: null,
                                                ),
                                              ),
                                              // Objectif
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                                                child: TextFormField(
                                                  controller: _model.textController2,
                                                  focusNode: _model.textFieldFocusNode2,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Objectif — constantes & examen clinique',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                          font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                        ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                  maxLines: null,
                                                ),
                                              ),
                                              // Analyse
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                                                child: TextFormField(
                                                  controller: _model.textController3,
                                                  focusNode: _model.textFieldFocusNode3,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Analyse — diagnostic (CIM-10 : B50, J06.9, E11...)',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                          font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                        ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                  maxLines: null,
                                                ),
                                              ),
                                              // Plan
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 10.0),
                                                child: TextFormField(
                                                  controller: _model.textController4,
                                                  focusNode: _model.textFieldFocusNode4,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Plan — traitement & suivi',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                                          font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                        ),
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                  maxLines: null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Bouton Enregistrer le compte rendu SOAP
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                                        child: InkWell(
                                          onTap: () async {
                                            final subj = _model.textController1?.text.trim() ?? '';
                                            final obj = _model.textController2?.text.trim() ?? '';
                                            final analysis = _model.textController3?.text.trim() ?? '';
                                            final plan = _model.textController4?.text.trim() ?? '';

                                            if (subj.isEmpty && obj.isEmpty && analysis.isEmpty && plan.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Veuillez renseigner au moins une section du SOAP.'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                              return;
                                            }

                                            try {
                                              await FirebaseFirestore.instance.collection('soap_notes').add({
                                                'patient_uid': patientId,
                                                'patient_name': currentPatientName,
                                                'doctor_uid': currentUserUid,
                                                'doctor_name': currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Dr. Traitant',
                                                'subjective': subj,
                                                'objective': obj,
                                                'analysis': analysis,
                                                'plan': plan,
                                                'created_at': FieldValue.serverTimestamp(),
                                              });

                                              if (context.mounted) {
                                                await showDialog(
                                                  context: context,
                                                  builder: (alertDialogContext) => AlertDialog(
                                                    title: const Text('Compte rendu enregistré !'),
                                                    content: const Text('Le compte rendu SOAP a été enregistré avec succès dans le dossier médical.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(alertDialogContext),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Erreur: $e'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 45.0,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF582414),
                                                  FlutterFlowTheme.of(context).tertiary,
                                                ],
                                                stops: const [0.0, 1.0],
                                                begin: const AlignmentDirectional(1.0, -1.0),
                                                end: const AlignmentDirectional(-1.0, 1.0),
                                              ),
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Enregistrer le compte rendu',
                                                  style: FlutterFlowTheme.of(context).labelSmall.override(
                                                        font: GoogleFonts.outfit(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                const Icon(
                                                  Icons.save_rounded,
                                                  color: Colors.white,
                                                  size: 20.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(height: 14.0)),
                                  ),
                                ),
                              ),

                              // ════════════════════════════════════════════════════════════
                              // ONGLET 2 : ORDONNANCE DYNAMIQUE
                              // ════════════════════════════════════════════════════════════
                              SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // Formulaire Prescription
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
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
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prescription',
                                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                'Ajouter votre prescription destinée à votre patient ici',
                                                maxLines: 2,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      fontSize: 10.0,
                                                    ),
                                              ),
                                              Divider(
                                                height: 16.0,
                                                thickness: 1.0,
                                                color: FlutterFlowTheme.of(context).alternate,
                                              ),
                                              // Molécule
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model.textController5,
                                                        focusNode: _model.textFieldFocusNode5,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          hintText: 'Molécule - Ex : Penicilline ...',
                                                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                                          enabledBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0xFF165AC5), width: 1.0),
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                          ),
                                                          filled: true,
                                                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                          contentPadding: const EdgeInsets.all(8.0),
                                                        ),
                                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    InkWell(
                                                      onTap: () {
                                                        _openPrescriptionDialogWithFields(context, patientId, currentPatientName);
                                                      },
                                                      child: Container(
                                                        width: 85.0,
                                                        height: 30.0,
                                                        decoration: BoxDecoration(
                                                          gradient: const LinearGradient(
                                                            colors: [Color(0xFF6D2F19), Color(0xFFC34213)],
                                                          ),
                                                          borderRadius: BorderRadius.circular(5.0),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                                            SizedBox(width: 4),
                                                            Icon(Icons.add, color: Colors.white, size: 14),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Quantité
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model.textController6,
                                                        focusNode: _model.textFieldFocusNode6,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          hintText: 'Quantité - Ex : 1 boite',
                                                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                                          enabledBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0xFF165AC5), width: 1.0),
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                          ),
                                                          filled: true,
                                                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                          contentPadding: const EdgeInsets.all(8.0),
                                                        ),
                                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    InkWell(
                                                      onTap: () {
                                                        _openPrescriptionDialogWithFields(context, patientId, currentPatientName);
                                                      },
                                                      child: Container(
                                                        width: 85.0,
                                                        height: 30.0,
                                                        decoration: BoxDecoration(
                                                          gradient: const LinearGradient(
                                                            colors: [Color(0xFF6D2F19), Color(0xFFC34213)],
                                                          ),
                                                          borderRadius: BorderRadius.circular(5.0),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                                            SizedBox(width: 4),
                                                            Icon(Icons.add, color: Colors.white, size: 14),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Posologie
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller: _model.textController7,
                                                        focusNode: _model.textFieldFocusNode7,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          hintText: 'Posologie - Ex : 1 cp x 2 par jour',
                                                          hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                                          enabledBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0xFF165AC5), width: 1.0),
                                                          ),
                                                          focusedBorder: const UnderlineInputBorder(
                                                            borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                          ),
                                                          filled: true,
                                                          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                          contentPadding: const EdgeInsets.all(8.0),
                                                        ),
                                                        style: FlutterFlowTheme.of(context).bodyMedium,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    InkWell(
                                                      onTap: () {
                                                        _openPrescriptionDialogWithFields(context, patientId, currentPatientName);
                                                      },
                                                      child: Container(
                                                        width: 85.0,
                                                        height: 30.0,
                                                        decoration: BoxDecoration(
                                                          gradient: const LinearGradient(
                                                            colors: [Color(0xFF6D2F19), Color(0xFFC34213)],
                                                          ),
                                                          borderRadius: BorderRadius.circular(5.0),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text('Ajouter', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                                            SizedBox(width: 4),
                                                            Icon(Icons.add, color: Colors.white, size: 14),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Bouton Émettre & Signer l'Ordonnance
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                                child: InkWell(
                                                  onTap: () => _openPrescriptionDialogWithFields(context, patientId, currentPatientName),
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 38.0,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFF16C583), Color(0xFF0F9D58)],
                                                        stops: [0.0, 1.0],
                                                        begin: AlignmentDirectional(1.0, -1.0),
                                                        end: AlignmentDirectional(-1.0, 1.0),
                                                      ),
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          "Émettre & Signer l'Ordonnance",
                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                font: GoogleFonts.outfit(
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                color: Colors.white,
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                        ),
                                                        const SizedBox(width: 8.0),
                                                        const Icon(
                                                          Icons.verified_outlined,
                                                          color: Colors.white,
                                                          size: 16.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Historique des Prescriptions Dynamique
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Prescriptions Émises',
                                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 8.0),
                                              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                                stream: FirebaseFirestore.instance
                                                    .collection('prescriptions')
                                                    .where('patient_uid', isEqualTo: patientId)
                                                    .snapshots(),
                                                builder: (context, prescSnap) {
                                                  if (prescSnap.connectionState == ConnectionState.waiting) {
                                                    return const Center(
                                                      child: Padding(
                                                        padding: EdgeInsets.all(16.0),
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    );
                                                  }
                                                  final allDocs = prescSnap.data?.docs ?? [];
                                                  if (allDocs.isEmpty) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                                                      child: Center(
                                                        child: Column(
                                                          children: [
                                                            Icon(Icons.medication_outlined, size: 36.0, color: FlutterFlowTheme.of(context).secondaryText),
                                                            const SizedBox(height: 6.0),
                                                            Text(
                                                              'Aucune ordonnance émise',
                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                                    fontSize: 12.0,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return ListView.separated(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    primary: false,
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: allDocs.length,
                                                    separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                                                    itemBuilder: (context, idx) {
                                                      final doc = allDocs[idx];
                                                      final data = doc.data();
                                                      final meds = (data['medications'] as List<dynamic>?) ?? [];
                                                      String medName = 'Médicament';
                                                      String posology = '';
                                                      if (meds.isNotEmpty) {
                                                        final firstMed = meds.first;
                                                        if (firstMed is Map) {
                                                          medName = (firstMed['name'] as String?) ?? 'Médicament';
                                                          final dosage = (firstMed['dosage'] as String?) ?? '';
                                                          final duration = (firstMed['duration'] as String?) ?? '';
                                                          posology = (dosage.isNotEmpty ? '- $dosage' : '') + (duration.isNotEmpty ? ' ($duration)' : '');
                                                        } else {
                                                          medName = firstMed.toString();
                                                        }
                                                      }
                                                      final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                                                      final dateStr = createdAt != null
                                                          ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year.toString().substring(2)}'
                                                          : '';

                                                      return InkWell(
                                                        onTap: () {
                                                          PrescriptionViewModal.show(
                                                            context,
                                                            prescriptionData: data,
                                                            prescriptionId: doc.id,
                                                          );
                                                        },
                                                        child: Container(
                                                          constraints: const BoxConstraints(minWidth: double.infinity),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0x4DD29139),
                                                            borderRadius: BorderRadius.circular(6.0),
                                                          ),
                                                          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 8.0, 10.0, 8.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                  medName,
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                                        fontSize: 12.0,
                                                                      ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  posology.isNotEmpty ? posology : 'Voir détails',
                                                                  textAlign: TextAlign.center,
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                                        color: FlutterFlowTheme.of(context).secondaryText,
                                                                        fontSize: 11.0,
                                                                      ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Text(
                                                                dateStr,
                                                                textAlign: TextAlign.end,
                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                      fontSize: 11.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ════════════════════════════════════════════════════════════
                              // ONGLET 3 : HISTOIRE DE LA MALADIE DYNAMIQUE
                              // ════════════════════════════════════════════════════════════
                              SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // Formulaire d'ajout d'historique
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
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
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Histoire de la maladie',
                                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                              Text(
                                                "Décrivez l'histoire de la maladie en relatant la symptomatologie de façon chronologique.",
                                                maxLines: 2,
                                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                                      font: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      fontSize: 10.0,
                                                    ),
                                              ),
                                              Divider(
                                                height: 16.0,
                                                thickness: 1.0,
                                                color: FlutterFlowTheme.of(context).alternate,
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                                                child: TextFormField(
                                                  controller: _model.textController8,
                                                  focusNode: _model.textFieldFocusNode8,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    hintText: 'Décrivez ici ...',
                                                    hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                                    enabledBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0xFF165AC5), width: 1.0),
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide(color: Color(0x00000000), width: 1.0),
                                                    ),
                                                    filled: true,
                                                    fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    contentPadding: const EdgeInsets.all(8.0),
                                                  ),
                                                  style: FlutterFlowTheme.of(context).bodyMedium,
                                                  maxLines: 4,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                                child: InkWell(
                                                  onTap: () async {
                                                    final text = _model.textController8?.text.trim() ?? '';
                                                    if (text.isEmpty) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text("Veuillez décrire l'histoire de la maladie."),
                                                            backgroundColor: Colors.orange,
                                                          ),
                                                        );
                                                      }
                                                      return;
                                                    }

                                                    try {
                                                      await FirebaseFirestore.instance.collection('patient_history').add({
                                                        'patient_uid': patientId,
                                                        'patient_name': currentPatientName,
                                                        'doctor_uid': currentUserUid,
                                                        'doctor_name': currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Dr. Traitant',
                                                        'description': text,
                                                        'created_at': FieldValue.serverTimestamp(),
                                                      });

                                                      _model.textController8?.clear();
                                                      FocusScope.of(context).unfocus();
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Histoire de la maladie enregistrée avec succès.'),
                                                            backgroundColor: Color(0xFF16C583),
                                                          ),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 35.0,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [Color(0xFF6D2F19), Color(0xFFC34213)],
                                                        stops: [0.0, 1.0],
                                                        begin: AlignmentDirectional(1.0, -1.0),
                                                        end: AlignmentDirectional(-1.0, 1.0),
                                                      ),
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'Terminer',
                                                          style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                font: GoogleFonts.outfit(
                                                                  fontWeight: FontWeight.w600,
                                                                ),
                                                                color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                fontSize: 12.0,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                        ),
                                                        const SizedBox(width: 10.0),
                                                        const Icon(
                                                          Icons.insert_drive_file_outlined,
                                                          color: Colors.white,
                                                          size: 14.0,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Liste chronologique des histoires enregistrées
                                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                      stream: FirebaseFirestore.instance
                                          .collection('patient_history')
                                          .where('patient_uid', isEqualTo: patientId)
                                          .snapshots(),
                                      builder: (context, histSnap) {
                                        if (histSnap.connectionState == ConnectionState.waiting) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        }
                                        final docs = histSnap.data?.docs ?? [];
                                        if (docs.isEmpty) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Icon(Icons.history_edu_outlined, size: 38.0, color: FlutterFlowTheme.of(context).secondaryText),
                                                  const SizedBox(height: 6.0),
                                                  Text(
                                                    'Aucun historique enregistré',
                                                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                          font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                          color: FlutterFlowTheme.of(context).secondaryText,
                                                          fontSize: 12.0,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4.0),
                                                  Text(
                                                    "Rédigez l'histoire de la maladie ci-dessus pour l'enregistrer.",
                                                    style: FlutterFlowTheme.of(context).labelSmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          primary: false,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: docs.length,
                                          itemBuilder: (context, index) {
                                            final doc = docs[index];
                                            final data = doc.data();
                                            final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                                            final dateStr = createdAt != null
                                                ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}'
                                                : '';
                                            final description = (data['description'] as String?) ?? '';
                                            final isLast = index == docs.length - 1;

                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
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
                                                      padding: const EdgeInsets.all(14.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: const Color(0x4DD29139),
                                                                  borderRadius: BorderRadius.circular(6.0),
                                                                ),
                                                                padding: const EdgeInsetsDirectional.fromSTEB(10.0, 4.0, 10.0, 4.0),
                                                                child: Text(
                                                                  'Histoire - ${docs.length - index}',
                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: FlutterFlowTheme.of(context).tertiary,
                                                                        fontSize: 12.0,
                                                                      ),
                                                                ),
                                                              ),
                                                              Text(
                                                                dateStr,
                                                                style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                      fontSize: 12.0,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 10.0),
                                                          Text(
                                                            description,
                                                            maxLines: 10,
                                                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                  font: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                                                                  color: FlutterFlowTheme.of(context).secondaryText,
                                                                  fontSize: 10.0,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (!isLast)
                                                  Align(
                                                    alignment: const AlignmentDirectional(-1.0, 0.0),
                                                    child: Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 0.0, 0.0),
                                                      child: Container(
                                                        width: 2.0,
                                                        height: 40.0,
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme.of(context).alternate,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
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
            ),
          ),
        );
      },
    );
  }

  void _openPrescriptionDialogWithFields(BuildContext context, String patientId, String patientName) {
    PrescriptionCreationDialog.show(
      context,
      patientUid: patientId,
      patientName: patientName,
    ).then((val) {
      if (val == true) {
        _model.textController5?.clear();
        _model.textController6?.clear();
        _model.textController7?.clear();
        safeSetState(() {});
      }
    });
  }
}
