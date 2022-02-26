import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:byule/main.dart';
import 'package:byule/model/memberModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/alarmModel.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/todayMatch.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/uiData.dart';
import 'dart:math';

import 'package:byule/util/util.dart';

class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService _instance = DatabaseService._privateConstructor();

  static DatabaseService get instance => _instance;

  MainController _controller = Get.find();

  UserModel get _user => _controller.user.value;

  //auth instance
  FirebaseAuth _auth = FirebaseAuth.instance;

  static String today = Util.todayMatchDateFormat(DateTime.now());

  //user collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  //todayMatch collection reference
  final CollectionReference todayMatchCollection = FirebaseFirestore.instance.collection('todayMatch'); // 매일 자정에 생성

  //todaySignal collection reference
  final CollectionReference todaySignalCollection = FirebaseFirestore.instance.collection('todaySignal'); // signalting 보낸거

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

  //Coin receipt/usage Log
  final CollectionReference coinLogCollection = FirebaseFirestore.instance.collection('coinLog');

  //withDrawUser
  final CollectionReference withDrawCollection = FirebaseFirestore.instance.collection('withDrawUsers');

  //today signalting
  //0이면 시그널 x, 1이면 내가 보낸거, 2이면 매칭
  Future<Map<String, dynamic>> checkConnectionAndSignal(String oppositeUid) async {
    print("checkConnectionAndSignal");
    QuerySnapshot connectionSnapshot = _user.man
        ? await todayConnectionCollection.where("manId", isEqualTo: _user.uid).where("womanId", isEqualTo: oppositeUid).get()
        : await todayConnectionCollection.where("womanId", isEqualTo: _user.uid).where("manId", isEqualTo: oppositeUid).get();
    if (connectionSnapshot.docs.length > 0)
      //연결
      return {"result": 2, "docId": connectionSnapshot.docs[0].id};
    else {
      QuerySnapshot snapshot = await todaySignalCollection
          .where("sender", isEqualTo: _user.uid)
          .where("receiver", isEqualTo: oppositeUid)
          .where("today", isEqualTo: Util.todayMatchDateFormat(DateTime.now()))
          .get();
      if (snapshot.docs.length > 0)
        return {"result": 1};
      else
        return {"result": 0};
    }
  }

  Future<bool> sendSignal(String oppositeUid, String docId, String oppositeName) async {
    Get.dialog(Center(child: CircularProgressIndicator()));
    QuerySnapshot snapshot = await todaySignalCollection
        .where("sender", isEqualTo: oppositeUid)
        .where("receiver", isEqualTo: _user.uid)
        .where("todayMatch", isEqualTo: docId)
        .get();
    await userCollection.doc(_user.uid).update({"free": DateTime.now()});
    if (snapshot.docs.length > 0) {
      //상대방이 나한테 보낸 시그널 존재 => 매칭
      print('match success');
      await todayConnectionCollection.doc().set({
        "matchId": snapshot.docs[0].id,
        "date": today,
        "manId": _user.man ? _user.uid : oppositeUid,
        "womanId": _user.man ? oppositeUid : _user.uid,
        "push": oppositeUid
      }).whenComplete(() async {
        await alarmCollection.doc().set({"body": _user.name, "receiver": oppositeUid, "time": DateTime.now(), "type": "match"});
        await alarmCollection.doc().set({"body": oppositeName, "receiver": _user.uid, "time": DateTime.now(), "type": "match"});
        Get.back();
        Get.dialog(NotificationDialog(
          title: "매치 성공",
          contents: "서로를 선택하셨습니다!",
        ));
        //Get.defaultDialog(title: "매치 성공!", middleText: "서로를 선택하셨습니다!");
      });
      return true;
    } else {
      await todaySignalCollection.doc().set(
          {"sender": _user.uid, "receiver": oppositeUid, "todayMatch": docId, "time": DateTime.now(), "today": today}).whenComplete(() {
        alarmCollection.doc().set({"body": "", "receiver": oppositeUid, "time": DateTime.now(), "type": "signalting"});
      }).catchError((e) {
        Get.back();
        return false;
      });
      Get.back();
      return true;
    }
  }

  makeMeeting({String title, int number, String loc1, String loc2, String loc3, String introduce, File imageFile, List memberList}) async {
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
      "meetingImageUrl": meetingImageUrl,
      "banList": [],
      "deletedTime": null,
      "memberList": memberList,
    };

    print('memberList : $memberList');
    meetingDoc.set(newMeeting);

    Get.back();
  }

  deleteMeeting(String docId, {int process}) async {
    await meetingCollection.doc(docId).update({
      "deletedTime": DateTime.now(),
      "process": process,
    });
  }

  deleteMyMeeting(String docId) async {
    await meetingCollection.doc(docId).update({"deletedTime": DateTime.now()});
  }

  deleteApplyMeeting(String meetingDocId, String applyDocId) async {
    await meetingCollection.doc(meetingDocId).update({"process": 4});
    await meetingApplyCollection.doc(applyDocId).update({"process": 4});
  }

  Stream<QuerySnapshot> getTotalMeetingList() {
    return meetingCollection
        .where("deletedTime", isNull: true)
        .where("createdAt", isGreaterThan: DateTime.now().subtract(Duration(days: 14)))
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

  Future<List<QueryDocumentSnapshot>> getTodayConnectionList() async {
    print("getTodayConnectionList");
    QuerySnapshot snapshot = _user.man
        ? await todayConnectionCollection.where("manId", isEqualTo: _user.uid).get()
        : await todayConnectionCollection.where("womanId", isEqualTo: _user.uid).get();
    return snapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getMyMeetingList() async {
    QuerySnapshot snapshot = await meetingCollection
        .where("deletedTime", isNull: true)
        .where("userId", isEqualTo: _user.uid)
        .orderBy("createdAt", descending: true)
        .get();
    return snapshot.docs;
  }

  Future<QueryDocumentSnapshot> getApplyData(String meetingId) async {
    QuerySnapshot snapshot =
    await meetingApplyCollection.where("meeting", isEqualTo: meetingId).orderBy("createdAt", descending: true).get();
    if (snapshot.docs.length > 0)
      return snapshot.docs[0];
    else
      return null;
  }

  Future<bool> acceptApply({String meetingId, String applyId, String meetingTitle, String receiver}) {
    try {
      meetingCollection.doc(meetingId).update({"process": 1});
      meetingApplyCollection.doc(applyId).update({"process": 1});
      alarmCollection.doc().set({"body": meetingTitle, "receiver": receiver, "time": DateTime.now(), "type": "accept"});
      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<bool> refuseApply({String meetingId, String applyId, String meetingTitle, String receiver}) {
    Get.dialog(Center(child: CircularProgressIndicator()));
    try {
      meetingCollection.doc(meetingId).update({"process": null, "apply": null});
      meetingApplyCollection.doc(applyId).update({"process": 2});
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
    QuerySnapshot snapshot =
    await meetingApplyCollection.where("userId", isEqualTo: _user.uid).orderBy("createdAt", descending: true).get();
    print('myapply : ${snapshot.size}');
    if (snapshot.docs != null) {
      List meetingIdList = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        if (snapshot.docs[i].data()['process'] != null && snapshot.docs[i].data()['process'] != 4) {
          meetingIdList.add(snapshot.docs[i].data()['meeting']);
        } else
          print('process is null');
      }

      // List meetingIdList = snapshot.docs.map((e) => e.data()["meeting"]).toList();
      List<MeetingModel> meetingList = [];
      for (int i = 0; i < meetingIdList.length; i++) {
        DocumentSnapshot snapshot = await meetingCollection.doc(meetingIdList[i]).get();
        Map<String, dynamic> meeting = snapshot.data();
        meeting["_id"] = meetingIdList[i];
        meeting["isMine"] = false;
        meeting['createdAt'] = meeting['createdAt'].toDate().toString();
        if (meeting["deletedTime"] != null) meeting["deletedTime"] = meeting["deletedTime"].toDate().toString();
        meetingList.add(MeetingModel.fromJson(meeting));
      }
      return meetingList;
    } else
      return [];
  }

  Future<bool> applyMeeting(String meetingId, String msg, String title, String receiver) async {
    Get.dialog(Center(child: CircularProgressIndicator()));
    // process 0 : 신청 중, 1 : 연결, 2 : 거절

    DocumentSnapshot snapshot = await meetingCollection.doc(meetingId).get();

    if (snapshot.data()["process"] == 0 || snapshot.data()["process"] == 1) {
      Get.back();
      print("타인 신청중");
      CustomedFlushBar(Get.context, "이미 신청중인 미팅입니다.");
      return Future.value(false);
    }

    String applyId;
    String alarmId;

    bool writeResult = await FirebaseFirestore.instance.runTransaction((transaction) async {
      await meetingCollection.doc(meetingId).update({
        "process": 0,
      });

      DocumentReference newMeetingApply = meetingApplyCollection.doc();
      DocumentReference newAlarm = alarmCollection.doc();

      applyId = newMeetingApply.id;
      alarmId = newAlarm.id;

      transaction.set(newMeetingApply, {
        "user": userCollection.doc(_user.uid),
        "userId": _user.uid,
        "meeting": meetingId,
        "msg": msg,
        "createdAt": DateTime.now(),
        "process": 0
      });

      transaction.set(newAlarm, {"body": title, "receiver": receiver, "time": DateTime.now(), "type": "apply"});
      transaction.update(meetingCollection.doc(meetingId), {
        "process": 0,
        "apply": {
          "applyId": newMeetingApply.id,
          "user": userCollection.doc(_user.uid),
          "userId": _user.uid,
          "msg": msg,
          "createdAt": DateTime.now(),
          "phone": _user.phoneNumber
        }
      });
    }).then((value) {
      print("meeting apply success!!");
      Get.back();
      return Future.value(true);
    }).catchError((error) {
      print("meeting apply failed : $error");
      Get.back();
      return Future.value(false);
    });

    print("writeResult : $writeResult");

    if (writeResult)
      return await 0.3.delay(() async {
        DocumentSnapshot meetingDoc = await meetingCollection.doc(meetingId).get();

        if (meetingDoc.data()["apply"]["applyId"] != applyId) {
          //delete function started
          return FirebaseFirestore.instance.runTransaction((transaction) async {
            {
              transaction.delete(meetingApplyCollection.doc(applyId));
              transaction.delete(meetingApplyCollection.doc(alarmId));
            }
          }).then((value) {
            print("meeting delete success!!");
            return Future<bool>.value(false);
          }).catchError((error) {
            print("meeting delete failed : $error");
            return Future<bool>.value(false);
          });
        } else
          return Future<bool>.value(true);
      }); else return Future<bool>.value(false);
  }

  Future<bool> checkRefusedBeforeApply(String meetingId) async {
    QuerySnapshot snapshot = await meetingApplyCollection
        .where("userId", isEqualTo: _user.uid)
        .where("meeting", isEqualTo: meetingId)
        .where("process", isEqualTo: 2)
        .get();

    print('snapshot1 : $snapshot');
    print('snapshot2 : ${snapshot.isBlank}');
    print('snapshot3 : ${snapshot.docs.isEmpty}');
    if (snapshot.docs.isEmpty) {
      print('aaa');
      return false;
    } else {
      print('bbb');
      Get.dialog(NotificationDialog(contents: "최근 거절된 미팅입니다"));
      QueryDocumentSnapshot doc = snapshot.docs[0];
      DocumentReference docRef = doc.reference;
      await docRef.update({"process": null});
      return true;
    }
    QueryDocumentSnapshot doc = snapshot.docs[0];
    DocumentReference docRef = doc.reference;
    await docRef.update({"process": null});
    return true;
  }

  checkRefused(String meetingId, bool isRefused) async {
    QuerySnapshot snapshot = await meetingApplyCollection
        .where("userId", isEqualTo: _user.uid)
        .where("meeting", isEqualTo: meetingId)
        .where("process", isEqualTo: isRefused ? 2 : 1)
        .get();
    QueryDocumentSnapshot doc = snapshot.docs[0];
    DocumentReference docRef = doc.reference;
    await docRef.update({"process": null});
  }

  Future<UserModel> getOppositeUserInfo(String uid) async {
    UserModel oppositeUser;
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    Map data = snapshot.data();
    if (data != null)
      oppositeUser = UserModel.fromJson({
        "uid": data["uid"],
        "profileInfo": data["profileInfo"],
        'phone': data['phone'].toString(),
        'deleted': data["deleted"]
      }); // deleted 테스트용임
    else
      oppositeUser = UserModel.fromJson({"deleted": true}); //회원탈퇴한 유저
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

        ///Todo 매핑 왜하쥐?? 로그인 에러뜸
        ///리스트가 디비에 맵일 때는 ㄱㅊ
        ///근데 리스트에 왜 맵이 되는경우가 있음??
        data["memberList"] = Util.mapMembers(data["memberList"]);

        UserModel user = UserModel.fromJson(data);
        _controller.updateUser(user);
        await Jiffy.locale('ko');
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

  Future<bool> checkStop(String uid) async {
    DocumentSnapshot data = await userCollection.doc(uid).get();
    if (data['stop']) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  Future<bool> newUser() async {
    bool result;
    List uploadedPics = [];
    QuerySnapshot snapshot = await DatabaseService.instance.withDrawCollection.where("phone", isEqualTo: _user.phone).get();
    if (snapshot.docs.length != 0) {
      withDrawCollection.doc(snapshot.docs[0].id).delete();
    }
    await Future.forEach(_user.pics, (element) async {
      int index = _user.pics.indexOf(element);
      String uploadedUrl = await uploadUserImage(element, index);
      uploadedPics.add(uploadedUrl);
    });
    UserModel uploadUser = _user;
    uploadUser.profileInfo["pics"] = uploadedPics;
    uploadUser.invite = false;
    uploadUser.coin = 25;
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

  updateBanList(String from, String to, ReportType reportType) async {
    if (reportType == ReportType.daily) {
      await userCollection.doc(from).update({
        'banList': FieldValue.arrayUnion([
          <String, dynamic>{'from': from, 'to': to, 'when': DateTime.now()}
        ]),
      });
      await userCollection.doc(to).update({
        'banList': FieldValue.arrayUnion([
          <String, dynamic>{'from': from, 'to': to, 'when': DateTime.now()}
        ]),
      });
    } else if (reportType == ReportType.meeting) {
      await meetingCollection.doc(to).update({
        'banList': FieldValue.arrayUnion([
          <String, dynamic>{'from': from, 'to': to, 'when': DateTime.now()}
        ]),
      });
    }
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

  Future<String> uploadMemberImage(String filePath, int memberIndex) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('user/${_user.uid + 'member' + memberIndex.toString()}');
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
    QuerySnapshot snapshot =
    await todayMatchCollection.doc(today).collection("matches").where(_user.man ? "men" : "women", arrayContains: _user.uid).get();
    // DocumentSnapshot userSnapshot = await userCollection.doc(_user.uid).collection("todayMatch").doc(today).get();
    // var matchIdList = userSnapshot.data()["documentId"];
    List<TodayMatch> todayMatchList = [];
    snapshot.docs.forEach((element) {
      int groupSize = element.data()['womenProfile'].length;
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
        "userid": _user.uid,
        "coin": 20,
        "usage": "친구 초대",
        "oppositeUserid": snapshot.docs[0].id,
        "date": DateTime.now(),
        "userCoin": _user.coin + 20
      });
      await coinLogCollection.doc().set({
        "userid": snapshot.docs[0].id,
        "coin": 20,
        "usage": "친구 초대",
        "oppositeUserid": _user.uid,
        "date": DateTime.now(),
        "userCoin": snapshot.docs[0]['coin'] + 20
      });
      await userCollection.doc(snapshot.docs[0].id).update({"coin": FieldValue.increment(20)});
      await userCollection.doc(_user.uid).update({"coin": FieldValue.increment(20)});
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

  useCoin(int coin, int type, {String oppositeUserid, Map<String, dynamic> newMeeting}) async {
    DocumentReference coinLogDoc = coinLogCollection.doc();
    coinUsage() {
      switch (type) {
        case 0:
          {
            return "시그널 보내기";
          }
          break;
        case 1:
          {
            return "미팅 생성";
          }
          break;
        case 2:
          {
            return "미팅 참여";
          }
          break;
        case 3:
          {
            return "하트 충전";
          }
          break;
      }
    }

    Map<String, dynamic> newCoinLog = {
      "userid": _user.uid,
      "coin": coin,
      "usage": coinUsage(),
      "oppositeUserid": oppositeUserid ?? "",
      "meeting": newMeeting ?? {},
      "date": DateTime.now(),
      "userCoin": _user.coin - coin,
    };
    await coinLogDoc.set(newCoinLog);
    _controller.useCoin(coin);
    await userCollection.doc(_user.uid).update({"coin": _user.coin});
  }

  Stream<QuerySnapshot> getCoinLog() {
    return coinLogCollection.where('userid', isEqualTo: _user.uid).orderBy('date', descending: true).snapshots();
  }

  Future<Map<String, dynamic>> purchaseReceipt(PurchasedItem purchasedItem) async {
    Map transactionReceipt;
    String productId = purchasedItem.productId;
    String orderId;
    String purchaseToken;
    String packageName;
    // TODO 테스트 해봐야됨
    if (Platform.isAndroid) {
      transactionReceipt = jsonDecode(purchasedItem.transactionReceipt); //string => map
    } else {
      transactionReceipt = jsonDecode(purchasedItem.originalTransactionIdentifierIOS); //string => map
    }
    orderId = transactionReceipt["orderId"];
    purchaseToken = transactionReceipt["purchaseToken"];
    packageName = transactionReceipt["packageName"];

    int addCoin = int.parse(productId.replaceFirst('coin', ''));

    Map<String, dynamic> receiptInfo = {
      "userid": _user.uid,
      "usage": "하트 충전",
      "coin": addCoin,
      "userCoin": _user.coin + addCoin,
      "data": {
        "orderId": orderId,
        "productId": productId,
        "purchaseToken": purchaseToken,
        "packageName": packageName,
        "verified": "영수증 확인중"
      },
      "date": DateTime.now(),
    };

    try {
      await coinLogCollection.doc().set(receiptInfo);
      await userCollection.doc(_user.uid).update({"coin": FieldValue.increment(addCoin)});
      return Future.value({"result": true, "coin": addCoin});
    } on FirebaseException catch (e) {
      return Future.value({"result": false});
    } catch (e) {
      return Future.value({"result": false});
    }
  }

  checkFree() async {
    int today = int.parse(Util.dateFormat(DateTime.now()).replaceAll('-', ''));
    int freeDate;
    DocumentSnapshot data = await userCollection.doc(_user.uid).get();
    if (data['free'] == null) {
      _controller.isFree.value = true;
    } else {
      freeDate = int.parse(Util.dateFormat(data['free'].toDate()).replaceAll('-', ''));
      if (freeDate == today) {
        _controller.isFree.value = false;
      } else {
        _controller.isFree.value = true;
      }
    }
  }

  Future deleteTodayConnection(String docId) async {
    await todayConnectionCollection.doc(docId).delete(); // delete 된 todayConnection 은 내 미팅페이지에서 안 불러오도록
  }

  updateDailyMeetingActivation(bool bool) async {
    await userCollection.doc(_user.uid).update({"dailyMeetingActivation": bool});
  }

  Future withDraw() async {
    await FirebaseAuth.instance.currentUser.delete();
    Map<String, dynamic> withDrawUser = {
      "withDrawTime": DateTime.now(),
      "phone": _controller.user.value.phone,
    };
    await DatabaseService.instance.withDrawCollection.add(withDrawUser);
    await DatabaseService.instance.userCollection.doc(_controller.user.value.uid).delete();

    //update today match
    QuerySnapshot snapshot =
    await todayMatchCollection.doc(today).collection("matches").where(_user.man ? "men" : "women", arrayContains: _user.uid).get();
    snapshot.docs.forEach((element) async {
      List<dynamic> uidList = _user.man ? element.data()["men"] : element.data()["women"];
      int index = uidList.indexWhere((element) => element == _user.uid);
      List<dynamic> profileList = _user.man ? element.data()["menProfile"] : element.data()["womenProfile"];
      Map<String, dynamic> myProfile = profileList[index];
      myProfile["deleted"] = true;
      profileList[index] = myProfile;
      Map<String, dynamic> updateQuery = {"${_user.man ? "menProfile" : "womenProfile"}": profileList};
      await todayMatchCollection.doc(today).collection("matches").doc(element.id).update(updateQuery);
    });

    //get my meeting list
    List<String> meetingDocList = [];
    List<String> applyDocList = [];
    QuerySnapshot myMeetingSnapshot = await meetingCollection
        .where("deletedTime", isNull: true)
        .where("userId", isEqualTo: _user.uid)
        .orderBy("createdAt", descending: true)
        .get();

    myMeetingSnapshot.docs.forEach((element) {
      meetingDocList.add(element.id);
      if (element.data()["apply"] != null) applyDocList.add(element.data()["apply"]["applyId"]);
    });

    //delete my meeting
    for (int i = 0; i < meetingDocList.length; i++) {
      await deleteMeeting(meetingDocList[i]);
    }

    //나한테 apply 다 거절
    for (int i = 0; i < applyDocList.length; i++) {
      await meetingApplyCollection.doc(applyDocList[i]).update({"process": 2});
    }

    //내가 보낸 apply 다 삭제
    List<String> myApplyDocList = [];
    //네기 보낸 apply 해당하는 meeting 의 apply 삭제
    List<String> myApplyMeetingDocList = [];
    QuerySnapshot myApplySnapshot =
    await meetingApplyCollection.where("userId", isEqualTo: _user.uid).orderBy("createdAt", descending: true).get();

    myApplySnapshot.docs.forEach((e) {
      myApplyDocList.add(e.id);
      myApplyMeetingDocList.add(e.data()["meeting"]);
    });

    for (int i = 0; i < myApplyDocList.length; i++) {
      await deleteApply(myApplyDocList[i]);
    }

    for (int i = 0; i < myApplyMeetingDocList.length; i++) {
      await meetingCollection.doc(myApplyMeetingDocList[i]).update({"apply": null, "process": null});
    }

    Get.offAll(() => Splash());
  }

  deleteApply(String docId) async {
    await meetingApplyCollection.doc(docId).delete();
  }

  deleteDaily(String docId) async {
    await todayConnectionCollection.doc(docId).update({"deletedTime": DateTime.now(), "deleteUser": _user.uid});
  }

  deleteMeetingApply(String docId) async {
    await meetingApplyCollection.doc(docId).update({"process": 3});
  }

  addMember(MemberModel newMember) async {
    await userCollection.doc(_user.uid).update({"memberList.${_user.memberList?.length ??0}" : newMember.toJson()});
  }

  editMember(MemberModel newMember) async {
    await userCollection.doc(_user.uid).update({"memberList.${newMember.index}" : newMember.toJson()});
  }

  deleteMember(MemberModel newMember) async {
    if(newMember.url != null && newMember.url.contains('https://firebasestorage.googleapis.com')) {
      Reference storageReference = FirebaseStorage.instance.ref().child('user/${_user.uid + 'member' + newMember.index.toString()}');
      storageReference.delete();
    }
    await userCollection.doc(_user.uid).update({"memberList.${newMember.index}" : FieldValue.delete()});
  }
}