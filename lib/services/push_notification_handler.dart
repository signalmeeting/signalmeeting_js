import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/meeting/my_meeting_page.dart';

class PushNotificationsHandler {
  PushNotificationsHandler._();

  factory PushNotificationsHandler() => _instance;
  static final PushNotificationsHandler _instance = PushNotificationsHandler._();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  MainController _mainController = Get.find();

  Future<void> init() async {
    print("PushNotificationsHandler init");
    String token = await _firebaseMessaging.getToken();

    if (token != _mainController.user.value.deviceToken) await DatabaseService.instance.updateDeviceToken(token);

    if (!_initialized) {
// For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
//You can subscribed to a topic, if you need to send to all devices
//user segmented messages is not supported for the Admin SDK
      _firebaseMessaging.subscribeToTopic("AllPushNotifications");
      _firebaseMessaging.configure(
//fires when the app is open and running in the foreground.
        onMessage: onForegroundMessage,

//fires if the app is fully terminated.
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunch: $message");
//do whatever
        },
//fires if the app is closed, but still running in the background.
        onResume: (Map<String, dynamic> message) async {
          print("onResume: $message");
//do whatever
        },
      );
      _initialized = true;
    }
  }

  handleFcmMessage(Map<String, dynamic> message) async {
    print('handleFcmMessage : ' + message.toString());
    var messageType = message['data']['type'];
    // var id = message['data']['id'];
    if (messageType == 'meeting_apply') {
      Get.to(() => MyMeetingPage());
    } else if (message['data']['type'] == 'meeting_match') {

    } else if (message['data']['type'] == 'meeting_reject') {

    } else if (message['data']['type'] == 'signal_receive') {

    } else if (message['data']['type'] == 'signal_match') {

    }
  }

  Future onForegroundMessage(Map<String, dynamic> message) async {
    print("onForegroundMessage: $message");
    if (Platform.isIOS) {
      message['data'] = {'type': message['type'], 'id': message['id'], 'nickName': message['nickName']};
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    print('local push');
    print('message: $message');
    if (message['data']['type'] == 'meeting_apply') {
      Get.snackbar(message['notification']['title'], message['notification']['body'], onTap: (_) => this.handleFcmMessage(message));
    } else if (message['data']['type'] == 'meeting_match') {
      Get.snackbar(message['notification']['title'], message['notification']['body'], onTap: (_) => this.handleFcmMessage(message));
    } else if (message['data']['type'] == 'signal_receive') {
      Get.snackbar(message['notification']['title'], message['notification']['body'], onTap: (_) => this.handleFcmMessage(message));
    } else if (message['data']['type'] == 'signal_reject') {
      Get.snackbar(message['notification']['title'], message['notification']['body'], onTap: (_) => this.handleFcmMessage(message));
    } else if (message['data']['type'] == 'signal_match') {
      Get.snackbar(message['notification']['title'], message['notification']['body'], onTap: (_) => this.handleFcmMessage(message));
    }
    // else {
    //   await flutterLocalNotificationsPlugin.show(
    //     0,
    //     message['notification']['title'],
    //     message['notification']['body'],
    //     platformChannelSpecifics,
    //     payload: jsonEncode(message),
    //   );
    // }
    return Future.value(true);
  }
}
