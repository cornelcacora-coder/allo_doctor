const fs = require('fs');
const file = 'lib/doctor/agenda/agenda_widget.dart';
let c = fs.readFileSync(file, 'utf8');

const oldSort = `final appointments = List<AppointmentsRecord>.from(
                                        snapshot.data ?? [])
                                      ..sort((a, b) => (b.createdAt ?? DateTime(0))
                                          .compareTo(a.createdAt ?? DateTime(0)));`;

const newSort = `final allAppts = List<AppointmentsRecord>.from(snapshot.data ?? []);
                                    final appointments = allAppts.where((a) {
                                      final docId = a.doctorId;
                                      final docName = a.doctorName;
                                      if (docId.isNotEmpty && currentUserUid.isNotEmpty && docId == currentUserUid) return true;
                                      if (docName.isNotEmpty && currentUserDisplayName.isNotEmpty && docName.toLowerCase() == currentUserDisplayName.toLowerCase()) return true;
                                      return docId.isEmpty && docName.isEmpty;
                                    }).toList()
                                      ..sort((a, b) => (b.createdAt ?? DateTime(0))
                                          .compareTo(a.createdAt ?? DateTime(0)));`;

const isCrlf = c.includes('\r\n');
const oldNorm = isCrlf ? oldSort.replace(/\n/g, '\r\n') : oldSort;
const newNorm = isCrlf ? newSort.replace(/\n/g, '\r\n') : newSort;

if (c.includes(oldNorm)) {
  c = c.split(oldNorm).join(newNorm);
  fs.writeFileSync(file, c, 'utf8');
  console.log('Successfully filtered appointments in agenda_widget.dart');
} else {
  console.log('Sort pattern not found');
}
