// import 'package:byule/model/memberModel.dart';
// import 'package:byule/ui/drawer/my_profile_page.dart';
// import 'package:byule/ui/member/member_edit_page.dart';
// import 'package:byule/ui/widget/cached_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:reorderables/reorderables.dart';
//
// class MemberMyMeetingList extends StatefulWidget {
//   final int number;
//   MemberMyMeetingList(this.number);
//
//   @override
//   _MemberMyMeetingListState createState() => _MemberMyMeetingListState();
// }
//
// class _MemberMyMeetingListState extends State<MemberMyMeetingList> {
//   final double _avatarRadius = Get.width*0.13 / 2;
//   final double _spaceSize = Get.width*0.04;
//   List<Widget> _tiles;
//
//   @override
//   void initState() {
//     super.initState();
//     _tiles = <Widget>[
//       for(int i = 0; i < widget.number-1 ; i++)
//         memberAvatar(''),
//       memberAddAvatar(),
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     setState(() {
//       _tiles = <Widget>[
//         for(int i = 0; i < widget.number-1; i++)
//           memberAvatar(''),
//         memberAddAvatar(),
//       ];
//     });
//
//     void _onReorder(int oldIndex, int newIndex) {
//       setState(() {
//         Widget row = _tiles.removeAt(oldIndex);
//         _tiles.insert(newIndex, row);
//       });
//     }
//
//     var wrap = ReorderableWrap(
//         spacing: _spaceSize,
//         runSpacing: _spaceSize,
//         // padding: const EdgeInsets.all(8),
//         children: _tiles,
//         onReorder: _onReorder,
//         onNoReorder: (int index) {
//           //this callback is optional
//           debugPrint('${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
//         },
//         onReorderStarted: (int index) {
//           //this callback is optional
//           debugPrint('${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
//         }
//     );
//
//     var column = Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         wrap,
//         // ButtonBar(
//         //   alignment: MainAxisAlignment.start,
//         //   children: <Widget>[
//         //     IconButton(
//         //       iconSize: 50,
//         //       icon: Icon(Icons.add_circle),
//         //       color: Colors.deepOrange,
//         //       padding: const EdgeInsets.all(0.0),
//         //       onPressed: () {
//         //         var newTile = Icon(Icons.filter_9_plus, size: _iconSize);
//         //         setState(() {
//         //           _tiles.add(newTile);
//         //         });
//         //       },
//         //     ),
//         //     IconButton(
//         //       iconSize: 50,
//         //       icon: Icon(Icons.remove_circle),
//         //       color: Colors.teal,
//         //       padding: const EdgeInsets.all(0.0),
//         //       onPressed: () {
//         //         setState(() {
//         //           _tiles.removeAt(0);
//         //         });
//         //       },
//         //     ),
//         //   ],
//         // ),
//       ],
//     );
//
//     return SingleChildScrollView(
//       child: column,
//     );
//   }
//
//   Widget memberAvatar(String imageUrl) {
//     return GestureDetector(
//       onTap: () => Get.to(() => MyProfilePage()),
//       child: cachedImage(
//         imageUrl,
//         width: _avatarRadius * 2,
//         height: _avatarRadius * 2,
//         radius: 7,
//       ),
//     );
//   }
//
//   Widget memberAddAvatar() {
//     return GestureDetector(
//       onTap: () => Get.to(() => MemberEditPage(MemberModel(), false,)),
//       child: Container(
//         width: _avatarRadius * 2,
//         height: _avatarRadius * 2,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(7),
//         border: Border.all(color: Colors.grey)),
//         child: Icon(Icons.add, color: Colors.grey),
//         // child: Icon(Icons.add, color: Colors.grey),
//       ),
//     );
//   }
// }
//
