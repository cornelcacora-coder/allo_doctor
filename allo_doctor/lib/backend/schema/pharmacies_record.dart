import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PharmaciesRecord extends FirestoreRecord {
  PharmaciesRecord._(
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

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "is_guard" field.
  bool? _isGuard;
  bool get isGuard => _isGuard ?? false;
  bool hasIsGuard() => _isGuard != null;

  // "guard_hours" field.
  String? _guardHours;
  String get guardHours => _guardHours ?? '';
  bool hasGuardHours() => _guardHours != null;

  // "owner_ref" field.
  DocumentReference? _ownerRef;
  DocumentReference? get ownerRef => _ownerRef;
  bool hasOwnerRef() => _ownerRef != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _address = snapshotData['address'] as String?;
    _city = snapshotData['city'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _isGuard = snapshotData['is_guard'] as bool?;
    _guardHours = snapshotData['guard_hours'] as String?;
    _ownerRef = snapshotData['owner_ref'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('pharmacies');

  static Stream<PharmaciesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PharmaciesRecord.fromSnapshot(s));

  static Future<PharmaciesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PharmaciesRecord.fromSnapshot(s));

  static PharmaciesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PharmaciesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PharmaciesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PharmaciesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PharmaciesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PharmaciesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPharmaciesRecordData({
  String? name,
  String? address,
  String? city,
  LatLng? location,
  String? phoneNumber,
  bool? isGuard,
  String? guardHours,
  DocumentReference? ownerRef,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'address': address,
      'city': city,
      'location': location,
      'phone_number': phoneNumber,
      'is_guard': isGuard,
      'guard_hours': guardHours,
      'owner_ref': ownerRef,
    }.withoutNulls,
  );

  return firestoreData;
}

class PharmaciesRecordDocumentEquality implements Equality<PharmaciesRecord> {
  const PharmaciesRecordDocumentEquality();

  @override
  bool equals(PharmaciesRecord? e1, PharmaciesRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.address == e2?.address &&
        e1?.city == e2?.city &&
        e1?.location == e2?.location &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.isGuard == e2?.isGuard &&
        e1?.guardHours == e2?.guardHours &&
        e1?.ownerRef == e2?.ownerRef;
  }

  @override
  int hash(PharmaciesRecord? e) => const ListEquality().hash([
        e?.name,
        e?.address,
        e?.city,
        e?.location,
        e?.phoneNumber,
        e?.isGuard,
        e?.guardHours,
        e?.ownerRef
      ]);

  @override
  bool isValidKey(Object? o) => o is PharmaciesRecord;
}
