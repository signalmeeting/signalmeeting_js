import 'package:flutter/material.dart';
import 'package:byule/controller/main_controller.dart';
import 'package:byule/services/database.dart';
import 'package:byule/ui/meeting/meeting_detail_page.dart';
import 'package:byule/ui/widget/flush_bar.dart';
import 'package:get/get.dart';
import 'main_dialog.dart';

enum ReportType {daily, meeting}

class ReportDialog extends StatelessWidget {
  final MainController _mainController = Get.find();
  final MeetingDetailController meetingDetailController;

  final String uidOrId;
  final ReportType reportType;
  ReportDialog(this.uidOrId, this.reportType, {this.meetingDetailController});

  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: '신고 및 차단하기',
      buttonText: '신고 및 차단하기',
      contents: reportContents(),
      onPressed: () async {
        Get.back();
        Get.back();
        DatabaseService.instance.updateBanList(_mainController.user.value.uid, uidOrId, reportType);
        _mainController.updateBanList(_mainController.user.value.uid, uidOrId, reportType, meetingDetailController);
        CustomedFlushBar(Get.context, '신고 및 차단이 접수되었습니다 \n신고당한 계정은 3회 이상 신고시 앱이용이 정지됩니다. ');
      },
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
