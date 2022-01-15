import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/controller/meeting_controller.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/services/database.dart';
import 'package:byule/services/push_notification_handler.dart';
import 'package:byule/ui/drawer/inquiry_page.dart';
import 'package:byule/ui/lobby.dart';
import 'package:byule/ui/start/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:byule/ui/start/start_page_3.dart';

import 'model/userModel.dart';
import 'services/inAppManager.dart';
import 'services/push_notification_handler.dart';
import 'services/push_notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app;

  try {
    app = await Firebase.initializeApp(
      name: 'byule',
      options: FirebaseOptions(
        appId: (Platform.isIOS || Platform.isMacOS) ? '1:387245324127:ios:488a89f7e82800aca3a8ea' : '1:387245324127:android:f336e996594ce3e0a3a8ea',
        apiKey: 'AIzaSyDnw8E0LXbk8cwCNbI8ujSWyMzLZ7iivMA',
        messagingSenderId: '387245324127',
        projectId: 'byule-8ee89',
        databaseURL: 'https://byule-8ee89-default-rtdb.asia-southeast1.firebasedatabase.app/',
      ),
    );


  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      app = Firebase.app('byule');
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }

  FirebaseFunctions.instance.useFunctionsEmulator(origin: 'https://asia-northeast3-byule-8ee89.cloudfunctions.net');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(app));
}

class MyApp extends StatelessWidget {
  final FirebaseApp app;
  MyApp(this.app);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
      statusBarColor: Colors.white, //or set color with: Color(0xFF0000FF)
    ));
    return GetMaterialApp(
      title: 'byule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "AppleSDGothicNeoM",
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: BindingsBuilder(() => {
            Get.put(MainController(app)),
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
              print(snapshot.data);
              return FutureBuilder<bool>(
                  future: DatabaseService.instance.checkAuth(uid, phone),
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    else if (snapshot.data) {
                      MainController _mainController = Get.find();
                      if(_mainController.user.value.stop)
                        return InquiryPage(); // 이용문의 페이지
                      else {
                        return LobbyPage();
                      }
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
