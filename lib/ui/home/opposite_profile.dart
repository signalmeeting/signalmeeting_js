import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/meeting/meeting_detail_page.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/ui/widget/dialog/report_dialog.dart';
import 'package:signalmeeting/ui/widget/flush_bar.dart';
import 'package:signalmeeting/ui/widget/noCoin.dart';
import 'package:signalmeeting/util/style/appColor.dart';
import 'package:signalmeeting/util/style/btStyle.dart';

class OppositeProfilePage extends StatefulWidget {
  final UserModel user;
  final bool isTodayMatch; //todayMatch , meeting 신청 확인 2개 양식
  final String docId; //todayMatch docId
  final bool isItFromChat;

  OppositeProfilePage(
      this.user, {
        this.isTodayMatch = true,
        this.docId,
        this.isItFromChat = false,
      });

  @override
  _OppositeProfilePageState createState() => _OppositeProfilePageState();
}

class _OppositeProfilePageState extends State<OppositeProfilePage> {
  MeetingDetailController meetingDetailController;

  MeetingModel get meeting => meetingDetailController.meeting.value;
  double width = Get.width * 0.9;
  double height = Get.width * 0.9;

  MainController _controller = Get.find();
  MyMeetingController _myMeetingController = Get.find();

  bool _buttonClicked = false;
  bool _signalSent = false;

  UserModel get myuser => _controller.user.value;

  @override
  void initState() {
    if (!widget.isTodayMatch) {
      meetingDetailController = Get.find(tag: Get.arguments);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                profileImage(),
                //애니메이션 버튼
                if (!_signalSent && widget.isTodayMatch && !widget.isItFromChat)
                  FutureBuilder(
                    future: DatabaseService.instance.checkConnectionAndSignal(widget.user.uid),
                    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (!snapshot.hasData)
                        return Container(); //인창, 시그널 보냈으면 보냈습니다 표시 추가 예정,,
                      else {
                        int result = snapshot.data["result"];
                        return Column(
                          children: [
                            AnimatedCrossFade(
                                firstChild: TextButton(
                                  style: BtStyle.changeState(_buttonClicked),
                                  child: _buttonClicked
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '1',
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
                                      : Text('시그널 보내기'),
                                  onPressed: _buttonClicked ? () => onPressSignalButton() : () => setState(() => _buttonClicked = true),
                                ),
                                secondChild: Container(),
                                crossFadeState:
                                result == 1 || result == 2 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300)),
                            if (result == 2)
                              TextButton(
                                  style: BtStyle.textSub200,
                                  onPressed: () {
                                    //시그널 매치 됐을 때 채팅방으로 가는 버튼
                                    MainController.goToChatPage(snapshot.data["docId"], widget.user, 'signal');
                                  },
                                  child: Text('대화하기')),
                          ],
                        );
                      }
                    },
                  ),
                //divider
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Container(
                    height: 10,
                    color: Colors.grey[200],
                  ),
                ),
                if (!widget.isTodayMatch) Obx(() => !widget.isTodayMatch && meeting.process == 0 ? acceptOrNot() : Container()),
                //닉네임
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: Get.width * 0.05, top: 25, bottom: 5),
                      child: Text(
                        widget.user.name,
                        style: TextStyle(
                          fontSize: 23,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                //나이, 직업
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: Get.width * 0.05, bottom: 25),
                      child: Text(
                        '${widget.user.age}, ${widget.user.career}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                _InfoForm('지역', '${widget.user.loc1} ${widget.user.loc2}'),
                _InfoForm('키', widget.user.tall),
                _InfoForm('체형', widget.user.bodyType),
                _InfoForm('흡연', widget.user.smoke),
                _InfoForm('음주', widget.user.drink),
                _InfoForm('종교', widget.user.religion),
                _InfoForm('mbti', widget.user.mbti),
                _InfoForm('간단소개', widget.user.introduce),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onPressSignalButton() async {
    if (myuser.coin < 1) {
      Get.dialog(NoCoinDialog());
    } else {
      //시그널 보내기, 코인 소모
      bool result = await DatabaseService.instance.sendSignal(widget.user.uid, widget.docId);
      await DatabaseService.instance.useCoin(1, 0, oppositeUserid: widget.user.uid);
      if (result) {
        CustomedFlushBar(context, '시그널을 보냈습니다');
        setState(() {
          _signalSent = true;
        });
      }
    }
  }

  Widget _InfoForm(String category, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: Get.width * 0.25,
          height: 55,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$category',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.transparent,
          width: Get.width * 0.65,
          height: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: value != null
                ? <Widget>[
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ]
                : <Widget>[
              Text(
                '-',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget acceptOrNot() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.all(10),
          width: Get.width * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200], width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Text(meeting.apply.msg),
        ),
        SizedBox(height: 10.0),
        acceptOrNotButtons(),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            height: 10,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  _onPressAccept() async {
    await DatabaseService.instance
        .acceptApply(meetingId: meeting.id, applyId: meeting.apply.applyId, meetingTitle: meeting.title, receiver: widget.user.uid);
    meetingDetailController.meeting.update((meeting) {
      meeting.process = 1;
    });
    // print('Get.arguments : ${meetingDetailController}');

    // print('Get.arguments : ${meetingDetailController}');
    CustomedFlushBar(Get.context, '축하합니다! 미팅이 성사되었습니다!');
    //바깥으로 보내버리는건 좀 아닌듯
    //수락 시 - 수락 거절 부분 없애고,(오픈 컨테이너로?)
    //거절 시  - 바깥으로 보내고 플러시 한번 띄워주??

    1.delay(() {
      for (int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
        if (_myMeetingController.myMeetingList[i].id == meetingDetailController.meeting.value.id) {
          _myMeetingController.myMeetingList[i].process = 1;
        }
      }
    });
  }

  Widget acceptOrNotButtons() {
    return Row(
      children: [
        SizedBox(
          width: Get.width * 0.05,
        ),
        Flexible(
          child: TextButton(
            child: Text('수락'),
            style: BtStyle.textMain200,
            onPressed: () => _onPressAccept(),
          ),
        ),
        SizedBox(
          width: Get.width * 0.05,
        ),
        Flexible(
          child: TextButton(
            child: Text('거절'),
            style: BtStyle.textMain100,
            onPressed: () {
              DatabaseService.instance.refuseApply(
                  meetingId: meeting.id, applyId: meeting.apply.applyId, meetingTitle: meeting.title, receiver: widget.user.uid);

              //인창, 여기 null이 맞을까 2가 맞을까??
              for (int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
                if (_myMeetingController.myMeetingList[i].id == meeting.id) {
                  _myMeetingController.myMeetingList[i].process = null;
                }
              }
              meetingDetailController.meeting.update((meeting) => meeting.process = null);
            },
          ),
        ),
        SizedBox(
          width: Get.width * 0.05,
        ),
      ],
    );
  }

  Widget profileImage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
              child: Swiper(
                loop: false,
                itemBuilder: (BuildContext context, int index) {
                  return Hero(
                      tag: 'today_signal' + widget.user.uid,
                      child: cachedImage(
                        widget.user.pics[index],
                        width: width,
                        height: height,
                        radius: 0,
                      ));
                },
                itemCount: widget.user.pics.length,
                pagination: new SwiperPagination(
                  builder: new DotSwiperPaginationBuilder(color: Colors.white30, activeColor: Colors.white70),
                ),
              ),
            ),
          ),
          Positioned(
            child: InkWell(
              onTap: () => Get.dialog(ReportDialog(widget.user.uid, ReportType.daily)),
              child: Container(
                width: 30,
                height: 30,
                child: Image.asset(
                  'assets/report.png',
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            top: 10,
            right: 10,
          ),
        ],
      ),
    );
  }
}
