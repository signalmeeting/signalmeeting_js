import 'package:byule/util/style/appColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_dialog.dart';

class MemberIntroduceDialog extends StatelessWidget {
  final String letter;
  MemberIntroduceDialog(this.letter);

  final GlobalKey<FormState> _textFormKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = letter;
    return MainDialog(
      title: '멤버 소개',
      buttonText: '완료',
      contents: memberIntroduceContents(),
      onPressed: () => Get.back(result: _textController.text),
    );
  }

  Widget memberIntroduceContents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Form(
            key: _textFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: TextFormField(
                    style: TextStyle(color: Colors.black.withOpacity(0.7)),
                    cursorColor: AppColor.main100,
                    controller: _textController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: letter != '' ?  null : '매력을 간단하게 소개해주세요!',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[200]),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey[200]),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 16,),
      ],
    );
  }

}
