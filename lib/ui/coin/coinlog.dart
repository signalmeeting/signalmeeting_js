import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_date_picker.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/drawer/store_page.dart';
import 'package:signalmeeting/util/util.dart';
import 'package:signalmeeting/ui/widget/dialog/main_dialog.dart';

class CoinLog extends StatefulWidget {

  @override
  _CoinLogState createState() => _CoinLogState();
}

class DateController extends GetxController{
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  RxBool filtered = false.obs;
}

class _CoinLogState extends State<CoinLog> {
  MainController _mainController = Get.find();
  DateController dateController = Get.put(DateController());
  UserModel get user => _mainController.user.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              //Obx(() => top()),
              Obx(() => top2()),
              //divider("사용 내역"),
              mid()
              ,
              Divider(height: 1, color: Colors.black38,),
              StreamBuilder<QuerySnapshot>(
                  stream: DatabaseService.instance.getCoinLog(),
                  builder: (BuildContext context ,AsyncSnapshot<QuerySnapshot> snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator(),);
                    if(!snapshot.hasData)
                      return Center(child:Text("데이터가 없습니다"));
                    if(snapshot.data.size == 0)
                      return Expanded(child: Center(child:Text("사용 기록이 없습니다")));
                    return bottom(snapshot.data.docs);
                  }
              ),
            ],
          ),
        )
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

  Widget rowText(String text1, String text2) {
    return Row(
      children: <Widget>[
        Text(text1 + " :",
          style: TextStyle(
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(text2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget top() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: Get.height / 8,
        child: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("보유 하트",
                    style: TextStyle(
                      fontSize: 18,
                      //fontFamily: "AppleSDGothicNeoB"
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left : 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                      SizedBox(width : 5),
                      Padding(
                        padding: const EdgeInsets.only(bottom : 3.0),
                        child: Text(user.coin.toString(),
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight : FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  Widget top2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 8),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
          color: Colors.blue[900],
        ),
        height: Get.height / 10,
        child: Center(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left : 15.0),
                  child: Text("보유 하트",
                    style: TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    Padding(
                      padding: const EdgeInsets.only(right : 15.0, bottom: 3.0),
                      child: Text(user.coin.toString(),
                        style: TextStyle(
                            fontSize: 20,
                            //fontWeight : FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ]
          ),
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
                  dialogCase(logList, index);
                },
                child: ListTile(
                  title: Text(logList[index]['usage']),
                  subtitle: Text(Util.coinLogDateFormat(logList[index]['date'].toDate())),
                  trailing: Text(coinUsage(logList[index]['usage'], logList[index]['coin']),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (logList[index]['usage'] == "친구 초대" || logList[index]['usage'] == "하트 충전")
                            ? Colors.red : Colors.blue
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget mid() {
    return Container(
      height: Get.height/12,
      decoration: BoxDecoration(
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left : 15.0),
            child: Text("충전/사용 내역",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        '내 하트',
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


  showMeetingDialog(Map<String, dynamic> meeting) {
    String location = meeting['loc1'] + " " + meeting['loc2'] + " " + meeting['loc3'];
    Get.dialog(MainDialog(
      title: "미팅 정보",
      contents: Padding(
        padding: const EdgeInsets.only(bottom : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    rowText("미팅 인원", meeting["number"].toString()),
                    rowText("위치", location),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      buttonText: "확인",
      onPressed: () => Get.back(),
    ));
  }


  dialogCase(List logList, int index) {
    switch(logList[index]['usage']) {
      case '시그널 보내기' : {
        return null;
      } break;
      case '미팅 생성' : {
        showMeetingDialog(logList[index]['meeting']);
      } break;
      case '미팅 참여': {
        showMeetingDialog(logList[index]['meeting']);
      } break;
      case "친구 초대": {
        return null;
      } break;
    }
  }

  phoneNumber(String phone) {
    if(phone.contains("+"))
      return "0" + phone.substring(3,5) +"-" + phone.substring(5,9) + "-" + phone.substring(9,13) ;
    else
      return "0" + phone.substring(2,4) +"-" + phone.substring(4,8) + "-" + phone.substring(8,12);
  }

  coinUsage(String usage, int coin) {
    if(usage == "친구 초대" || usage == "하트 충전") {
      return "+" + (coin < 0 ? -coin : coin).toString()  + " 하트";
    } else {
      return "-" + coin.toString()  + " 하트";
    }
  }
}
