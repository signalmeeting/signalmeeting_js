import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/util/style/appColor.dart';
import 'package:signalmeeting/util/style/btStyle.dart';

class MainDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final Widget contents;
  final VoidCallback onPressed;
  final Color buttonColor = AppColor.main200;

  const MainDialog({Key key, this.title, this.buttonText, this.contents, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(17)), color: const Color(0xffffffff)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontFamily: "AppleSDGothicNeoB",),),
              SizedBox(height: 20,),
              contents,
              SizedBox(
                height: Get.width*0.11,
                child: TextButton(
                  onPressed: onPressed,
                  child: Text(buttonText, style: TextStyle(color: buttonColor, fontFamily: "AppleSDGothicNeoM",),),
                  style: BtStyle.textDialog,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}