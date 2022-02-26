import 'package:byule/util/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/ui/widget/dialog/noCoinDialog.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';

class OppositeProfilePage extends StatefulWidget {
  final UserModel user;
  final String docId; //todayMatch docId
  final bool isItFromChat;

  OppositeProfilePage(
    this.user, {
    this.docId,
    this.isItFromChat = false,
  });

  @override
  _OppositeProfilePageState createState() => _OppositeProfilePageState();
}

class _OppositeProfilePageState extends State<OppositeProfilePage> {
  double width = Get.width * 0.9;
  double height = Get.width * 0.9;

  MainController _controller = Get.find();

  bool _buttonClicked = false;
  bool _signalSent = false;

  UserModel get myuser => _controller.user.value;

  bool get isFree => _controller.isFree.value;
  List<Map<String, dynamic>> memberListToShow = [];


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
                if (!_signalSent && !widget.isItFromChat)
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
                                              '3',
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
                                  onPressed: _buttonClicked
                                      ? () {
                                          onPressSignalButton();
                                        }
                                      : isFree
                                          ? () => onPressSignalButton()
                                          : () => setState(() => _buttonClicked = true),
                                ),
                                secondChild: Container(),
                                crossFadeState: result == 1 || result == 2 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300)),
                            if (result == 2)
                              TextButton(
                                  style: BtStyle.textSub200,
                                  onPressed: () {
                                    //시그널 매치 됐을 때 채팅방으로 가는 버튼
                                    MainController.goToChatPage(snapshot.data["docId"], widget.user, 'signalting');
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
    if (myuser.coin < 3 && !isFree) {
      Get.dialog(NoCoinDialog());
    } else {
      //시그널 보내기, 코인 소모
      if (!isFree)
        await DatabaseService.instance.useCoin(3, 0, oppositeUserid: widget.user.uid);
      else if (myuser.man) {
        await DatabaseService.instance.useCoin(-1, 3, oppositeUserid: widget.user.uid);
      } else if (!myuser.man) {
        await DatabaseService.instance.useCoin(-5, 3, oppositeUserid: widget.user.uid);
      }
      bool result = await DatabaseService.instance.sendSignal(widget.user.uid, widget.docId, widget.user.name);
      if (result) {
        if (isFree && myuser.man) {
          _controller.isFree.value = false;
          CustomedFlushBar(context, '일일 참여 보상 하트 1개가 지급되었습니다!');
        } else if (isFree && !myuser.man) {
          _controller.isFree.value = false;
          CustomedFlushBar(context, '일일 참여 보상 하트 5개가 지급되었습니다!');
        } else {
          CustomedFlushBar(context, '시그널을 보냈습니다');
        }

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
          Positioned(
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
            top: 10,
            left: 10,
          ),
        ],
      ),
    );
  }
}
