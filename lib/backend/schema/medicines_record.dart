import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class MedicinesRecord extends FirestoreRecord {
  MedicinesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "pharmacy_ref" field.
  DocumentReference? _pharmacyRef;
  DocumentReference? get pharmacyRef => _pharmacyRef;
  bool hasPharmacyRef() => _pharmacyRef != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "category" field.
  String? _category;
  String get category => _category ?? '';
  bool hasCategory() => _category != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "is_low_stock" field.
  bool? _isLowStock;
  bool get isLowStock => _isLowStock ?? false;
  bool hasIsLowStock() => _isLowStock != null;

  // "status" field. (Disponible, Stock faible, Rupture)
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _pharmacyRef = snapshotData['pharmacy_ref'] as DocumentReference?;
    _name = snapshotData['name'] as String?;
    _category = snapshotData['category'] as String?;
    _price = castToNullableNumber(snapshotData['price'])?.toDouble();
    _quantity = castToNullableNumber(snapshotData['quantity'])?.toInt();
    _isLowStock = snapshotData['is_low_stock'] as bool?;
    _status = snapshotData['status'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('medicines');

  static Stream<MedicinesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MedicinesRecord.fromSnapshot(s));

  static Future<MedicinesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MedicinesRecord.fromSnapshot(s));

  static MedicinesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      MedicinesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MedicinesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MedicinesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MedicinesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MedicinesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMedicinesRecordData({
  DocumentReference? pharmacyRef,
  String? name,
  String? category,
  double? price,
  int? quantity,
  bool? isLowStock,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'pharmacy_ref': pharmacyRef,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'is_low_stock': isLowStock,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class MedicinesRecordDocumentEquality implements Equality<MedicinesRecord> {
  const MedicinesRecordDocumentEquality();

  @override
  bool equals(MedicinesRecord? e1, MedicinesRecord? e2) {
    return e1?.pharmacyRef == e2?.pharmacyRef &&
        e1?.name == e2?.name &&
        e1?.category == e2?.category &&
        e1?.price == e2?.price &&
        e1?.quantity == e2?.quantity &&
        e1?.isLowStock == e2?.isLowStock &&
        e1?.status == e2?.status;
  }

  @override
  int hash(MedicinesRecord? e) => const ListEquality().hash([
        e?.pharmacyRef,
        e?.name,
        e?.category,
        e?.price,
        e?.quantity,
        e?.isLowStock,
        e?.status
      ]);

  @override
  bool isValidKey(Object? o) => o is MedicinesRecord;
}
