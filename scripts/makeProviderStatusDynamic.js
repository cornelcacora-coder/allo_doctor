const fs = require('fs');
const path = require('path');

// 1. Process home_pharmacy_widget.dart
const pharmaPath = path.join(__dirname, '../lib/pharmacy/home_pharmacy/home_pharmacy_widget.dart');
let pharmaContent = fs.readFileSync(pharmaPath, 'utf8');

// Add imports if not present
if (!pharmaContent.includes('package:cloud_firestore/cloud_firestore.dart')) {
  pharmaContent = pharmaContent.replace(
    "import 'home_pharmacy_model.dart';",
    "import 'home_pharmacy_model.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '/auth/firebase_auth/auth_util.dart';"
  );
}

// Replace header with StreamBuilder
const pharmaTargetStart = 'Container(\r\n                      height: 180.0,';
const pharmaTargetAlt = 'Container(\n                      height: 180.0,';

const pharmaReplacement = `StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: currentUserUid.isNotEmpty
                          ? FirebaseFirestore.instance.collection('users').doc(currentUserUid).snapshots()
                          : null,
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final displayName = (data?['displayName'] as String?)?.trim().isNotEmpty == true
                            ? data!['displayName'] as String
                            : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Pharmacie Partenaire');
                        final photoUrl = (data?['photoUrl'] as String?) ?? currentUserPhoto;
                        final status = (data?['status'] as String?) ?? 'en_attente';
                        final isValidated = status == 'validé' || status == 'active';

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 180.0,
                              child: Stack(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                children: [
                                  ClipRRect(
                                    child: Container(
                                      height: 160.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context).primary,
                                            FlutterFlowTheme.of(context).secondary
                                          ],
                                          stops: [0.0, 1.0],
                                          begin: AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: CachedNetworkImage(
                                          fadeInDuration: Duration(milliseconds: 0),
                                          fadeOutDuration: Duration(milliseconds: 0),
                                          imageUrl:
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTuJd79lESiMSYUkRiR6opa4IdwozzX3xy1WKWfCEQ0j-58u2c3RFLYxqsx&s=10',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          alignment: Alignment(0.0, 0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 1.0),
                                    child: Container(
                                      width: 100.0,
                                      height: 100.0,
                                      decoration: BoxDecoration(
                                        color: FlutterFlowTheme.of(context).secondaryBackground,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: ClipOval(
                                          child: photoUrl.isNotEmpty
                                              ? CachedNetworkImage(
                                                  fadeInDuration: Duration(milliseconds: 0),
                                                  fadeOutDuration: Duration(milliseconds: 0),
                                                  imageUrl: photoUrl,
                                                  width: 96.0,
                                                  height: 96.0,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 96.0,
                                                  height: 96.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).primary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'P',
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
                                ],
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-0.75, -0.03),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      displayName,
                                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isValidated ? Icons.verified_rounded : Icons.pending_outlined,
                                          color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).secondary,
                                          size: 16.0,
                                        ),
                                        Text(
                                          isValidated ? 'Pharmacie Partenaire Validée' : 'En attente de validation par l\\'administrateur',
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).secondary,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),`;

// We need to replace from `Container(\r?\n\s+height: 180.0,` up to and including the closing of `Align` containing `DJAGGER`
const pharmaRegex = /Container\(\s+height:\s*180\.0,[\s\S]*?Text\(\s*'DJAGGER'[\s\S]*?\.divide\(SizedBox\(width:\s*4\.0\)\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),/;

if (pharmaRegex.test(pharmaContent)) {
  pharmaContent = pharmaContent.replace(pharmaRegex, pharmaReplacement);
  fs.writeFileSync(pharmaPath, pharmaContent, 'utf8');
  console.log('Successfully updated home_pharmacy_widget.dart');
} else {
  console.log('Pharma regex did not match, check content');
}

// 2. Process home_clinique_widget.dart
const clinicPath = path.join(__dirname, '../lib/clinique/home_clinique/home_clinique_widget.dart');
let clinicContent = fs.readFileSync(clinicPath, 'utf8');

if (!clinicContent.includes('package:cloud_firestore/cloud_firestore.dart')) {
  clinicContent = clinicContent.replace(
    "import 'home_clinique_model.dart';",
    "import 'home_clinique_model.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '/auth/firebase_auth/auth_util.dart';"
  );
}

const clinicReplacement = `StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: currentUserUid.isNotEmpty
                          ? FirebaseFirestore.instance.collection('users').doc(currentUserUid).snapshots()
                          : null,
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final displayName = (data?['displayName'] as String?)?.trim().isNotEmpty == true
                            ? data!['displayName'] as String
                            : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Clinique Partenaire');
                        final photoUrl = (data?['photoUrl'] as String?) ?? currentUserPhoto;
                        final status = (data?['status'] as String?) ?? 'en_attente';
                        final isValidated = status == 'validé' || status == 'active';

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 160.0,
                              child: Stack(
                                alignment: AlignmentDirectional(0.0, -1.0),
                                children: [
                                  ClipRRect(
                                    child: Container(
                                      width: double.infinity,
                                      height: 160.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            FlutterFlowTheme.of(context).primary,
                                            FlutterFlowTheme.of(context).secondary
                                          ],
                                          stops: [0.0, 1.0],
                                          begin: AlignmentDirectional(0.0, -1.0),
                                          end: AlignmentDirectional(0, 1.0),
                                        ),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: CachedNetworkImage(
                                          fadeInDuration: Duration(milliseconds: 0),
                                          fadeOutDuration: Duration(milliseconds: 0),
                                          imageUrl:
                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ6hVKdKfq0JnzVj27911KfCJhhT4_zzpj6g7ZbsTsrX75TbZhL_zm9wFU&s=10',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          alignment: Alignment(0.0, 0.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-0.75, -0.03),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 0.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      displayName,
                                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            font: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            color: FlutterFlowTheme.of(context).primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isValidated ? Icons.verified_rounded : Icons.pending_outlined,
                                          color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).warning,
                                          size: 16.0,
                                        ),
                                        Text(
                                          isValidated ? 'Clinique Partenaire Validée' : 'En attente de validation par l\\'administrateur',
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                color: isValidated ? Color(0xFF16CB83) : FlutterFlowTheme.of(context).warning,
                                                letterSpacing: 0.0,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ].divide(SizedBox(width: 4.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),`;

const clinicRegex = /Container\(\s+height:\s*160\.0,[\s\S]*?Text\(\s*'Fondation MATETE'[\s\S]*?\.divide\(SizedBox\(width:\s*4\.0\)\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),/;

if (clinicRegex.test(clinicContent)) {
  clinicContent = clinicContent.replace(clinicRegex, clinicReplacement);
  fs.writeFileSync(clinicPath, clinicContent, 'utf8');
  console.log('Successfully updated home_clinique_widget.dart');
} else {
  console.log('Clinic regex did not match, check content');
}
