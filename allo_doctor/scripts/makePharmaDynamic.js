const fs = require('fs');

const filePath = 'lib/patient/pharma_list/pharma_list_widget.dart';
let raw = fs.readFileSync(filePath, 'utf8');
const isCrlf = raw.includes('\r\n');
let content = raw.replace(/\r\n/g, '\n');

if (!content.includes('package:cloud_firestore/cloud_firestore.dart')) {
  content = content.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'package:cloud_firestore/cloud_firestore.dart';");
}

// Locate the Column starting immediately after 'PHARMACIES DISPONIBLES'
const headerMarker = "'PHARMACIES DISPONIBLES'";
const headerIdx = content.indexOf(headerMarker);
if (headerIdx === -1) {
  console.error('Header not found!');
  process.exit(1);
}

// Find Column( after header
const colMarker = 'Column(\n                                    mainAxisSize: MainAxisSize.min,';
const startIdx = content.indexOf(colMarker, headerIdx);
if (startIdx === -1) {
  console.error('Column start not found!');
  process.exit(1);
}

// The end marker is ].divide(SizedBox(height: 24.0)), which closes the parent Column children
const endMarker = '].divide(SizedBox(height: 24.0)),';
const endIdx = content.indexOf(endMarker, startIdx);
if (endIdx === -1) {
  console.error('End marker not found!');
  process.exit(1);
}

// Let's create the dynamic StreamBuilder replacement
const replacement = `StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance.collection('pharmacies').snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19BF82)),
                                            ),
                                          ),
                                        );
                                      }
                                      final docs = snapshot.data!.docs;
                                      final searchText = _model.textController?.text.trim().toLowerCase() ?? '';
                                      final filteredDocs = searchText.isEmpty
                                          ? docs
                                          : docs.where((d) {
                                              final name = (d.data()['name'] as String? ?? '').toLowerCase();
                                              final city = (d.data()['city'] as String? ?? '').toLowerCase();
                                              final address = (d.data()['address'] as String? ?? '').toLowerCase();
                                              return name.contains(searchText) || city.contains(searchText) || address.contains(searchText);
                                            }).toList();

                                      if (filteredDocs.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.local_pharmacy_outlined, size: 56.0, color: Color(0xFF19BF82)),
                                                SizedBox(height: 12.0),
                                                Text(
                                                  'Aucune pharmacie disponible',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                    font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                  ),
                                                ),
                                                SizedBox(height: 6.0),
                                                Text(
                                                  'Les pharmacies enregistrées apparaîtront ici dès leur configuration.',
                                                  textAlign: TextAlign.center,
                                                  style: FlutterFlowTheme.of(context).labelMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: filteredDocs.map((doc) {
                                          final data = doc.data();
                                          final name = (data['name'] as String?)?.trim() ?? 'Pharmacie';
                                          final address = (data['address'] as String?) ?? (data['city'] as String?) ?? 'Brazzaville';
                                          final hours = (data['guard_hours'] as String?) ?? (data['hours'] as String?) ?? '08h - 20h';
                                          final isGuard = (data['is_guard'] as bool?) ?? false;
                                          final photoUrl = (data['photo_url'] as String?) ?? (data['cover'] as String?) ?? '';
                                          final phone = (data['phone_number'] as String?) ?? (data['phone'] as String?) ?? '';

                                          return Align(
                                            alignment: AlignmentDirectional(0.0, -1.0),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () async {
                                                context.pushNamed(PharmaViewWidget.routeName);
                                              },
                                              child: Material(
                                                color: Colors.transparent,
                                                elevation: 2.0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 80.0,
                                                  decoration: BoxDecoration(
                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          width: 50.0,
                                                          height: 50.0,
                                                          decoration: BoxDecoration(
                                                            color: Color(0x22FFE500),
                                                            borderRadius: BorderRadius.circular(12.0),
                                                          ),
                                                          child: photoUrl.isNotEmpty
                                                              ? ClipRRect(
                                                                  borderRadius: BorderRadius.circular(12.0),
                                                                  child: Image.network(photoUrl, fit: BoxFit.cover),
                                                                )
                                                              : Icon(Icons.local_pharmacy_rounded, color: Color(0xFF19BF82), size: 28.0),
                                                        ),
                                                        SizedBox(width: 12.0),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      name,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: FlutterFlowTheme.of(context).labelLarge.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Icon(Icons.verified_rounded, color: Color(0xFF19BF82), size: 16.0),
                                                                ],
                                                              ),
                                                              SizedBox(height: 4.0),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: isGuard ? Color(0x2319BF82) : Color(0x23D2BB39),
                                                                      borderRadius: BorderRadius.circular(6.0),
                                                                    ),
                                                                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                                                    child: Text(
                                                                      isGuard ? 'De Garde' : address,
                                                                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                        font: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                                                        color: isGuard ? Color(0xFF19BF82) : Color(0xFFB8A600),
                                                                        fontSize: 10.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8.0),
                                                                  Text('•', style: TextStyle(color: FlutterFlowTheme.of(context).secondaryText)),
                                                                  SizedBox(width: 8.0),
                                                                  Text(
                                                                    hours,
                                                                    style: FlutterFlowTheme.of(context).bodySmall.override(
                                                                      font: GoogleFonts.outfit(),
                                                                      color: FlutterFlowTheme.of(context).secondaryText,
                                                                      fontSize: 11.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (phone.isNotEmpty)
                                                          IconButton(
                                                            icon: Icon(Icons.phone_outlined, color: Color(0xFF19BF82), size: 20.0),
                                                            onPressed: () async {
                                                              await launchURL('tel:' + phone);
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList().divide(SizedBox(height: 16.0)),
                                      );
                                    },
                                  ),\n                                `;

content = content.substring(0, startIdx) + replacement + content.substring(endIdx);
if (isCrlf) content = content.replace(/\n/g, '\r\n');
fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated pharma_list_widget.dart');
