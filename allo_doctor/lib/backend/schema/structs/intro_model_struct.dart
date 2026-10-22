// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class IntroModelStruct extends FFFirebaseStruct {
  IntroModelStruct({
    String? image,
    String? title,
    String? subTitle,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _image = image,
        _title = title,
        _subTitle = subTitle,
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

  // "subTitle" field.
  String? _subTitle;
  String get subTitle => _subTitle ?? '';
  set subTitle(String? val) => _subTitle = val;

  bool hasSubTitle() => _subTitle != null;

  static IntroModelStruct fromMap(Map<String, dynamic> data) =>
      IntroModelStruct(
        image: data['image'] as String?,
        title: data['title'] as String?,
        subTitle: data['subTitle'] as String?,
      );

  static IntroModelStruct? maybeFromMap(dynamic data) => data is Map
      ? IntroModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'title': _title,
        'subTitle': _subTitle,
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
        'subTitle': serializeParam(
          _subTitle,
          ParamType.String,
        ),
      }.withoutNulls;

  static IntroModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      IntroModelStruct(
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
        subTitle: deserializeParam(
          data['subTitle'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'IntroModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is IntroModelStruct &&
        image == other.image &&
        title == other.title &&
        subTitle == other.subTitle;
  }

  @override
  int get hashCode => const ListEquality().hash([image, title, subTitle]);
}

IntroModelStruct createIntroModelStruct({
  String? image,
  String? title,
  String? subTitle,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    IntroModelStruct(
      image: image,
      title: title,
      subTitle: subTitle,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

IntroModelStruct? updateIntroModelStruct(
  IntroModelStruct? introModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    introModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addIntroModelStructData(
  Map<String, dynamic> firestoreData,
  IntroModelStruct? introModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (introModel == null) {
    return;
  }
  if (introModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && introModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final introModelData = getIntroModelFirestoreData(introModel, forFieldValue);
  final nestedData = introModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = introModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getIntroModelFirestoreData(
  IntroModelStruct? introModel, [
  bool forFieldValue = false,
]) {
  if (introModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(introModel.toMap());

  // Add any Firestore field values
  mapToFirestore(introModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getIntroModelListFirestoreData(
  List<IntroModelStruct>? introModels,
) =>
    introModels?.map((e) => getIntroModelFirestoreData(e, true)).toList() ?? [];
