// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChartModelStruct extends FFFirebaseStruct {
  ChartModelStruct({
    String? xValue,
    String? yValue,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _xValue = xValue,
        _yValue = yValue,
        super(firestoreUtilData);

  // "xValue" field.
  String? _xValue;
  String get xValue => _xValue ?? '';
  set xValue(String? val) => _xValue = val;

  bool hasXValue() => _xValue != null;

  // "yValue" field.
  String? _yValue;
  String get yValue => _yValue ?? '';
  set yValue(String? val) => _yValue = val;

  bool hasYValue() => _yValue != null;

  static ChartModelStruct fromMap(Map<String, dynamic> data) =>
      ChartModelStruct(
        xValue: data['xValue'] as String?,
        yValue: data['yValue'] as String?,
      );

  static ChartModelStruct? maybeFromMap(dynamic data) => data is Map
      ? ChartModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'xValue': _xValue,
        'yValue': _yValue,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'xValue': serializeParam(
          _xValue,
          ParamType.String,
        ),
        'yValue': serializeParam(
          _yValue,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChartModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChartModelStruct(
        xValue: deserializeParam(
          data['xValue'],
          ParamType.String,
          false,
        ),
        yValue: deserializeParam(
          data['yValue'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChartModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChartModelStruct &&
        xValue == other.xValue &&
        yValue == other.yValue;
  }

  @override
  int get hashCode => const ListEquality().hash([xValue, yValue]);
}

ChartModelStruct createChartModelStruct({
  String? xValue,
  String? yValue,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    ChartModelStruct(
      xValue: xValue,
      yValue: yValue,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

ChartModelStruct? updateChartModelStruct(
  ChartModelStruct? chartModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    chartModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addChartModelStructData(
  Map<String, dynamic> firestoreData,
  ChartModelStruct? chartModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (chartModel == null) {
    return;
  }
  if (chartModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && chartModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final chartModelData = getChartModelFirestoreData(chartModel, forFieldValue);
  final nestedData = chartModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = chartModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getChartModelFirestoreData(
  ChartModelStruct? chartModel, [
  bool forFieldValue = false,
]) {
  if (chartModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(chartModel.toMap());

  // Add any Firestore field values
  mapToFirestore(chartModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getChartModelListFirestoreData(
  List<ChartModelStruct>? chartModels,
) =>
    chartModels?.map((e) => getChartModelFirestoreData(e, true)).toList() ?? [];
