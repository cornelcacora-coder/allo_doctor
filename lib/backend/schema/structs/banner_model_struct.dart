// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BannerModelStruct extends FFFirebaseStruct {
  BannerModelStruct({
    String? image,
    String? title,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _image = image,
        _title = title,
        super(firestoreUtilData);

  // "image" field.
  String? _image;
  String get image => _image ?? '';
  set image(String? val) => _image = val;

  bool hasImage() => _image != null;

  // "title" field.
  String? _title;
  String get title => _title ?? '';
  set title(String? val) => _title = val;

  bool hasTitle() => _title != null;

  static BannerModelStruct fromMap(Map<String, dynamic> data) =>
      BannerModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
      );

  static BannerModelStruct? maybeFromMap(dynamic data) => data is Map
      ? BannerModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'image': serializeParam(
          _image,
          ParamType.String,
        ),
        'title': serializeParam(
          _title,
          ParamType.String,
        ),
      }.withoutNulls;

  static BannerModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      BannerModelStruct(
        image: deserializeParam(
          data['image'],
          ParamType.String,
          false,
        ),
        title: deserializeParam(
          data['title'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'BannerModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BannerModelStruct &&
        image == other.image &&
        title == other.title;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title]);
}

BannerModelStruct createBannerModelStruct({
  String? image,
  String? title,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    BannerModelStruct(
      image: image,
      title: title,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

BannerModelStruct? updateBannerModelStruct(
  BannerModelStruct? bannerModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    bannerModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addBannerModelStructData(
  Map<String, dynamic> firestoreData,
  BannerModelStruct? bannerModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (bannerModel == null) {
    return;
  }
  if (bannerModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && bannerModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final bannerModelData =
      getBannerModelFirestoreData(bannerModel, forFieldValue);
  final nestedData =
      bannerModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = bannerModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getBannerModelFirestoreData(
  BannerModelStruct? bannerModel, [
  bool forFieldValue = false,
]) {
  if (bannerModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(bannerModel.toMap());

  // Add any Firestore field values
  mapToFirestore(bannerModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getBannerModelListFirestoreData(
  List<BannerModelStruct>? bannerModels,
) =>
    bannerModels?.map((e) => getBannerModelFirestoreData(e, true)).toList() ??
    [];
