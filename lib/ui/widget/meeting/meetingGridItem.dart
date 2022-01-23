import 'package:animations/animations.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/ui/widget/meeting/meetingGrid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/dialog/confirm_dialog.dart';
import 'package:byule/ui/widget/dialog/main_dialog.dart';
import 'package:byule/ui/widget/dialog/notification_dialog.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:byule/util/util.dart';
import '../cached_image.dart';

Widget meetingGridItem(MeetingModel item, {bool isMine = false, bool didIApplied = false, bool refusedOrDeleted = false, bool myMeeting = false}) {
  return InkWell(
    onTap: () {
      if(refusedOrDeleted) {
        //Get.defaultDialog(title: '거절된 미팅\n미팅이 거절되었습니다');
        Get.dialog(NotificationDialog(contents: item.process == 3 ? "미팅이 삭제되었습니다" : "미팅이 거절되었습니다",));
        DatabaseService.instance.checkRefused(item.id, item.process != 3 ? true : false);
        MyMeetingController _controller = Get.find();
        _controller.myMeetingApplyList.remove(item);
      }

      if(item.process == 0 && !item.isMine && !didIApplied) {
        CustomedFlushBar(Get.context, '신청이 진행중인 미팅입니다');
      } else if(item.process == 1 && !item.isMine && !didIApplied) {
        CustomedFlushBar(Get.context, '이미 성사된 미팅입니다');
      } else if(item.process == 4 && !item.isMine){
        CustomedFlushBar(Get.context, '이미 성사된 미팅입니다');
      } else if(item.process == 4 && item.isMine){
        Get.dialog(NotificationDialog(contents: "상대방이 미팅을 삭제했습니다",));
      }

    },
    onLongPress: () {
      MainController _controller = Get.find();
      if(item.isMine && (item.apply == null || item.process == 1)) {
        Get.dialog(
            MainDialog(
              title: "알림",
              contents: Padding(
                padding: const EdgeInsets.only(left: 18, bottom : 18.0),
                child: Text("미팅을 삭제하시겠습니까?", textAlign: TextAlign.center,),
              ),
              buttonText: "삭제",
              onPressed: () async {
                await DatabaseService.instance.deleteMeeting(item.id, process : item.process == 1 ? 3 : item.process);
                MyMeetingController _controller = Get.find();
                _controller.myMeetingList.remove(item);
                Get.back();
                CustomedFlushBar(Get.context, "삭제가 완료되었습니다!");
              },));
      }
      if(item.isMine && item.process == 0){
        Get.dialog(
        NotificationDialog(
          contents: "미팅을 거절후 삭제해주세요",
        ));
      }
      if(item.apply.userId == _controller.user.value.uid && item.process == 1){
        Get.dialog(
            MainDialog(
              title: "알림",
              contents: Padding(
                padding: const EdgeInsets.only(left: 18, bottom : 18.0),
                child: Text("미팅을 삭제하시겠습니까?", textAlign: TextAlign.center,),
              ),
              buttonText: "삭제",
              onPressed: () async {
                await DatabaseService.instance.deleteApplyMeeting(item.id, item.apply.applyId);
                MyMeetingController controller = Get.find();
                controller.myMeetingApplyList.remove(item);
                Get.back();
                CustomedFlushBar(Get.context, "삭제가 완료되었습니다!");
              },));
      }
      if(item.process == 4 && item.isMine){
        Get.dialog(MainDialog(
          title: "알림",
          contents: Padding(
            padding: const EdgeInsets.only(left: 18, bottom : 18.0),
            child: Text("미팅을 삭제하시겠습니까?", textAlign: TextAlign.center,),
          ),
          buttonText: "삭제",
          onPressed: () async {
            await DatabaseService.instance.deleteMyMeeting(item.id);
            MyMeetingController controller = Get.find();
            controller.myMeetingList.remove(item);
            Get.back();
            CustomedFlushBar(Get.context, "삭제가 완료되었습니다!");
          },));
      }
    },
    child: Stack(
      children: <Widget>[
        OpenContainer(
          useRootNavigator: true,
          tappable: ((didIApplied || item.isMine || item.process == null) && !refusedOrDeleted && item.process != 4) ? true : false,
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
            //print('gridItem clicked : $item');
            MeetingDetailController _meetingDetailController = Get.put(MeetingDetailController(item), tag: item.id);
            return MeetingDetailPage(_meetingDetailController);
          }
      ),
        !myMeeting ? Positioned(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(5.2), topRight: Radius.circular(5.2)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38.withOpacity(0.2), Colors.black38.withOpacity(0)],)
            ),
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 3),
              child: Text(
                "D-${(14 - DateTime.now().difference(item.createdAt).inDays).toString()}",
                style: TextStyle(fontFamily: "AppleSDGothicNeoB", fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          top: 7, right: 7.7, left: 7.7,
        ) : Container(width: 10, height: 10, color: Colors.transparent,),
      ]
    ),
  );
}

Widget closedItem(MeetingModel item) {
  return Card(
    elevation: 1.5,
    margin: const EdgeInsets.all(4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(3.0),
          //임시 이미지
          child: cachedImage(item.meetingImageUrl??'', width: 30, height: imageSize, radius: 7.0),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Builder(builder: (context) {
                      Color textColor;

                      if (item.process == 0) {
                        textColor = Colors.red[600];
                      } else if(item.process == 1) {
                        textColor = Colors.blue[600];
                      } else {
                        textColor = Colors.black87;
                      }

                      return Text(
                        item.process == 0 || item.process == 1 || item.process == 4 ? '${item.number} / ${item.number}' : '0 / ${item.number}',
                        style: TextStyle(fontSize: 14, color: textColor, fontFamily: 'AppleSDGothicNeoB'),
                      );
                    }),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Text(
                        '${item.man ? '남' : '여'}ㅣ${item.loc1} ${item.loc2} ${(item.loc3 != "")? "- " + item.loc3 : ""}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                Text(
                  item.title,
                  style: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'AppleSDGothicNeoB'),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
      ],
    ),
  );
}