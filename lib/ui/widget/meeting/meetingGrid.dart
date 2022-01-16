import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:byule/model/meetingModel.dart';

import 'meetingGridItem.dart';


Widget meetingGrid (List<MeetingModel> meetingList, String uid) {
  final options = LiveOptions(showItemInterval: Duration(milliseconds: 100),showItemDuration: Duration(milliseconds: 500),);
  return LiveGrid.options(
    options: options,
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