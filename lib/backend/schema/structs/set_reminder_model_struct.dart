// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SetReminderModelStruct extends FFFirebaseStruct {
  SetReminderModelStruct({
    DateTime? time,
    bool? isRemind,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _time = time,
        _isRemind = isRemind,
        super(firestoreUtilData);

  // "time" field.
  DateTime? _time;
  DateTime? get time => _time;
  set time(DateTime? val) => _time = val;

  bool hasTime() => _time != null;

  // "isRemind" field.
  bool? _isRemind;
  bool get isRemind => _isRemind ?? false;
  set isRemind(bool? val) => _isRemind = val;

  bool hasIsRemind() => _isRemind != null;

  static SetReminderModelStruct fromMap(Map<String, dynamic> data) =>
      SetReminderModelStruct(
        time: data['time'] as DateTime?,
        isRemind: data['isRemind'] as bool?,
      );

  static SetReminderModelStruct? maybeFromMap(dynamic data) => data is Map
      ? SetReminderModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'time': _time,
        'isRemind': _isRemind,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'time': serializeParam(
          _time,
          ParamType.DateTime,
        ),
        'isRemind': serializeParam(
          _isRemind,
          ParamType.bool,
        ),
      }.withoutNulls;

  static SetReminderModelStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      SetReminderModelStruct(
        time: deserializeParam(
          data['time'],
          ParamType.DateTime,
          false,
        ),
        isRemind: deserializeParam(
          data['isRemind'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'SetReminderModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is SetReminderModelStruct &&
        time == other.time &&
        isRemind == other.isRemind;
  }

  @override
  int get hashCode => const ListEquality().hash([time, isRemind]);
}

SetReminderModelStruct createSetReminderModelStruct({
  DateTime? time,
  bool? isRemind,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    SetReminderModelStruct(
      time: time,
      isRemind: isRemind,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

SetReminderModelStruct? updateSetReminderModelStruct(
  SetReminderModelStruct? setReminderModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    setReminderModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addSetReminderModelStructData(
  Map<String, dynamic> firestoreData,
  SetReminderModelStruct? setReminderModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (setReminderModel == null) {
    return;
  }
  if (setReminderModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && setReminderModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final setReminderModelData =
      getSetReminderModelFirestoreData(setReminderModel, forFieldValue);
  final nestedData =
      setReminderModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = setReminderModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getSetReminderModelFirestoreData(
  SetReminderModelStruct? setReminderModel, [
  bool forFieldValue = false,
]) {
  if (setReminderModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(setReminderModel.toMap());

  // Add any Firestore field values
  mapToFirestore(setReminderModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getSetReminderModelListFirestoreData(
  List<SetReminderModelStruct>? setReminderModels,
) =>
    setReminderModels
        ?.map((e) => getSetReminderModelFirestoreData(e, true))
        .toList() ??
    [];
