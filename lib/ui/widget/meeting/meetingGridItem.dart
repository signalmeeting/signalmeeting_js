import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/model/meetingModel.dart';
import 'package:signalmeeting/ui/meeting/meeting_detail_page.dart';

import '../cached_image.dart';

Widget meetingGridItem(MeetingModel item, {bool isMine = false, bool isApply = false}) {
  return OpenContainer(
      transitionDuration: Duration(milliseconds: 800),
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
      openBuilder: (context, action) {
        MeetingDetailController _meetingDetailController = Get.put(MeetingDetailController(item, false), tag: item.id);
        return MeetingDetailPage(item, _meetingDetailController);
      }
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
                      '${item.man ? '남' : '여'}ㅣ${item.loc1} ${item.loc2} - ${item.loc3}',
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