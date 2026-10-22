import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LabResultsRecord extends FirestoreRecord {
  LabResultsRecord._(
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

  // "clinic_ref" field.
  DocumentReference? _clinicRef;
  DocumentReference? get clinicRef => _clinicRef;
  bool hasClinicRef() => _clinicRef != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  bool hasTitle() => _title != null;

  // "file_url" field.
  String? _fileUrl;
  String get fileUrl => _fileUrl ?? '';
  bool hasFileUrl() => _fileUrl != null;

  // "status" field. (En attente, Valide)
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "uploaded_at" field.
  DateTime? _uploadedAt;
  DateTime? get uploadedAt => _uploadedAt;
  bool hasUploadedAt() => _uploadedAt != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _doctorRef = snapshotData['doctor_ref'] as DocumentReference?;
    _clinicRef = snapshotData['clinic_ref'] as DocumentReference?;
    _title = snapshotData['title'] as String?;
    _fileUrl = snapshotData['file_url'] as String?;
    _status = snapshotData['status'] as String?;
    _uploadedAt = snapshotData['uploaded_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('lab_results');

  static Stream<LabResultsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LabResultsRecord.fromSnapshot(s));

  static Future<LabResultsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LabResultsRecord.fromSnapshot(s));

  static LabResultsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LabResultsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LabResultsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LabResultsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LabResultsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LabResultsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLabResultsRecordData({
  DocumentReference? patientRef,
  DocumentReference? doctorRef,
  DocumentReference? clinicRef,
  String? title,
  String? fileUrl,
  String? status,
  DateTime? uploadedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'doctor_ref': doctorRef,
      'clinic_ref': clinicRef,
      'title': title,
      'file_url': fileUrl,
      'status': status,
      'uploaded_at': uploadedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class LabResultsRecordDocumentEquality implements Equality<LabResultsRecord> {
  const LabResultsRecordDocumentEquality();

  @override
  bool equals(LabResultsRecord? e1, LabResultsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.doctorRef == e2?.doctorRef &&
        e1?.clinicRef == e2?.clinicRef &&
        e1?.title == e2?.title &&
        e1?.fileUrl == e2?.fileUrl &&
        e1?.status == e2?.status &&
        e1?.uploadedAt == e2?.uploadedAt;
  }

  @override
  int hash(LabResultsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.doctorRef,
        e?.clinicRef,
        e?.title,
        e?.fileUrl,
        e?.status,
        e?.uploadedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is LabResultsRecord;
}
