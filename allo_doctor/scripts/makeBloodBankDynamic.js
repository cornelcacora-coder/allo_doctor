const fs = require('fs');

const filePath = 'lib/patient/blood_bank_list/blood_bank_list_widget.dart';
let content = fs.readFileSync(filePath, 'utf8');

// Ensure import 'package:cloud_firestore/cloud_firestore.dart'; is present
if (!content.includes('package:cloud_firestore/cloud_firestore.dart')) {
  content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
}

const startMarker = 'wrapWithModel(\n                                    model: _model.clinicCardModel1,';
const endMarker = '].divide(SizedBox(height: 24.0)),';

const startIndex = content.indexOf(startMarker);
const endIndex = content.indexOf(endMarker, startIndex);

if (startIndex === -1 || endIndex === -1) {
  console.error('Markers not found! startIndex:', startIndex, 'endIndex:', endIndex);
  process.exit(1);
}

const replacement = `StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance.collection('blood_banks').snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC0F0F)),
                                            ),
                                          ),
                                        );
                                      }
                                      var docs = snapshot.data!.docs;
                                      final selectedFilter = _model.choiceChipsValue;
                                      if (selectedFilter != null && selectedFilter != 'Tous') {
                                        docs = docs.where((d) {
                                          final groups = (d.data()['groups'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                                          return groups.contains(selectedFilter);
                                        }).toList();
                                      }
                                      if (docs.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.bloodtype_outlined, size: 56.0, color: Color(0xFFCC0F0F)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune banque de sang disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les banques de sang partenaires s\\'afficheront ici dès qu\\'elles seront ajoutées.',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return Column(
                                        children: docs.map((doc) {
                                          final data = doc.data();
                                          final name = (data['name'] as String?)?.trim() ?? 'Banque de Sang';
                                          final location = (data['location'] as String?) ?? (data['address'] as String?) ?? (data['city'] as String?) ?? 'Brazzaville';
                                          final distance = (data['distance'] as String?) ?? '';
                                          final cover = (data['cover'] as String?) ?? (data['photo_url'] as String?);
                                          final phone = (data['phone'] as String?) ?? (data['phoneNumber'] as String?) ?? '';

                                          return ClinicBloodCardWidget(
                                            name: name,
                                            location: location,
                                            distance: distance,
                                            cover: cover,
                                            buyBlood: () async {
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
                                                      child: GetBloodWidget(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            contactClinic: () async {
                                              if (phone.isNotEmpty) {
                                                await launchURL('https://wa.me/$phone');
                                              }
                                            },
                                          );
                                        }).toList().divide(SizedBox(height: 24.0)),
                                      );
                                    },
                                  ),\n                                `;

content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated blood_bank_list_widget.dart');
