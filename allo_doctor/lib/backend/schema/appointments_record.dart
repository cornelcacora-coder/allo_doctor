import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AppointmentsRecord extends FirestoreRecord {
  AppointmentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "patient_ref" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "patient_name" field.
  String? _patientName;
  String get patientName => _patientName ?? '';
  bool hasPatientName() => _patientName != null;

  // "patient_email" field.
  String? _patientEmail;
  String get patientEmail => _patientEmail ?? '';
  bool hasPatientEmail() => _patientEmail != null;

  // "doctor_ref" field.
  DocumentReference? _doctorRef;
  DocumentReference? get doctorRef => _doctorRef;
  bool hasDoctorRef() => _doctorRef != null;

  // "clinic_ref" field.
  DocumentReference? _clinicRef;
  DocumentReference? get clinicRef => _clinicRef;
  bool hasClinicRef() => _clinicRef != null;

  // "date_time" field.
  DateTime? _dateTime;
  DateTime? get dateTime => _dateTime;
  bool hasDateTime() => _dateTime != null;

  // "appointment_type" field.
  String? _appointmentType;
  String get appointmentType => _appointmentType ?? '';
  bool hasAppointmentType() => _appointmentType != null;

  // "consult_mode" field.
  String? _consultMode;
  String get consultMode => _consultMode ?? 'cabinet';
  bool hasConsultMode() => _consultMode != null;

  // "day" field.
  String? _day;
  String get day => _day ?? '';
  bool hasDay() => _day != null;

  // "time_slot" field.
  String? _timeSlot;
  String get timeSlot => _timeSlot ?? '';
  bool hasTimeSlot() => _timeSlot != null;

  // "type" field. (Cabinet / Teleconsultation)
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "status" field. (En attente, Confirme, Termine, Annule)
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "symptoms" field.
  String? _symptoms;
  String get symptoms => _symptoms ?? '';
  bool hasSymptoms() => _symptoms != null;

  // "fee" field.
  double? _fee;
  double get fee => _fee ?? 0.0;
  bool hasFee() => _fee != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updated_at" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _patientName = snapshotData['patient_name'] as String?;
    _patientEmail = snapshotData['patient_email'] as String?;
    _doctorRef = snapshotData['doctor_ref'] as DocumentReference?;
    _clinicRef = snapshotData['clinic_ref'] as DocumentReference?;
    _dateTime = snapshotData['date_time'] as DateTime?;
    _appointmentType = snapshotData['appointment_type'] as String?;
    _consultMode = snapshotData['consult_mode'] as String?;
    _day = snapshotData['day'] as String?;
    _timeSlot = snapshotData['time_slot'] as String?;
    _type = snapshotData['type'] as String?;
    _status = snapshotData['status'] as String?;
    _symptoms = snapshotData['symptoms'] as String?;
    _fee = castToNullableNumber(snapshotData['fee'])?.toDouble();
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updatedAt = snapshotData['updated_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('appointments');

  static Stream<AppointmentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AppointmentsRecord.fromSnapshot(s));

  static Future<AppointmentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AppointmentsRecord.fromSnapshot(s));

  static AppointmentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      AppointmentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AppointmentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AppointmentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AppointmentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AppointmentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAppointmentsRecordData({
  DocumentReference? patientRef,
  String? patientName,
  String? patientEmail,
  DocumentReference? doctorRef,
  DocumentReference? clinicRef,
  DateTime? dateTime,
  String? appointmentType,
  String? consultMode,
  String? day,
  String? timeSlot,
  String? type,
  String? status,
  String? symptoms,
  double? fee,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'patient_name': patientName,
      'patient_email': patientEmail,
      'doctor_ref': doctorRef,
      'clinic_ref': clinicRef,
      'date_time': dateTime,
      'appointment_type': appointmentType,
      'consult_mode': consultMode,
      'day': day,
      'time_slot': timeSlot,
      'type': type,
      'status': status,
      'symptoms': symptoms,
      'fee': fee,
      'created_at': createdAt,
      'updated_at': updatedAt,
    }.withoutNulls,
  );
  return firestoreData;
}

class AppointmentsRecordDocumentEquality
    implements Equality<AppointmentsRecord> {
  const AppointmentsRecordDocumentEquality();

  @override
  bool equals(AppointmentsRecord? e1, AppointmentsRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.patientName == e2?.patientName &&
        e1?.patientEmail == e2?.patientEmail &&
        e1?.doctorRef == e2?.doctorRef &&
        e1?.clinicRef == e2?.clinicRef &&
        e1?.dateTime == e2?.dateTime &&
        e1?.appointmentType == e2?.appointmentType &&
        e1?.consultMode == e2?.consultMode &&
        e1?.day == e2?.day &&
        e1?.timeSlot == e2?.timeSlot &&
        e1?.type == e2?.type &&
        e1?.status == e2?.status &&
        e1?.symptoms == e2?.symptoms &&
        e1?.fee == e2?.fee &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt;
  }

  @override
  int hash(AppointmentsRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.patientName,
        e?.patientEmail,
        e?.doctorRef,
        e?.clinicRef,
        e?.dateTime,
        e?.appointmentType,
        e?.consultMode,
        e?.day,
        e?.timeSlot,
        e?.type,
        e?.status,
        e?.symptoms,
        e?.fee,
        e?.createdAt,
        e?.updatedAt,
      ]);

  @override
  bool isValidKey(Object? o) => o is AppointmentsRecord;
}
