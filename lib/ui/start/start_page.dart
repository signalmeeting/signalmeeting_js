import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/ui/start/start_page_2.dart';
import 'package:signalmeeting/util/style/appColor.dart';
import 'package:signalmeeting/util/style/btStyle.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.3,0.6],
                    colors: [AppColor.sub200, AppColor.sub100]
                )
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Image.asset('assets/start_page.png')),
              //로고 이미지(임시)
              Padding(
                padding: const EdgeInsets.only(bottom: 25, left: 25, right: 25),
                child: ButtonTheme(
                  minWidth: Get.width*0.9,
                  height: 50.0,
                  child: TextButton(
                    child: Text(
                      '전화번호로 계속',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16
                      ),
                    ),
                    onPressed: () => Get.to(() => StartPage2()),
                    style: BtStyle.splash,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
