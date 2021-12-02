import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';
import 'package:signalmeeting/ui/widget/colored_button.dart';
import 'package:signalmeeting/ui/widget/dialog/report_dialog.dart';
import 'package:signalmeeting/ui/widget/flush_bar.dart';
import 'package:signalmeeting/ui/widget/noCoin.dart';

class OppositeProfilePage extends StatefulWidget {
  final UserModel user;
  final bool isTodayMatch; //todayMatch , meeting 신청 확인 2개 양식
  final Map<String, dynamic> meetingData;
  final String docId;

  OppositeProfilePage(this.user, {this.isTodayMatch = true, this.meetingData, this.docId});

  @override
  _OppositeProfilePageState createState() => _OppositeProfilePageState();
}

class _OppositeProfilePageState extends State<OppositeProfilePage> {
  double width = Get.width * 0.9;
  double height = Get.width * 0.9;

  MainController _controller = Get.find();
  MyMeetingController _myMeetingController = Get.find();

  bool _buttonClicked = false;
  bool _signalSent = false;
  bool _acceptClicked = false;

  UserModel get myuser => _controller.user.value;

  @override
  Widget build(BuildContext context) {
    print('### ${widget.meetingData}');
    return Scaffold(
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                profileImage(),
                //애니메이션 버튼
                if (!_signalSent && widget.isTodayMatch)
                  FutureBuilder(
                    future: DatabaseService.instance.checkConnectionAndSignal(widget.user.uid),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }
                      if (!snapshot.hasData)
                        return Container(
                        );
                      //인창, 시그널 보냈으면 보냈습니다 표시 추가 예정,,
                      else {
                        print(snapshot.data);
                        return AnimatedCrossFade(
                            firstChild: AnimatedCrossFade(
                                firstChild: _SignalButton(false),
                                secondChild: _SignalButton(true),
                                crossFadeState: _buttonClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 400)),
                            secondChild: SizedBox(),
                            crossFadeState: snapshot.data == 1 || snapshot.data == 2 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            // data == 2일 때 번호 떠야됨
                            duration: const Duration(milliseconds: 400));
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
                if (!widget.isTodayMatch)
                  acceptOrNot(),
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

  Widget _SignalButton(bool clicked) {
    return ButtonTheme(
      highlightColor: Colors.transparent,
      minWidth: Get.width * 0.9,
      height: 40.0,
      child: RaisedButton(
        disabledElevation: 2,
        focusElevation: 2,
        elevation: 2,
        hoverElevation: 2,
        highlightElevation: 2,
        child: clicked
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '1',
                    style: TextStyle(
                      color: Colors.red[200],
                      fontSize: 18,
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
              )
            : Text(
                '시그널 보내기',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
        color: clicked ? Colors.white : Colors.red[200],
        shape: RoundedRectangleBorder(
            side: clicked ? BorderSide(width: 1.5, color: Colors.red[200]) : BorderSide.none, borderRadius: BorderRadius.circular(5)),
        onPressed: clicked ? () => onPressSignalButton() : () => setState(() => _buttonClicked = true),
      ),
    );
  }

  onPressSignalButton() async {
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
    //process 도 받아와서 확인을 해야한다,,,
    print('widget.meetingData ${widget.meetingData['process']}');
    return Column(
      children: [
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.all(10),
          width: Get.width*0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300], width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Text(widget.meetingData["msg"]),
        ),
        SizedBox(height: 10.0),
        //수락이면 바로 전화번호
        //수락이면 그냥 여기로 안오는거 같은데 수락이면 이즈 투데이 매치가 트루임??
        widget.meetingData['process'] == 1 ? phoneNumWidget() : AnimatedCrossFade(
            firstChild: acceptOrNotButtons(),
            secondChild: phoneNumWidget(),
            crossFadeState: _acceptClicked ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 400)),
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

  Widget acceptOrNotButtons() {
    return Row(
      children: [
        SizedBox(width: Get.width*0.05,),
        Flexible(
          child: ColoredButton(
            text: '수락',
            color: Colors.red[200],
            onPressed: () {
              setState(() => _acceptClicked = true);
              DatabaseService.instance.acceptApply(
                  meetingId: widget.meetingData["meetingId"],
                  applyId: widget.meetingData["applyId"],
                  meetingTitle: widget.meetingData["title"],
                  receiver: widget.user.uid);

              for(int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
                if(_myMeetingController.myMeetingList[i].id == widget.meetingData["meetingId"]) {
                  return _myMeetingController.myMeetingList[i].process = 1;
                }
              }
              CustomedFlushBar(context, '축하합니다! 미팅이 성사되었습니다!');
              //바깥으로 보내버리는건 좀 아닌듯
              //수락 시 - 수락 거절 부분 없애고,(오픈 컨테이너로?)
              //거절 시  - 바깥으로 보내고 플러시 한번 띄워주??
            },
          ),
        ),
        SizedBox(width: Get.width*0.05,),
        Flexible(
          child: ColoredButton(
            text: '거절',
            color: Colors.red[100],
            onPressed: () {
              DatabaseService.instance.refuseApply(
                  meetingId: widget.meetingData["meetingId"],
                  applyId: widget.meetingData["applyId"],
                  meetingTitle: widget.meetingData["title"],
                  receiver: widget.user.uid);

              for(int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
                if(_myMeetingController.myMeetingList[i].id == widget.meetingData["meetingId"]) {
                  _myMeetingController.myMeetingList[i].process = 2;
                }
              }
              Get.back();
              Get.back();
            },
          ),
        ),
        SizedBox(width: Get.width*0.05,),
      ],
    );
  }

  Widget phoneNumWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      width: Get.width*0.9,
      child: SelectableText(
        widget.user.phoneNumber,
        style: TextStyle(
            fontSize: 25, decoration: TextDecoration.underline),
        onTap: () {
          Clipboard.setData(ClipboardData(text: widget.user.phoneNumber));
          CustomedFlushBar(context, '전화번호가 복사 되었습니다');
        },
      ),
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
                width: 20,
                height: 20,
                child: Image.asset('assets/report.png', color: Colors.white.withOpacity(0.7),),
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
