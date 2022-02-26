import 'dart:async';

import 'package:byule/ui/meeting/make_meeting_page.dart';
import 'package:byule/ui/meeting/my_meeting_page.dart';
import 'package:byule/ui/test/adminPage.dart';
import 'package:byule/ui/widget/dialog/main_dialog.dart';
import 'package:byule/ui/widget/dialog/noCoinDialog.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/coin/coinlog.dart';
import 'package:byule/ui/meeting/meeting_page.dart';
import 'package:byule/ui/menu/menu_page.dart';
import 'package:in_app_review/in_app_review.dart';
import 'home/home_page.dart';
import 'menu/menu_page.dart';


class LobbyController extends GetxController {
  RxInt selectedIndex = 0.obs;
  MainController _mainController = Get.find();
  bool needForceUpdate = false;
  RxBool isFabVisible = true.obs;

  @override
  void onInit() async {
    print('lobbycontroller oninit');
    DatabaseService.instance.getTodayMatch();
    DatabaseService.instance.checkFree();
    //_mainController.inAppManager = InAppManager()..init();
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
    'tab_member',
    'tab_menu',
  ];

  final List inactiveIcons = [Icons.favorite, Icons.group, Icons.notifications];

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    MeetingPage(),
    MyMeetingPage(),
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
    // if(_mainController.needForceUpdate) {
    //
    // }
    if(_mainController.needForceUpdate) {
      0.delay(() => Get.dialog(
          MainDialog(
            title: '알림',
            buttonText: '업데이트',
            contents: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(child: Text('보다 나은 서비스 이용을 위해\n지금 바로 업데이트 하세요!', textAlign: TextAlign.center, style: TextStyle(height: 1.5),)),
            ),
            onPressed: () {
              final InAppReview inAppReview = InAppReview.instance;
              return inAppReview.openStoreListing();
            },
          ),
          barrierDismissible: false));
    }


    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Obx(
            () => Scaffold(
              floatingActionButton: _lobbyController.selectedIndex.value == 1 && _lobbyController.isFabVisible.value
                  ? FloatingActionButton(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Image.asset('assets/fab.png', color: Colors.white, height: 33, width: 33),
                      ),
                      backgroundColor: AppColor.main200,
                      onPressed: () => (_user.coin < 20)
                          ? Get.dialog(NoCoinDialog())
                          : Get.to(() => MakeMeetingPage()))
                  : null,
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
                        buildTabbar('내 미팅', 2),
                        buildTabbar('설정', 3),
                      ],
                    ),
                  )),
            ),
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
          //TextButton(child: Text("admin"), onPressed : () => Get.to(() => AdminPage())),
          Padding(
            padding: EdgeInsets.only(right: Get.height * 0.02),
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
