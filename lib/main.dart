import 'dart:io';

import 'package:byule/binding/bindings.dart';
import 'package:byule/ui/meeting/opposite_profile/meeting_opposite_profile_page.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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
import 'package:package_info/package_info.dart';
import 'package:byule/util/style/appColor.dart';

import 'model/userModel.dart';
import 'services/inAppManager.dart';
import 'services/push_notification_handler.dart';
import 'services/push_notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app;

  try {
    app = await Firebase.initializeApp(
      name: 'signalmeeting',
      options: FirebaseOptions(
        appId: (Platform.isIOS || Platform.isMacOS) ? '1:387245324127:ios:488a89f7e82800aca3a8ea' : '1:387245324127:android:f336e996594ce3e0a3a8ea',
        apiKey: 'AIzaSyDnw8E0LXbk8cwCNbI8ujSWyMzLZ7iivMA',
        messagingSenderId: '387245324127',
        projectId: 'signalmeeting-8ee89',
        databaseURL: 'https://signalmeeting-8ee89-default-rtdb.asia-southeast1.firebasedatabase.app/',
      ),
    );

  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      app = Firebase.app('signalmeeting');
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }

  FirebaseFunctions.instance.useFunctionsEmulator(origin: 'https://asia-northeast3-signalmeeting-8ee89.cloudfunctions.net');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp(app));
}

const MaterialColor kPrimaryColor = const MaterialColor(
  0xfff39595,
  const <int, Color>{
    50: const Color(0xfff39595),
    100: const Color(0xfff39595),
    200: const Color(0xfff39595),
    300: const Color(0xfff39595),
    400: const Color(0xfff39595),
    500: const Color(0xfff39595),
    600: const Color(0xfff39595),
    700: const Color(0xfff39595),
    800: const Color(0xfff39595),
    900: const Color(0xfff39595),
  },
);

class MyApp extends StatelessWidget {
  final FirebaseApp app;
  MyApp(this.app);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
      statusBarColor: Colors.transparent, //or set color with: Color(0xFF0000FF)
    ));
    return GetMaterialApp(
      title: 'byule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "AppleSDGothicNeoM",
        // primaryColor: AppColor.main200,
        primarySwatch: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialBinding: BindingsBuilder(() => {
            Get.put(MainController(app)),
          }),
      home: Splash(),
      getPages: [
        GetPage(name: '/meeting_opposite_profile', page: () => MeetingOppositeProfilePage(), binding: MeetingOppositeProfileBinding()),
      ],
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
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            if (snapshot.data == null) {
              return StartPage();
            } else {
              String uid = snapshot.data.uid;
              String phone =  snapshot.data.phoneNumber;
              print(snapshot.data);
              return FutureBuilder<List<bool>>(
                  future: Future.wait([DatabaseService.instance.checkAuth(uid, phone), checkForceUpdate()]),
                  builder: (context, AsyncSnapshot<List<bool>> snapshot) {
                    print('no snapshot?? ${snapshot.data}');
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        !snapshot.hasData)
                      return Center(child: CircularProgressIndicator());
                    else if (snapshot.data[0]) {
                      MainController _mainController = Get.find();
                      _mainController.needForceUpdate = snapshot.data[1];
                      print('???? ${_mainController.needForceUpdate}');
                      if (_mainController.user.value.stop)
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

  Future<bool> checkForceUpdate() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeoutMillis: 10000));

    await remoteConfig.fetch(expiration: const Duration(seconds: 10));
    await remoteConfig.activateFetched();

    String minAppVersion = remoteConfig.getString('min_version');
    String latestAppVersion = remoteConfig.getString('latest_version'); //업데이트 권유 넣을꺼면 사용
    print('minAppVersion : $minAppVersion');
    print('latestAppVersion : $latestAppVersion');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    List<String> currentV = currentVersion.split(".");
    List<String> minAppV = minAppVersion.split(".");

    bool needForceUpdate = false;

    for (var i = 0; i <= 2; i++) {
      needForceUpdate = int.parse(minAppV[i]) > int.parse(currentV[i]);
      if (int.parse(minAppV[i]) != int.parse(currentV[i])) break;
    }

    return needForceUpdate;
  }

}