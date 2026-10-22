// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CouponModelStruct extends FFFirebaseStruct {
  CouponModelStruct({
    String? name,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _name = name,
        super(firestoreUtilData);

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  static CouponModelStruct fromMap(Map<String, dynamic> data) =>
      CouponModelStruct(
        name: data['name'] as String?,
      );

  static CouponModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CouponModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'name': _name,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
      }.withoutNulls;

  static CouponModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      CouponModelStruct(
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CouponModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CouponModelStruct && name == other.name;
  }

  @override
  int get hashCode => const ListEquality().hash([name]);
}

CouponModelStruct createCouponModelStruct({
  String? name,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CouponModelStruct(
      name: name,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CouponModelStruct? updateCouponModelStruct(
  CouponModelStruct? couponModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    couponModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCouponModelStructData(
  Map<String, dynamic> firestoreData,
  CouponModelStruct? couponModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (couponModel == null) {
    return;
  }
  if (couponModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && couponModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final couponModelData =
      getCouponModelFirestoreData(couponModel, forFieldValue);
  final nestedData =
      couponModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = couponModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCouponModelFirestoreData(
  CouponModelStruct? couponModel, [
  bool forFieldValue = false,
]) {
  if (couponModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(couponModel.toMap());

  // Add any Firestore field values
  mapToFirestore(couponModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCouponModelListFirestoreData(
  List<CouponModelStruct>? couponModels,
) =>
    couponModels?.map((e) => getCouponModelFirestoreData(e, true)).toList() ??
    [];
