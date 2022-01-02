import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/controller/main_controller.dart';

import 'dialog/notification_dialog.dart';


Widget deletedUser({double size, Function onPressed}) {
  if(size == null)
    size = Get.height * 0.17;
  MainController _controller = Get.find();
  return GestureDetector(
    onTap: () {
      Get.dialog(NotificationDialog(contents: '죄송합니다. 상대의 회원 탈퇴 혹은 기타 사유로 카드를 열람하실 수 없습니다', onPressed: onPressed,));
    },
    // Get.defaultDialog(title: '시그널팅',
    //     middleText: '죄송합니다. 상대의 회원 탈퇴 혹은 기타 사유로 카드를 열람하실 수 없습니다'),
    child: Obx(
      () => Container(
        width: size,
        height: size,
        color: !_controller.user.value.man
            ? Colors.blue[100].withOpacity(0.1)
            : Colors.red[100].withOpacity(0.1),
        child: Icon(Icons.favorite, color: Colors.red[50], size: size*0.4,),
      ),
    ),
  );
}