import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PrescriptionsRecord extends FirestoreRecord {
  PrescriptionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "patient_ref" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "doctor_ref" field.
  DocumentReference? _doctorRef;
  DocumentReference? get doctorRef => _doctorRef;
  bool hasDoctorRef() => _doctorRef != null;

  // "pharmacy_ref" field.
  DocumentReference? _pharmacyRef;
  DocumentReference? get pharmacyRef => _pharmacyRef;
  bool hasPharmacyRef() => _pharmacyRef != null;

  // "medications" field.
  List<String>? _medications;
  List<String> get medications => _medications ?? const [];
  bool hasMedications() => _medications != null;

  // "status" field. (Active, En preparation, Delivree, Expiree)
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "notes" field.
  String? _notes;
  String get notes => _notes ?? '';
  bool hasNotes() => _notes != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _doctorRef = snapshotData['doctor_ref'] as DocumentReference?;
    _pharmacyRef = snapshotData['pharmacy_ref'] as DocumentReference?;
    _medications = getDataList(snapshotData['medications']);
    _status = snapshotData['status'] as String?;
    _notes = snapshotData['notes'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('prescriptions');

  static Stream<PrescriptionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PrescriptionsRecord.fromSnapshot(s));

  static Future<PrescriptionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PrescriptionsRecord.fromSnapshot(s));

  static PrescriptionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PrescriptionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PrescriptionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PrescriptionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PrescriptionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PrescriptionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPrescriptionsRecordData({
  DocumentReference? patientRef,
  DocumentReference? doctorRef,
  DocumentReference? pharmacyRef,
  List<String>? medications,
  String? status,
  String? notes,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'doctor_ref': doctorRef,
      'pharmacy_ref': pharmacyRef,
      'medications': medications,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PrescriptionsRecordDocumentEquality
    implements Equality<PrescriptionsRecord> {
  const PrescriptionsRecordDocumentEquality();

  @override
  bool equals(PrescriptionsRecord? e1, PrescriptionsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.patientRef == e2?.patientRef &&
        e1?.doctorRef == e2?.doctorRef &&
        e1?.pharmacyRef == e2?.pharmacyRef &&
        listEquality.equals(e1?.medications, e2?.medications) &&
        e1?.status == e2?.status &&
        e1?.notes == e2?.notes &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(PrescriptionsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.doctorRef,
        e?.pharmacyRef,
        e?.medications,
        e?.status,
        e?.notes,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PrescriptionsRecord;
}
