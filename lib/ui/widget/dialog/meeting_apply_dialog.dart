import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/ui/widget/member/member_pick_list.dart';
import 'package:byule/util/style/btStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingApplyDialog extends StatelessWidget {
  final MeetingModel meeting;
  final MeetingDetailController meetingDetailController;
  MeetingApplyDialog(this.meeting, this.meetingDetailController);

  final TextEditingController _selfIntroductionController = TextEditingController();

  final MainController _mainController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(17)), color: const Color(0xffffffff)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('미팅 신청', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontFamily: "AppleSDGothicNeoB",),),
              SizedBox(height: 20,),
              meetingApplyContents(),
              SizedBox(
                height: Get.width*0.11,
                child: TextButton(
                  onPressed: () => applyMeeting(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '5',
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.2
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.favorite,
                        size: 20,
                      ),
                    ],
                  ),
                  style: BtStyle.textDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget meetingApplyContents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            MemberPickList(meetingDetailController.pickedMemberIndexList, (index) {
              if (meetingDetailController.pickedMemberIndexList.contains(index)) {
                meetingDetailController.pickedMemberIndexList.remove(index);
              } else {
                meetingDetailController.pickedMemberIndexList.add(index);
              }
            }),
            SizedBox(height: 12),
            TextField(
              cursorColor: Colors.red[200],
              controller: _selfIntroductionController,
              maxLength: 500,
              minLines: 5,
              style: TextStyle(
                fontFamily: "AppleSDGothicNeoM",
              ),
              maxLines: 10,
              decoration: InputDecoration(
                counterText: '',
                hintText: '상대에게 보낼 메세지를 작성해주세요.',
                hintStyle: TextStyle(
                  fontFamily: "AppleSDGothicNeoM",
                ),
                filled: true,
                fillColor: Colors.grey[50],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey[300]),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey[300]),
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16,),
      ],
    );
  }

  void applyMeeting() async {
    ///멤버를 인원에 맞게 설정해주세요
    if (meetingDetailController.pickedMemberIndexList.length + 1 != meeting.number) {
      Get.dialog(NotificationDialog(
        title: "잠깐!",
        contents: "미팅 인원에 맞도록 멤버를 선택해주세요",
        contents2: "( ${meetingDetailController.pickedMemberIndexList.length} / ${meeting.number - 1} )",
      ));
      return;
    }

    FocusScope.of(Get.context).unfocus();

    ///최근에 거절당한 미팅 있는지 확인
    bool refusedExist = await DatabaseService.instance.checkRefusedBeforeApply(this.meeting.id);
    if (refusedExist) return;

    bool result = await DatabaseService.instance.applyMeeting(
        this.meeting.id, _selfIntroductionController.text, this.meeting.title, this.meeting.user.id, meetingDetailController.pickedMemberIndexList.map((memberIndex) => _mainController.user.value.memberList[memberIndex]).toList());
    if (result) {
      meetingDetailController.meeting.update((meeting) => meeting.process = 0);
      Map<String, dynamic> applyMeeting = {
        "title": meeting.title,
        "loc1": meeting.loc1,
        "loc2": meeting.loc2,
        "loc3": meeting.loc3,
        "number": meeting.number,
        "introduce": meeting.introduce,
      };
      await DatabaseService.instance.useCoin(5, 2, newMeeting: applyMeeting, oppositeUserid: meeting.userId);
    }
    Get.back();
    CustomedFlushBar(Get.context, '미팅 신청이 완료되었습니다!');
  }

}
