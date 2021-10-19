import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColoredButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  ColoredButton({this.text, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      highlightColor: Colors.transparent,
      minWidth: Get.width * 0.9,
      height: 40.0,
      child: RaisedButton(
        disabledElevation: 2,
        focusElevation: 2,
        elevation: 2,
        hoverElevation: 2,
        highlightElevation: 2,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        onPressed: onPressed,
      ),
    );
  }
}