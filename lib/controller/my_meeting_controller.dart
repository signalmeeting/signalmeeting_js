import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/model/userModel.dart';
import 'package:signalmeeting/services/database.dart';

class MyMeetingController extends GetxController {
  MainController _mainController = Get.find();

  UserModel get user => _mainController.user.value;

  RxList<Map<String,UserModel>> todayConnectionList = <Map<String,UserModel>>[].obs;
  RxList<MeetingModel> myMeetingList = <MeetingModel>[].obs;
  RxList<MeetingModel> myMeetingApplyList = <MeetingModel>[].obs;

  @override
  void onInit() {
    // called immediately after the widget is allocated memory
    refresh();
    super.onInit();
  }

  refresh() {
    getTodayConnectionList();
    getMyMeetingList();
    getMyApplyMeetingList();
  }

  getTodayConnectionList() async {
    List<QueryDocumentSnapshot> resultList = await DatabaseService.instance.getTodayConnectionList();
    if(resultList.length > 0) {
      List<Map<String,UserModel>> connectionList = [];
      for (int i = 0; i < resultList.length; i++) {
        QueryDocumentSnapshot e = resultList[i];
        UserModel opposite = user.man
            ? await DatabaseService.instance.getOppositeUserInfo(e.data()["womanId"])
            : await DatabaseService.instance.getOppositeUserInfo(e.data()["manId"]);
        connectionList.add({e.id : opposite});
      }
      this.todayConnectionList.assignAll(connectionList);
    }
  }

  getMyMeetingList() async {
    List<QueryDocumentSnapshot> resultList = await DatabaseService.instance.getMyMeetingList();
    List<MeetingModel> list = [];
    for (int i = 0; i < resultList.length; i++) {
      Map<String, dynamic> meeting = resultList[i].data();
      meeting["_id"] = resultList[i].id;
      meeting["isMine"] = true;
      if (meeting["process"] == 0 || meeting["process"] == 1) // apply 존재 //인창 수정, 성사 후에도 상대방 확인 위해 meeting["process"] == 1 추가
      {
        QueryDocumentSnapshot applyData = await DatabaseService.instance.getApplyData(resultList[i].id);
        Map data = applyData.data();
        UserModel user = await DatabaseService.instance.getOppositeUserInfo(data["userId"]);
        meeting["applyUser"] = user.toJson();
        // meeting["apply"] = {"msg": data["msg"], "createdAt" : data["createdAt"], "id" : applyData.id};
      }
      list.add(MeetingModel.fromJson(meeting));
    }
    this.myMeetingList.assignAll(list);
  }

  getMyApplyMeetingList() async {
    List<MeetingModel> resultList = await DatabaseService.instance.getMyApplyMeetingList();
    this.myMeetingApplyList.assignAll(resultList);
  }
}
