import 'package:byule/controller/meeting_opposite_profile_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/ui/drawer/custom_drawer.dart';
import 'package:byule/ui/meeting/widgets/member_cards.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingOppositeProfilePage extends StatelessWidget {

  final MeetingOppositeProfileController _controller = Get.find();
  MeetingModel get meeting => _controller.meeting;
  List<MemberModel> get memberListToShow => _controller.memberListToShow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drawerAppBar(context, '상대방 확인'),
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: Column(
          children: <Widget>[
            Obx(
            () => MemberCards(
                memberList: memberListToShow,
                loaded: memberListToShow.isNotEmpty,
                deleted: false,
                meetingId: meeting.id,
                meeting: meeting,
                meetingOwner: _controller.user,
                // meetingDetailController: meetingDetailController,
              ),
            ),
            Obx(() =>  meeting.process == 0 ? acceptOrNot() : Container()),

          ],
        ),
      ),
    );
  }


  Widget acceptOrNot() {
    return Column(
      children: [
        SizedBox(height: 10.0),
        Container(
          padding: EdgeInsets.all(10),
          width: Get.width * 0.9,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200], width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
          ),
          child: Text(meeting.apply.msg),
        ),
        SizedBox(height: 10.0),
        acceptOrNotButtons(),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            height: 10,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }



  Widget acceptOrNotButtons() {
    return Row(
      children: [
        SizedBox(
          width: Get.width * 0.05,
        ),
        Flexible(
          child: TextButton(
            child: Text('수락'),
            style: BtStyle.textMain200,
            onPressed: () => _controller.onPressAccept(),
          ),
        ),
        SizedBox(
          width: Get.width * 0.05,
        ),
        Flexible(
          child: TextButton(
            child: Text('거절'),
            style: BtStyle.textMain100,
            onPressed: () => _controller.onPressReject(),
          ),
        ),
        SizedBox(
          width: Get.width * 0.05,
        ),
      ],
    );
  }
}
