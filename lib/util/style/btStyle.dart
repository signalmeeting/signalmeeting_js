import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/util/style/appColor.dart';

class BtStyle {
  BtStyle._();

  static ButtonStyle get mainBtStyle => TextButton.styleFrom(
    primary: AppColor.main,
    side: BorderSide(color: AppColor.main, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100.0),
    ),
    // overlayColor: MaterialStateProperty.all(Colors.grey[200]),
    elevation: 0,
    minimumSize: Size(Get.width*0.55, Get.width*0.11),

  );
}