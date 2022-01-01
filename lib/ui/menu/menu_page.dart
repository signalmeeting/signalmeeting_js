import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/ui/drawer/inquiry_page.dart';
import 'package:signalmeeting/ui/drawer/invite_friends_page.dart';
import 'package:signalmeeting/ui/drawer/my_profile_page.dart';
import 'package:signalmeeting/ui/drawer/notice_page.dart';
import 'package:signalmeeting/ui/drawer/personalInfo.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/ui/drawer/terms.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/util/style/btStyle.dart';

class MenuPage extends StatelessWidget {
  final MainController _mainController = Get.find();
  UserModel get _user => _mainController.user.value;
  final InAppReview inAppReview = InAppReview.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22,15,15,15),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: cachedImage(
                  _user.firstPic,
                  width: 50,
                  height: 50,
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user.name,
                    style: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: "AppleSDGothicNeoB", height: 1),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    '${_user.career}, ${_user.loc1} ${_user.loc2}',
                    style: TextStyle(fontSize: 13, color: Colors.black45, height: 1),
                  ),
                ],
              )
            ],
          ),
        ),
        divider(8),
        menuItemWithIcon('프로필', 'profile',() => Get.to(() => MyProfilePage())),
        divider(0.3),
        menuItemWithIcon('스토어', 'store', () => Get.to(() => StorePage())),
        divider(0.3),
        menuItemWithIcon('공지사항', 'notice', () => Get.to(() => NoticePage())),
        divider(0.3),
        menuItemWithIcon('친구 초대', 'inviteFriend', () => Get.to(() => InviteFriendsPage())),
        divider(0.3),
        menuItemWithIcon('리뷰 쓰기', 'review', () => inAppReview.openStoreListing()),
        divider(8),
        menuItem('문의 및 계정', 'store', () => Get.to(() => InquiryPage())),
        divider(0.3),
        menuItem('이용 약관', 'store', () => Get.to(() => Terms())),
        divider(0.3),
        menuItem('개인정보 처리방침', 'store', () => Get.to(() => PersonalInfo())),
        divider(0.3),
      ],
    );
  }

  Widget menuItemWithIcon(String title, String image , VoidCallback onPressed) {
    return TextButton.icon(
      label: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left : 10.0),
              child: Text(title),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ),
          ],
        ),
      ),
      style: BtStyle.menu,
      icon: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Image.asset('assets/menu_$image.png', color: Colors.black87, height: Get.height * 0.03, width: Get.height * 0.03,),
      ),
      onPressed: onPressed,

      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // child: Text('$title'),
    );
  }

  Widget menuItem(String title, String image , VoidCallback onPressed) {
    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(title),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ],
      ),
      style: BtStyle.menu,
      onPressed: onPressed,
    );
  }

  Widget divider(height) => Container(height: height.toDouble(), color: Colors.grey[100]);

}