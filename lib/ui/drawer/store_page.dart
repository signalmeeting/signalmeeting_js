import 'package:byule/ui/drawer/invite_friends_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:byule/controller/main_controller.dart';

class StorePage extends StatelessWidget {

  MainController _mainConroller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          highlightColor: Colors.white,
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          '스토어',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.favorite, color: Colors.redAccent,),
                Container(
                  width: 5,
                ),
                GetX<MainController>(
                  builder: (_) {
                    String coin = _.user.value.coin.toString();
                    return Text(
                      coin,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
          ),
          ScrollConfiguration(
            behavior: ScrollBehavior(),
            child: GlowingOverscrollIndicator(
              axisDirection: AxisDirection.down,
              color: Colors.white,
              child: ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ItemTile(10, '3,900'),
                      ItemTile(30, '9,500'),
                      ItemTile(50, '14,500'),
                      ItemTile(110, '29,500'),
                      inviteFriendTile()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ItemTile(number, price) {
    return GestureDetector(
      onTap: () {
        print("ontap item");
        _mainConroller.inAppManager.requestPurchase("coin$number");
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 0, left: 18, right: 18),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 10),
                      child: Icon(Icons.favorite, color: Colors.red[200],),
                    ),
                    Text(
                      '$number',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Text(
                    '$price 원',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget inviteFriendTile() {
    return GestureDetector(
      onTap: () => Get.to(() => InviteFriendsPage()),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 0, left: 18, right: 18),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 18.0, right: 10),
                      child: Icon(Icons.favorite, color: Colors.blue[200],),
                    ),
                    Text(
                      '20',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: Text(
                    '친구 초대',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
