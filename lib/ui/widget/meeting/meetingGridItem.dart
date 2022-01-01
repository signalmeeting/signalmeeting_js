import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/my_meeting_controller.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/services/database.dart';
import 'package:signalmeeting/ui/meeting/meeting_detail_page.dart';
import 'package:signalmeeting/ui/widget/dialog/confirm_dialog.dart';
import 'package:signalmeeting/ui/widget/dialog/main_dialog.dart';
import 'package:signalmeeting/ui/widget/dialog/notification_dialog.dart';
import 'package:signalmeeting/ui/widget/flush_bar.dart';

import '../cached_image.dart';

Widget meetingGridItem(MeetingModel item, {bool isMine = false, bool didIApplied = false, bool refused = false}) {
  return InkWell(
    onTap: () {

      print('is it refused ? : $refused');

      if(refused) {
        //Get.defaultDialog(title: '거절된 미팅\n미팅이 거절되었습니다');
        Get.dialog(NotificationDialog(contents: "미팅이 거절되었습니다",));
        DatabaseService.instance.checkRefused(item.id);
        MyMeetingController _controller = Get.find();
        _controller.myMeetingApplyList.remove(item);
      }

      if(item.process == 0 && !item.isMine && !didIApplied) {
        CustomedFlushBar(Get.context, '신청이 진행중인 미팅입니다');
      } else if(item.process == 1 && !item.isMine && !didIApplied) {
        CustomedFlushBar(Get.context, '이미 성사된 미팅입니다');
      }

    },
    onLongPress: () {
      if(item.isMine && item.apply == null) {
        Get.dialog(
            MainDialog(
              title: "알림",
              contents: Padding(
                padding: const EdgeInsets.only(left: 18, bottom : 18.0),
                child: Text("미팅을 삭제하시겠습니까?", textAlign: TextAlign.center,),
              ),
              buttonText: "삭제",
              onPressed: () {
                DatabaseService.instance.deleteMeeting(item.id);
                Get.back();
                CustomedFlushBar(Get.context, "삭제가 완료되었습니다!");
              },));
      }
    },
    child: OpenContainer(
        useRootNavigator: true,
        tappable: ((didIApplied || item.isMine || item.process == null) && !refused) ? true : false,
        transitionDuration: Duration(milliseconds: 500),
        openShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.2),
        ),
        closedColor: Colors.transparent,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.2),
        ),
        openElevation: 0,
        closedElevation: 0,
        closedBuilder: (context, action) => closedItem(item),
        onClosed: (Null) async {
          await 1.delay();
          Get.delete<MeetingDetailController>(tag: item.id);
        },
        openBuilder: (context, action) {
          MeetingDetailController _meetingDetailController = Get.put(MeetingDetailController(item), tag: item.id);
          return MeetingDetailPage(_meetingDetailController);
        }
    ),
  );
}

Widget closedItem(MeetingModel item) {
  return Card(
    elevation: 1.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Padding(
          padding: const EdgeInsets.all(3.0),
          //임시 이미지
          child: cachedImage(item.meetingImageUrl??'', width: 30, height: 30, radius: 7.0),
        )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Builder(builder: (context) {
                    Color textColor;

                    if (item.process == 1) {
                      textColor = Colors.blue[600];
                    } else {
                      textColor = Colors.black87;
                    }

                    return Text(
                      item.process == 0 || item.process == 1 ? '${item.number} / ${item.number}' : '0 / ${item.number}',
                      style: TextStyle(fontSize: 12, color: textColor, fontFamily: 'AppleSDGothicNeoM'),
                    );
                  }),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Text(
                      '${item.man ? '남' : '여'}ㅣ${item.loc1} ${item.loc2} ${(item.loc3 != "")? "- " + item.loc3 : ""}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              Text(
                item.title,
                style: TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    ),
  );
}