import 'package:animator/animator.dart';
import 'package:byule/controller/meeting_opposite_profile_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/ui/drawer/custom_drawer.dart';
import 'package:byule/ui/meeting/widgets/member_cards.dart';
import 'package:byule/ui/widget/dialog/meeting_letter_dialog.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingOppositeProfilePage extends StatelessWidget {

  final MeetingOppositeProfileController _controller = Get.find();
  MeetingModel get meeting => _controller.meeting;
  List<MemberModel> get memberListToShow => _controller.memberListToShow;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.main100,
            elevation: 0,
            leading: IconButton(
              highlightColor: Colors.white,
              icon: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Icon(Icons.arrow_back_ios, color: Colors.white,),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [GestureDetector(
              onTap: () => Get.dialog(MeetingLetterDialog(meeting.apply.msg)),
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: Animator(
                    duration: Duration(milliseconds: 1000),
                    cycles: 0,
                    curve: Curves.elasticOut,
                    tween: Tween<double>(begin: 24.0, end: 30.0),
                    builder: (context, animatorState, child) =>
                        Image.asset('assets/love_letter.png', height: animatorState.value, width: animatorState.value)),
              ),
            ),],
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            centerTitle: true,
            title: Text(
              '상대방 확인',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [0.0, 0.90], colors: [AppColor.main100, Colors.white])),
              ),
              ScrollConfiguration(
                behavior: ScrollBehavior(),
                child: Column(
                  children: <Widget>[
                    Obx(
                      () => MemberCards(
                        memberList: memberListToShow,
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
            ],
          ),
        ),
      ),
    );
  }


  Widget acceptOrNot() {
    return Column(
      children: [
        Container(color: Colors.grey[300], height: 1),
        acceptOrNotButtons(),
      ],
    );
  }



  Widget acceptOrNotButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: Get.width * 0.05,
          ),
          Flexible(
            child: ElevatedButton(
              child: Text('수락'),
              style: BtStyle.textMain200,
              onPressed: () => _controller.onPressAccept(),
            ),
          ),
          SizedBox(
            width: Get.width * 0.05,
          ),
          Flexible(
            child: ElevatedButton(
              child: Text('거절'),
              style: BtStyle.textMain100,
              onPressed: () => _controller.onPressReject(),
            ),
          ),
          SizedBox(
            width: Get.width * 0.05,
          ),
        ],
      ),
    );
  }
}
