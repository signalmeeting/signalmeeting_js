import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/util/util.dart';
import 'dart:math';

class DailyMeetingTest2 extends StatefulWidget {

  @override
  _DailyMeetingTest2State createState() => _DailyMeetingTest2State();
}

class _DailyMeetingTest2State extends State<DailyMeetingTest2> {
  Map<String, dynamic> groupByLoc = {
    '서울' : {'man' : ["a"], 'woman' : []},
    '부산' : {'man' : [], 'woman' : []},
    '대구' : {'man' : [], 'woman' : []},
    '인천' : {'man' : [], 'woman' : []},
    '광주' : {'man' : [], 'woman' : []},
    '대전' : {'man' : [], 'woman' : []},
    '울산' : {'man' : [], 'woman' : []},
    '경기' : {'man' : [], 'woman' : []},
    '강원' : {'man' : [], 'woman' : []},
    '충북' : {'man' : [], 'woman' : []},
    '충남' : {'man' : [], 'woman' : []},
    '세종' : {'man' : [], 'woman' : []},
    '전북' : {'man' : [], 'woman' : []},
    '전남' : {'man' : [], 'woman' : []},
    '경북' : {'man' : [], 'woman' : []},
    '경남' : {'man' : [], 'woman' : []},
    '제주' : {'man' : [], 'woman' : []},
  };

  List<Map<String,dynamic>> dummyMan =  [
    {"name" : "A" , "banList" : [],},
    {"name" : "B" , "banList" : [],},
    {"name" : "C" , "banList" : [],},
    {"name" : "D" , "banList" : [],},
    {"name" : "E" , "banList" : [],},
    {"name" : "F" , "banList" : [],},
    {"name" : "G" , "banList" : [],},
    {"name" : "H" , "banList" : [],},
    {"name" : "I" , "banList" : [],},
    {"name" : "J" , "banList" : [],},
    {"name" : "K" , "banList" : [],},
    {"name" : "L" , "banList" : [],},
  ];

  List<Map<String,dynamic>> dummyWoman =  [
    {"name" : "1" , "banList" : [],},
    {"name" : "2" , "banList" : [],},
    {"name" : "3" , "banList" : [],},
    {"name" : "4" , "banList" : [],},
    {"name" : "5" , "banList" : [],},
    {"name" : "6" , "banList" : [],},
    {"name" : "7" , "banList" : [],},
    {"name" : "8" , "banList" : [],},
    {"name" : "9" , "banList" : [],},
    {"name" : "10" , "banList" : [],},
    {"name" : "11" , "banList" : [],},
    {"name" : "12" , "banList" : [],},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test2"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService.instance.userCollection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(),);
          if(snapshot.hasData)
            snapshot.data.docs.forEach((e) {
              String loc = (e.data() as dynamic)['profileInfo']['loc1'];
              bool isMan = (e.data() as dynamic)['profileInfo']['man'];
              //groupByLoc[(loc == "서울" || loc == "경기") ? "서울" : loc][(isMan) ? 'man' : 'woman'].add(e.data());
            });
          return Column(
            children: [
                totalUser(),
              Divider(height: 1, color: Colors.black,),
              matchedUser(dummyMan, dummyWoman),
            ],
          );
        }
      ),
    );
  }

  Widget totalUser() {
    List loc = groupByLoc.keys.toList();
    return Container(
      height: Get.height / 4,
      child: ListView.builder(
          itemCount: loc.length,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title: Row(
                children: [
                  Text(loc[index] + ": "),
                  Text("남 : " + groupByLoc[loc[index]]['man'].length.toString()),
                  Text(" / "),
                  Text("여 : " + groupByLoc[loc[index]]['woman'].length.toString()),
                ],
              ),
            );
          }),
    );
  }

  Widget matchedUser(List man, List woman) {
    List dailyMeeting = makeMeeting(man, woman);
    return Expanded(
      child: Container(
        child: ListView.builder(
          itemCount: dailyMeeting.length,
          itemBuilder: (BuildContext context, int index){
            return ListTile(
              title: Text(dailyMeeting[index].toString(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ),
    );
  }

  //Function

  makeMeeting(List man, List woman){
    List initMan = man;
    List initWoman = woman;
    List dailyMeeting = [];
    bool moreMan = true;
    if(woman.length > man.length){
      moreMan = false;
    }

    if(moreMan){
      man = setLength(man);
    } else {
      woman = setLength(woman);
    }
    print('totalMan : $man}');
    print('initWoman : $initWoman');
    if(moreMan){
      for(int i = 0; i < man.length ; i++){
        print('manLoop : $i');
        List<dynamic> manTotalBanList = [];
        for(int k = 0; k < 4; k++){ // 남자 총 banList
          manTotalBanList.addAll(man[i][k]['banList']);
        }
        print('manTotalBan : $manTotalBanList');
        List<Map<String,dynamic>> _man = man[i];
        List<Map<String,dynamic>> _woman = []; // _man과 매칭될 여자 데이터 list
        for(int j = 0; j < woman.length ; j++) {
          print('womanj ${woman[j]}');
          if(manTotalBanList.contains(woman[j]['name'])){ // 남자 BanList에 포함된 여자면 Pass
            print('BannedWoman ${woman[j]}');
            continue;
          } else {
            if(checkBan(_man, woman[j]['banList'])){
              _woman.add(woman[j]);
              print('## $_woman');
            }
            if(_woman.length == 4){
              List<Map<String,dynamic>> temp = [];
              temp = (_man + _woman).toList();
              dailyMeeting.add(temp);
              woman.removeWhere((e) => _woman.contains(e) == true);
              break;
            } else if(j == woman.length - 1){

            }
          }
        }
      }
    }
    print('Daily : $dailyMeeting');
    return dailyMeeting;
  }

  setLength(List A){ // List 길이 4의 배수로
    int num = 0;
    if(A.length % 4 != 0){
      num = 4 - A.length % 4;
    }
    A.shuffle();
    A.addAll(A.sublist(0,num));
    List temp = [];
    for(int i=0; i < A.length; i += 4){
      temp.add(A.sublist(i,i+4));
    }
    return temp;
  }

  checkBan(List userList, List banList){ //ban check
    for(int i =0; i < userList.length; i++){
      if(banList.contains(userList[i])){
        return false;
      }
    }
    return true;
  }

  setNoBannedList(List userList, List beforeList){
    /*
    for(int i =0 ; i < userList.length ; i++){
      if(beforeList.contains(userList[i]))
    }

     */
  }

  addNoBanned(){

  }

}
