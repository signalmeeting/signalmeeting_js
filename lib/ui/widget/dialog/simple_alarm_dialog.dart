import 'package:flutter/material.dart';
import 'main_dialog.dart';

class SimpleAlarmDialog extends StatelessWidget {
  final String title;
  final String buttonText;
  final String mainText;

  const SimpleAlarmDialog(this.title, this.buttonText, this.mainText);


  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: title,
      buttonText: buttonText,
      contents: contents(mainText),
      onPressed: () {},
    );
  }

  Widget contents(String mainText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mainText)
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

}
