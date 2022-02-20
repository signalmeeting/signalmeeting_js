import 'dart:io';
import 'dart:ui';

import 'package:byule/model/memberModel.dart';
import 'package:byule/ui/meeting/make_meeting_page.dart';
import 'package:byule/ui/widget/dialog/meeting_letter_dialog.dart';
import 'package:byule/ui/widget/member/member_pick_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:byule/controller/chat_controller.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/chat/chat_page.dart';
import 'package:byule/ui/home/opposite_profile.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/ui/widget/deletedUser.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/dialog/noCoinDialog.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';

//oppositeUser > '방장 - 지원자' 간 서로
//applyUser > 지원자
class MeetingDetailController extends GetxController {
  RxBool applied = false.obs;
  RxBool buttonClicked = false.obs;
  RxBool userLoaded = false.obs;
  UserModel meetingOwner = UserModel();
  Rx<MeetingModel> meeting = MeetingModel().obs;
  UserModel oppositeUser;
  List<Map<String, dynamic>> memberListToShow = [];

  final MeetingModel initialMeeting;
  MeetingDetailController(this.initialMeeting);

  @override
  void onInit() async {
    meeting.value = initialMeeting;
    //meetingOwner init
    DocumentSnapshot snapshot = await meeting.value.user.get();
    Map<String, dynamic> data = snapshot.data();
    if(data == null)
      data = {"deleted" : true};

    if(data["memberList"] !=null) {
      Map<String, dynamic> memberMap = data["memberList"];
      data["memberList"] = memberMap.values.map((e) => e).toList();
    }
    meetingOwner = UserModel.fromJson(data);
    userLoaded.value = true;

    Map<String, dynamic> userByMember = MemberModel(
      index: null,
      url: meetingOwner.profileInfo['pics'][0],
      age: meetingOwner.profileInfo['age'].toString(),
      tall: meetingOwner.profileInfo['tall'].toString(),
      career: meetingOwner.profileInfo['career'],
      loc1: meetingOwner.profileInfo['loc1'],
      loc2: meetingOwner.profileInfo['loc2'],
      bodyType: meetingOwner.profileInfo['bodyType'],
      smoke: meetingOwner.profileInfo['smole'],
      drink: meetingOwner.profileInfo['drink'],
      mbti: meetingOwner.profileInfo['mbti'],
      introduce: meetingOwner.profileInfo['introduce'],
    ).toJson();

    memberListToShow.add(userByMember);
    if(meeting.value.memberList != null) {
      meeting.value.memberList.forEach((member) => memberListToShow.add(member));
    }


    0.5.delay(() => Get.dialog(MeetingLetterDialog(meeting.value.introduce)));

    super.onInit();
  }
}

class MeetingDetailPage extends StatelessWidget {
  // final MeetingModel meeting;
  final MeetingDetailController meetingDetailController;
  final MakeMeetingController _makeMeetingController = Get.put(MakeMeetingController());

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
              colors: [AppColor.main100, AppColor.main100, Colors.white, Colors.white])
      ),
      child: SafeArea(
        // bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            if(buttonClicked) {
              meetingDetailController.buttonClicked.value = false;
              return false;
            } return true;
          },
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.75], colors: [AppColor.main100, Colors.white])),
                ),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      titleCard(),
                      cardSwiper(),
                      // introduceCard(),

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
                Obx(() => appliedNoti(context))
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
                  width: Get.width - 16,
                  child: TextButton(
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
                    onPressed: buttonClicked ? (user.coin < 5) ? () => Get.dialog(NoCoinDialog()) : () async {
                                ///멤버를 인원에 맞게 설정해주세요
                                if(_makeMeetingController.pickedMemberIndexList.length + 1 != meeting.number) {
                                  Get.dialog(NotificationDialog(
                                    title: "잠깐!",
                                    contents: "미팅 인원에 맞도록 멤버를 선택해주세요",
                                    contents2: "( ${_makeMeetingController.pickedMemberIndexList.length} / ${meeting.number - 1} )",
                                  ));
                                  return;
                                }

                                FocusScope.of(context).unfocus();

                                ///최근에 거절당한 미팅 있는지 확인
                                bool refusedExist = await DatabaseService
                                    .instance
                                    .checkRefusedBeforeApply(this.meeting.id);
                                if (refusedExist) return;

                                bool result = await DatabaseService.instance
                                    .applyMeeting(
                                        this.meeting.id,
                                        _selfIntroductionController.text,
                                        this.meeting.title,
                                        this.meeting.user.id);
                                if (result) {
                                  meetingDetailController.meeting
                                      .update((meeting) => meeting.process = 0);
                                  Map<String, dynamic> applyMeeting = {
                                    "title": meeting.title,
                                    "loc1": meeting.loc1,
                                    "loc2": meeting.loc2,
                                    "loc3": meeting.loc3,
                                    "number": meeting.number,
                                    "introduce": meeting.introduce,
                                  };
                                  await DatabaseService.instance.useCoin(5, 2,
                                      newMeeting: applyMeeting,
                                      oppositeUserid: meeting.userId);
                                }
                              }
                        : () => meetingDetailController.buttonClicked.value = true,
                  ),
                ),),
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
                    MemberPickList(),
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
                        fillColor: Colors.grey.withOpacity(0.1),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextButton(
                child: Text('상대방 확인'),
                style: BtStyle.textMain200,
                onPressed: () async {
                  DocumentSnapshot snapshot;
                  if (meeting.isMine) {
                    snapshot = await meeting.apply.user.get();
                  } else {
                    snapshot = await meeting.user.get();
                  }
                  Map<String, dynamic> data = snapshot.data();
                  meetingDetailController.oppositeUser = UserModel.fromJson(data);
                  Get.to(() => OppositeProfilePage(meetingDetailController.oppositeUser, isTodayMatch: false),
                      arguments: meeting.id, preventDuplicates: false);
                }),
          ),
        ),
        if (meeting.process == 1)
          Padding(
            padding: const EdgeInsets.only(right : 8.0),
            child: Container(
              width: 75,
              child: TextButton(
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
                child: Container(width: 25, child: Image.asset('assets/bubble_chat.png', color: Colors.white,)),
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
              child: Text('미팅 수락을 기다리고 있습니다',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: "AppleSDGothicNeoM",
            ),
          )),
        ),
        crossFadeState: meeting.process == 0 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 100));
  }

  Widget buildOppositeProfile(Map<String, dynamic> member) {
    if(meetingDetailController.userLoaded.value)
    return meetingOwner.deleted != null  ? deletedUser(onPressed : () {}) : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10),
          child: meetingOwner.pics.length > 0 ? BluredImage(member['url'], meetingDetailController.meeting.value.id) : Container(),
        ),
        Wrap(
          children: [
            MyChip(member['age'] + '살'),
            MyChip(member['tall'] + 'cm'),
            MyChip(null),
            MyChip(member['bodyType']),
            MyChip(member['career']),
            MyChip('${member['loc1']} ${member['loc2']}'),
            MyChip(member['mbti']),
          ],
        ),
      ],
    ); else return Center(child: CircularProgressIndicator());
  }

  Widget BluredImage(String pic, String id) {
    bool banned = false;
    meeting.banList?.forEach((banItem) {
      if(banItem['from'] == this.user.uid) {
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
            onTap: () => !meeting.isMine ? banned
                ? Get.dialog(NotificationDialog(contents: "이미 신고 했습니다"))
                : Get.dialog(ReportDialog(id, ReportType.meeting, meetingDetailController: meetingDetailController)) : (){},
            child: Container(
              width: 30,
              height: 30,
              child: !meeting.isMine ?
                Image.asset('assets/report.png', color: Colors.white.withOpacity(0.7),) : Container(),
            ),
          ),
          top: 10,
          right: 10,
        )
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

  Widget titleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 3,
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
                          '${meeting.loc1} ${meeting.loc2} - ${meeting.loc3}, ${meeting.number} : ${meeting.number}',
                          style: TextStyle(
                              color: Colors.black45,
                              fontSize: 17,
                              fontFamily: "AppleSDGothicNeoM",
                              height: 1
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.dialog(MeetingLetterDialog(meeting.introduce)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Image.asset('assets/love_letter.png', height: 20, width: 20),
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

  Widget introduceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Card(
        margin: EdgeInsets.all(8),
        elevation: 3,
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
              Padding(
                padding: const EdgeInsets.only(top: 0.0, bottom: 10),
                child: Text(
                  '미팅 소개',
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
                    meeting.introduce,
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
    );
  }

  Widget cardSwiper() {
    return Flexible(
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) => mainCard(meetingDetailController.memberListToShow[index]),
          loop: false,
          scale: 0.78,
          fade: 0.55,
          itemCount: meetingDetailController.memberListToShow.length,
          viewportFraction: 0.8,
        ),
      ),
    );
  }

  Widget mainCard(Map<String, dynamic> member) {
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
                          member['introduce']??'',
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

}
