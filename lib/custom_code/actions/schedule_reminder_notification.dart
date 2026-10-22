// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:timezone/timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future scheduleReminderNotification(
  BuildContext context,
  int notificationId,
  int hour,
  int minute,
) async {
  // Add your function code here!
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();
  // var locations = tz.timeZoneDatabase.locations;

  // tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();

  // final String timeZoneName =
  //     await platform.invokeMethod<String>('getTimeZoneName');
  // // final timeZone = TimeZone();
  // // String timeZoneName = await timeZone.getTimeZoneName();
  try {
    Location getlocal =
        tz.getLocation(timeZoneName!.replaceAll("Calcutta", "Kolkata"));
    tz.setLocalLocation(getlocal);
  } catch (e) {
    print(e);
    Location getlocal = tz.getLocation(FFAppState().defTimeZoneName);
    tz.setLocalLocation(getlocal);
  }

//  Future<void> _scheduleWeeklyMondayTenAMNotification(
  // int id, int day, int hour, int minute) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "",
      "",
      // _nextInstanceOfTenAM(),
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'com.mycompany.mathsriddleapp',
          'com.mycompany.mathsriddleapp channel',
        ),
      ),
      // androidAllowWhileIdle: true,

      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
  // matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
}

TZDateTime _nextInstanceOfTime(int hour, int minute) {
  print("SEdule timer  ==== $hour:$minute");
  final TZDateTime now = tz.TZDateTime.now(tz.local);
  TZDateTime scheduledDate =
      TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // print("SEdule timer  ==== $scheduledDate");

  return scheduledDate;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
