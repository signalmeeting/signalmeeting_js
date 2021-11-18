import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/controller/meeting_controller.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/services/push_notification_handler.dart';
import 'package:signalmeeting/ui/lobby.dart';
import 'package:signalmeeting/ui/start/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signalmeeting/ui/start/start_page_3.dart';

import 'model/userModel.dart';
import 'services/push_notification_handler.dart';
import 'services/push_notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFunctions.instance.useFunctionsEmulator(origin: 'https://asia-northeast3-signalmeeting-8ee89.cloudfunctions.net');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  print("push test");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'signalmeeting',
      theme: ThemeData(
        fontFamily: "AppleSDGothicNeoM",
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: BindingsBuilder(() => {
            Get.put(MainController()),
          }),
      home: Splash(),
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          // TODO 처음 실행시 여러번 3번? 불림
          // 회원가입 후 auth 없앴을 때 반영안됨 (앱에서 로그아웃 안해서 auth 남아있는듯)
          builder: (context, AsyncSnapshot<User> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if (snapshot.data == null) {
              return StartPage();
            } else {
              String uid = snapshot.data.uid;
              String phone = snapshot.data.phoneNumber;
              print(snapshot.data.uid);
              return FutureBuilder<bool>(
                  future: DatabaseService.instance.checkAuth(uid, phone),
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    else if (snapshot.data) {
                      PushNotificationsHandler().init();
                      return LobbyPage();
                    } else {
                      // auth 는 있는데 db 에 userData 없음 => 프로필입력페이지로
                      return StartPage3();
                    }
                  });
            }
          }),
    );
  }
}
