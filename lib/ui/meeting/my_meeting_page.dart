import 'package:animations/animations.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/my_meeting_controller.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/home/opposite_profile.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/ui/widget/deletedUser.dart';
import 'package:byule/ui/widget/dialog/confirm_dialog.dart';
import 'package:byule/ui/widget/meeting/meetingGridItem.dart';

import 'meeting_detail_page.dart';

class MyMeetingPage extends StatefulWidget {
  @override
  _MyMeetingPageState createState() => _MyMeetingPageState();
}

class _MyMeetingPageState extends State<MyMeetingPage> {
  final MyMeetingController _controller = Get.find();

  @override
  void initState() {
    _controller.refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          highlightColor: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '내 미팅',
          style: TextStyle(
            color: Colors.black,
            fontFamily: "AppleSDGothicNeoM",
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: [
                      categoryText('데일리 미팅'),
                      _controller.todayConnectionList.length != 0
                          ? buildList(_controller.todayConnectionList, short: true)
                          : noMeeting('성사된 데일리 미팅이 없습니다'),
                      categoryText('만든 미팅'),
                      _controller.myMeetingList.length != 0 ? buildList(_controller.myMeetingList, isMine: true) : noMeeting('만든 미팅이 없습니다'),
                      categoryText('신청한 미팅'),
                      _controller.myMeetingApplyList.length != 0 ? buildList(_controller.myMeetingApplyList) : noMeeting('신청한 미팅이 없습니다'),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  buildList(List itemList, {bool short = false, bool isMine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
      child: LiveGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemList.length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: Tween<double>(
              begin: 0,
              end: 1,
            ).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.1),
                end: Offset.zero,
              ).animate(animation),
              child: Builder(
                builder: (context) {
                  if (short) {
                    return shortTileRow(itemList[index]);
                  } else if (isMine) {
                    return meetingGridItem(itemList[index], isMine: true, myMeeting: true);
                  } else {
                    bool refused = false;
                    if(itemList[index].process == null) {
                      refused = true;
                    }
                    return meetingGridItem(itemList[index], didIApplied: true, refused: refused, myMeeting: true);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget meetingItem(MeetingModel item, {bool isMine = false, bool isApply = false}) {
  //   return OpenContainer(
  //     transitionDuration: Duration(milliseconds: 800),
  //     openShape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(5.2),
  //     ),
  //     closedColor: Colors.transparent,
  //     closedShape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(5.2),
  //     ),
  //     openElevation: 0,
  //     closedElevation: 0,
  //     openBuilder: (context, action) {
  //       MeetingDetailController _meetingDetailController = Get.put(MeetingDetailController(item, false), tag: item.id);
  //       if (isMine && (item.process == 0 || item.process == 1)) {
  //         print('this it myMeeting item : $item');
  //         return MeetingDetailPage(item, _meetingDetailController);
  //       } else if (isApply) {
  //         return MeetingDetailPage(item, _meetingDetailController, isApplied: true);
  //       }
  //       return MeetingDetailPage(item, _meetingDetailController);
  //     },
  //     closedBuilder: (context, action) => Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 3.0),
  //       child: Card(
  //         elevation: 2,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.transparent,
  //             borderRadius: BorderRadius.all(Radius.circular(10)),
  //             border: Border.all(color: Colors.grey[100], width: 0.5),
  //           ),
  //           child: Row(
  //             children: <Widget>[
  //               Expanded(
  //                 flex: 2,
  //                 child: Column(
  //                   children: <Widget>[
  //                     Container(
  //                       alignment: Alignment.bottomLeft,
  //                       height: 34,
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(left: 16.0),
  //                         child: Text(
  //                           item.title,
  //                           style: TextStyle(fontSize: 15),
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 5,
  //                     ),
  //                     Container(
  //                       alignment: Alignment.topLeft,
  //                       height: 30,
  //                       child: Padding(
  //                         padding: const EdgeInsets.only(left: 16.0),
  //                         child: Text(
  //                           '${item.loc1} ${item.loc2} - ${item.loc3}',
  //                           style: TextStyle(color: Colors.grey[600]),
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 flex: 1,
  //                 child: Container(
  //                   alignment: Alignment.centerRight,
  //                   height: 64,
  //                   child: Padding(
  //                     padding: const EdgeInsets.only(right: 32.0),
  //                     child: Builder(builder: (context) {
  //                       Color textColor;
  //
  //                       if (item.process == 1) {
  //                         textColor = Colors.blue[600];
  //                       } else {
  //                         textColor = Colors.black87;
  //                       }
  //
  //                       return Text(
  //                         item.process == 0 || item.process == 1 ? '${item.number} / ${item.number}' : '0 / ${item.number}',
  //                         style: TextStyle(fontSize: 15, color: textColor, fontFamily: 'AppleSDGothicNeoM'),
  //                       );
  //                     }),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget shortTileRow(Map<String, UserModel> connection) {
    String docId = connection.keys.toList()[0];
    UserModel user = connection.values.toList()[0];
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: user.deleted == true ? deletedUser(onPressed: () async{
          await DatabaseService.instance.deleteTodayConnection(docId);
          _controller.todayConnectionList.removeWhere((element) => element.keys.toList()[0] == docId);
          Get.back();
        }) : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                child: ProfileImageForm2(user),
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: (Get.width - 54) / 3 - 10,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.all(3),
              child: Text(
                user.name,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget ProfileImageForm2(UserModel user) {
    return GestureDetector(
      /* 데일리미팅 삭제
      onLongPress: (){
        Get.defaultDialog(
            title: "삭제",
            content: Text("삭제하시겠습니까?"),
            onConfirm: (){},
            onCancel: (){});
      },
       */
      onTap: () {
        Get.to(() => OppositeProfilePage(user));
        print('this is opposite : ${'today_signal' + user.uid}');
      },
      child: Hero(
        tag: 'today_signal' + user.uid,
        child: cachedImage(user.firstPic, radius: 7.0),
      ),
    );
  }

  Widget categoryText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: Get.width * 0.05,
        ),
        Expanded(
            child: Container(
          height: 1,
          color: Colors.black26,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(text, style: TextStyle(fontSize: 15, fontFamily: 'AppleSDGothicNeoB')),
        ),
        Expanded(
            child: Container(
          height: 1,
          color: Colors.black26,
        )),
        SizedBox(
          width: Get.width * 0.05,
        ),
      ],
    );
  }

  Widget noMeeting(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Container(
          height: AppBar().preferredSize.height,
          child: Center(
              child: Text(text,
                  style: TextStyle(
                    fontFamily: "AppleSDGothicNeoM",
                  )))),
    );
  }
}
