import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_dialog.dart';

class MeetingLetterDialog extends StatelessWidget {
  final String letter;
  MeetingLetterDialog(this.letter);

  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: '소개',
      buttonText: '확인',
      contents: meetingLetterContents(),
      onPressed: () => Get.back(),
    );
  }

  Widget meetingLetterContents() {
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
                Text(letter, style: TextStyle(color: Colors.black.withOpacity(0.7)),),
              ],
            ),
          ),
        ),
        SizedBox(height: 16,),
      ],
    );
  }

}
