import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/coin/coinlog.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/meeting/meeting_page.dart';
import 'package:byule/ui/menu/menu_page.dart';
import 'package:byule/ui/test/dailymeetingtest2.dart';
import 'package:byule/ui/test/dailymeetingtest3.dart';
import 'package:byule/util/util.dart';

import 'alarm/alarmPage.dart';
import 'drawer/custom_drawer.dart';
import 'home/home_page.dart';
import 'menu/menu_page.dart';


class LobbyController extends GetxController {
  RxInt selectedIndex = 0.obs;
  @override
  void onInit() {
    DatabaseService.instance.getTodayMatch();
    DatabaseService.instance.checkFree();
    super.onInit();
  }
}

class LobbyPage extends StatelessWidget {

  final MainController _mainController = Get.find();
  final LobbyController _lobbyController = Get.put(LobbyController());
  final MyMeetingController _myMeetingController = Get.put(MyMeetingController());

  UserModel get _user => _mainController.user.value;

  int get _selectedIndex => _lobbyController.selectedIndex.value;

  final Color activeColor = Colors.black87;
  final Color inactiveColor = Colors.black26;

  final List<String> iconImages = [
    'tab_daily',
    'tab_meeting',
    'tab_alarm',
    'tab_menu',
  ];

  final List inactiveIcons = [Icons.favorite, Icons.group, Icons.notifications];

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MeetingPage(),
    AlarmPage(),
    MenuPage(),
  ];

  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();

  Future<bool> _onWillPop(BuildContext context) {

    if (_selectedIndex != 0) {
      _lobbyController.selectedIndex.value = 0;
      return Future.value(false);
    }
    return Future.value(true);

  }

  @override
  Widget build(BuildContext context) {
    print('build lobby');
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Scaffold(
            key: _key,
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            appBar: buildAppBar(context),
            body: Obx(() => _widgetOptions.elementAt(_selectedIndex)),
            bottomNavigationBar: SizedBox(
                height: 60,
                child: Obx(
                  () => Row(
                    children: <Widget>[
                      buildTabbar('데일리', 0),
                      buildTabbar('미팅', 1),
                      buildTabbar('알림', 2),
                      buildTabbar('설정', 3),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          '시그널팅',
          style: TextStyle(color: Colors.black, fontFamily: "AppleSDGothicNeoM"),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => Get.to(() => CoinLog()),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
                  Container(
                    width: 5,
                  ),
                  Obx(
                        () => Text(
                      _user.coin.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "AppleSDGothicNeoM",
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }

  Widget buildTabbar(String tabName, int index) {
    var tabbarWidth = Get.width / 4;
    return Container(
      color: Colors.white,
      width: tabbarWidth,
      child: InkWell(
        onTap: () => _lobbyController.selectedIndex.value = index,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[300]),
            ),
          ),
          width: tabbarWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _selectedIndex == index
                  ? Image.asset('assets/${iconImages[index]}.png', color: activeColor, height: Get.height * 0.03, width: Get.height * 0.03,)
                  : Image.asset('assets/${iconImages[index]}.png', color: inactiveColor, height: Get.height * 0.03, width: Get.height * 0.03,),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: Text(tabName, style: _barTextStyle(_selectedIndex == index)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _barTextStyle(active) {
    if (active)
      return TextStyle(color: activeColor, fontSize: 12, fontFamily: "AppleSDGothicNeoM");
    else
      return TextStyle(color: Colors.black26, fontSize: 12, fontFamily: "AppleSDGothicNeoM");
  }
}
