import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/alarmModel.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/model/todayMatch.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/util/uiData.dart';
import 'dart:math';

import 'package:signalmeeting/util/util.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService _instance = DatabaseService._privateConstructor();

  static DatabaseService get instance => _instance;

  MainController _controller = Get.find();

  UserModel get _user => _controller.user.value;

  //auth instance
  FirebaseAuth _auth = FirebaseAuth.instance;

  static String today = Util.todayMatchDateFormat(DateTime.now());

  final StreamController streamController = StreamController.broadcast();

  final int groupSize = 4;

  //user collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  //todayMatch collection reference
  final CollectionReference todayMatchCollection = FirebaseFirestore.instance.collection('todayMatch'); // 매일 자정에 생성

  //todaySignal collection reference
  final CollectionReference todaySignalCollection = FirebaseFirestore.instance.collection('todaySignal'); // signal 보낸거

  //todayMatch connection collection reference
  final CollectionReference todayConnectionCollection = FirebaseFirestore.instance.collection('todayConnection'); // todayMatch 성사된거

  //meeting collection reference
  final CollectionReference meetingCollection = FirebaseFirestore.instance.collection('meeting');

  //meeting apply collection reference
  final CollectionReference meetingApplyCollection = FirebaseFirestore.instance.collection('meetingApply');

  //notices  collection reference
  final CollectionReference noticeCollection = FirebaseFirestore.instance.collection('notices');

  //alarms  collection reference
  final CollectionReference alarmCollection = FirebaseFirestore.instance.collection('alarms');

  //invite freind
  final CollectionReference inviteCollection = FirebaseFirestore.instance.collection('invites');

  //Coin UsageLog
  final CollectionReference coinLogCollection = FirebaseFirestore.instance.collection('coinLog');

  //today signal
  //0이면 시그널 x, 1이면 내가 보낸거, 2이면 매칭
  Future<int> checkConnectionAndSignal(String oppositeUid) async {
    print("checkConnectionAndSignal");
    QuerySnapshot connectionSnapshot = _user.man
        ? await todayConnectionCollection.where("manId", isEqualTo: _user.uid).where("womanId", isEqualTo: oppositeUid).get()
        : await todayConnectionCollection.where("womanId", isEqualTo: _user.uid).where("manId", isEqualTo: oppositeUid).get();
    if (connectionSnapshot.docs.length > 0)
      //연결
      return 2;
    else {
      QuerySnapshot snapshot =
          await todaySignalCollection.where("sender", isEqualTo: _user.uid).where("receiver", isEqualTo: oppositeUid).where("today", isEqualTo: Util.todayMatchDateFormat(DateTime.now())).get();
      if (snapshot.docs.length > 0)
        return 1;
      else
        return 0;
    }
  }

  Future<bool> sendSignal(String oppositeUid, String docId) async {
    Get.dialog(Center(child: CircularProgressIndicator()));
    QuerySnapshot snapshot = await todaySignalCollection
        .where("sender", isEqualTo: oppositeUid)
        .where("receiver", isEqualTo: _user.uid)
        .where("todayMatch", isEqualTo: docId)
        .get();
    if (snapshot.docs.length > 0) {
      //상대방이 나한테 보낸 시그널 존재 => 매칭
      print('match success');
      await todayConnectionCollection.doc().set({
        "matchId": snapshot.docs[0].id,
        "date": today,
        "manId": _user.man ? _user.uid : oppositeUid,
        "womanId": _user.man ? oppositeUid : _user.uid,
        "push": oppositeUid
      }).whenComplete(() {
        alarmCollection.doc().set({"body": _user.name, "receiver": oppositeUid, "time": DateTime.now(), "type": "match"});
        Get.back();
        Get.defaultDialog(title: "매치 성공!", middleText: "서로를 선택하셨습니다!");
      });
      return true;
    } else {
      await todaySignalCollection.doc().set(
          {"sender": _user.uid, "receiver": oppositeUid, "todayMatch": docId, "time": DateTime.now(), "today": today}).whenComplete(() {
        alarmCollection.doc().set({"body": "", "receiver": oppositeUid, "time": DateTime.now(), "type": "signal"});
      }).catchError((e) {
        Get.back();
        return false;
      });
      Get.back();
      return true;
    }
  }

  makeMeeting({String title, int number, String loc1, String loc2, String loc3, String introduce, File imageFile}) async {
    Get.dialog(Center(child: CircularProgressIndicator()));

    DocumentReference meetingDoc = meetingCollection.doc();
    String meetingImageUrl = await uploadMeetingImage(imageFile, meetingDoc.id);
    Map<String, dynamic> newMeeting = {
      "user": userCollection.doc(_user.uid),
      "userId": _user.uid,
      "title": title,
      "number": number,
      "loc1": loc1,
      "loc2": loc2,
      "loc3": loc3,
      "introduce": introduce,
      "createdAt": DateTime.now(),
      "man": this._user.profileInfo['man'], //인창, 추가
      "meetingImageUrl" : meetingImageUrl,
      "banList" : [],
    };

    meetingDoc.set(newMeeting);

    Get.back();
  }

  Stream<QuerySnapshot> getTotalMeetingList() {
    return meetingCollection
        .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 31)))
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  // Stream<QuerySnapshot> getMeetingListFilter({String loc1, String loc2, int type}) {
  //   Stream<QuerySnapshot> snapshot;
  //   // 14일 내에 것만 불러옴
  //   if (loc2 == '전체') {
  //     if (loc1 == '전체' && type == 1)
  //       snapshot = meetingCollection
  //           .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
  //           .orderBy("createdAt", descending: true)
  //           .snapshots();
  //     else if (type == 0)
  //       snapshot = meetingCollection
  //           .where("loc1", isEqualTo: loc1)
  //           .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
  //           .orderBy("createdAt", descending: true)
  //           .snapshots();
  //     else
  //       snapshot = meetingCollection
  //           .where("loc1", isEqualTo: loc1)
  //           .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
  //           .orderBy("createdAt", descending: true)
  //           .snapshots();
  //   } else {
  //     if (type == 0)
  //       snapshot = meetingCollection
  //           .where("loc1", isEqualTo: loc1)
  //           .where("loc2", isEqualTo: loc2)
  //           .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
  //           .orderBy("createdAt", descending: true)
  //           .snapshots();
  //     else
  //       snapshot = meetingCollection
  //           .where("loc1", isEqualTo: loc1)
  //           .where("loc2", isEqualTo: loc2)
  //           .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
  //           .orderBy("createdAt", descending: true)
  //           .snapshots();
  //   }
  //   return snapshot;
  // }

  Future<bool> getMyApply(String meetingId) async {
    QuerySnapshot snapshot = await meetingApplyCollection.where("meeting", isEqualTo: meetingId).where("user", isEqualTo: _user.uid).get();
    if (snapshot.docs.length > 0) {
      return Future.value(true);
    } else return Future.value(false);
  }

  Future<List<QueryDocumentSnapshot>> getTodayConnectionList() async {
    print("getTodayConnectionList");
    QuerySnapshot snapshot = _user.man
        ? await todayConnectionCollection.where("manId", isEqualTo: _user.uid).get()
        : await todayConnectionCollection.where("womanId", isEqualTo: _user.uid).get();
    print(snapshot.docs.length);
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getMyMeetingList() async {
    QuerySnapshot snapshot = await meetingCollection
        .where("userId", isEqualTo: _user.uid)
        .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
        .orderBy("createdAt", descending: true)
        .get();
    return snapshot.docs;
  }

  Future<QueryDocumentSnapshot> getApplyData(String meetingId) async {
    QuerySnapshot snapshot =
    await meetingApplyCollection
        .where("meeting", isEqualTo: meetingId)
        .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
        .orderBy("createdAt", descending: true)
        .get();
    if (snapshot.docs.length > 0)
      return snapshot.docs[0];
    else
      return null;
  }

  Future<bool> acceptApply({String meetingId, String applyId, String meetingTitle, String receiver}) {
    Get.dialog(Center(child: CircularProgressIndicator()));
    try {
      meetingCollection.doc(meetingId).update({"process": 1});
      meetingApplyCollection.doc(applyId).update({"process": 1});
      alarmCollection.doc().set({"body": meetingTitle, "receiver": receiver, "time": DateTime.now(), "type": "accept"});
      Get.back();
      return Future.value(true);
    } catch (e) {
      print(e);
      Get.back();
      return Future.value(false);
    }
  }

  Future<bool> refuseApply({String meetingId, String applyId, String meetingTitle, String receiver}) {
    Get.dialog(Center(child: CircularProgressIndicator()));
    try {
      meetingCollection.doc(meetingId).update({"process": null, "apply": null});
      meetingApplyCollection.doc(applyId).delete();
      //인창 "type": "refuse",, 일케 해둠
      alarmCollection.doc().set({"body": meetingTitle, "receiver": receiver, "time": DateTime.now(), "type": "refuse"});
      Get.back();
      return Future.value(true);
    } catch (e) {
      print(e);
      Get.back();
      return Future.value(false);
    }
  }

  Future<List<MeetingModel>> getMyApplyMeetingList() async {
    print('_user.uid : ${_user.uid}');
    QuerySnapshot snapshot = await meetingApplyCollection.where("userId", isEqualTo: _user.uid).get();
    if (snapshot.docs != null) {
      List meetingIdList = snapshot.docs.map((e) => e.data()["meeting"]).toList();
      print('meetingIdList : $meetingIdList');
      List<MeetingModel> meetingList = [];
      for (int i = 0; i < meetingIdList.length; i++) {
        DocumentSnapshot snapshot = await meetingCollection.doc(meetingIdList[i]).get();
        Map<String, dynamic> meeting = snapshot.data();
        meeting["_id"] = meetingIdList[i];
        meeting["isMine"] = false;
        meetingList.add(MeetingModel.fromJson(meeting));
      }
      return meetingList;
    } else
      return [];
  }

  applyMeeting(String meetingId, String msg, String title, String receiver) async {
    try {
      Get.dialog(Center(child: CircularProgressIndicator()));
      // process 0 : 신청 중, 1 : 연결, 2 : 거절
      DocumentSnapshot snapshot = await meetingCollection.doc(meetingId).get();
      QuerySnapshot applySnapshot =
          await meetingApplyCollection.where("userId", isEqualTo: _user.uid).where("meeting", isEqualTo: meetingId).get();
      if (snapshot.data()["process"] == 0 || snapshot.data()["process"] == 1) {
        Get.back();
        print("타인 신청중");
        Get.defaultDialog(title: "알림", middleText: "이미 신청중인 미팅입니다.");
        return Future.value(false);
      } else if (applySnapshot.docs.length > 0) {
        Get.back();
        print("내가 신청중");
        Get.defaultDialog(title: "알림", middleText: "신청한 미팅입니다.");
      } else {
        await meetingCollection.doc(meetingId).update({
          "process": 0,
          "apply": {
            "user": userCollection.doc(_user.uid),
            "userId": _user.uid,
            "msg": msg,
            "createdAt": DateTime.now(),
            "phone": _user.phoneNumber
          }
        });
        await meetingApplyCollection.doc().set({
          "user": userCollection.doc(_user.uid),
          "userId": _user.uid,
          "meeting": meetingId,
          "msg": msg,
          "createdAt": DateTime.now(),
          "process": 0
        }).then((value) => alarmCollection
            .doc()
            .set({"body": title, "receiver": receiver, "time": DateTime.now(), "type": "apply"})); // process 0 : 신청중 , 1 : 연결, 2: 거절
        Get.back();
//        Get.defaultDialog(title: "신청 완료", middleText: "성공적으로 신청되었습니다!");
        return Future.value(true);
      }
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<UserModel> getOppositeUserInfo(String uid) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    Map data = snapshot.data();

    UserModel oppositeUser = UserModel.fromJson({"uid": data["uid"], "profileInfo": data["profileInfo"], 'phone': data['phone'].toString()});
    return oppositeUser;
  }

  Future<bool> checkAuth(String uid, String phone) async {
    print("login by $uid");
    if (uid != null) {
      DocumentSnapshot snapshot = await userCollection.doc(uid).get();
      if (snapshot.data() != null) {
        Map<dynamic, dynamic> data = snapshot.data();
        data["uid"] = snapshot.id;
        data["phone"] = data["phone"].toString();
        UserModel user = UserModel.fromJson(data);
        _controller.updateUser(user);
        return Future.value(true);
      } else {
        UserModel user = UserModel.initUser();
        user.uid = uid;
        user.phone = phone;
        _controller.updateUser(user);
        return Future.value(false);
      }
    } else
      return Future.value(false);
  }

  Future<bool> newUser() async {
    bool result;
    List uploadedPics = [];
    await Future.forEach(_user.pics, (element) async {
      int index = _user.pics.indexOf(element);
      String uploadedUrl = await uploadUserImage(element, index);
      uploadedPics.add(uploadedUrl);
    });
    UserModel uploadUser = _user;
    uploadUser.profileInfo["pics"] = uploadedPics;
    uploadUser.invite = false;
    Map data = uploadUser.toJson();
    data.removeWhere((key, value) => key == "authCode");
    await userCollection.doc(data["uid"]).set(data).whenComplete(() => result = true).catchError((e) {
      result = false;
    });
    return result;
  }

  Future<bool> changeProfileValue(String key, var value) async {
    bool result;
    await userCollection.doc(_user.uid).update({key: value}).whenComplete(() => result = true).catchError((e) {
          result = false;
        });
    return result;
  }

  Future<bool> updateBanList(String from, String to, bool isItDaily) async {
    bool result;
    if(isItDaily) {
      userCollection
        ..doc('$from/banList').set({'from': from, 'to': to, 'when': DateTime.now()})
        ..doc('$to/banList').set({'from': from, 'to': to, 'when': DateTime.now()})
            .whenComplete(() => result = true)
            .catchError((e) {
          result = false;
        });
    }else {
      meetingCollection.doc('$to/banList').set({'from': from, 'when': DateTime.now()})
            .whenComplete(() => result = true)
            .catchError((e) {
          result = false;
        });
    }

    return result;
  }

  Future<bool> uploadUserPic(List<dynamic> pics) async {
    bool result;
    await userCollection.doc(_user.uid).update({"profileInfo.pics": pics}).whenComplete(() => result = true).catchError((e) {
          result = false;
        });
    return result;
  }

  Future<String> uploadUserImage(String filePath, int index) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('user/${_user.uid + index.toString()}');
    UploadTask uploadTask = storageReference.putFile(File(filePath));
    String returnURL;
    await uploadTask.whenComplete(() async {
      print('File Uploaded');
      await storageReference.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
      });
    });
    return returnURL;
  }

  Future<String> uploadMeetingImage(File imageFile, String meetingId) async {
    print('check 0 : $imageFile');
    Reference storageReference = FirebaseStorage.instance.ref().child('meeting/$meetingId');
    print('check 1 : $storageReference');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    print('check 2 : $uploadTask');
    String returnURL;
    await uploadTask.whenComplete(() async {
      print('File Uploaded');
      await storageReference.getDownloadURL().then((fileURL) {
        returnURL = fileURL;
      });
    });
    return returnURL;
  }

  Future<bool> updateDeviceToken(String token) async {
    bool result;
    await userCollection.doc(_user.uid).update({"pushInfo.deviceToken": token}).whenComplete(() {
      return result = true;
    }).catchError((e) {
      result = false;
    });
    return result;
  }

  Future<bool> getTodayMatch() async {
    String today = Util.todayMatchDateFormat(DateTime.now());
    QuerySnapshot snapshot = await todayMatchCollection.doc(today).collection("matches").where(_user.man ? "men" : "women", arrayContains: _user.uid).get();
    // DocumentSnapshot userSnapshot = await userCollection.doc(_user.uid).collection("todayMatch").doc(today).get();
    // var matchIdList = userSnapshot.data()["documentId"];
    List<TodayMatch> todayMatchList = [];
    snapshot.docs.forEach((element) {
      List<UserModel> sameGenders = [];
      List<UserModel> oppositeGenders = [];
      for (int i = 0; i < groupSize; i++) {
        sameGenders.add(UserModel(
          uid: element[_user.man ? "men" : "women"][i],
          profileInfo: element[_user.man ? "menProfile" : "womenProfile"][i],
        ));
        oppositeGenders.add(UserModel(
          uid: element[_user.man ? "women" : "men"][i],
          profileInfo: element[_user.man ? "womenProfile" : "menProfile"][i],
        ));
      }
      TodayMatch todayMatch = TodayMatch(documentId: element.id, sameGenders: sameGenders, oppositeGenders: oppositeGenders);
      todayMatchList.add(todayMatch);
    });
    _controller.updateTodayMatchList(todayMatchList);
  }

  // await userCollection.doc(element["uid"]).collection("todayMatch").doc(today).set({
  // "documentId": FieldValue.arrayUnion([documentId])
  // }, SetOptions(merge: true));

  Future<List<DocumentSnapshot>> getNotices() async {
    QuerySnapshot snapshot = await noticeCollection.get();
    if (snapshot.docs != null) {
      return Future.value(snapshot.docs);
    } else
      return [];
  }

//추천인
  Future<bool> inviteFriend(String inviteCode) async {
    Get.dialog(Center(child: CircularProgressIndicator()));
    print('inviteCode : $inviteCode');
    QuerySnapshot snapshot = await userCollection.where("uid", isGreaterThan: inviteCode).get();
    print('snapshot : ${snapshot.docs[0]}');
    if (snapshot.docs.isNotEmpty && (inviteCode != _user.uid.substring(0, 10))) {
      Map<String, dynamic> body = {"receiver": inviteCode, "sender": _user.uid, "time": DateTime.now()};
      await inviteCollection.doc().set(body);
      await userCollection.doc(_user.uid).update({"invite": true});
      await coinLogCollection.doc().set({
        "userid" : _user.uid,
        "coin" : 50,
        "usage" : "친구 초대",
        "oppositeUserid" : snapshot.docs[0].id,
        "date" : DateTime.now(),
      });
      await coinLogCollection.doc().set({
        "userid" : snapshot.docs[0].id,
        "coin" : 50,
        "usage" : "친구 초대",
        "oppositeUserid" : _user.uid,
        "date" : DateTime.now(),
      });
      await userCollection.doc(snapshot.docs[0].id).update({"coin": FieldValue.increment(50)});
      await userCollection.doc(_user.uid).update({"coin": FieldValue.increment(50)});
      Get.back();
      return Future.value(true);
    } else {
      Get.back();
      return Future.value(false);
    }
  }

  Future<List<AlarmModel>> getAlarms() async {
    QuerySnapshot snapshot = await alarmCollection.where("receiver", isEqualTo: _user.uid).orderBy("time", descending: true).get();
    if (snapshot.docs != null) {
      List<DocumentSnapshot> resultList = snapshot.docs;
      List<AlarmModel> alarmList = resultList.map<AlarmModel>((DocumentSnapshot e) {
        Map data = e.data();
        data["id"] = e.id;
        data["time"] = data["time"].toDate().toString();
        return AlarmModel.fromJson(data);
      }).toList();
      return Future.value(alarmList);
    } else
      return [];
  }

  useCoin(int coin, int type, {String oppositeUserid, Map<String, dynamic> newMeeting}) async{
    DocumentReference coinLogDoc = coinLogCollection.doc();
    coinUsage() {
      switch(type) {
        case 0 : {
          return "시그널 보내기";
        } break;
        case 1 : {
          return "미팅 생성";
        } break;
        case 2: {
          return "미팅 참여";
        } break;
      }
    }
    /*
    String meetingImageUrl = await uploadMeetingImage(newMeeting['imageFile'], coinLogDoc.id);
    Map<String, dynamic> _newMeeting = {
      "title": newMeeting['title'],
      "number": newMeeting['number'],
      "loc1": newMeeting['loc1'],
      "loc2": newMeeting['loc2'],
      "loc3": newMeeting['loc3'],
      "introduce": newMeeting['introduce'],
      "imageFile": meetingImageUrl,
    };
     */

    Map<String, dynamic> newCoinLog = {
      "userid" : _user.uid,
      "coin" : coin,
      "usage" : coinUsage(),
      "oppositeUserid" : oppositeUserid ?? "",
      "meeting" : newMeeting ?? {},
      "date" : DateTime.now(),
    };
      await coinLogDoc.set(newCoinLog);
      _controller.useCoin(coin);
      await userCollection.doc(_user.uid).update({"coin" : _user.coin});
  }
  
  Stream<QuerySnapshot> getCoinLog() {
    return coinLogCollection
        .where('userid', isEqualTo : _user.uid)
        .orderBy('date', descending : true)
        .snapshots();
  }

}
