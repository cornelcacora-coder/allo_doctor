// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CategoryModelStruct extends FFFirebaseStruct {
  CategoryModelStruct({
    String? image,
    String? name,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _image = image,
        _name = name,
        super(firestoreUtilData);

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  static CategoryModelStruct fromMap(Map<String, dynamic> data) =>
      CategoryModelStruct(
        image: data['image'] as String?,
        name: data['name'] as String?,
      );

  static CategoryModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CategoryModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'name': _name,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
      }.withoutNulls;

  static CategoryModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      CategoryModelStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'CategoryModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CategoryModelStruct &&
        image == other.image &&
        name == other.name;
  }

  @override
  int get hashCode => const ListEquality().hash([image, name]);
}

CategoryModelStruct createCategoryModelStruct({
  String? image,
  String? name,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CategoryModelStruct(
      image: image,
      name: name,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CategoryModelStruct? updateCategoryModelStruct(
  CategoryModelStruct? categoryModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    categoryModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCategoryModelStructData(
  Map<String, dynamic> firestoreData,
  CategoryModelStruct? categoryModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (categoryModel == null) {
    return;
  }
  if (categoryModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && categoryModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final categoryModelData =
      getCategoryModelFirestoreData(categoryModel, forFieldValue);
  final nestedData =
      categoryModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = categoryModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCategoryModelFirestoreData(
  CategoryModelStruct? categoryModel, [
  bool forFieldValue = false,
]) {
  if (categoryModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(categoryModel.toMap());

  // Add any Firestore field values
  mapToFirestore(categoryModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCategoryModelListFirestoreData(
  List<CategoryModelStruct>? categoryModels,
) =>
    categoryModels
        ?.map((e) => getCategoryModelFirestoreData(e, true))
        .toList() ??
    [];
