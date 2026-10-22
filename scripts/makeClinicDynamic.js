const fs = require('fs');

const filePath = 'lib/patient/clinic_list/clinic_list_widget.dart';
let raw = fs.readFileSync(filePath, 'utf8');
const isCrlf = raw.includes('\r\n');
let content = raw.replace(/\r\n/g, '\n');

if (!content.includes('package:cloud_firestore/cloud_firestore.dart')) {
  content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
}

const modelIdx = content.indexOf('_model.clinicCardModel1');
if (modelIdx === -1) {
  console.error('_model.clinicCardModel1 not found!');
  process.exit(1);
}
const startIndex = content.lastIndexOf('wrapWithModel(', modelIdx);
const endMarker = '].divide(SizedBox(height: 24.0)),';
const endIndex = content.indexOf(endMarker, startIndex);

if (startIndex === -1 || endIndex === -1) {
  console.error('Markers not found! startIndex:', startIndex, 'endIndex:', endIndex);
  process.exit(1);
}

const replacement = `StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                     stream: FirebaseFirestore.instance.collection('clinics').snapshots(),
                                     builder: (context, snapshot) {
                                       if (!snapshot.hasData) {
                                         return Center(
                                           child: Padding(
                                             padding: EdgeInsets.all(20.0),
                                             child: CircularProgressIndicator(
                                               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF165AC5)),
                                             ),
                                           ),
                                         );
                                       }
                                       var docs = snapshot.data!.docs;
                                       final selectedFilter = _model.choiceChipsValue;
                                       if (selectedFilter != null && selectedFilter != 'Tous') {
                                         docs = docs.where((d) {
                                           final services = (d.data()['services'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
                                           return services.any((s) => s.contains(selectedFilter.toLowerCase()));
                                         }).toList();
                                       }
                                       if (docs.isEmpty) {
                                         return Center(
                                           child: Padding(
                                             padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                             child: Column(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 Icon(Icons.local_hospital_outlined, size: 56.0, color: Color(0xFF165AC5)),
                                                 SizedBox(height: 12.0),
                                                 Text(
                                                   'Aucune clinique disponible',
                                                   textAlign: TextAlign.center,
                                                   style: FlutterFlowTheme.of(context).titleMedium.override(
                                                     font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                   ),
                                                 ),
                                                 SizedBox(height: 6.0),
                                                 Text(
                                                   'Les cliniques et centres de santé s\\'afficheront ici dès qu\\'ils seront ajoutés.',
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
                                           final name = (data['name'] as String?)?.trim() ?? 'Clinique';
                                           final location = (data['address'] as String?) ?? (data['city'] as String?) ?? (data['location'] as String?) ?? 'Brazzaville';
                                           final cover = (data['cover'] as String?) ?? (data['photo_url'] as String?);
                                           final phone = (data['phone_number'] as String?) ?? (data['phone'] as String?) ?? '';

                                           return ClinicCardWidget(
                                             name: name,
                                             location: location,
                                             cover: cover,
                                             bookMeet: () async {
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
                                                       child: GetMedicalAppointmentWidget(
                                                         isDoctorView: false,
                                                       ),
                                                     ),
                                                   );
                                                 },
                                               ).then((value) => safeSetState(() {}));
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
if (isCrlf) content = content.replace(/\n/g, '\r\n');
fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated clinic_list_widget.dart');
