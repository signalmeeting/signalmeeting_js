import 'dart:ui';

import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/ui/widget/deletedUser.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';

class MemberCards extends StatelessWidget {
  final List<MemberModel> memberList;
  final bool loaded;
  final bool deleted;
  final String meetingId;
  final MeetingModel meeting;
  final UserModel meetingOwner;
  final VoidCallback onTapReport;
  // final MeetingDetailController meetingDetailController;

  MemberCards(
      {@required this.memberList,
      @required this.loaded,
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
    return loaded
        ? deleted
            ? deletedUser(onPressed: () {})
            : Flexible(
                child: ScrollConfiguration(
                  behavior: ScrollBehavior(),
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) => mainCard(memberList[index]),
                    loop: false,
                    scale: 0.78,
                    fade: 0.55,
                    itemCount: memberList.length,
                    viewportFraction: 0.8,
                  ),
                ),
              )
        : Center(child: CircularProgressIndicator());
  }

  Widget mainCard(MemberModel member) {
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        color: Colors.red[50],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Card(
              margin: EdgeInsets.all(0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    //주선자 정보

                    buildOppositeProfile(member),

                    //소개
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                      child: Text(
                        '멤버 소개',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "AppleSDGothicNeoB",
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          member.introduce ?? '',
                          style: TextStyle(
                            fontFamily: "AppleSDGothicNeoM",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOppositeProfile(MemberModel member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10),
          child: meetingOwner.pics.length > 0 ? BluredImage(member.url, meetingId) : Container(),
        ),
        Wrap(
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
      ],
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
                  color: Colors.grey[100],
                  // border: Border.all(color: AppColor.main100.withOpacity(0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: "AppleSDGothicNeoL",
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
          width: Get.width - 106,
          height: Get.width - 106,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            //blur 덮는 과정
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: cachedImage(
                    pic,
                    width: Get.width - 106,
                    height: Get.width - 106,
                  ),
                ),
                meeting.process == 1
                    ? Container()
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                                  borderRadius: BorderRadius.circular(4),
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
