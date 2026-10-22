import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClinicsRecord extends FirestoreRecord {
  ClinicsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "staff_refs" field.
  List<DocumentReference>? _staffRefs;
  List<DocumentReference> get staffRefs => _staffRefs ?? const [];
  bool hasStaffRefs() => _staffRefs != null;

  // "services" field.
  List<String>? _services;
  List<String> get services => _services ?? const [];
  bool hasServices() => _services != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _address = snapshotData['address'] as String?;
    _city = snapshotData['city'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _staffRefs = getDataList(snapshotData['staff_refs']);
    _services = getDataList(snapshotData['services']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('clinics');

  static Stream<ClinicsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClinicsRecord.fromSnapshot(s));

  static Future<ClinicsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClinicsRecord.fromSnapshot(s));

  static ClinicsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ClinicsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClinicsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClinicsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClinicsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClinicsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClinicsRecordData({
  String? name,
  String? address,
  String? city,
  String? phoneNumber,
  List<DocumentReference>? staffRefs,
  List<String>? services,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      'phone_number': phoneNumber,
      'staff_refs': staffRefs,
      'services': services,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClinicsRecordDocumentEquality implements Equality<ClinicsRecord> {
  const ClinicsRecordDocumentEquality();

  @override
  bool equals(ClinicsRecord? e1, ClinicsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.address == e2?.address &&
        e1?.city == e2?.city &&
        e1?.phoneNumber == e2?.phoneNumber &&
        listEquality.equals(e1?.staffRefs, e2?.staffRefs) &&
        listEquality.equals(e1?.services, e2?.services);
  }

  @override
  int hash(ClinicsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.address,
        e?.city,
        e?.phoneNumber,
        e?.staffRefs,
        e?.services
      ]);

  @override
  bool isValidKey(Object? o) => o is ClinicsRecord;
}
