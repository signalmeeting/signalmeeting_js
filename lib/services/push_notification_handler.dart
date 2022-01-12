import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/chat_controller.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/meeting/my_meeting_page.dart';

class PushNotificationsHandler {
  PushNotificationsHandler._();

  factory PushNotificationsHandler() => _instance;
  static final PushNotificationsHandler _instance = PushNotificationsHandler._();

  MainController _mainController = Get.find();

  Future<void> init() async {
    print("PushNotificationsHandler init");
    String token = await FirebaseMessaging.instance.getToken();
    if (token != _mainController.user.value.deviceToken) await DatabaseService.instance.updateDeviceToken(token);
    // Firebase 초기화부터 해야 FirebaseMessaging 를 사용할 수 있다.

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // Android용 새 Notification Channel
    const AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
      'high_importance_channel', // 임의의 id
      'High Importance Notifications', // 설정에 보일 채널명
      'This channel is used for important notifications.', // 설정에 보일 채널 설명
      importance: Importance.max,
    );

    // Notification Channel을 디바이스에 생성
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);


    // FlutterLocalNotificationsPlugin 초기화. 이 부분은 notification icon 부분에서 다시 다룬다.
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/launcher_icon'),
            iOS: IOSInitializationSettings()),
        onSelectNotification: onLocalMessage);



    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      RemoteNotification notification = rm.notification;

      Map<String, dynamic> data = rm.data;

      String payload = json.encode({
        'data': data,
        'notification': {'title': rm.notification?.title ?? '', 'body': rm.notification?.body ?? '', 'show_in_foreground': true}
      });
      // if (Platform.isIOS) {
      //   data = {'type': data['type'], 'id': data['id'], 'name': data['name']};
      // }

      print('foreground data : $data');

      if (notification != null && !isSameRoom(data["roomId"])) {
        flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // AndroidNotificationChannel()에서 생성한 ID
              'High Importance Notifications',
              'This channel is used for important notifications.',
              // other properties...
            ),
          ),
          payload: payload
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage rm) {
      handleFcmMessage(rm);
    });

    return true;
  }

  isSameRoom(String roomId) {
    print("isSameRoom : $isSameRoom");
    // print('currentRoom : '+ (store.currentChatRoomIds.isNotEmptylast));
    // print('currentRoom : '+ (store.currentChatRoomIds.last??'')  + ' roomId : '  + roomId);
    bool isRegistered = Get.isRegistered<ChatController>(tag : roomId);
    return isRegistered;
  }

  handleFcmMessage(RemoteMessage message) async {
    String messageType = message.data['type'];
    // var id = message['data']['id'];
    if (messageType.startsWith("meeting") || messageType.startsWith("signal")) {
      Get.to(() => MyMeetingPage());
    } else if (messageType == "chat") {
      UserModel oppositeUser = await DatabaseService.instance.getOppositeUserInfo(message.data["opposite"]);
      MainController.goToChatPage(message.data["roomId"], oppositeUser, message.data["roomType"]);
    }
  }


  Future onLocalMessage(String message) {
    //앱 살아있을때
    print('onLocalMessage $message');
    if (message != null) {
      Map<String, dynamic> remoteMessage = jsonDecode(message);
      Map<String, dynamic> data = remoteMessage['data'];
      Map<String, dynamic> notification = remoteMessage['notification'];

      handleFcmMessage(RemoteMessage(data: data, notification: RemoteNotification.fromMap(notification)));
    }

    return Future.value(true);
  }
}
