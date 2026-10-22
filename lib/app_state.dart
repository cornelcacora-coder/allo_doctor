import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _isIntro = prefs.getBool('ff_isIntro') ?? _isIntro;
    });
    _safeInit(() {
      _isLogin = prefs.getBool('ff_isLogin') ?? _isLogin;
    });
    _safeInit(() {
      _deviceId = prefs.getString('ff_deviceId') ?? _deviceId;
    });
    _safeInit(() {
      _currencyType = prefs.getString('ff_currencyType') ?? _currencyType;
    });
    _safeInit(() {
      if (prefs.containsKey('ff_userDetail')) {
        try {
          final serializedData = prefs.getString('ff_userDetail') ?? '{}';
          _userDetail =
              LoginModelStruct.fromSerializableMap(jsonDecode(serializedData));
        } catch (e) {
          print("Can't decode persisted data type. Error: $e.");
        }
      }
    });
    _safeInit(() {
      _phone = prefs.getString('ff_phone') ?? _phone;
    });
    _safeInit(() {
      _countryCodeEdit =
          prefs.getString('ff_countryCodeEdit') ?? _countryCodeEdit;
    });
    _safeInit(() {
      _countryName = prefs.getString('ff_countryName') ?? _countryName;
    });
    _safeInit(() {
      _searchList = prefs.getStringList('ff_searchList') ?? _searchList;
    });
    _safeInit(() {
      _setReminderList = prefs
              .getStringList('ff_setReminderList')
              ?.map((x) {
                try {
                  return SetReminderModelStruct.fromSerializableMap(
                      jsonDecode(x));
                } catch (e) {
                  print("Can't decode persisted data type. Error: $e.");
                  return null;
                }
              })
              .withoutNulls
              .toList() ??
          _setReminderList;
    });
    _safeInit(() {
      _defTimeZoneName =
          prefs.getString('ff_defTimeZoneName') ?? _defTimeZoneName;
    });
    _safeInit(() {
      _currentPassword =
          prefs.getString('ff_currentPassword') ?? _currentPassword;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  bool _isIntro = false;
  bool get isIntro => _isIntro;
  set isIntro(bool value) {
    _isIntro = value;
    prefs.setBool('ff_isIntro', value);
  }

  bool _isLogin = false;
  bool get isLogin => _isLogin;
  set isLogin(bool value) {
    _isLogin = value;
    prefs.setBool('ff_isLogin', value);
  }

  bool _connected = true;
  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
  }

  String _deviceId = '';
  String get deviceId => _deviceId;
  set deviceId(String value) {
    _deviceId = value;
    prefs.setString('ff_deviceId', value);
  }

  String _currencyType = '';
  String get currencyType => _currencyType;
  set currencyType(String value) {
    _currencyType = value;
    prefs.setString('ff_currencyType', value);
  }

  LoginModelStruct _userDetail = LoginModelStruct.fromSerializableMap(jsonDecode(
      '{\"userName\":\"Dev cooper\",\"firstName\":\"Dev\",\"lastName\":\"Cooper\",\"email\":\"devcooper@gmail.com\",\"countryCode\":\"+91\",\"phoneNumber\":\"9909999099\",\"password\":\"123456\"}'));
  LoginModelStruct get userDetail => _userDetail;
  set userDetail(LoginModelStruct value) {
    _userDetail = value;
    prefs.setString('ff_userDetail', value.serialize());
  }

  void updateUserDetailStruct(Function(LoginModelStruct) updateFn) {
    updateFn(_userDetail);
    prefs.setString('ff_userDetail', _userDetail.serialize());
  }

  List<IntroModelStruct> _introList = [
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/otldk9ffgrti/Onboarding1.png\",\"title\":\"Transform your study routine with us\",\"subTitle\":\"Transform your study routine with our cutting edge education app\"}')),
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/oeoghvj89n7k/Onboarding2.png\",\"title\":\"Master new skills anytime, anywhere with us\",\"subTitle\":\"Master new skills anytime, anywhere with our dynamic education app\"}')),
    IntroModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/mfbr0an2pguu/Onboarding3.png\",\"title\":\"Master new skills anytime, anywhere with us\",\"subTitle\":\"Master new skills anytime, anywhere with our dynamic education app\"}'))
  ];
  List<IntroModelStruct> get introList => _introList;
  set introList(List<IntroModelStruct> value) {
    _introList = value;
  }

  void addToIntroList(IntroModelStruct value) {
    introList.add(value);
  }

  void removeFromIntroList(IntroModelStruct value) {
    introList.remove(value);
  }

  void removeAtIndexFromIntroList(int index) {
    introList.removeAt(index);
  }

  void updateIntroListAtIndex(
    int index,
    IntroModelStruct Function(IntroModelStruct) updateFn,
  ) {
    introList[index] = updateFn(_introList[index]);
  }

  void insertAtIndexInIntroList(int index, IntroModelStruct value) {
    introList.insert(index, value);
  }

  String _phone = '9909999099';
  String get phone => _phone;
  set phone(String value) {
    _phone = value;
    prefs.setString('ff_phone', value);
  }

  String _countryCodeEdit = '91';
  String get countryCodeEdit => _countryCodeEdit;
  set countryCodeEdit(String value) {
    _countryCodeEdit = value;
    prefs.setString('ff_countryCodeEdit', value);
  }

  String _countryCode = '91';
  String get countryCode => _countryCode;
  set countryCode(String value) {
    _countryCode = value;
  }

  String _countryName = 'IN';
  String get countryName => _countryName;
  set countryName(String value) {
    _countryName = value;
    prefs.setString('ff_countryName', value);
  }

  int _homePageIndex = 0;
  int get homePageIndex => _homePageIndex;
  set homePageIndex(int value) {
    _homePageIndex = value;
  }

  List<String> _searchList = [];
  List<String> get searchList => _searchList;
  set searchList(List<String> value) {
    _searchList = value;
    prefs.setStringList('ff_searchList', value);
  }

  void addToSearchList(String value) {
    searchList.add(value);
    prefs.setStringList('ff_searchList', _searchList);
  }

  void removeFromSearchList(String value) {
    searchList.remove(value);
    prefs.setStringList('ff_searchList', _searchList);
  }

  void removeAtIndexFromSearchList(int index) {
    searchList.removeAt(index);
    prefs.setStringList('ff_searchList', _searchList);
  }

  void updateSearchListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    searchList[index] = updateFn(_searchList[index]);
    prefs.setStringList('ff_searchList', _searchList);
  }

  void insertAtIndexInSearchList(int index, String value) {
    searchList.insert(index, value);
    prefs.setStringList('ff_searchList', _searchList);
  }

  List<CategoryModelStruct> _categoriesList = [
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/zcdzqwuux2xt/design.png\",\"name\":\"Design\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/siypxta0gh7s/finance.png\",\"name\":\"Finance\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/u088tatyle0m/business.png\",\"name\":\"Business\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/d9lebovu2684/codding.png\",\"name\":\"Codding\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/vxf5akllrata/science.png\",\"name\":\"Science\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/a5dou85vh2cp/programming.png\",\"name\":\"Programing\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/z90w7p4mcsx6/trading.png\",\"name\":\"Trading\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/msr9zwd46s0r/physics.png\",\"name\":\"Physics\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/9xdajwkzmubu/english.png\",\"name\":\"Programing\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/cl4h548mocsh/photography.png\",\"name\":\"Photography\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/jy2lszhga4pu/machine_learn.png\",\"name\":\"Machine learn\"}')),
    CategoryModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://picsum.photos/seed/11/600\",\"name\":\"Cloud security\"}'))
  ];
  List<CategoryModelStruct> get categoriesList => _categoriesList;
  set categoriesList(List<CategoryModelStruct> value) {
    _categoriesList = value;
  }

  void addToCategoriesList(CategoryModelStruct value) {
    categoriesList.add(value);
  }

  void removeFromCategoriesList(CategoryModelStruct value) {
    categoriesList.remove(value);
  }

  void removeAtIndexFromCategoriesList(int index) {
    categoriesList.removeAt(index);
  }

  void updateCategoriesListAtIndex(
    int index,
    CategoryModelStruct Function(CategoryModelStruct) updateFn,
  ) {
    categoriesList[index] = updateFn(_categoriesList[index]);
  }

  void insertAtIndexInCategoriesList(int index, CategoryModelStruct value) {
    categoriesList.insert(index, value);
  }

  List<CourseModelStruct> _trendingCourseList = [
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/sakl2wm3yl5x/Trending_course1.png\",\"name\":\"Basic of share market\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"30.0\"}')),
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/u377rssa6pbu/Trending_course2.png\",\"name\":\"Create 3D with blender\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"40.0\"}')),
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/mra19iemji8p/Trending_course3.png\",\"name\":\"Basic web programming\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"30.0\"}')),
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/2qsd056bapox/Trending_course4.png\",\"name\":\"Learn cloud security\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"80.0\"}')),
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/i0y95njxdswt/Trending_course5.png\",\"name\":\"Basic photo editing\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"30.0\"}')),
    CourseModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/8xwuszmfzg14/Trending_course6.png\",\"name\":\"Basic app programming\",\"reviews\":\"4.5\",\"totalReviews\":\"4.2k\",\"price\":\"80.0\"}'))
  ];
  List<CourseModelStruct> get trendingCourseList => _trendingCourseList;
  set trendingCourseList(List<CourseModelStruct> value) {
    _trendingCourseList = value;
  }

  void addToTrendingCourseList(CourseModelStruct value) {
    trendingCourseList.add(value);
  }

  void removeFromTrendingCourseList(CourseModelStruct value) {
    trendingCourseList.remove(value);
  }

  void removeAtIndexFromTrendingCourseList(int index) {
    trendingCourseList.removeAt(index);
  }

  void updateTrendingCourseListAtIndex(
    int index,
    CourseModelStruct Function(CourseModelStruct) updateFn,
  ) {
    trendingCourseList[index] = updateFn(_trendingCourseList[index]);
  }

  void insertAtIndexInTrendingCourseList(int index, CourseModelStruct value) {
    trendingCourseList.insert(index, value);
  }

  List<NotificationsModelStruct> _notificationsList = [
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Submission reminder\",\"subTitle\":\"Just a friendly reminder figma is due in 7 days. Submit your work on time.\",\"createAt\":\"30 seconds ago\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"New module unlocked\",\"subTitle\":\"Dive into draw wireframe in the figma masterclass elearning course.\\r\",\"createAt\":\"30 mins ago\"}')),
    NotificationsModelStruct.fromSerializableMap(jsonDecode(
        '{\"title\":\"Fresh content alert\",\"subTitle\":\"Learn something new in the latest update to the figma elearning course.\",\"createAt\":\"2 hours ago\"}'))
  ];
  List<NotificationsModelStruct> get notificationsList => _notificationsList;
  set notificationsList(List<NotificationsModelStruct> value) {
    _notificationsList = value;
  }

  void addToNotificationsList(NotificationsModelStruct value) {
    notificationsList.add(value);
  }

  void removeFromNotificationsList(NotificationsModelStruct value) {
    notificationsList.remove(value);
  }

  void removeAtIndexFromNotificationsList(int index) {
    notificationsList.removeAt(index);
  }

  void updateNotificationsListAtIndex(
    int index,
    NotificationsModelStruct Function(NotificationsModelStruct) updateFn,
  ) {
    notificationsList[index] = updateFn(_notificationsList[index]);
  }

  void insertAtIndexInNotificationsList(
      int index, NotificationsModelStruct value) {
    notificationsList.insert(index, value);
  }

  List<ChatsModelStruct> _chatList = [
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/kfwnr7dm50z9/Mentors1.png\",\"name\":\"Ralph edwards\",\"chat\":\"Hello\",\"lastCreateAt\":\"23:00\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/j16ml8ikczk7/Mentors2.png\",\"name\":\"Esther howards\",\"chat\":\"Awesome\",\"lastCreateAt\":\"22:00\"}')),
    ChatsModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/dls6nx49sa40/Mentors7.png\",\"name\":\"Leslie alexender\",\"chat\":\"Hyy\",\"lastCreateAt\":\"10:00\"}'))
  ];
  List<ChatsModelStruct> get chatList => _chatList;
  set chatList(List<ChatsModelStruct> value) {
    _chatList = value;
  }

  void addToChatList(ChatsModelStruct value) {
    chatList.add(value);
  }

  void removeFromChatList(ChatsModelStruct value) {
    chatList.remove(value);
  }

  void removeAtIndexFromChatList(int index) {
    chatList.removeAt(index);
  }

  void updateChatListAtIndex(
    int index,
    ChatsModelStruct Function(ChatsModelStruct) updateFn,
  ) {
    chatList[index] = updateFn(_chatList[index]);
  }

  void insertAtIndexInChatList(int index, ChatsModelStruct value) {
    chatList.insert(index, value);
  }

  List<String> _couponList = ['HOLIDAYDEAL', 'ERFTGW', 'WELCOME20'];
  List<String> get couponList => _couponList;
  set couponList(List<String> value) {
    _couponList = value;
  }

  void addToCouponList(String value) {
    couponList.add(value);
  }

  void removeFromCouponList(String value) {
    couponList.remove(value);
  }

  void removeAtIndexFromCouponList(int index) {
    couponList.removeAt(index);
  }

  void updateCouponListAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    couponList[index] = updateFn(_couponList[index]);
  }

  void insertAtIndexInCouponList(int index, String value) {
    couponList.insert(index, value);
  }

  List<ChartModelStruct> _chartList = [
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"MON\",\"yValue\":\"5\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"TUE\",\"yValue\":\"3\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"WED\",\"yValue\":\"2\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"THU\",\"yValue\":\"2\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"FRI\",\"yValue\":\"5\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"SAT\",\"yValue\":\"2\"}')),
    ChartModelStruct.fromSerializableMap(
        jsonDecode('{\"xValue\":\"SUN\",\"yValue\":\"3\"}'))
  ];
  List<ChartModelStruct> get chartList => _chartList;
  set chartList(List<ChartModelStruct> value) {
    _chartList = value;
  }

  void addToChartList(ChartModelStruct value) {
    chartList.add(value);
  }

  void removeFromChartList(ChartModelStruct value) {
    chartList.remove(value);
  }

  void removeAtIndexFromChartList(int index) {
    chartList.removeAt(index);
  }

  void updateChartListAtIndex(
    int index,
    ChartModelStruct Function(ChartModelStruct) updateFn,
  ) {
    chartList[index] = updateFn(_chartList[index]);
  }

  void insertAtIndexInChartList(int index, ChartModelStruct value) {
    chartList.insert(index, value);
  }

  List<CourseModelStruct> _favouriteList = [];
  List<CourseModelStruct> get favouriteList => _favouriteList;
  set favouriteList(List<CourseModelStruct> value) {
    _favouriteList = value;
  }

  void addToFavouriteList(CourseModelStruct value) {
    favouriteList.add(value);
  }

  void removeFromFavouriteList(CourseModelStruct value) {
    favouriteList.remove(value);
  }

  void removeAtIndexFromFavouriteList(int index) {
    favouriteList.removeAt(index);
  }

  void updateFavouriteListAtIndex(
    int index,
    CourseModelStruct Function(CourseModelStruct) updateFn,
  ) {
    favouriteList[index] = updateFn(_favouriteList[index]);
  }

  void insertAtIndexInFavouriteList(int index, CourseModelStruct value) {
    favouriteList.insert(index, value);
  }

  String _favText = 'Course is favourite';
  String get favText => _favText;
  set favText(String value) {
    _favText = value;
  }

  String _unfavText = 'Course is unfavourite';
  String get unfavText => _unfavText;
  set unfavText(String value) {
    _unfavText = value;
  }

  List<ReviewModelStruct> _reviewList = [
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/yichry95lazm/Mentors3.png\",\"name\":\"Ralph edwards\",\"title\":\"greens inside plate on desk.\",\"subTitle\":\"It is a long established fact that a reader will be distracted by the readable content of a page when the point of using\",\"review\":\"4.0\"}')),
    ReviewModelStruct.fromSerializableMap(jsonDecode(
        '{\"image\":\"https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/skill-sprout-go7q3c/assets/blpo2cptrshd/Mentors2.png\",\"name\":\"Jane cooper\",\"title\":\"greens inside plate on desk.\",\"subTitle\":\"It is a long established fact that a reader will be distracted by the readable content of a page when the point of using\",\"review\":\"4.0\"}'))
  ];
  List<ReviewModelStruct> get reviewList => _reviewList;
  set reviewList(List<ReviewModelStruct> value) {
    _reviewList = value;
  }

  void addToReviewList(ReviewModelStruct value) {
    reviewList.add(value);
  }

  void removeFromReviewList(ReviewModelStruct value) {
    reviewList.remove(value);
  }

  void removeAtIndexFromReviewList(int index) {
    reviewList.removeAt(index);
  }

  void updateReviewListAtIndex(
    int index,
    ReviewModelStruct Function(ReviewModelStruct) updateFn,
  ) {
    reviewList[index] = updateFn(_reviewList[index]);
  }

  void insertAtIndexInReviewList(int index, ReviewModelStruct value) {
    reviewList.insert(index, value);
  }

  List<SetReminderModelStruct> _setReminderList = [];
  List<SetReminderModelStruct> get setReminderList => _setReminderList;
  set setReminderList(List<SetReminderModelStruct> value) {
    _setReminderList = value;
    prefs.setStringList(
        'ff_setReminderList', value.map((x) => x.serialize()).toList());
  }

  void addToSetReminderList(SetReminderModelStruct value) {
    setReminderList.add(value);
    prefs.setStringList('ff_setReminderList',
        _setReminderList.map((x) => x.serialize()).toList());
  }

  void removeFromSetReminderList(SetReminderModelStruct value) {
    setReminderList.remove(value);
    prefs.setStringList('ff_setReminderList',
        _setReminderList.map((x) => x.serialize()).toList());
  }

  void removeAtIndexFromSetReminderList(int index) {
    setReminderList.removeAt(index);
    prefs.setStringList('ff_setReminderList',
        _setReminderList.map((x) => x.serialize()).toList());
  }

  void updateSetReminderListAtIndex(
    int index,
    SetReminderModelStruct Function(SetReminderModelStruct) updateFn,
  ) {
    setReminderList[index] = updateFn(_setReminderList[index]);
    prefs.setStringList('ff_setReminderList',
        _setReminderList.map((x) => x.serialize()).toList());
  }

  void insertAtIndexInSetReminderList(int index, SetReminderModelStruct value) {
    setReminderList.insert(index, value);
    prefs.setStringList('ff_setReminderList',
        _setReminderList.map((x) => x.serialize()).toList());
  }

  String _defTimeZoneName = 'America/Detroit';
  String get defTimeZoneName => _defTimeZoneName;
  set defTimeZoneName(String value) {
    _defTimeZoneName = value;
    prefs.setString('ff_defTimeZoneName', value);
  }

  String _currentPassword = '';
  String get currentPassword => _currentPassword;
  set currentPassword(String value) {
    _currentPassword = value;
    prefs.setString('ff_currentPassword', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
