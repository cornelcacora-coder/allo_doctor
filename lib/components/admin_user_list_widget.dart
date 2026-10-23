import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'admin_user_list_model.dart';
export 'admin_user_list_model.dart';

/// Liste dynamique des médecins/pharmacies/cliniques en attente de validation.
class AdminUserListWidget extends StatefulWidget {
  const AdminUserListWidget({super.key});

  @override
  State<AdminUserListWidget> createState() => _AdminUserListWidgetState();
}

class _AdminUserListWidgetState extends State<AdminUserListWidget> {
  late AdminUserListModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AdminUserListModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _updateStatus(String uid, String newStatus) async {
    final bool isVal = newStatus == 'validé' || newStatus == 'valide';
    final payload = {
      'status': newStatus,
      'isValidated': isVal,
      'is_validated': isVal,
      'updated_at': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance.collection('users').doc(uid).set(payload, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection('User').doc(uid).set(payload, SetOptions(merge: true));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'validé':
        return const Color(0xFF16CB83);
      case 'rejeté':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'validé':
        return 'Validé';
      case 'rejeté':
        return 'Rejeté';
      default:
        return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Color(0x33000000),
                offset: Offset(0.0, 2.0),
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 4.0,
                      height: 24.0,
                      decoration: BoxDecoration(
                        color: Color(0xFF165C40),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                    Text(
                      'Prestataires à valider',
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            font: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                            lineHeight: 1.4,
                          ),
                    ),
                  ].divide(SizedBox(width: 8.0)),
                ),
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', whereNotIn: ['User', 'admin'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Erreur de chargement',
                        style: FlutterFlowTheme.of(context).labelMedium,
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF511458)),
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48.0, color: FlutterFlowTheme.of(context).secondaryText),
                          SizedBox(height: 8.0),
                          Text(
                            'Aucun prestataire enregistré',
                            style: FlutterFlowTheme.of(context).labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.0),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final uid = doc.id;
                      final name = (data['displayName'] as String?)?.trim().isNotEmpty == true
                          ? data['displayName'] as String
                          : (data['email'] as String?) ?? 'Sans nom';
                      final role = (data['role'] as String?) ?? '';
                      final photoUrl = (data['photoUrl'] as String?) ?? (data['photo_url'] as String?) ?? '';
                      final status = (data['status'] as String?) ?? 'en_attente';
                      final isValidated = status == 'validé';
                      final isRejected = status == 'rejeté';

                      return Material(
                        color: Colors.transparent,
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: _statusColor(status).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 44.0,
                                      height: 44.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                                      ),
                                      child: ClipOval(
                                        child: photoUrl.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: photoUrl,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) => Icon(Icons.person, color: FlutterFlowTheme.of(context).primary),
                                              )
                                            : Icon(Icons.person, color: FlutterFlowTheme.of(context).primary),
                                      ),
                                    ),
                                    SizedBox(width: 12.0),
                                    // Nom + rôle
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name,
                                                  style: FlutterFlowTheme.of(context).labelLarge.override(
                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                        fontSize: 14.0,
                                                      ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isValidated)
                                                Icon(Icons.verified_rounded, color: Color(0xFF16CB83), size: 16.0),
                                            ],
                                          ),
                                          SizedBox(height: 2.0),
                                          Row(
                                            children: [
                                              Text(
                                                role,
                                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                                      font: GoogleFonts.outfit(),
                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                      fontSize: 11.0,
                                                    ),
                                              ),
                                              SizedBox(width: 8.0),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(status).withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(6.0),
                                                ),
                                                child: Text(
                                                  _statusLabel(status),
                                                  style: TextStyle(
                                                    color: _statusColor(status),
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Boutons valider/rejeter — seulement si pas encore validé/rejeté
                                if (!isValidated || isRejected)
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF16CB83),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                            ),
                                            icon: Icon(Icons.check_circle_outline, size: 16.0),
                                            label: Text('Valider', style: GoogleFonts.outfit(fontSize: 13.0, fontWeight: FontWeight.w600)),
                                            onPressed: () => _updateStatus(uid, 'validé'),
                                          ),
                                        ),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red.shade50,
                                              foregroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 8.0),
                                            ),
                                            icon: Icon(Icons.cancel_outlined, size: 16.0),
                                            label: Text('Rejeter', style: GoogleFonts.outfit(fontSize: 13.0, fontWeight: FontWeight.w600)),
                                            onPressed: () => _updateStatus(uid, 'rejeté'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Bouton ré-évaluer si déjà validé
                                if (isValidated)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: BorderSide(color: Colors.red.withOpacity(0.4)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                          padding: EdgeInsets.symmetric(vertical: 6.0),
                                        ),
                                        icon: Icon(Icons.remove_circle_outline, size: 14.0),
                                        label: Text('Révoquer validation', style: GoogleFonts.outfit(fontSize: 12.0)),
                                        onPressed: () => _updateStatus(uid, 'rejeté'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
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
    );
  }
}
