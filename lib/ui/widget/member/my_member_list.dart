import 'package:byule/controller/main_controller.dart';
import 'package:byule/model/memberModel.dart';
import 'package:byule/model/userModel.dart';
import 'package:byule/ui/drawer/my_profile_page.dart';
import 'package:byule/ui/member/member_edit_page.dart';
import 'package:byule/ui/widget/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';

class MyMemberList extends StatefulWidget {
  @override
  _MyMemberListState createState() => _MyMemberListState();
}

class _MyMemberListState extends State<MyMemberList> {
  final MainController _mainController = Get.find();

  UserModel get _user => _mainController.user.value;

  final double _avatarRadius = Get.width * 0.13 / 2;
  final double _spaceSize = Get.width * 0.04;

  List<MemberModel> get _memberList => _user.memberList ?? [];

  List<Widget> _tiles;

  @override
  void initState() {
    super.initState();
    _tiles = <Widget>[
      if (_memberList.isNotEmpty)
        for (int i = 0; i < _memberList.length; i++) memberAvatar(i),
      memberAddAvatar(),
    ];
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      Widget row = _tiles.removeAt(oldIndex);
      _tiles.insert(newIndex, row);
    });
  }

  @override
  Widget build(BuildContext context) {

    var wrap = ReorderableWrap(
        spacing: _spaceSize,
        runSpacing: _spaceSize,
        // padding: const EdgeInsets.all(8),
        children: _tiles,
        onReorder: _onReorder,
        onNoReorder: (int index) {
          //this callback is optional
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
        },
        onReorderStarted: (int index) {
          //this callback is optional
          debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
        });

    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        wrap,
      ],
    );

    return SingleChildScrollView(
      child: column,
    );
  }

  Widget memberAvatar(int index) {
    return GestureDetector(
      onTap: () => Get.to(() => MemberEditPage(_memberList[index])),
      child: cachedImage(
        _memberList[index].url ?? '',
        width: _avatarRadius * 2,
        height: _avatarRadius * 2,
        radius: 7,
      ),
    );
  }

  Widget memberAddAvatar() {
    return GestureDetector(
      onTap: () => Get.to(() => MemberEditPage(MemberModel(index: _memberList.length ))),
      child: Container(
        width: _avatarRadius * 2,
        height: _avatarRadius * 2,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.grey)),
        child: Icon(Icons.add, color: Colors.grey),
        // child: Icon(Icons.add, color: Colors.grey),
      ),
    );
  }
}
