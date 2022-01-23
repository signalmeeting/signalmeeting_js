import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:byule/model/meetingModel.dart';
import 'package:get/get.dart';

import 'meetingGridItem.dart';

double innerPadding = 3;
double crossAxisSpacing = 0;
double cardPadding = 4;
double imageSize = (Get.width*0.96 - innerPadding*4 - crossAxisSpacing -cardPadding*2)/2;

Widget meetingGrid (List<MeetingModel> meetingList, String uid) {

  final options = LiveOptions(showItemInterval: Duration(milliseconds: 200),showItemDuration: Duration(milliseconds: 500),);
  return LiveGrid.options(
    options: options,
    shrinkWrap: true,
    itemCount: meetingList.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisExtent: imageSize + innerPadding*2 + 60,
      crossAxisSpacing: crossAxisSpacing,
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