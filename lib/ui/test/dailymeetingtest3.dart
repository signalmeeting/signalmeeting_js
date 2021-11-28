import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/widget/dialog/report_dialog.dart';
import 'package:signalmeeting/util/util.dart';
import 'dart:math';

class DailyMeetingTest3 extends StatefulWidget {
  @override
  _DailyMeetingTest3State createState() => _DailyMeetingTest3State();
}

class _DailyMeetingTest3State extends State<DailyMeetingTest3> {
  Map<String, dynamic> groupByLoc = {
    '서울': {
      'man': ["a"],
      'woman': []
    },
    '부산': {'man': [], 'woman': []},
    '대구': {'man': [], 'woman': []},
    '인천': {'man': [], 'woman': []},
    '광주': {'man': [], 'woman': []},
    '대전': {'man': [], 'woman': []},
    '울산': {'man': [], 'woman': []},
    '경기': {'man': [], 'woman': []},
    '강원': {'man': [], 'woman': []},
    '충북': {'man': [], 'woman': []},
    '충남': {'man': [], 'woman': []},
    '세종': {'man': [], 'woman': []},
    '전북': {'man': [], 'woman': []},
    '전남': {'man': [], 'woman': []},
    '경북': {'man': [], 'woman': []},
    '경남': {'man': [], 'woman': []},
    '제주': {'man': [], 'woman': []},
  };

  List<Map<String, dynamic>> dummyMan = [
    {
      "name": "A",
      "banList": ["1"],
      "isMan": true
    },
    {
      "name": "B",
      "banList": ["1"],
      "isMan": true
    },
    {"name": "C", "banList": [], "isMan": true},
    {
      "name": "D",
      "banList": ["3"],
      "isMan": true
    },
    {"name": "E", "banList": [], "isMan": true},
    {
      "name": "F",
      "banList": ["4", "5"],
      "isMan": true
    },
    {"name": "G", "banList": [], "isMan": true},
    {"name": "H", "banList": [], "isMan": true},
    {"name": "I", "banList": [], "isMan": true},
    {"name": "J", "banList": [], "isMan": true},
    {"name": "K", "banList": [], "isMan": true},
    {"name": "L", "banList": [], "isMan": true},
    {"name": "M", "banList": [], "isMan": true},
  ];

  List<Map<String, dynamic>> dummyWoman = [
    {"name": "1", "banList": [], "isMan": false},
    {"name": "2", "banList": [], "isMan": false},
    {
      "name": "3",
      "banList": ["A"],
      "isMan": false
    },
    {"name": "4", "banList": [], "isMan": false},
    {"name": "5", "banList": [], "isMan": false},
    {
      "name": "6",
      "banList": ["C"],
      "isMan": false
    },
    {"name": "7", "banList": [], "isMan": false},
    {"name": "8", "banList": [], "isMan": false},
    /*
    {"name" : "9" , "banList" : [],},
    {"name" : "10" , "banList" : [],},
    {"name" : "11" , "banList" : [],},
    {"name" : "12" , "banList" : [],},

     */
  ];

  List<Map<String, dynamic>> dummyManForTest = [];
  List<Map<String, dynamic>> dummyWomanForTest = [];

  List _matchedList = [];
  List _matchedGroupList = [];
  List _totalGroupList = [];

  @override
  void initState() {
    dummyManForTest.assignAll(dummyMan);
    dummyWomanForTest.assignAll(dummyWoman);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test2"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: DatabaseService.instance.userCollection.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            if (snapshot.hasData)
              snapshot.data.docs.forEach((e) {
                String loc = (e.data() as dynamic)['profileInfo']['loc1'];
                bool isMan = (e.data() as dynamic)['profileInfo']['man'];
                //groupByLoc[(loc == "서울" || loc == "경기") ? "서울" : loc][(isMan) ? 'man' : 'woman'].add(e.data());
              });
            return SingleChildScrollView(
              child: Column(
                  children: <Widget>[TextButton(onPressed: () => _matchManWoman(dummyMan, dummyWoman), child: Text("function excute"))] +
                      _matchedGroupList
                          .map((item) => Text("${_matchedGroupList.indexOf(item)} ${item[0]} \n  ${item[1]}"))
                          .toList()
                      +
                      _totalGroupList
                      .map((item) => Text("${_totalGroupList.indexOf(item)} ${item[0]} \n  ${item[1]}"))
                    .toList()
                // [
                // totalUser(),
                // Divider(height: 1, color: Colors.black,),
                // matchedUser(dummyMan, dummyWoman),
                // ],
              ),
            );
          }),
    );
  }

  Function _matchManWoman(List<Map<String, dynamic>> _dummyMan, List<Map<String, dynamic>> _dummyWoman) {
    //남자 한 명씩 돌림
    _matchedList.clear();
    _matchedGroupList.clear();
    _totalGroupList.clear();
    for (int i = 0; i < _dummyMan.length; i++) {
      Map _man = _dummyMan[i];
      List _banList = _man["banList"];
      //여자 더 이상 없으면 다시 초기화
      //TODO 남은 여자가 다 banList 일 때 예외 처리 해줘야됨 => 전체 여자에서 한 번 돌려줌
      if (dummyWomanForTest.length == 0) {
        dummyWomanForTest.assignAll(_dummyWoman);
      }
      //
      List _possibleWomanList = dummyWomanForTest.where((element) => !_banList.contains(element["name"])).toList();
      if(_possibleWomanList.length == 0){ // 모두다 밴이면
        for (int i = 0; i < _dummyWoman.length; i++) { // 전체여자에서 한명 찾아서 넣어줌
          if (!_dummyWoman[i]["banList"].contains(_man["name"])) {
            _matchedList.add({"man": _man, "woman": _dummyWoman[i]});
            dummyManForTest.remove(_man);
            break;
          }
        }
      }
      for (int i = 0; i < _possibleWomanList.length; i++) {
        //여자 한 명씩 돌리면서 banList 에 남자 없으면 매칭, list 에서 삭제
        if (!_possibleWomanList[i]["banList"].contains(_man["name"])) {
          _matchedList.add({"man": _man, "woman": _possibleWomanList[i]});
          dummyManForTest.remove(_man);
          dummyWomanForTest.remove(_possibleWomanList[i]);
          break;
        }
      }
    }
    dummyManForTest.assignAll(_dummyMan);
    dummyWomanForTest.assignAll(_dummyWoman);

    _groupMatch();
    setState(() {});
  }

  Function _groupMatch() {
    bool finish = false;
    List _matchedListCopy = [];
    _matchedListCopy.assignAll(_matchedList);
    List _matchIndex = List.generate(_matchedList.length, (index) => 0);
    // print("_matchIndex : $_matchIndex");
    Map _match;
    Map _oppositeMatch;
    while(_matchedListCopy.length > 1) {
      //TODO 마지막에 남는 한 팀 => 앞에서부터 banList 안걸리는애 하나 가져옴
      _match = _matchedListCopy[0];
      _matchedListCopy.remove(_match);
      List _userList = [_match["man"]["name"], _match["woman"]["name"]];
      List<String> _manBanList = _match["man"]["banList"].map<String>((e) => e.toString()).toList();
      List<String> _womanBanList = _match["woman"]["banList"].map<String>((e) => e.toString()).toList();
      List _banList = _manBanList..addAll(_womanBanList);
      for (int i = 0; i < _matchedListCopy.length; i++) {
        _oppositeMatch = _matchedListCopy[i];
        print("_oppositeMatch : $_oppositeMatch");
        List _oppositeUserList = [_oppositeMatch["man"]["name"], _oppositeMatch["woman"]["name"]];
        List<String> _oppositeManBanList = _oppositeMatch["man"]["banList"].map<String>((e) => e.toString()).toList();
        List<String> _oppositeWomanBanList = _oppositeMatch["woman"]["banList"].map<String>((e) => e.toString()).toList();
        List _oppositeBanList = _oppositeManBanList..addAll(_oppositeWomanBanList);
        //서로가 banList 에 있는지 확인
        if (_banList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0 &&
            _oppositeBanList.toSet().intersection(_userList.toSet()).toList().length == 0) {
          _matchedGroupList.add([_match, _oppositeMatch]);
          _matchedListCopy.remove(_oppositeMatch);
          break;
        }
      }
    }
    if(_matchedListCopy.length != 0){
      List _matchedListCopy2 = [];
      _matchedListCopy2.assignAll(_matchedList);
      _match = _matchedListCopy[0];
      _matchedListCopy.remove(_match);
      List _userList = [_match["man"]["name"], _match["woman"]["name"]];
      List<String> _manBanList = _match["man"]["banList"].map<String>((e) => e.toString()).toList();
      List<String> _womanBanList = _match["woman"]["banList"].map<String>((e) => e.toString()).toList();
      List _banList = _manBanList..addAll(_womanBanList);
      for (int i = 0; i < _matchedListCopy2.length; i++) {
        _oppositeMatch = _matchedListCopy2[i];
        print("_oppositeMatch : $_oppositeMatch");
        List _oppositeUserList = [_oppositeMatch["man"]["name"], _oppositeMatch["woman"]["name"]];
        List<String> _oppositeManBanList = _oppositeMatch["man"]["banList"].map<String>((e) => e.toString()).toList();
        List<String> _oppositeWomanBanList = _oppositeMatch["woman"]["banList"].map<String>((e) => e.toString()).toList();
        List _oppositeBanList = _oppositeManBanList..addAll(_oppositeWomanBanList);
        //서로가 banList 에 있는지 확인
        if (_banList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0 &&
            _oppositeBanList.toSet().intersection(_userList.toSet()).toList().length == 0) {
          _matchedGroupList.add([_match, _oppositeMatch]);
          break;
        }
      }
    }
    finalMatch();
    print(_matchedGroupList);
  }

  Function finalMatch(){
    List _matchedGroupListCopy = [];
    _matchedGroupListCopy.assignAll(_matchedGroupList);
    print('## ${_matchedGroupList.length}');

    List _match;
    List _oppositeMatch;

    while(_matchedGroupListCopy.length > 1){
      _match = _matchedGroupListCopy[0];
      _matchedGroupListCopy.remove(_match);
      List _userList = [_match[0]["man"]["name"], _match[1]["man"]["name"], _match[0]["woman"]["name"], _match[1]["woman"]["name"]];

      List<String> _manBanList = _match[0]["man"]["banList"].map<String>((e) => e.toString()).toList()
        + _match[1]["man"]["banList"].map<String>((e) => e.toString()).toList()
      ;
      List<String> _womanBanList = _match[0]["woman"]["banList"].map<String>((e) => e.toString()).toList()
        + _match[1]["woman"]["banList"].map<String>((e) => e.toString()).toList()
      ;

      List _banList = _manBanList..addAll(_womanBanList);
      for (int i = 0; i < _matchedGroupListCopy.length; i++) {
        _oppositeMatch = _matchedGroupListCopy[i];
        List _oppositeUserList = [_oppositeMatch[0]["man"]["name"], _oppositeMatch[1]["man"]["name"], _oppositeMatch[0]["woman"]["name"], _oppositeMatch[1]["woman"]["name"]];
        List<String> _oppositeManBanList = _oppositeMatch[0]["man"]["banList"].map<String>((e) => e.toString()).toList()
            + _oppositeMatch[1]["man"]["banList"].map<String>((e) => e.toString()).toList()
        ;
        List<String> _oppositeWomanBanList = _oppositeMatch[0]["woman"]["banList"].map<String>((e) => e.toString()).toList()
            + _oppositeMatch[1]["woman"]["banList"].map<String>((e) => e.toString()).toList()
        ;
        List _oppositeBanList = _oppositeManBanList..addAll(_oppositeWomanBanList);
        //서로가 banList 에 있는지 확인
        if (_banList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0 &&
            _oppositeBanList.toSet().intersection(_userList.toSet()).toList().length == 0 //&&
           // _userList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0
        ) {
          _totalGroupList.add([_match, _oppositeMatch]);
          _matchedGroupListCopy.remove(_oppositeMatch);
          break;
        }
      }
    }
    if(_matchedGroupListCopy.length != 0){
      List _matchedGroupListCopy2 = [];
      _matchedGroupListCopy2.assignAll(_matchedGroupList);
      List _match;
      List _oppositeMatch;
      _match = _matchedGroupListCopy[0];
      _matchedGroupListCopy.remove(_match);
      List _userList = [_match[0]["man"]["name"], _match[1]["man"]["name"], _match[0]["woman"]["name"], _match[1]["woman"]["name"]];

      List<String> _manBanList = _match[0]["man"]["banList"].map<String>((e) => e.toString()).toList()
          + _match[1]["man"]["banList"].map<String>((e) => e.toString()).toList()
      ;
      List<String> _womanBanList = _match[0]["woman"]["banList"].map<String>((e) => e.toString()).toList()
          + _match[1]["woman"]["banList"].map<String>((e) => e.toString()).toList()
      ;

      List _banList = _manBanList..addAll(_womanBanList);
      for (int i = 0; i < _matchedGroupListCopy.length; i++) {
        _oppositeMatch = _matchedGroupListCopy[i];
        List _oppositeUserList = [_oppositeMatch[0]["man"]["name"], _oppositeMatch[1]["man"]["name"], _oppositeMatch[0]["woman"]["name"], _oppositeMatch[1]["woman"]["name"]];
        List<String> _oppositeManBanList = _oppositeMatch[0]["man"]["banList"].map<String>((e) => e.toString()).toList()
            + _oppositeMatch[1]["man"]["banList"].map<String>((e) => e.toString()).toList()
        ;
        List<String> _oppositeWomanBanList = _oppositeMatch[0]["woman"]["banList"].map<String>((e) => e.toString()).toList()
            + _oppositeMatch[1]["woman"]["banList"].map<String>((e) => e.toString()).toList()
        ;
        List _oppositeBanList = _oppositeManBanList..addAll(_oppositeWomanBanList);
        //서로가 banList 에 있는지 확인
        if (_banList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0 &&
            _oppositeBanList.toSet().intersection(_userList.toSet()).toList().length == 0 && 
            _userList.toSet().intersection(_oppositeUserList.toSet()).toList().length == 0 // 유저 안겹치게
        ) {
          _totalGroupList.add([_match, _oppositeMatch]);
          break;
        }
      }
    }

  }
}