import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:signalmeeting/ui/drawer/how_to_use_page.dart';
import 'package:signalmeeting/ui/drawer/inquiry_page.dart';
import 'package:signalmeeting/ui/drawer/invite_friends_page.dart';
import 'package:signalmeeting/ui/drawer/my_profile_page.dart';
import 'package:signalmeeting/ui/drawer/notice_page.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';

//클래스화 시켜준 다음에 변수들 받지말고 오비엑스 달아야되나?
Widget customDrawer(pic, nickName, loc1, loc2, career, BuildContext context) {
  final InAppReview inAppReview = InAppReview.instance;

  return Drawer(
    child: ListView(
      children: <Widget>[
        DrawerHeader(
          margin: EdgeInsets.only(bottom: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: cachedImage(
                      pic,
                      width: 70,
                      height: 70,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nickName,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      Text(
                        career,
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      Text(
                        '$loc1 $loc2',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
          decoration: BoxDecoration(color: Colors.blue[100]),
        ),
        drawerTileForm('프로필', () => Get.to(MyProfilePage(), transition: Transition.native)),
        // drawerTileForm('진행 방법', () => Get.to(HowToUsePage(), transition: Transition.rightToLeftWithFade)),
        drawerTileForm('스토어', () => Get.to(StorePage(), transition: Transition.rightToLeftWithFade)),
        Container(height: 2, color: Colors.blue[50]),
        drawerTileForm('공지사항', () => Get.to(NoticePage(), transition: Transition.rightToLeftWithFade)),
        drawerTileForm('친구 초대', () => Get.to(InviteFriendsPage(), transition: Transition.rightToLeftWithFade)),
        drawerTileForm('리뷰 쓰기', () => inAppReview.openStoreListing()),
        drawerTileForm('문의 및 계정', () => Get.to(InquiryPage(), transition: Transition.rightToLeftWithFade)),
      ],
    ),
  );
}

Widget drawerTileForm(String title, VoidCallback onPressed) {
  return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('$title'),
      ),
      onTap: onPressed);
}

Widget drawerAppBar(BuildContext context, title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      highlightColor: Colors.white,
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
