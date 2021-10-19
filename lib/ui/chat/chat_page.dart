import 'package:flutter/material.dart';
import 'package:signalmeeting/ui/chat/chat_list_page.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {setState(() {});});
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 4.0,
              ),
              tabItem('소개팅', 0),
              tabItem('미팅', 1),
            ],
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController, children: <Widget>[ChatListPage(), ChatListPage()]),
          ),
        ],
      ),
    );
  }

  tabItem(String title, int index) => GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              color: _tabController.index == index ? Colors.black : Colors.grey,
              fontSize: 20,
            ),
          ),
        ),
      );
}
