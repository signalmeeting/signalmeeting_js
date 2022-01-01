import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_dialog.dart';

class NotificationDialog extends StatelessWidget {
  final String title;
  final String contents;
  final VoidCallback onPressed;

  NotificationDialog({this.title, this.contents, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: title ?? "알림",
      contents: Center(child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(contents),
      )),
      buttonText: "확인",
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}


