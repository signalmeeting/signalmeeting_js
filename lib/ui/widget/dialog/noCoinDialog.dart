import 'package:flutter/material.dart';
import 'package:byule/ui/drawer/store_page.dart';
import 'package:byule/ui/widget/dialog/confirm_dialog.dart';
import 'notification_dialog.dart';
import 'package:get/get.dart';

class NoCoinDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ConfirmDialog(
      title: "하트 부족",
      text: '하트가 부족합니다.\n스토어로 이동하시겠습니까?',
      confirmText: "이동",
      onConfirmed: () => Get.to(() => StorePage(), transition: Transition.rightToLeftWithFade),
    );
  }
}
