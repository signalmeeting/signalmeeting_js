import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/util.dart';
import 'package:get/get.dart';

import 'my_meeting_controller.dart';

class MeetingOppositeProfileController extends GetxController {

  String meetingId;
  UserModel user;

  MeetingOppositeProfileController(this.meetingId, this.user);

  MyMeetingController _myMeetingController = Get.find();

  MeetingDetailController meetingDetailController;

  MeetingModel get meeting => meetingDetailController.meeting.value;

  RxList<MemberModel> memberListToShow = <MemberModel>[].obs;

  void onInit() {
    meetingDetailController = Get.find(tag: meetingId);

    memberListToShow.add(Util.userToMemberModel(user.profileInfo));

    if (user.memberList != null) {
      user.memberList.forEach((member) => memberListToShow.add(member));
    }

    super.onInit();
  }


  onPressAccept() async {
    await DatabaseService.instance
        .acceptApply(meetingId: meeting.id, applyId: meeting.apply.applyId, meetingTitle: meeting.title, receiver: user.uid);
    meetingDetailController.meeting.update((meeting) {
      meeting.process = 1;
    });

    CustomedFlushBar(Get.context, '축하합니다! 미팅이 성사되었습니다!');
    //바깥으로 보내버리는건 좀 아닌듯
    //수락 시 - 수락 거절 부분 없애고,(오픈 컨테이너로?)
    //거절 시  - 바깥으로 보내고 플러시 한번 띄워주??

    1.delay(() {
      for (int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
        if (_myMeetingController.myMeetingList[i].id == meetingDetailController.meeting.value.id) {
          _myMeetingController.myMeetingList[i].process = 1;
        }
      }
    });
  }

  onPressReject() {
    DatabaseService.instance.refuseApply(
        meetingId: meeting.id, applyId: meeting.apply.applyId, meetingTitle: meeting.title, receiver: user.uid);

    //인창, 여기 null이 맞을까 2가 맞을까??
    for (int i = 0; i < _myMeetingController.myMeetingList.length; i++) {
      if (_myMeetingController.myMeetingList[i].id == meeting.id) {
        _myMeetingController.myMeetingList[i].process = null;
      }
    }
    meetingDetailController.meeting.update((meeting) => meeting.process = null);
  }
}