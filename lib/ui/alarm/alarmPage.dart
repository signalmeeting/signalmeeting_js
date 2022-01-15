import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/alarmModel.dart';
import 'package:byule/services/database.dart';

class AlarmPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: DatabaseService.instance.getAlarms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else if (!snapshot.hasData) return Container();
          else {
            List<AlarmModel> alarmList = snapshot.data;
            return ScrollConfiguration(
              behavior: ScrollBehavior(),
              child: GlowingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                color: Colors.white,
                child: alarmList.length == 0 ? noAlarm() : ListView(
                    children: alarmList
                        .map(
                          (e) => e.type == 'signalting'
                              ? SignalAlarm('데일리 미팅 ${e.body}', e.date)
                              : e.type == 'match'
                                  ? MatchingAlarm(e.body, e.date)
                                  : e.type == 'accept'
                                      ? AcceptedAlarm(e.body, e.date)
                                      : e.type == 'reject'
                                          ? RejectedAlarm(e.body, e.date)
                                          : e.type == 'apply' ? ApplyAlarm(e.body, e.date) : Container(),
                        )
                        .toList()),
              ),
            );
          }
        });
  }

  Widget SignalAlarm(from, when) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "'$from'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' 에서 누군가 나에게 ',
                    ),
                    TextSpan(text: '호감을 표현 ', style: TextStyle(color: Colors.red[300])),
                    TextSpan(
                      text: '했어요! 회원님도 ',
                    ),
                    TextSpan(text: '시그널', style: TextStyle(color: Colors.red[300])),
                    TextSpan(
                      text: '을 보내보세요!',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget MatchingAlarm(who, when) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "'$who'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' 님과 매칭되었어요!',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget AcceptedAlarm(from, when) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "'$from'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' 에서 회원님의 신청을 수락했어요!',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget RejectedAlarm(from, when) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "'$from'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' 에서 회원님의 신청을 거절했어요',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ApplyAlarm(which, when) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]),
          )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 10, right: 18),
            child: Container(
              alignment: Alignment.bottomLeft,
              child: Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(text: "'$which'", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: ' 에 신청이 들어왔어요!',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 5, bottom: 10),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text(
                "$when",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget noAlarm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.notifications_off),
          SizedBox(height: 10,),
          Text("받은 알림이 없습니다.",style: TextStyle(fontFamily: "AppleSDGothicNeoB")),
        ],
      ),
    );
  }
}
