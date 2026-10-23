const fs = require('fs');
const path = require('path');

// ─── profile_user_widget.dart ──────────────────────────────────────────────
const profilePath = path.join(__dirname, '..', 'lib', 'patient', 'profile_user', 'profile_user_widget.dart');
let content = fs.readFileSync(profilePath, 'utf8');
const norm = content.replace(/\r\n/g, '\n');

// 1) Wrap the existing outer StreamBuilder in another StreamBuilder that also fetches counts
const oldStream = `              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: currentUserUid.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserUid)
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data() ?? {};
                  final displayName = (userData['name'] as String?)?.trim().isNotEmpty == true
                      ? userData['name'] as String
                      : ((userData['nom'] as String?)?.trim().isNotEmpty == true
                          ? userData['nom'] as String
                          : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Utilisateur'));
                  final phone = (userData['phone'] as String?)?.trim().isNotEmpty == true
                      ? userData['phone'] as String
                      : ((userData['telephone'] as String?)?.trim().isNotEmpty == true
                          ? userData['telephone'] as String
                          : 'Non renseigné');
                  final city = (userData['city'] as String?)?.trim().isNotEmpty == true
                      ? userData['city'] as String
                      : ((userData['ville'] as String?)?.trim().isNotEmpty == true
                          ? userData['ville'] as String
                          : 'Brazzaville');
                  final email = (userData['email'] as String?)?.trim().isNotEmpty == true
                      ? userData['email'] as String
                      : (currentUserEmail.isNotEmpty ? currentUserEmail : '');
                  final role = (userData['role'] as String?)?.trim().isNotEmpty == true
                      ? userData['role'] as String
                      : 'patient';
                  final photoUrl = (userData['photoUrl'] as String?) ?? '';`;

const newStream = `              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: currentUserUid.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUserUid)
                        .snapshots()
                    : const Stream.empty(),
                builder: (context, snapshot) {
                  final userData = snapshot.data?.data() ?? {};
                  final displayName = (userData['name'] as String?)?.trim().isNotEmpty == true
                      ? userData['name'] as String
                      : ((userData['nom'] as String?)?.trim().isNotEmpty == true
                          ? userData['nom'] as String
                          : (currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'Utilisateur'));
                  final phone = (userData['phone'] as String?)?.trim().isNotEmpty == true
                      ? userData['phone'] as String
                      : ((userData['telephone'] as String?)?.trim().isNotEmpty == true
                          ? userData['telephone'] as String
                          : 'Non renseigné');
                  final city = (userData['city'] as String?)?.trim().isNotEmpty == true
                      ? userData['city'] as String
                      : ((userData['ville'] as String?)?.trim().isNotEmpty == true
                          ? userData['ville'] as String
                          : 'Brazzaville');
                  final email = (userData['email'] as String?)?.trim().isNotEmpty == true
                      ? userData['email'] as String
                      : (currentUserEmail.isNotEmpty ? currentUserEmail : '');
                  final role = (userData['role'] as String?)?.trim().isNotEmpty == true
                      ? userData['role'] as String
                      : 'patient';
                  final photoUrl = (userData['photoUrl'] as String?) ?? '';
                  // Dynamic counts from Firestore
                  final bloodGroup = (userData['bloodGroup'] as String?)?.isNotEmpty == true
                      ? userData['bloodGroup'] as String
                      : ((userData['blood_group'] as String?)?.isNotEmpty == true
                          ? userData['blood_group'] as String
                          : (userData['groupe_sanguin'] as String?) ?? '--');`;

if (norm.includes(oldStream)) {
  content = norm.replace(oldStream, newStream);
  console.log('✅ Added bloodGroup + dynamic counts extraction');
} else {
  console.log('❌ oldStream not found');
}

// 2) Replace static StateitemWidget counts with dynamic ones
const oldStats = `                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40.0,
                          child: wrapWithModel(
                            model: _model.stateitemModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: StateitemWidget(
                              label: 'Examen',
                              count: '0',
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
                              label: 'Consultations',
                              count: '10',
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
                              label: 'Groupe',
                              count: 'O+',
                            ),
                          ),
                        ),
                      ].divide(SizedBox(width: 32.0)),
                    ),`;

const newStats = `                    StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: currentUserUid.isNotEmpty
                          ? FirebaseFirestore.instance
                              .collection('appointments')
                              .snapshots()
                              .map((s) => s.docs.where((d) {
                                    final pId = d.data()['patient_id'] as String?;
                                    final pEmail = d.data()['patient_email'] as String?;
                                    return (pId != null && pId == currentUserUid) ||
                                        (pEmail != null &&
                                            pEmail.toLowerCase() ==
                                                currentUserEmail.toLowerCase());
                                  }).toList())
                          : Stream.value([]),
                      builder: (context, apptSnap) {
                        final apptCount = apptSnap.data?.length ?? 0;
                        return StreamBuilder<List<QueryDocumentSnapshot>>(
                          stream: currentUserUid.isNotEmpty
                              ? FirebaseFirestore.instance
                                  .collection('lab_results')
                                  .snapshots()
                                  .map((s) => s.docs.where((d) {
                                        final ref = d.data()['patient_ref'] as DocumentReference?;
                                        return ref?.id == currentUserUid;
                                      }).toList())
                              : Stream.value([]),
                          builder: (context, labSnap) {
                            final labCount = labSnap.data?.length ?? 0;
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 40.0,
                                  child: wrapWithModel(
                                    model: _model.stateitemModel1,
                                    updateCallback: () => safeSetState(() {}),
                                    child: StateitemWidget(
                                      label: 'Examens',
                                      count: labCount.toString(),
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
                                      label: 'Rendez-vous',
                                      count: apptCount.toString(),
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
                                      label: 'Groupe',
                                      count: bloodGroup,
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 32.0)),
                            );
                          },
                        );
                      },
                    ),`;

if (content.includes(oldStats)) {
  content = content.replace(oldStats, newStats);
  console.log('✅ Replaced static stats with dynamic StreamBuilder counts');
} else {
  console.log('❌ oldStats not found');
}

fs.writeFileSync(profilePath, content, 'utf8');
console.log('Done writing profile_user_widget.dart');
