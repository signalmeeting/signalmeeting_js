import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget CustomedFlushBar(BuildContext context, String text) {
  return Flushbar(
    backgroundColor:
    Colors.black.withOpacity(0.7),
    margin: EdgeInsets.all(8),
    borderRadius: 8,
    message: text,
    duration: Duration(seconds: 2),
  )..show(context);
}