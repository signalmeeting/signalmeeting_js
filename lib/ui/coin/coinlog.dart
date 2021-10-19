import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/util/util.dart';

class CoinLog extends StatefulWidget {

  @override
  _CoinLogState createState() => _CoinLogState();
}

class _CoinLogState extends State<CoinLog> {
  MainController _mainController = Get.find();
  UserModel get user => _mainController.user.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.instance.getCoinLog(),
        builder: (BuildContext context ,AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(),);
          if(!snapshot.hasData)
            return Center(child:Text("사용 기록이 없습니다"));
          else
          return SafeArea(
            child: Column(
              children: <Widget>[
                Obx(() => top()),
                divider("사용 내역"),
                bottom(snapshot.data.docs),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget divider(String text) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(child: Container(height: 1, color: Colors.black,)),
        SizedBox(width: Get.width * 0.03,),
        Text(text),
        SizedBox(width: Get.width * 0.03,),
        Expanded(child: Container(height:1, color: Colors.black)),
      ],
    );
  }

  Widget top() {
    return Container(
      height: Get.height / 8,
      child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical : 6.0),
              child: Text("보유 코인",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 18,
                ),
                SizedBox(width : 5),
                Text(user.coin.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight : FontWeight.bold
                  ),
                ),
              ],
            ),
          ]
          ),
      ),
    );
  }

  Widget bottom(List<QueryDocumentSnapshot> docs) {
    List logList = [];
    docs.forEach((QueryDocumentSnapshot e) {
      Map<String, dynamic> log = e.data();
      logList.add(log);
    });
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount : logList.length,
            itemBuilder: (BuildContext context, int index){
              return GestureDetector(
                onTap: (){
                  (logList[index]['usage'] == '시그널 보내기') ?
                  oppositeUserDialog(logList[index]["oppositeUserid"]) :
                  showMeetingDialog(logList[index]["meeting"]);
                },
                child: ListTile(
                  title: Text(logList[index]['usage']),
                  subtitle: Text(Util.coinLogDateFormat(logList[index]['date'].toDate())),
                  trailing: Text("-" + logList[index]['coin'].toString() + " 코인",// 코인 구매 => +
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue // 코인 구매 추가 하면  ? Colors.blue ? Colors.red
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: const Text(
          '내 코인',
          style: TextStyle(color: Colors.black, fontFamily: "AppleSDGothicNeoM"),
        ),
      actions: [
        IconButton(
          icon: Icon(
              Icons.storefront_outlined
          ),
          onPressed: () => Get.to(() => StorePage()),
        )
      ],
    );
  }

  oppositeUserDialog(String uid) async{
    UserModel oppositeUser = await DatabaseService.instance.getOppositeUserInfo(uid);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("상대 정보"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("이름 : " + oppositeUser.name),
              Text("나이 : " + oppositeUser.age),
              Text("전화번호 : " + oppositeUser.phone),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  showMeetingDialog(Map<String, dynamic> meeting) {
    String location = meeting['loc1'] + " " + meeting['loc2'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("미팅 정보"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("미팅 인원 : " + meeting["number"].toString()),
              Text("위치 : " + location),
              Text("상세 위치 : " + meeting['loc3']),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
/*
  showMeetingDialog2(Map<String, dynamic> meeting, String uid) async{
    UserModel oppositeUser = await DatabaseService.instance.getOppositeUserInfo(uid);
    String location = meeting['loc1'] + " " + meeting['loc2'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("미팅 정보"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("미팅 인원 : " + meeting["number"].toString()),
              Text("위치 : " + location),
              Text("상세 위치 : " + meeting['loc3']),
              Divider(
                height: 1,
              ),
              Text("이름 : " + oppositeUser.name),
              Text("나이 : " + oppositeUser.age),
              Text("전화번호 : " + oppositeUser.phone),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }


  dialogCase(List logList, int index) {
    switch(logList[index]['usage']) {
      case '시그널 보내기' : {
        return oppositeUserDialog(logList[index]['oppositeUserid']);
      } break;
      case '미팅 생성' : {
        return showMeetingDialog(logList[index]['meeting']);
      } break;
      case '미팅 참여': {
        return showMeetingDialog2(logList[index]['meeting'], logList[index]['oppositeUserid']);
      } break;
    }
  }

 */
}
