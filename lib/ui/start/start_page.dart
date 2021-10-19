import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signalmeeting/ui/start/start_page_2.dart';

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
                    colors: [Colors.blue[200], Colors.blue[100]]
                )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Image.asset('assets/start_page.png')),
              //로고 이미지(임시)
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: ButtonTheme(
                  minWidth: Get.width*0.9,
                  height: 50.0,
                  child: RaisedButton(
                    highlightElevation: 0,
                    elevation: 0,
                    child: Text(
                      '전화번호로 계속',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16
                      ),
                    ),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    onPressed: ()  => Get.to(() => StartPage2()),
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
