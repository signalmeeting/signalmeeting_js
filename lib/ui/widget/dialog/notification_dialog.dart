import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_dialog.dart';

class NotificationDialog extends StatelessWidget {
  final String title;
  final String contents;
  final String contents2;
  final VoidCallback onPressed;
  final String buttonText;

  NotificationDialog({this.title, this.contents, this.onPressed, this.contents2, this.buttonText});

  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: title ?? "알림",
      contents: Center(child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: (contents2 == null) ? Text(contents) : Column(children: <Widget>[Text(contents),SizedBox(height: 16,), Text(contents2)],),
      )),
      buttonText: buttonText??'확인',
      onPressed: onPressed ?? () => Get.back(),
    );
  }
}


