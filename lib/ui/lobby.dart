import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/coin/coinlog.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/ui/meeting/meeting_page.dart';
import 'package:signalmeeting/util/util.dart';

import 'alarm/alarmPage.dart';
import 'chat/chat_page.dart';
import 'drawer/custom_drawer.dart';
import 'home/home_page.dart';

import 'package:firebase_auth/firebase_auth.dart';

class LobbyController extends GetxController {
  RxInt selectedIndex = 0.obs;
  @override
  void onInit() {
    DatabaseService.instance.getTodayMatch();
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

  final List activeIcons = [
    Icons.favorite,
    Icons.group,
    Icons.notifications,
  ];

  final List inactiveIcons = [Icons.favorite, Icons.group, Icons.notifications];

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MeetingPage(),
    AlarmPage(),
  ];

  Future<bool> _onWillPop() {
    if (_selectedIndex != 0) {
      _lobbyController.selectedIndex.value = 0;
      return Future.value(false);
    }
    return Util.onWillPop();
  }

  @override
  Widget build(BuildContext context) {
    print('build lobby');
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: buildAppBar(context),
          drawer: Obx(() => customDrawer(_user.firstPic, _user.name, _user.loc1, _user.loc2, _user.career, context)),
          body: Obx(() => Center(child: _widgetOptions.elementAt(_selectedIndex))),
          bottomNavigationBar: SizedBox(
              height: Get.height * 0.08,
              child: Obx(
                () => Row(
                  children: <Widget>[
                    buildTabbar('데일리', 0),
                    buildTabbar('미팅', 1),
                    buildTabbar('알림', 2),
                  ],
                ),
              )),
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
    var tabbarWidth = Get.width / 3;
    return Container(
      color: Colors.grey[50],
      width: tabbarWidth,
      child: InkWell(
//        highlightcolor: Colors.transparent,
//        splashcolor: Colors.transparent,
//        padding: 0,
//        borderRadius: 0,
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
                  ? Icon(activeIcons[index], color: activeColor, size: Get.height * 0.03)
                  : Icon(inactiveIcons[index], color: inactiveColor, size: Get.height * 0.03),
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
      return TextStyle(color: activeColor, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1);
    else
      return TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1);
  }
}
