const fs = require('fs');
const file = 'lib/doctor/agenda/agenda_widget.dart';
let c = fs.readFileSync(file, 'utf8');

// 1. Update _initStreams query for confirmed tab to include rescheduled and refused
const oldInit = `      _confirmedAppointmentsStream = queryAppointmentsRecord(
        queryBuilder: (q) => q.where('status', isEqualTo: 'confirmed'),
        limit: 50,
      );`;

const newInit = `      _confirmedAppointmentsStream = queryAppointmentsRecord(
        queryBuilder: (q) => q.where('status', whereIn: ['confirmed', 'rescheduled', 'cancelled', 'refused']),
        limit: 50,
      );`;

// 2. Add _rescheduleAppointment method
const methodHelper = `
  Future<void> _rescheduleAppointment(BuildContext context, AppointmentsRecord appt) async {
    final dayController = TextEditingController(text: appt.day.isNotEmpty ? appt.day : 'Demain');
    final timeController = TextEditingController(text: appt.timeSlot.isNotEmpty ? appt.timeSlot : '10h00 - 10h30');
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.schedule_send_rounded, color: Color(0xFFE67E22)),
            SizedBox(width: 8),
            Text('Reporter le rendez-vous', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient : \${appt.patientName.isNotEmpty ? appt.patientName : "Patient"}',
                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: FlutterFlowTheme.of(context).primaryText),
              ),
              SizedBox(height: 14),
              TextField(
                controller: dayController,
                decoration: InputDecoration(
                  labelText: 'Nouvelle date (ex: Demain, 26 Octobre)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Nouveau créneau (ex: 11h - 11h30)',
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Motif du report (visible par le patient)',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text('Annuler', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE67E22),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await appt.reference.update({
                'status': 'rescheduled',
                'rescheduled_day': dayController.text.trim(),
                'rescheduled_slot': timeController.text.trim(),
                'rescheduled_note': noteController.text.trim(),
                'updated_at': FieldValue.serverTimestamp(),
              });
              if (dCtx.mounted) Navigator.pop(dCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rendez-vous reporté. Le patient en est informé ✓'),
                    backgroundColor: Color(0xFFE67E22),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Confirmer le report', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
`;

// Insert method before @override initState
const initMarker = '@override\n  void initState() {';
const initMarkerCRLF = '@override\r\n  void initState() {';

const isCrlf = c.includes('\r\n');
if (isCrlf) {
  c = c.replace(oldInit.replace(/\n/g, '\r\n'), newInit.replace(/\n/g, '\r\n'));
  c = c.replace(initMarkerCRLF, methodHelper.replace(/\n/g, '\r\n') + '\r\n  ' + initMarkerCRLF);
} else {
  c = c.replace(oldInit, newInit);
  c = c.replace(initMarker, methodHelper + '\n  ' + initMarker);
}

// 3. Replace the 2 action buttons (Confirmer / Annuler) with 3 buttons (Valider / Reporter / Refuser)
const oldButtons = `                                                   Row(
                                                     children: [
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await appt.reference
                                                                 .update({
                                                               'status':
                                                                   'confirmed',
                                                               'updated_at': FieldValue
                                                                   .serverTimestamp(),
                                                             });
                                                             ScaffoldMessenger.of(
                                                                     context)
                                                                 .showSnackBar(
                                                               SnackBar(
                                                                 content: Text(
                                                                     'RDV confirmé ✓'),
                                                                 backgroundColor:
                                                                     Color(
                                                                         0xFF00A651),
                                                                 behavior:
                                                                     SnackBarBehavior
                                                                         .floating,
                                                                 margin:
                                                                     EdgeInsets.all(
                                                                         16),
                                                                 shape:
                                                                     RoundedRectangleBorder(
                                                                   borderRadius:
                                                                       BorderRadius
                                                                           .circular(
                                                                               12),
                                                                 ),
                                                               ),
                                                             );
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration:
                                                                 BoxDecoration(
                                                               gradient:
                                                                   LinearGradient(
                                                                 colors: [
                                                                   Color(
                                                                       0xFF1E1458),
                                                                   Color(
                                                                       0xFF165AC5)
                                                                 ],
                                                                 begin:
                                                                     AlignmentDirectional(
                                                                         1, -1),
                                                                 end:
                                                                     AlignmentDirectional(
                                                                         -1, 1),
                                                               ),
                                                               borderRadius:
                                                                   BorderRadius
                                                                       .circular(
                                                                           8),
                                                               ),
                                                             child: Center(
                                                               child: Text(
                                                                 'Confirmer',
                                                                 style: TextStyle(
                                                                   color: Colors
                                                                       .white,
                                                                   fontWeight:
                                                                       FontWeight
                                                                           .w600,
                                                                   fontSize: 13,
                                                                 ),
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                       SizedBox(width: 8),
                                                       Expanded(
                                                         child: GestureDetector(
                                                           onTap: () async {
                                                             await appt.reference
                                                                 .update({
                                                               'status':
                                                                   'cancelled',
                                                               'updated_at': FieldValue
                                                                   .serverTimestamp(),
                                                             });
                                                           },
                                                           child: Container(
                                                             height: 36,
                                                             decoration:
                                                                 BoxDecoration(
                                                               color: FlutterFlowTheme
                                                                       .of(context)
                                                                   .primaryBackground,
                                                               borderRadius:
                                                                   BorderRadius
                                                                       .circular(
                                                                           8),
                                                               border: Border.all(
                                                                   color: Colors
                                                                       .red
                                                                       .shade200),
                                                             ),
                                                             child: Center(
                                                               child: Text(
                                                                 'Annuler',
                                                                 style: TextStyle(
                                                                   color: Colors
                                                                       .red
                                                                       .shade600,
                                                                   fontWeight:
                                                                       FontWeight
                                                                           .w600,
                                                                   fontSize: 13,
                                                                 ),
                                                               ),
                                                             ),
                                                           ),
                                                         ),
                                                       ),
                                                     ],
                                                   ),`;

const newButtons = `                                                   Row(
                                                     children: [
                                                       // Bouton 1: Valider
                                                       Expanded(
                                                         child: ElevatedButton(
                                                           style: ElevatedButton.styleFrom(
                                                             backgroundColor: Color(0xFF16CB83),
                                                             foregroundColor: Colors.white,
                                                             padding: EdgeInsets.symmetric(vertical: 8),
                                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                             elevation: 0,
                                                           ),
                                                           onPressed: () async {
                                                             await appt.reference.update({
                                                               'status': 'confirmed',
                                                               'updated_at': FieldValue.serverTimestamp(),
                                                             });
                                                             ScaffoldMessenger.of(context).showSnackBar(
                                                               SnackBar(
                                                                 content: Text('Rendez-vous validé et confirmé ✓'),
                                                                 backgroundColor: Color(0xFF16CB83),
                                                                 behavior: SnackBarBehavior.floating,
                                                               ),
                                                             );
                                                           },
                                                           child: Text('Valider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // Bouton 2: Reporter
                                                       Expanded(
                                                         child: ElevatedButton(
                                                           style: ElevatedButton.styleFrom(
                                                             backgroundColor: Color(0xFFE67E22),
                                                             foregroundColor: Colors.white,
                                                             padding: EdgeInsets.symmetric(vertical: 8),
                                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                             elevation: 0,
                                                           ),
                                                           onPressed: () => _rescheduleAppointment(context, appt),
                                                           child: Text('Reporter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                         ),
                                                       ),
                                                       SizedBox(width: 6),
                                                       // Bouton 3: Refuser
                                                       Expanded(
                                                         child: OutlinedButton(
                                                           style: OutlinedButton.styleFrom(
                                                             foregroundColor: Colors.red.shade700,
                                                             side: BorderSide(color: Colors.red.shade300),
                                                             padding: EdgeInsets.symmetric(vertical: 8),
                                                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                           ),
                                                           onPressed: () async {
                                                             await appt.reference.update({
                                                               'status': 'refused',
                                                               'updated_at': FieldValue.serverTimestamp(),
                                                             });
                                                             ScaffoldMessenger.of(context).showSnackBar(
                                                               SnackBar(
                                                                 content: Text('Rendez-vous refusé'),
                                                                 backgroundColor: Colors.red,
                                                                 behavior: SnackBarBehavior.floating,
                                                               ),
                                                             );
                                                           },
                                                           child: Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                         ),
                                                       ),
                                                     ],
                                                   ),`;

const oldNorm = isCrlf ? oldButtons.replace(/\n/g, '\r\n') : oldButtons;
const newNorm = isCrlf ? newButtons.replace(/\n/g, '\r\n') : newButtons;

if (c.includes(oldNorm)) {
  c = c.replace(oldNorm, newNorm);
  console.log('Action buttons replaced successfully');
} else {
  console.log('Action buttons pattern not found');
}

fs.writeFileSync(file, c, 'utf8');
console.log('Finished updating agenda_widget.dart');
