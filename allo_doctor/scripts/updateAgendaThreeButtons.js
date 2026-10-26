const fs = require('fs');
const path = require('path');

const targetPath = path.join(__dirname, '..', 'lib', 'doctor', 'agenda', 'agenda_widget.dart');
let content = fs.readFileSync(targetPath, 'utf8');

// Replace the two buttons with three buttons: Valider, Reporter, Refuser
const oldButtonsPattern = /SizedBox\(height: 12\),\r?\n\s*Row\(\r?\n\s*children: \[\r?\n\s*Expanded\(\r?\n\s*child: GestureDetector\(\r?\n\s*onTap: \(\) async \{\r?\n\s*await appt\.reference\r?\n\s*\.update\({\r?\n\s*'status':\r?\n\s*'confirmed',[\s\S]*?child: Center\(\r?\n\s*child: Text\(\r?\n\s*'Annuler'[\s\S]*?\),\r?\n\s*\),\r?\n\s*\),\r?\n\s*\),\r?\n\s*\],\r?\n\s*\),/m;

const newButtons = `SizedBox(height: 12),
                                                   Row(
                                                     children: [
                                                       // 1. Bouton Valider
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await appt.reference.update({
                                                               'status': 'confirmed',
                                                               'updated_at': FieldValue.serverTimestamp(),
                                                             });
                                                             if (context.mounted) {
                                                               ScaffoldMessenger.of(context).showSnackBar(
                                                                 SnackBar(
                                                                   content: Text('Rendez-vous validé avec succès ✓'),
                                                                   backgroundColor: Color(0xFF00A651),
                                                                   behavior: SnackBarBehavior.floating,
                                                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                 ),
                                                               );
                                                             }
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: Color(0xFF00A651),
                                                               borderRadius: BorderRadius.circular(8),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Valider',
                                                                   style: TextStyle(
                                                                     color: Colors.white,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // 2. Bouton Reporter
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await _rescheduleAppointment(context, appt);
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: Color(0xFFE67E22),
                                                               borderRadius: BorderRadius.circular(8),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.schedule, color: Colors.white, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Reporter',
                                                                   style: TextStyle(
                                                                     color: Colors.white,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // 3. Bouton Refuser
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             final confirm = await showDialog<bool>(
                                                               context: context,
                                                               builder: (dCtx) => AlertDialog(
                                                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                                                 title: Text('Refuser le rendez-vous ?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                                                 content: Text('Le patient sera averti que sa demande a été refusée.'),
                                                                 actions: [
                                                                   TextButton(
                                                                     onPressed: () => Navigator.pop(dCtx, false),
                                                                     child: Text('Annuler', style: TextStyle(color: Colors.grey.shade600)),
                                                                   ),
                                                                   ElevatedButton(
                                                                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                                                     onPressed: () => Navigator.pop(dCtx, true),
                                                                     child: Text('Refuser'),
                                                                   ),
                                                                 ],
                                                               ),
                                                             );
                                                             if (confirm == true) {
                                                               await appt.reference.update({
                                                                 'status': 'refused',
                                                                 'updated_at': FieldValue.serverTimestamp(),
                                                               });
                                                               if (context.mounted) {
                                                                 ScaffoldMessenger.of(context).showSnackBar(
                                                                   SnackBar(
                                                                     content: Text('Rendez-vous refusé.'),
                                                                     backgroundColor: Colors.red,
                                                                     behavior: SnackBarBehavior.floating,
                                                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                   ),
                                                                 );
                                                               }
                                                             }
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: FlutterFlowTheme.of(context).primaryBackground,
                                                               borderRadius: BorderRadius.circular(8),
                                                               border: Border.all(color: Colors.red.shade300),
                                                             ),
                                                             child: Row(
                                                               mainAxisAlignment: MainAxisAlignment.center,
                                                               children: [
                                                                 Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 16),
                                                                 SizedBox(width: 4),
                                                                 Text(
                                                                   'Refuser',
                                                                   style: TextStyle(
                                                                     color: Colors.red.shade600,
                                                                     fontWeight: FontWeight.w600,
                                                                     fontSize: 12,
                                                                   ),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),`;

if (oldButtonsPattern.test(content)) {
  content = content.replace(oldButtonsPattern, newButtons);
  console.log('Successfully replaced buttons in agenda_widget.dart');
} else {
  console.error('Could not find oldButtonsPattern');
}

// In Tab 2 (confirmed/treated list), update the static "Confirmé" badge to reflect actual status
const oldTab2Badge = `Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Color(0xFFE8F5E9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      'Confirmé',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF00A651),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),`;

const newTab2Badge = `Builder(
                                                    builder: (context) {
                                                      final st = appt.status;
                                                      Color bg = Color(0xFFE8F5E9);
                                                      Color txt = Color(0xFF00A651);
                                                      String label = 'Confirmé';
                                                      if (st == 'rescheduled') {
                                                        bg = Color(0xFFFFF3CD);
                                                        txt = Color(0xFFE67E22);
                                                        label = 'Reporté';
                                                      } else if (st == 'refused') {
                                                        bg = Color(0xFFFFEBEE);
                                                        txt = Colors.red.shade700;
                                                        label = 'Refusé';
                                                      } else if (st == 'cancelled') {
                                                        bg = Color(0xFFEEEEEE);
                                                        txt = Colors.grey.shade700;
                                                        label = 'Annulé';
                                                      }
                                                      return Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                            decoration: BoxDecoration(
                                                              color: bg,
                                                              borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Text(
                                                              label,
                                                              style: TextStyle(color: txt, fontSize: 11, fontWeight: FontWeight.w600),
                                                            ),
                                                          ),
                                                          if (st == 'confirmed') ...[
                                                            SizedBox(width: 6),
                                                            InkWell(
                                                              onTap: () => _rescheduleAppointment(context, appt),
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                decoration: BoxDecoration(
                                                                  color: Color(0xFFE67E22).withOpacity(0.12),
                                                                  borderRadius: BorderRadius.circular(6),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Icon(Icons.schedule, size: 12, color: Color(0xFFE67E22)),
                                                                    SizedBox(width: 3),
                                                                    Text('Reporter', style: TextStyle(color: Color(0xFFE67E22), fontSize: 10, fontWeight: FontWeight.bold)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ],
                                                      );
                                                    },
                                                  ),`;

// Standardize CRLF in comparison
const normContent = content.replace(/\r\n/g, '\n');
const normOldTab2Badge = oldTab2Badge.replace(/\r\n/g, '\n');

if (normContent.includes(normOldTab2Badge)) {
  content = normContent.replace(normOldTab2Badge, newTab2Badge.replace(/\r\n/g, '\n'));
  console.log('Successfully replaced Tab 2 badge');
} else {
  console.log('Tab 2 badge direct match not found, checking regex');
}

fs.writeFileSync(targetPath, content, 'utf8');
console.log('Finished writing agenda_widget.dart');
