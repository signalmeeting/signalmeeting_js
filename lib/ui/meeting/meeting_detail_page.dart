import 'dart:ui';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/home/opposite_profile.dart';
import 'package:signalmeeting/ui/meeting/my_meeting_page.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/ui/widget/dialog/confirm_dialog.dart';
import 'package:signalmeeting/ui/widget/dialog/report_dialog.dart';
import 'package:signalmeeting/ui/widget/noCoin.dart';

import '../../controller/my_meeting_controller.dart';

class MeetingDetailController extends GetxController {
  RxBool applied = false.obs;
  RxBool buttonClicked = false.obs;
  Rx<UserModel> oppositeUser = UserModel().obs;
  RxBool userLoading = false.obs;

  final MeetingModel meeting;
  final bool isApplied;

  MeetingDetailController(this.meeting, this.isApplied);

  @override
  void onInit() async {
    DocumentSnapshot snapshot = await meeting.user.get();
    Map<String, dynamic> data = snapshot.data();
    oppositeUser.value = UserModel.fromJson({"uid": data["uid"], "profileInfo": data["profileInfo"], 'phone': data['phone']});
    userLoading.value = true;
    if (isApplied)
      this.applied.value = true;
    else {
      bool result = await DatabaseService.instance.getMyApply(meeting.id);
      this.applied.value = result;
    }

    if (meeting.process == 1 && meeting.isMine && meeting.applyUser != null) {
      Get.dialog(ConfirmDialog(
        title: '성사된 미팅입니다!',
        text: '${meeting.applyUser.phoneNumber}',
        onConfirmed: () {},
        confirmText: '확인',
      ));
    } else if (meeting.process == 1 && !meeting.isMine && meeting.apply != null) {
      Get.dialog(ConfirmDialog(
        title: '성사된 미팅입니다',
        text: '다른 미팅에 신청해주세요', // '${meeting.apply['phone']}' => '다른 미팅에 신청해주세요'
        onConfirmed: () => Get.back(),
        confirmText: '확인',
      ));
    } else if (meeting.process == 1 && (meeting.applyUser == null || meeting.apply == null)) {
      Get.dialog(ConfirmDialog(
        title: '성사된 미팅입니다!',
        text: '내 미팅 페이지에서 확인해주세요',
        onConfirmed: () {
          Get.back();
          Get.to(() => MyMeetingPage());
        },
        confirmText: '확인',
      ));
    }
    super.onInit();
  }
}

class MeetingDetailPage extends StatelessWidget {
  final MeetingModel meeting;
  final bool isApplied;
  final MeetingDetailController meetingDetailController;

  MeetingDetailPage(this.meeting, this.meetingDetailController, {this.isApplied = false});


  // final MyMeetingController _myMeetingController = Get.put(MyMeetingController());
  final TextEditingController _selfIntroductionController = TextEditingController();

  final MainController _mainController = Get.find();
  UserModel get user => _mainController.user.value;
  bool get applied => meetingDetailController.applied.value;
  bool get buttonClicked => meetingDetailController.buttonClicked.value;
  UserModel get oppositeUser => meetingDetailController.oppositeUser.value;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(buttonClicked) {
          meetingDetailController.buttonClicked.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
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
                ),
                Container(
                  color: Colors.grey[300],
                  height: 1,
                ),
                if ((meeting.process == 0 || meeting.process == 1) && (applied == false) && (meeting.applyUser != null))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: ButtonTheme(
                      height: 45,
                      minWidth: Get.width - 16,
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
                          onPressed: () {
                            print('meeting.applyUser @@@@@@@@@@@@@ : ${meeting.applyUser}');
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OppositeProfilePage(meeting.applyUser, isTodayMatch: false, meetingData: {
                                          "msg": meeting.apply["msg"],
                                          "createdAt": meeting.apply["createdAt"],
                                          "applyId": meeting.apply["id"],
                                          "meetingId": meeting.id,
                                          "title": meeting.title,
                                          'process':meeting.process
                                        })));
                          }),
                    ),
                  ),
                //인창, 'this.applied ?? false ||' 부분 삭제 (신청 후 fade 되는 에니메이션 사라져서)
                if (!meeting.isMine) buildApplyButton(context)
              ],
            ),
            Obx(() => appliedNoti(context))
          ],
        ),
      ),
    );
  }

  buildApplyButton(BuildContext context) {
    return Obx(
      () => (this.applied || this.meeting.process == 0 || this.meeting.process == 1) // 신청중이거나 연결된 meeting은 신청못하게
          ? SizedBox()
          : Column(
              children: [
                AnimatedCrossFade(
                    firstChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: AnimatedCrossFade(
                        firstChild: ButtonTheme(
                          height: 45,
                          minWidth: Get.width - 16,
                          child: RaisedButton(
                              highlightElevation: 0,
                              elevation: 0,
                              child: Text(
                                '신청하기',
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
                              onPressed: () {
                                meetingDetailController.buttonClicked.value = true;
                              }),
                        ),
                        secondChild: ButtonTheme(
                          minWidth: Get.width - 16,
                          height: 45,
                          child: RaisedButton(
                              elevation: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '5',
                                    style: TextStyle(
                                      color: Colors.red[200],
                                      fontFamily: "AppleSDGothicNeoB",
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red[200],
                                    size: 20,
                                  ),
                                ],
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1.5, color: Colors.red[200]), borderRadius: BorderRadius.circular(5)),
                              onPressed: (user.coin < 5) ? () => Get.dialog(NoCoinDialog()) : () async {
                                FocusScope.of(context).unfocus();
                                await DatabaseService.instance.applyMeeting(
                                    this.meeting.id, _selfIntroductionController.text, this.meeting.title, this.meeting.user.id);
                                meetingDetailController.applied.value = true;
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
                        ),
                        crossFadeState: buttonClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 500),
                      ),
                    ),
                    secondChild: SizedBox(),
                    crossFadeState: this.applied ?? false ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 500)),
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
                    duration: const Duration(milliseconds: 500),
                  ),
                  crossFadeState: buttonClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 500),
                )
              ],
            ),
    );
  }

  appliedNoti(BuildContext context) {
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
            meeting.process == 0 ? '상대방의 수락을 기다리고 있습니다' : '성사된 미팅입니다!',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: "AppleSDGothicNeoM",
            ),
          )),
        ),
        crossFadeState: this.applied ?? false ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 500));
  }

  buildOppositeProfile() {
    if(meetingDetailController.userLoading.value)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10),
          child: oppositeUser.pics.length > 0 ? BluredImage(oppositeUser.pics[0], meetingDetailController.meeting.id) : Container(),
        ),
        Wrap(
          children: [
            MyChip(oppositeUser.age + '살'),
            MyChip(oppositeUser.tall + 'cm'),
            MyChip(null),
            MyChip(oppositeUser.bodyType),
            MyChip(oppositeUser.career),
            MyChip('${oppositeUser.loc1} ${oppositeUser.loc2}'),
            MyChip(oppositeUser.mbti),
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
                if (!(meeting.isMine ?? false))
                  meeting.process == 1
                      ? Container()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                if (!(meeting.isMine ?? false))
                  meeting.process == 1
                      ? Container()
                      : Center(
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
                        )
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
}
