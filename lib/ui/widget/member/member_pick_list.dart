import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/drawer/my_profile_page.dart';
import 'package:byule/ui/meeting/make_meeting_page.dart';
import 'package:byule/ui/member/member_edit_page.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:byule/util/style/appColor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class MemberPickList extends StatelessWidget {
  final RxList pickedMemberIndexList;
  final Function onTap;
  MemberPickList(this.pickedMemberIndexList, this.onTap);

  final MainController _mainController = Get.find();
  UserModel get _user => _mainController.user.value;

  final double _avatarRadius = Get.width * 0.13 / 2 - 1;
  final double _spaceSize = Get.width * 0.04;

  List<MemberModel> get _memberList => _user.memberList ?? [];


  @override
  Widget build(BuildContext context) {

    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Obx(
          () {
            if (_memberList.isNotEmpty) {

            }
            return ReorderableWrap(
              footer: memberAddAvatar(),
              spacing: _spaceSize,
              runSpacing: _spaceSize,
              // padding: const EdgeInsets.all(8),
              children: [
                if (_memberList.isNotEmpty)
                  for (int i = 0; i < _memberList.length; i++) memberAvatar(i),
              ],
              onReorder: (int oldIndex, int newIndex) {
                _mainController.reorderMember(oldIndex, newIndex);
              },
              onNoReorder: (int index) {
                //this callback is optional
                debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
              },
              onReorderStarted: (int index) {
                //this callback is optional
                debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
              });
          },
        ),
      ],
    );

    return SingleChildScrollView(
      child: column,
    );
  }

  Widget memberAvatar(int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: pickedMemberIndexList.contains(index) ? AppColor.sub300 : Colors.grey),
            ),
            child: cachedImage(
              _memberList[index].url ?? '',
              width: _avatarRadius * 2,
              height: _avatarRadius * 2,
              radius: 6,
            ),
          ),
        ),
        pickedMemberIndexList.contains(index) ? Positioned(
          right: 1,
          top: 1,
          child: GestureDetector(
            onTap: () => Get.to(() => MemberEditPage(_memberList[index], true, pickedMemberIndexList)),
            child: Container(
              width: 20,
              height: 20,
              // color: Colors.,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(6)),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Image.asset(
                  'assets/member_edit.png',
                  fit: BoxFit.fitWidth,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ) : Container(width:0, height: 0),
      ],
    );
  }

  Widget memberAddAvatar() {
    return GestureDetector(
      onTap: () => Get.to(() => MemberEditPage(MemberModel(index: _memberList.length), false, pickedMemberIndexList)),
      child: Container(
        width: _avatarRadius * 2 + 2,
        height: _avatarRadius * 2 + 2,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey)),
        child: Icon(Icons.add, color: Colors.grey),
        // child: Icon(Icons.add, color: Colors.grey),
      ),
    );
  }
}
