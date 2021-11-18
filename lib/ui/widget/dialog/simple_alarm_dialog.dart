import 'package:flutter/material.dart';
import 'main_dialog.dart';

class SimpleAlarmDialog extends StatelessWidget {
  final String title;
  final String buttonText;

  const SimpleAlarmDialog({Key key, this.title, this.buttonText}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: title,
      buttonText: buttonText,
      contents: reportContents(),
      onPressed: () {},
    );
  }

  Widget reportContents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                reportReasonText('개별 연락처 기재'),
                reportReasonText('개인정보 노출'),
                reportReasonText('부적절한 사진 업로드'),
                reportReasonText('기타 적절하지 않은 내용 포함'),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Text('위에 해당하는 경우 신고해주시기 바랍니다', style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
        ),
      ],
    );
  }

  Widget reportReasonText(String text) {
    Widget dot = Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
          width: 5,
          height: 5,
          decoration: new BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
          )),
    );
    return Row(
      children: [dot, Text(text, style: TextStyle(color: Colors.black.withOpacity(0.7)),),],
    );
  }
}
