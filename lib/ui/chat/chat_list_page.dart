import 'package:flutter/material.dart';
import 'package:signalmeeting/model/chatListModel.dart';
import 'package:signalmeeting/ui/widget/cached_image.dart';

class ChatListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container();
//      InfiniteList(
//      body: {'id': _c.account.id, 'type': 0},
//      pageToken: 0,
//      uri: 'chatLists',
//      items: List<ChatListModel>.from(_c.chatList),
//      itemParser: (item) => ChatListModel.fromJson(item),
//      buildItem: (item) => buildChatItem(item, context),
//      setItems: (items) => _c.chatList.assignAll(items),
//    );
  }

//  exitChatting(BuildContext context, String userId) => Alert.alert(context, '알림', '상대방이 방을 나갔습니다.', callback: () async {
//        await store.exitChatting(context, userId);
//      });

  Widget buildChatItem(ChatListModel item, BuildContext context) {
    return InkWell(
//      onTap: () => onPressChatItem(context, item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4.0),
                    child: Hero(
                        tag: 'chatList_Image_' + item.id,
                        child:
//                        item.oppositeExit
//                            ? Padding(
//                                padding: EdgeInsets.only(right: 10.0),
//                                child: Image(image: AssetImage("assets/images/placeholder.png"), width: 55, height: 55),
//                              )
//                            :
                            cachedImage(
                          item.oppositePic,
                          width: 55,
                          height: 55,
                          radius: 55 / 2,
                        ))),
                SizedBox(width: 4.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.oppositeName,
                        style: TextStyle(
//                          color: Color(item.oppositeExit ? 0xff797979 : 0xff091114),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item.link,
                        style: TextStyle(
//                          color: Color(item.oppositeExit ? 0xff797979 : 0xff091114),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
                width: double.infinity,
                height: 1,
                decoration: new BoxDecoration(color: Color(0xffefefef), borderRadius: BorderRadius.circular(1)))
          ],
        ),
      ),
    );
  }
}
