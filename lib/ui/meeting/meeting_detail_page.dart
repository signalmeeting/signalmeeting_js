import 'dart:io';
import 'dart:ui';
import 'package:animator/animator.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/ui/meeting/make_meeting_page.dart';
import 'package:byule/ui/meeting/widgets/member_cards.dart';
import 'package:byule/ui/widget/dialog/meeting_apply_dialog.dart';
import 'package:byule/ui/widget/dialog/meeting_letter_dialog.dart';
import 'package:byule/ui/widget/member/member_pick_list.dart';
import 'package:byule/util/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/dialog/noCoinDialog.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';

//oppositeUser > '방장 - 지원자' 간 서로
//applyUser > 지원자
class MeetingDetailController extends GetxController {
  RxBool applied = false.obs;
  RxBool buttonClicked = false.obs;
  RxBool userLoaded = false.obs;
  UserModel meetingOwner = UserModel.initUser();
  Rx<MeetingModel> meeting = MeetingModel().obs;
  UserModel oppositeUser;
  List<MemberModel> memberListToShow = <MemberModel>[];

  final MeetingModel initialMeeting;

  RxList<int> pickedMemberIndexList = <int>[].obs;
  RxInt needMemberNum = 0.obs;

  MeetingDetailController(this.initialMeeting);

  @override
  void onInit() async {
    meeting.value = initialMeeting;
    //meetingOwner init
    DocumentSnapshot snapshot = await meeting.value.user.get();
    Map<String, dynamic> data = snapshot.data();
    if (data == null) data = {"deleted": true};

    meetingOwner = UserModel.fromJson(data);
    userLoaded.value = true;

    MemberModel userByMember = Util.userToMemberModel(meetingOwner.profileInfo);

    memberListToShow.add(userByMember);
    if (meeting.value.memberList != null) {
      meeting.value.memberList.forEach((member) => memberListToShow.add(member));
    }

    super.onInit();
  }
}

class MeetingDetailPage extends StatelessWidget {
  // final MeetingModel meeting;
  final MeetingDetailController meetingDetailController;

  MeetingDetailPage(this.meetingDetailController);

  final TextEditingController _selfIntroductionController = TextEditingController();
  final MainController _mainController = Get.find();

  UserModel get user => _mainController.user.value;

  bool get applied => meetingDetailController.applied.value;

  bool get buttonClicked => meetingDetailController.buttonClicked.value;

  UserModel get meetingOwner => meetingDetailController.meetingOwner;

  MeetingModel get meeting => meetingDetailController.meeting.value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.5, 0.6, 1],
              colors: [AppColor.main100, AppColor.main100, Colors.white, Colors.white])),
      child: SafeArea(
        // bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            if (buttonClicked) {
              meetingDetailController.buttonClicked.value = false;
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.75],
                          colors: [AppColor.main100, Colors.white])),
                ),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      titleCard(),
                      MemberCards(
                        memberList: meetingDetailController.memberListToShow,
                        deleted: meetingOwner.deleted != null,
                        meetingId: meetingDetailController.meeting.value.id,
                        meeting: meeting,
                        meetingOwner: meetingOwner,
                        onTapReport: () =>
                            Get.dialog(ReportDialog(meeting.id, ReportType.meeting, meetingDetailController: meetingDetailController)),
                      ),

                      //전자는 들어 갔을 때, 수락 거절 버튼이 있어야됨 //후자는 상대방 프로필만
                      if ((meeting.process == 0 && meeting.isMine == true) || meeting.process == 1)
                        Column(
                          children: [
                            Container(color: Colors.grey[300], height: 1),
                            seeTheOppositeBt(),
                          ],
                        ),
                      if (user.man != meeting.man && !meeting.isMine && meeting.process == null)
                        Column(
                          children: [
                            Container(color: Colors.grey[300], height: 1),
                            buildApplyButton(context),
                          ],
                        )
                    ],
                  ),
                ),
                // Obx(() => appliedNoti(context))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildApplyButton(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: Get.width*0.9,
                  child: ElevatedButton(
                    style: BtStyle.changeState(buttonClicked),
                    child: buttonClicked
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.favorite,
                                size: 20,
                              ),
                            ],
                          )
                        : Text('신청하기'),
                    onPressed: buttonClicked
                        ? (user.coin < 5)
                            ? () => Get.dialog(NoCoinDialog())
                            : () => Get.dialog(MeetingApplyDialog(meeting, meetingDetailController))
                        : () => Get.dialog(MeetingApplyDialog(meeting, meetingDetailController)),
                  ),
                ),
              ),
              secondChild: SizedBox(),
              crossFadeState: this.applied ?? false ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100)),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Column(
                  children: [
                    MemberPickList(meetingDetailController.pickedMemberIndexList, (index) {
                      if (meetingDetailController.pickedMemberIndexList.contains(index)) {
                        meetingDetailController.pickedMemberIndexList.remove(index);
                      } else {
                        meetingDetailController.pickedMemberIndexList.add(index);
                      }
                    }),
                    SizedBox(height: 8),
                    TextField(
                      cursorColor: Colors.red[200],
                      controller: _selfIntroductionController,
                      maxLength: 500,
                      minLines: 5,
                      style: TextStyle(
                        fontFamily: "AppleSDGothicNeoM",
                      ),
                      maxLines: 10,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '상대에게 보낼 메세지를 작성해주세요.',
                        hintStyle: TextStyle(
                          fontFamily: "AppleSDGothicNeoM",
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[300]),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey[300]),
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: Container(),
              crossFadeState: this.applied ?? false ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 100),
            ),
            crossFadeState: buttonClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 100),
          )
        ],
      ),
    );
  }

  Widget seeTheOppositeBt() {
    return Row(
      children: [
        if (meeting.isMine)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.05, vertical: 6),
              child: ElevatedButton(
                  child: Text('상대방 확인'),
                  style: BtStyle.textMain200,
                  onPressed: () async {
                    DocumentSnapshot snapshot;
                    snapshot = await meeting.apply.user.get();
                    Map<String, dynamic> data = snapshot.data();

                    meetingDetailController.oppositeUser = UserModel.fromJson(data);
                    Get.toNamed('/meeting_opposite_profile', arguments: {"meetingId": meeting.id, "user": meetingDetailController.oppositeUser}, preventDuplicates: false);
                  }),
            ),
          ),
        if (meeting.process == 1)
          Padding(
            padding: meeting.isMine ? EdgeInsets.only(right: Get.width*0.05) : EdgeInsets.symmetric(horizontal: Get.width*0.05, vertical: 8),
            child: Container(
              width: meeting.isMine ? 75 : Get.width*0.9,
              child: ElevatedButton(
                style: BtStyle.textSub200,
                onPressed: () async {
                  DocumentSnapshot snapshot;
                  if (meeting.isMine) {
                    snapshot = await meeting.apply.user.get();
                  } else {
                    snapshot = await meeting.user.get();
                  }
                  Map<String, dynamic> data = snapshot.data();
                  MainController.goToChatPage(meeting.id, UserModel.fromJson(data), 'meeting');
                },
                child: Container(
                    width: 25,
                    child: Image.asset(
                      'assets/bubble_chat.png',
                      color: Colors.white,
                    )),
              ),
            ),
          ),
      ],
    );
  }

  Widget appliedNoti(BuildContext context) {
    return AnimatedCrossFade(
        firstCurve: Curves.easeInOutQuart,
        secondCurve: Curves.easeInOutQuart,
        firstChild: SizedBox(
          width: Get.width,
          height: 25,
        ),
        secondChild: Container(
          width: Get.width,
          height: 25,
          color: Colors.black12,
          child: Center(
              child: Text(
            '미팅 수락을 기다리고 있습니다',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: "AppleSDGothicNeoM",
            ),
          )),
        ),
        crossFadeState: meeting.process == 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 100));
  }

  Widget titleCard() {
    return Padding(
      padding: EdgeInsets.only(left: Get.width * 0.05, right: Get.width * 0.05, top: Platform.isAndroid ? 8 : 0),
      child: Card(
        margin: EdgeInsets.all(0),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //제목 및 인원
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3.0),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black54,
                          size: 18,
                        ),
                      )),
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          '${meeting.loc1} ${meeting.loc2} ${meeting.loc3}, ${meeting.number} : ${meeting.number}',
                          style: TextStyle(color: Colors.black45, fontSize: 17, fontFamily: "AppleSDGothicNeoM", height: 1),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.dialog(MeetingLetterDialog(meeting.introduce)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Stack(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                          ),
                          Animator(
                              duration: Duration(milliseconds: 1000),
                              cycles: 0,
                              curve: Curves.elasticOut,
                              tween: Tween<double>(begin: 18.0, end: 24.0),
                              builder: (context, animatorState, child) =>
                                  Image.asset('assets/love_letter.png', height: animatorState.value, width: animatorState.value)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 0),
                    child: Text(
                      meeting.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "AppleSDGothicNeoB",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
