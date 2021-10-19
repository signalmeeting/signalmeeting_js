import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:signalmeeting/model/meetingModel.dart';

import 'meetingGridItem.dart';

Widget meetingGrid (List<MeetingModel> meetingList) {
  return LiveGrid(
    shrinkWrap: true,
    itemCount: meetingList.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
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
          child: meetingGridItem(meetingList[index]),
        ),
      );
    },
  );
}