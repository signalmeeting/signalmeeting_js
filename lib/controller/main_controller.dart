import 'dart:async';
import 'dart:math';

import 'package:byule/model/memberModel.dart';
import 'package:byule/services/inAppManager.dart';
import 'package:byule/services/push_notification_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/chat_controller.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/chat/chat_page.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/dialog/report_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';

class MainController extends GetxController {
  final FirebaseApp app;

  MainController(this.app);

  var user = UserModel().obs;
  RxList todayMatchList = [].obs;
  RxBool isLogOut = false.obs;
  RxBool isFree = false.obs;
  bool needForceUpdate = false;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  InAppManager inAppManager;

  @override
  void onInit() {
    3.delay(() {
      inAppManager = InAppManager()..init();
      PushNotificationsHandler().init();
    });
    super.onInit();
  }

  logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  updateTodayMatchList(items) {
    this.todayMatchList.assignAll(items);
  }

  newUser() async {
    Get.dialog(Center(child: CircularProgressIndicator()));
    bool result = await DatabaseService.instance.newUser();
    //Get.defaultDialog(title: "알림", middleText: "계정 생성에 실패했습니다", onConfirm: () => Get.back());
    if (!result) CustomedFlushBar(Get.context, "계정 생성에 실패했습니다");
    Get.back();
  }

  updateUser(UserModel user) {
    // print('new user : ${user.toString()}');
    this.user(user);
  }

  useCoin(int coin) async {
    user.update((val) => val.coin -= coin);
  }

  addCoin(int coin) {
    user.update((val) => val.coin += coin);
  }

  updateUserPics(pics) {
    //인창 수정
    user.update((val) => val.profileInfo["pics"] = pics);
  }

  finishInvite() {
    this.user.update((val) {
      val.invite = true;
      val.coin = val.coin + 50;
    });
  }

  changeProfile(String key, var value, {Function callback}) async {
    updateUser(user.value..profileInfo[key] = value);
  }

  //https://jude-m.medium.com/send-push-notifications-with-flutter-firebase-cloud-messaging-and-functions-5e9942a7f23c
  //nodejs code :  firebase deploy --only functions
  // 함수 새로 만들어서 deploy 해보기

  //https://medium.com/@umeshnalinde7/flutter-cloud-messaging-with-firebase-functions-firestore-android-175904a15537

  //https://firebase.google.com/docs/cloud-messaging/js/send-multiple?hl=ko
  Future<void> sendNotification(String promoId, String promoDesc) async {
    String deviceToken = await _firebaseMessaging.getToken();

    print("deviceToken : $deviceToken");

    final CollectionReference meetingApplyCollection = FirebaseFirestore.instance.collection('meeting_apply');
    await meetingApplyCollection
        .doc()
        .set({
          "user": "QuJp3HmwM7cuMVi8c9swfQwkYup2",
          "meeting": "zGPgH2MnhP2yWzdQZ5nB",
          "msg": "알림테스트",
          "createdAt": DateTime.now(),
          "process": 0
        })
        .then((value) => print("success"))
        .catchError((error) => print("error : $error")); // process 0 : 신청중 , 1 : 연결, 2: 거절
    // HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendFollowerNotification');
//{"token" : deviceToken}
//     await callable().then((value) => print("result : $value")).catchError((e) {
//       print("error : $e");
//     });
  }

  //인창, 간단 소개에도 써서 myProfilePage에서 여기로 옮김
  changeProfileValue(String key, var value, {Function callback}) async {
    //인창 추가
    user.update((val) => val.profileInfo[key] = value);

    changeProfile(key, value, callback: callback);
    Get.dialog(Center(child: CircularProgressIndicator()));
    bool result = await DatabaseService.instance.changeProfileValue("profileInfo." + key, value);
    Get.back();
    //인창 추가
    callback();
    // Get.defaultDialog(title: "알림", middleText: "죄송합니다. 수정에 실패했습니다.\n잠시 후 다시 시도해주세요");
    if (!result) CustomedFlushBar(Get.context, "죄송합니다. 수정에 실패했습니다.\n잠시 후 다시 시도해주세요");
  }

  updateBanList(String from, String to, ReportType reportType, MeetingDetailController meetingDetailController) {
    if (reportType == ReportType.daily) {
      user.update((val) => val.banList.add({'from': from, 'to': to, 'when': DateTime.now()}));
    } else if ((reportType == ReportType.meeting)) {
      meetingDetailController.meeting.value.banList.add({'from': from, 'to': to, 'when': DateTime.now()});
    }
  }

  static goToChatPage(String roomId, UserModel user, String type) {
    print("roomId : $roomId");
    Get.to(
      () => ChatPage(),
      binding: BindingsBuilder(() {
        Get.put(ChatController(roomId, user, type), tag: roomId);
      }),
      arguments: roomId,
      preventDuplicates: false,
    );
  }

  addMember(MemberModel newMember) async {
    if(newMember.url != null) {
      String uploadedUrl = await DatabaseService.instance.uploadMemberImage(newMember.url, newMember.index);
      newMember.url = uploadedUrl;
    }
    await DatabaseService.instance.addMember(newMember);
    user.update((val) => val.memberList == null ? val.memberList = [newMember] :  val.memberList.add(newMember));
  }

  editMember(MemberModel newMember) async {
    if(newMember.url != null && !newMember.url.contains('https://firebasestorage.googleapis.com')) {
      String uploadedUrl = await DatabaseService.instance.uploadMemberImage(newMember.url, newMember.index);
      newMember.url = uploadedUrl;
    }
    await DatabaseService.instance.editMember(newMember);
    user.update((val) => val.memberList[newMember.index] = newMember);
  }

  reorderMember(int index1, int index2) async {
    //index 1 <-> 2
    MemberModel member1 = user.value.memberList[index1];
    MemberModel member2 = user.value.memberList[index2];
    member1.index = index2;
    member2.index = index1;
    user.update((val) {
      val.memberList[index1] = member2;
      val.memberList[index2] = member1;
    });
    await DatabaseService.instance.reorderMember(index1, index2, member1, member2);
  }

  deleteMember(MemberModel newMember) async {
    await DatabaseService.instance.deleteMember(newMember);
    user.update((val) => val.memberList.removeAt(newMember.index));
    Get.back(closeOverlays: true);
  }

}
