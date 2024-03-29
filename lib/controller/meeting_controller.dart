import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';

class MeetingController extends GetxController {
  MainController _mainController = Get.find();

  UserModel get user => _mainController.user.value;

  RxList<MeetingModel> meetingList = <MeetingModel>[].obs; // 미팅 메인 페이지 리스트
  RxString loc1 = '전체'.obs; // 필터1
  RxString loc2 = '전체'.obs; // 필터2
  RxInt type = 0.obs; // 필터3

  @override
  void onInit() async{
    final prefs = await SharedPreferences.getInstance();
    this.loc1.value = prefs.getString('loc1Filter') ?? '전체';
    this.loc2.value = prefs.getString('loc2Filter') ?? '전체';
    this.type.value = prefs.getInt('typeFilter') ?? 0;
    super.onInit();
  }
  // getMeetingList({String loc1, String loc2, int type}) async {
  //   List<QueryDocumentSnapshot> meetingList = await DatabaseService.instance.getMeetingListFilter(loc1: loc1, loc2: loc2, type: type);
  //   this.meetingList.assignAll(meetingList.map((QueryDocumentSnapshot e) {
  //     Map<String, dynamic> meeting = e.data();
  //     meeting["_id"] = e.id;
  //     meeting["isMine"] = meeting["user"] == user.uid;
  //     return MeetingModel.fromJson(meeting);
  //   }).toList());
  //   print("meetingList : $meetingList");
  // }

  selectLocation1(String location1, VoidCallback callback) async{
    final prefs = await SharedPreferences.getInstance();
    try {
      this.loc1.value = location1;
      this.loc2.value = '전체';
      await prefs.setString('loc1Filter', location1);
      await prefs.setString('loc2Filter', '전체');
    } finally {
      print(this.loc1.value);
      print(this.loc2.value);
      // callback?.call();
    }
  }

  selectLocation2(String location2, VoidCallback callback) async{
    final prefs = await SharedPreferences.getInstance();
    try {
      loc2.value = location2;
      await prefs.setString('loc2Filter', location2);
      refresh();
      update();
    } finally {
      print('ㅁㅁㅁㅁ${this.loc1.value}');
      print('ㄴㄴㄴㄴ${this.loc2.value}');
      // callback?.call();
    }
    // callback?.call();
  }

  selectType(int type, VoidCallback callback) async{
    final prefs = await SharedPreferences.getInstance();
    this.type.value = type;
    await prefs.setInt('typeFilter', type);
    // callback?.call();
  }
}
