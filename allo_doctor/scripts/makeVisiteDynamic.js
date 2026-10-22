const fs = require('fs');

const filePath = 'lib/doctor/visite/visite_widget.dart';
let raw = fs.readFileSync(filePath, 'utf8');
const isCrlf = raw.includes('\r\n');
let content = raw.replace(/\r\n/g, '\n');

if (!content.includes('package:cloud_firestore/cloud_firestore.dart')) {
  content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
}

const listIdx = content.indexOf('ListView(');
const endMarker = '].divide(SizedBox(height: 14.0)),\n                    ),';
const endIdx = content.indexOf(endMarker, listIdx);

if (listIdx === -1 || endIdx === -1) {
  console.error('Markers not found! listIdx:', listIdx, 'endIdx:', endIdx);
  process.exit(1);
}

const replacement = `StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('appointments').where('consult_mode', isEqualTo: 'domicile').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final docs = snapshot.data!.docs;
                        if (docs.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.home_work_outlined, size: 56.0, color: FlutterFlowTheme.of(context).secondaryText),
                                  SizedBox(height: 12.0),
                                  Text(
                                    'Aucune visite à domicile en attente',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).titleMedium.override(
                                      font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    'Vos visites à domicile programmées s\\'afficheront ici.',
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context).labelMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: docs.map((doc) {
                            final data = doc.data();
                            final patientName = (data['patient_name'] as String?)?.trim().isNotEmpty == true
                                ? data['patient_name'] as String
                                : 'Patient';
                            final day = (data['day'] as String?) ?? '';
                            final timeSlot = (data['time_slot'] as String?) ?? '';
                            final sympto = day + (timeSlot.isNotEmpty ? ' • ' + timeSlot : '');

                            return InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(DmpWidget.routeName);
                              },
                              child: PatientCardWidget(
                                photo: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                                name: patientName,
                                sympto: sympto,
                                type: 'Domicile',
                              ),
                            );
                          }).toList().divide(SizedBox(height: 14.0)),
                        );
                      },
                    )`;

content = content.substring(0, listIdx) + replacement + content.substring(endIdx + endMarker.length);
if (isCrlf) content = content.replace(/\n/g, '\r\n');
fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated visite_widget.dart');
