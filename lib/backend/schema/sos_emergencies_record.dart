import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SosEmergenciesRecord extends FirestoreRecord {
  SosEmergenciesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "patient_ref" field.
  DocumentReference? _patientRef;
  DocumentReference? get patientRef => _patientRef;
  bool hasPatientRef() => _patientRef != null;

  // "patient_phone" field.
  String? _patientPhone;
  String get patientPhone => _patientPhone ?? '';
  bool hasPatientPhone() => _patientPhone != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "emergency_type" field. (Accident, Accouchement, Blessure Grave, Gene Respiratoire, Perte De Connaissance)
  String? _emergencyType;
  String get emergencyType => _emergencyType ?? '';
  bool hasEmergencyType() => _emergencyType != null;

  // "zone" field. (Bacongo, Talangai, Makelekele, etc.)
  String? _zone;
  String get zone => _zone ?? '';
  bool hasZone() => _zone != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "is_patient_conscious" field.
  bool? _isPatientConscious;
  bool get isPatientConscious => _isPatientConscious ?? true;
  bool hasIsPatientConscious() => _isPatientConscious != null;

  // "is_oxygen_required" field.
  bool? _isOxygenRequired;
  bool get isOxygenRequired => _isOxygenRequired ?? false;
  bool hasIsOxygenRequired() => _isOxygenRequired != null;

  // "status" field. (Declenche, Pris en charge, Cloture)
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  void _initializeFields() {
    _patientRef = snapshotData['patient_ref'] as DocumentReference?;
    _patientPhone = snapshotData['patient_phone'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _emergencyType = snapshotData['emergency_type'] as String?;
    _zone = snapshotData['zone'] as String?;
    _address = snapshotData['address'] as String?;
    _isPatientConscious = snapshotData['is_patient_conscious'] as bool?;
    _isOxygenRequired = snapshotData['is_oxygen_required'] as bool?;
    _status = snapshotData['status'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('sos_emergencies');

  static Stream<SosEmergenciesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => SosEmergenciesRecord.fromSnapshot(s));

  static Future<SosEmergenciesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => SosEmergenciesRecord.fromSnapshot(s));

  static SosEmergenciesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      SosEmergenciesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static SosEmergenciesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      SosEmergenciesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'SosEmergenciesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is SosEmergenciesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createSosEmergenciesRecordData({
  DocumentReference? patientRef,
  String? patientPhone,
  LatLng? location,
  String? emergencyType,
  String? zone,
  String? address,
  bool? isPatientConscious,
  bool? isOxygenRequired,
  String? status,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'patient_ref': patientRef,
      'patient_phone': patientPhone,
      'location': location,
      'emergency_type': emergencyType,
      'zone': zone,
      'address': address,
      'is_patient_conscious': isPatientConscious,
      'is_oxygen_required': isOxygenRequired,
      'status': status,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class SosEmergenciesRecordDocumentEquality
    implements Equality<SosEmergenciesRecord> {
  const SosEmergenciesRecordDocumentEquality();

  @override
  bool equals(SosEmergenciesRecord? e1, SosEmergenciesRecord? e2) {
    return e1?.patientRef == e2?.patientRef &&
        e1?.patientPhone == e2?.patientPhone &&
        e1?.location == e2?.location &&
        e1?.emergencyType == e2?.emergencyType &&
        e1?.zone == e2?.zone &&
        e1?.address == e2?.address &&
        e1?.isPatientConscious == e2?.isPatientConscious &&
        e1?.isOxygenRequired == e2?.isOxygenRequired &&
        e1?.status == e2?.status &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(SosEmergenciesRecord? e) => const ListEquality().hash([
        e?.patientRef,
        e?.patientPhone,
        e?.location,
        e?.emergencyType,
        e?.zone,
        e?.address,
        e?.isPatientConscious,
        e?.isOxygenRequired,
        e?.status,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is SosEmergenciesRecord;
}
