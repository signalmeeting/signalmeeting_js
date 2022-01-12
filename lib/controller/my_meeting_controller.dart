import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';

class MyMeetingController extends GetxController {
  MainController _mainController = Get.find();

  UserModel get user => _mainController.user.value;

  RxList<Map<String,UserModel>> todayConnectionList = <Map<String,UserModel>>[].obs;
  RxList<MeetingModel> myMeetingList = <MeetingModel>[].obs;
  RxList<MeetingModel> myMeetingApplyList = <MeetingModel>[].obs;
  RxList deletedDaily = [].obs;

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
        //deleteUser가 없다 / 있다 => 나 / 상대방
        if(e.data()['deleteUser'] == null){
          UserModel opposite = user.man
              ? await DatabaseService.instance.getOppositeUserInfo(e.data()["womanId"])
              : await DatabaseService.instance.getOppositeUserInfo(e.data()["manId"]);
          connectionList.add({e.id : opposite});
        } else if(e.data()['deleteUser'] != user.uid){
          this.deletedDaily.add(e.id.toString());
          UserModel opposite = user.man
              ? await DatabaseService.instance.getOppositeUserInfo(e.data()["womanId"])
              : await DatabaseService.instance.getOppositeUserInfo(e.data()["manId"]);
          connectionList.add({e.id : opposite});
        }
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
      meeting['createdAt'] = meeting['createdAt'].toDate().toString();
      if(meeting['deletedTime'] != null)
        meeting['deletedTime'] = meeting['deleteTime'].toDate().toString();
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
