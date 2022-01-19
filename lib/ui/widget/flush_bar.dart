import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

///IOS 에서는 Flushbar error 가 나서 이런식으로 써버림 ㅎ,,
void CustomedFlushBar(BuildContext context, String text) {
  // Get.snackbar('', text);
  Get.rawSnackbar(message: text,
    backgroundColor: Colors.black.withOpacity(0.7),
    margin: EdgeInsets.all(8),
    borderWidth: 8,
    borderRadius: 8,
    duration: Duration(seconds: 2),);
  // if(Platform.isAndroid) {
  //   return Flushbar(
  //     backgroundColor: Colors.black.withOpacity(0.7),
  //     margin: EdgeInsets.all(8),
  //     borderWidth: 8,
  //     borderRadius: BorderRadius.all(Radius.circular(8)),
  //     message: text,
  //     duration: Duration(seconds: 2),
  //   )..show(context);
  // } else {
  //   print('??????????????');
  //   showTopSnackBar(
  //     context,
  //     CustomSnackBar.success(
  //       message:
  //       "Good job, your release is successful. Have a nice day",
  //     ),
  //   );
  // }

}