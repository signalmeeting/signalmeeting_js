import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:signalmeeting/model/meetingModel.dart';

import 'meetingGridItem.dart';

Widget meetingGrid (List<MeetingModel> meetingList, String uid) {
  return LiveGrid(
    shrinkWrap: true,
    itemCount: meetingList.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    itemBuilder: (context, index, animation) {
      bool _didIApplied;
      if(meetingList[index].apply != null)
        _didIApplied = (meetingList[index].apply.userId == uid) ? true : false;
      else
        _didIApplied = false;
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
          child: meetingGridItem(meetingList[index], didIApplied: _didIApplied),
        ),
      );
    },
  );
}