import 'dart:ui';

import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/ui/widget/deletedUser.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';


class MemberCards extends StatelessWidget {
  final List<MemberModel> memberList;
  final bool deleted;
  final String meetingId;
  final MeetingModel meeting;
  final UserModel meetingOwner;
  final VoidCallback onTapReport;
  // final MeetingDetailController meetingDetailController;

  MemberCards(
      {@required this.memberList,
      @required this.deleted,
      @required this.meetingId,
      this.meeting,
      this.meetingOwner,
        this.onTapReport
      });

  final MainController _mainController = Get.find();

  UserModel get user => _mainController.user.value;

  @override
  Widget build(BuildContext context) {
    return deleted
        ? deletedUser(onPressed: () {})
        : Flexible(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) => mainCard(memberList[index]),
              loop: false,
              scale: 0.90,
              fade: 0.75,
              itemCount: memberList.length,
              viewportFraction: 0.9,
              pagination: new SwiperPagination(
                margin: const EdgeInsets.only(top: 30.0),
                alignment: Alignment.topCenter,
                builder: new DotSwiperPaginationBuilder(
                    color: Colors.white30,
                    activeColor: Colors.white70),
              ),
            ),
          );
  }

  Widget mainCard(MemberModel member) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: Get.width*0.03),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          //주선자 정보
          buildOppositeProfile(member),

          //소개
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
            child: Divider(thickness: 2, color: Colors.grey[100],),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                member.introduce ?? '',
                                style: TextStyle(
                                  fontFamily: "AppleSDGothicNeoM",
                                  // overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOppositeProfile(MemberModel member) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,8,8,0),
      child: meetingOwner.pics.length > 0
          ? Stack(children: [
              BluredImage(member.url??'', meetingId),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Center(
                  child: Wrap(
                    children: [
                      MyChip(member.age + '살'),
                      MyChip(member.tall + 'cm'),
                      MyChip(null),
                      MyChip(member.bodyType),
                      MyChip(member.career),
                      MyChip('${member.loc1} ${member.loc2}'),
                      MyChip(member.mbti),
                    ],
                  ),
                ),
              )
            ])
          : Container(),
    );
  }

  Widget MyChip(String text) => text != null
      ? Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColor.main200.withOpacity(0.6),
                  // border: Border.all(color: AppColor.main100.withOpacity(0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: "AppleSDGothicNeoL",
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      : Container(width: 0);

  Widget BluredImage(String pic, String id) {
    bool banned = false;
    meeting.banList?.forEach((banItem) {
      if (banItem['from'] == this.user.uid) {
        banned = true;
      }
    });

    return Stack(
      children: [
        Container(
          width: Get.width,
          height: Get.height*0.5,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: cachedImage(
                  pic,
                  width: Get.width,
                  height: Get.height*0.5,
                  radius: 12
                ),
              ),
              meeting.process == 1
                  ? Container()
                  : Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 1.5)),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                            child: Text(
                              '매칭 성사 시, 확인 가능',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "AppleSDGothicNeoM",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        Positioned(
          child: InkWell(
            onTap: () => !meeting.isMine
                ? banned
                    ? Get.dialog(NotificationDialog(contents: "이미 신고 했습니다"))
                    : onTapReport ?? () {}
                : () {},
            child: Container(
              width: 30,
              height: 30,
              child: !meeting.isMine
                  ? Image.asset(
                      'assets/report.png',
                      color: Colors.white.withOpacity(0.7),
                    )
                  : Container(),
            ),
          ),
          top: 10,
          right: 10,
        )
      ],
    );
  }
}
