import 'dart:math';
import 'dart:ui';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/ui/widget/deletedUser.dart';
import 'package:signalmeeting/ui/widget/dialog/notification_dialog.dart';
import 'package:signalmeeting/ui/widget/dialog/simple_alarm_dialog.dart';
import 'opposite_profile.dart';

const SCALE_FRACTION = 0.75;
const FULL_SCALE = 1.0;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MainController _controller = Get.find();

  UserModel get user => _controller.user.value;

  List<dynamic> get todayMatchList => _controller.todayMatchList;

  PageController _pageController = PageController(initialPage: 0);

  double currentIndex = 0;

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        currentIndex = _pageController.page;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('rebuild');
    return Obx(() => buildTodayMatch());
  }

  Widget buildTodayMatch() {
    return todayMatchList.length == 0
        ? Center(child: Text('오늘의 소개팅이 준비중입니다!'))
        : ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.right,
              color: Colors.white,
              child: Column(
                children: [
                  indicator(),
                  Expanded(
                    child: PageView.builder(
                        controller: _pageController,
                        itemCount: todayMatchList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final double scale = max(SCALE_FRACTION, FULL_SCALE - (index - currentIndex).abs());
                          return Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: Get.height * scale,
                              width: Get.width * scale,
                              child: Row(children: [
                                Expanded(child: buildTodayMatchColumn(todayMatchList[index].sameGenders, todayMatchList[index].documentId)),
                                Expanded(child: buildTodayMatchColumn(todayMatchList[index].oppositeGenders, todayMatchList[index].documentId))
                              ]),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
  }

  Widget indicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DotsIndicator(
            decorator: DotsDecorator(
              spacing: EdgeInsets.symmetric(horizontal: 3),
              size: Size(Get.width * 0.5 / 4 * 0.6, 3.0),
              activeSize: Size(Get.width * 0.5 / 4, 3.0),
              color: Colors.black12,
              activeColor: Colors.black54,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            dotsCount: todayMatchList.length,
            position: currentIndex,
          )
        ],
      ),
    );
  }

  Widget buildTodayMatchColumn(list, docId) {

    MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.start;
    switch (list.length) {
      case 2:
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
        break;
      case 3:
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
        break;
      case 4:
        _mainAxisAlignment = MainAxisAlignment.spaceEvenly;
        break;
      default:
        _mainAxisAlignment = MainAxisAlignment.spaceEvenly;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
          mainAxisAlignment: _mainAxisAlignment,
          children: list.map<Widget>((e) => Obx(() => todayMatchItem(e, docId))).toList()),
    );
  }

  Widget todayMatchItem(UserModel user, String docId) {
    bool sameGender = this.user.man == user.man;
    bool isMe = this.user.uid == user.uid;
    double size = Get.height * 0.17;
    bool notShow = false;
    this.user.banList?.forEach((banItem) {
      if ((user.uid != this.user.uid) &&
          (banItem['from'] == user.uid || banItem['to'] == user.uid)) {
        notShow = true;
      }
    });

    if(user.matchUserDeleted)
      notShow = true;

    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: sameGender || notShow
          ? null
          : () => Get.to(()=>OppositeProfilePage(user, docId: docId,)),
      child: Container(
        height: size,
        width: size,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 1.5,
                color: user.man ? Colors.blue[isMe ? 300 : 100] : Colors.red[isMe ? 300 : 100],
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Hero(
                    tag: 'today_signal' + user.uid,
                    child: notShow ? deletedUser(size : size)
                        : cachedImage(
                                  user.firstPic,
                          width: size,
                          height: size,
                        ),
                  ),
                ),
                if (sameGender)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  )
              ],
            )),
      ),
    );
  }
}
