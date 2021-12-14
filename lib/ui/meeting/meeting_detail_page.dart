import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:signalmeeting/controller/chat_controller.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/chat/chat_page.dart';
import 'package:signalmeeting/ui/home/opposite_profile.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/ui/widget/dialog/report_dialog.dart';
import 'package:signalmeeting/ui/widget/noCoin.dart';
import 'package:signalmeeting/util/style/btStyle.dart';

//oppositeUser > '방장 - 지원자' 간 서로
//applyUser > 지원자
class MeetingDetailController extends GetxController {
  RxBool applied = false.obs;
  RxBool buttonClicked = false.obs;
  RxBool userLoaded = false.obs;
  UserModel meetingOwner = UserModel();
  Rx<MeetingModel> meeting = MeetingModel().obs;
  UserModel oppositeUser;

  final MeetingModel initialMeeting;
  MeetingDetailController(this.initialMeeting);

  @override
  void onInit() async {
    meeting.value = initialMeeting;
    //meetingOwner init
    DocumentSnapshot snapshot = await meeting.value.user.get();
    Map<String, dynamic> data = snapshot.data();
    meetingOwner = UserModel.fromJson(data);

    userLoaded.value = true;
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
    return WillPopScope(
      onWillPop: () async {
        if(buttonClicked) {
          meetingDetailController.buttonClicked.value = false;
          return false;
        } return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            highlightColor: Colors.white,
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            '미팅 신청',
            style: TextStyle(
              color: Colors.black,
              fontFamily: "AppleSDGothicNeoM",
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.5], colors: [Colors.red[50], Colors.white])),
            ),
            Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  mainCard(),
                  Container(color: Colors.grey[300], height: 1),
                  //전자는 들어 갔을 때, 수락 거절 버튼이 있어야됨 //후자는 상대방 프로필만
                  if ((meeting.process == 0 && meeting.isMine == true) || meeting.process == 1)
                    seeTheOppositeBt(),
                  if (!meeting.isMine && meeting.process == null)
                    buildApplyButton(context)
                ],
              ),
            ),
            Obx(() => appliedNoti(context))
          ],
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: AnimatedCrossFade(
                  firstChild: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '신청하기',
                          ),
                        ],
                      ),
                      style: BtStyle.textMain200,
                      onPressed: () {
                        meetingDetailController.buttonClicked.value = true;
                      }),
                  secondChild: TextButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '5',
                            style: TextStyle(
                              fontFamily: "AppleSDGothicNeoB",
                              fontSize: 20,
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
                      ),
                      style: BtStyle.sideLine,
                      onPressed: (user.coin < 5) ? () => Get.dialog(NoCoinDialog()) : () async {
                        FocusScope.of(context).unfocus();
                        await DatabaseService.instance.applyMeeting(this.meeting.id, _selfIntroductionController.text, this.meeting.title, this.meeting.user.id);
                        meetingDetailController.meeting.update((meeting) => meeting.process = 0);
                        Map<String, dynamic> applyMeeting = {
                          "title" : meeting.title,
                          "loc1" : meeting.loc1,
                          "loc2" : meeting.loc2,
                          "loc3" : meeting.loc3,
                          "number" : meeting.number,
                          "introduce" : meeting.introduce,
                        };
                        await DatabaseService.instance.useCoin(5, 2, newMeeting: applyMeeting ,oppositeUserid: meeting.userId);
                      }),
                  crossFadeState: buttonClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 100),
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
                child: TextField(
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
                    fillColor: Colors.grey[100],
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            DocumentSnapshot snapshot;
            if(meeting.isMine) {
              snapshot = await meeting.apply.user.get();
            } else {
              snapshot = await meeting.user.get();
            }
            Map<String, dynamic> data = snapshot.data();
            meetingDetailController.oppositeUser = UserModel.fromJson(data);

            print('meeting.id : ${meeting.id}');
            print('meetingDetailController.oppositeUser : ${meetingDetailController.oppositeUser.name}');
            Get.to(() => ChatPage(),
            binding: BindingsBuilder(() {
              Get.put(ChatController(
                    meeting.id,
                    meetingDetailController.oppositeUser.uid,
                    meetingDetailController.oppositeUser.name),
                tag: meeting.id);
            }),
                arguments: meeting.id,
              preventDuplicates: false,
          );
          },
          child: Text('asd'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: RaisedButton(
              highlightElevation: 0,
              elevation: 0,
              child: Text(
                '상대방 확인',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "AppleSDGothicNeoB",
                  fontSize: 18,
                ),
              ),
              color: Colors.red[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onPressed: () async {
                DocumentSnapshot snapshot;
                if(meeting.isMine) {
                  snapshot = await meeting.apply.user.get();
                } else {
                  snapshot = await meeting.user.get();
                }
                Map<String, dynamic> data = snapshot.data();
                meetingDetailController.oppositeUser = UserModel.fromJson(data);
                Get.to(() => OppositeProfilePage(meetingDetailController.oppositeUser, isTodayMatch: false),
                  arguments: meeting.id,
                  preventDuplicates: false);

              }),
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

  Widget buildOppositeProfile() {
    if(meetingDetailController.userLoaded.value)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10),
          child: meetingOwner.pics.length > 0 ? BluredImage(meetingOwner.pics[0], meetingDetailController.meeting.value.id) : Container(),
        ),
        Wrap(
          children: [
            MyChip(meetingOwner.age + '살'),
            MyChip(meetingOwner.tall + 'cm'),
            MyChip(null),
            MyChip(meetingOwner.bodyType),
            MyChip(meetingOwner.career),
            MyChip('${meetingOwner.loc1} ${meetingOwner.loc2}'),
            MyChip(meetingOwner.mbti),
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
            onTap: () => banned
                ? Get.defaultDialog(title: '이미 신고 했습니다')
                : Get.dialog(ReportDialog(id, ReportType.meeting, meetingDetailController: meetingDetailController)),
            child: Container(
              width: 20,
              height: 20,
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
                  border: Border.all(color: Colors.grey[200], width: 1.5),
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

  Widget mainCard() {
    return Expanded(
      flex: 9,
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: GlowingOverscrollIndicator(
          axisDirection: AxisDirection.down,
          color: Colors.red[50],
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 18),
              child: Card(
                margin: EdgeInsets.all(8),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.fromLTRB(30, 15, 30, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      //제목 및 인원
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 5),
                        child: Text(
                          meeting.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: "AppleSDGothicNeoB",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          '${meeting.loc1} ${meeting.loc2} - ${meeting.loc3}, ${meeting.number} : ${meeting.number}',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 16,
                            fontFamily: "AppleSDGothicNeoM",
                          ),
                        ),
                      ),

                      //주선자 정보
                      Obx(() => buildOppositeProfile()),

                      //소개
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 10),
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
            ),
          ),
        ),
      ),
    );
  }
}
