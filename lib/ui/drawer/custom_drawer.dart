import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/ui/drawer/how_to_use_page.dart';
import 'package:signalmeeting/ui/drawer/inquiry_page.dart';
import 'package:signalmeeting/ui/drawer/invite_friends_page.dart';
import 'package:signalmeeting/ui/drawer/my_profile_page.dart';
import 'package:signalmeeting/ui/drawer/notice_page.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';

//클래스화 시켜준 다음에 변수들 받지말고 오비엑스 달아야되나?
Widget customDrawer(pic, nickName, loc1, loc2, career, BuildContext context) {
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
        DrawerTileForm('프로필', MyProfilePage()),
        DrawerTileForm('진행방법', HowToUsePage()),
        DrawerTileForm('스토어', StorePage()),
        Container(height: 2, color: Colors.blue[50]),
        DrawerTileForm('공지사항', NoticePage()),
        DrawerTileForm('친구초대', InviteFriendsPage()),
        DrawerTileForm('문의 및 계정', InquiryPage()),
      ],
    ),
  );
}

Widget DrawerTileForm(title, page) {
  return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('$title'),
      ),
      onTap: () => Get.to(page, transition: title == '프로필' ? Transition.native : Transition.rightToLeftWithFade));
}

Widget DrawerAppBar(BuildContext context, title) {
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
