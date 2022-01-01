import 'package:flutter/material.dart';

Widget drawerAppBar(BuildContext context, title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      highlightColor: Colors.white,
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        color: Colors.black,
      ),
    ),
  );
}
