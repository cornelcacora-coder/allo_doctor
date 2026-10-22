// ignore_for_file: unnecessary_getters_setters

import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class CourseModelStruct extends FFFirebaseStruct {
  CourseModelStruct({
    String? image,
    String? name,
    double? reviews,
    String? totalReviews,
    double? price,
    FirestoreUtilData firestoreUtilData = const FirestoreUtilData(),
  })  : _image = image,
        _name = name,
        _reviews = reviews,
        _totalReviews = totalReviews,
        _price = price,
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

  // "reviews" field.
  double? _reviews;
  double get reviews => _reviews ?? 0.0;
  set reviews(double? val) => _reviews = val;

  void incrementReviews(double amount) => reviews = reviews + amount;

  bool hasReviews() => _reviews != null;

  // "totalReviews" field.
  String? _totalReviews;
  String get totalReviews => _totalReviews ?? '';
  set totalReviews(String? val) => _totalReviews = val;

  bool hasTotalReviews() => _totalReviews != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  set price(double? val) => _price = val;

  void incrementPrice(double amount) => price = price + amount;

  bool hasPrice() => _price != null;

  static CourseModelStruct fromMap(Map<String, dynamic> data) =>
      CourseModelStruct(
        image: data['image'] as String?,
        name: data['name'] as String?,
        reviews: castToType<double>(data['reviews']),
        totalReviews: data['totalReviews'] as String?,
        price: castToType<double>(data['price']),
      );

  static CourseModelStruct? maybeFromMap(dynamic data) => data is Map
      ? CourseModelStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'image': _image,
        'name': _name,
        'reviews': _reviews,
        'totalReviews': _totalReviews,
        'price': _price,
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
        'reviews': serializeParam(
          _reviews,
          ParamType.double,
        ),
        'totalReviews': serializeParam(
          _totalReviews,
          ParamType.String,
        ),
        'price': serializeParam(
          _price,
          ParamType.double,
        ),
      }.withoutNulls;

  static CourseModelStruct fromSerializableMap(Map<String, dynamic> data) =>
      CourseModelStruct(
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
        reviews: deserializeParam(
          data['reviews'],
          ParamType.double,
          false,
        ),
        totalReviews: deserializeParam(
          data['totalReviews'],
          ParamType.String,
          false,
        ),
        price: deserializeParam(
          data['price'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'CourseModelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is CourseModelStruct &&
        image == other.image &&
        name == other.name &&
        reviews == other.reviews &&
        totalReviews == other.totalReviews &&
        price == other.price;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([image, name, reviews, totalReviews, price]);
}

CourseModelStruct createCourseModelStruct({
  String? image,
  String? name,
  double? reviews,
  String? totalReviews,
  double? price,
  Map<String, dynamic> fieldValues = const {},
  bool clearUnsetFields = true,
  bool create = false,
  bool delete = false,
}) =>
    CourseModelStruct(
      image: image,
      name: name,
      reviews: reviews,
      totalReviews: totalReviews,
      price: price,
      firestoreUtilData: FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
        delete: delete,
        fieldValues: fieldValues,
      ),
    );

CourseModelStruct? updateCourseModelStruct(
  CourseModelStruct? courseModel, {
  bool clearUnsetFields = true,
  bool create = false,
}) =>
    courseModel
      ?..firestoreUtilData = FirestoreUtilData(
        clearUnsetFields: clearUnsetFields,
        create: create,
      );

void addCourseModelStructData(
  Map<String, dynamic> firestoreData,
  CourseModelStruct? courseModel,
  String fieldName, [
  bool forFieldValue = false,
]) {
  firestoreData.remove(fieldName);
  if (courseModel == null) {
    return;
  }
  if (courseModel.firestoreUtilData.delete) {
    firestoreData[fieldName] = FieldValue.delete();
    return;
  }
  final clearFields =
      !forFieldValue && courseModel.firestoreUtilData.clearUnsetFields;
  if (clearFields) {
    firestoreData[fieldName] = <String, dynamic>{};
  }
  final courseModelData =
      getCourseModelFirestoreData(courseModel, forFieldValue);
  final nestedData =
      courseModelData.map((k, v) => MapEntry('$fieldName.$k', v));

  final mergeFields = courseModel.firestoreUtilData.create || clearFields;
  firestoreData
      .addAll(mergeFields ? mergeNestedFields(nestedData) : nestedData);
}

Map<String, dynamic> getCourseModelFirestoreData(
  CourseModelStruct? courseModel, [
  bool forFieldValue = false,
]) {
  if (courseModel == null) {
    return {};
  }
  final firestoreData = mapToFirestore(courseModel.toMap());

  // Add any Firestore field values
  mapToFirestore(courseModel.firestoreUtilData.fieldValues)
      .forEach((k, v) => firestoreData[k] = v);

  return forFieldValue ? mergeNestedFields(firestoreData) : firestoreData;
}

List<Map<String, dynamic>> getCourseModelListFirestoreData(
  List<CourseModelStruct>? courseModels,
) =>
    courseModels?.map((e) => getCourseModelFirestoreData(e, true)).toList() ??
    [];
