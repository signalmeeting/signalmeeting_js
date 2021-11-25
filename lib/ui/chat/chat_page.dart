import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signalmeeting/controller/chat_controller.dart';
import 'package:signalmeeting/model/messageModel.dart';
import 'package:signalmeeting/services/database.dart';

class Themes {
  static final ThemeData kIOSTheme = new ThemeData(
      primarySwatch: Colors.orange,
      primaryColor: Colors.grey[100],
      primaryColorBrightness: Brightness.light);

  static final ThemeData kDefaultTheme = new ThemeData(
      primaryColor: Colors.purple, accentColor: Colors.orangeAccent[400]);

  static ThemeData getTheme(BuildContext context) {
    return isiOS(context) ? Themes.kIOSTheme : Themes.kDefaultTheme;
  }

  static double getElevation(BuildContext context) =>
      isiOS(context) ? 0.0 : 4.0;

  static bool isiOS(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS;
}

class Constants {
  static const String APP_NAME = "FlutterChat";
  static const String MESSAGES_TABLE = "messages";
  static const String SEND_MESSAGE_HINT = "Send a message";
  static const String SEND = "Send";
}

class Message {
  static const String TEXT = 'text';
  static const String IMAGE_URL = 'imageUrl';
  static const String SENDER_NAME = 'senderName';
  static const String SENDER_PHOTO_URL = 'senderPhotoUrl';
}

class Analytics {
  static const String SEND_MESSAGE_EVENT = "send_message";
}

class ChatPage extends StatefulWidget {

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatController _chatController = Get.find(tag: Get.arguments);

  final TextEditingController _textController = new TextEditingController();

  DatabaseReference get reference => _chatController.messagesRef;

  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: buildFirebaseList(),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
            ],
          ),
        ));
  }

  FirebaseAnimatedList buildFirebaseList() {
    return new FirebaseAnimatedList(
        query: reference,
        sort: (a, b) => b.key.compareTo(a.key),
        padding: new EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, __) {
          print(snapshot.value);
          return ChatMessage(message: MessageModel.fromJson(jsonDecode(jsonEncode(snapshot.value))), animation: animation);
        });
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: buildTakePhotoButton(),
            ),
            new Flexible(
              child: buildSendTextField(),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: buildSendButton(),
            ),
          ])),
    );
  }

  Widget buildTakePhotoButton() {
    return new IconButton(
        icon: new Icon(Icons.photo_camera),
        onPressed: onTakePhotoButtonPressed);
  }

  TextField buildSendTextField() {
    return new TextField(
      controller: _textController,
      onSubmitted: _isComposing ? _onSendMessageButtonPressed : null,
      onChanged: _handleChanged,
      decoration:
      new InputDecoration.collapsed(hintText: Constants.SEND_MESSAGE_HINT),
    );
  }

  Widget buildSendButton() {
    return Themes.isiOS(context)
        ? new CupertinoButton(
        child: new Text(Constants.SEND),
        onPressed: () => _onSendMessageButtonPressed(_textController.text))
        : new IconButton(
        icon: new Icon(Icons.send),
        onPressed: () => _onSendMessageButtonPressed(_textController.text));
  }

  Future onTakePhotoButtonPressed() async {
    File imageFile = await ImagePicker.pickImage();
    String imageFileName = createImageFileName();
    String downloadUrl = await uploadPhoto(imageFileName, imageFile);
    _sendMessage(imageUrl: downloadUrl);
  }

  Future<String> uploadPhoto(String imageFileName, File imageFile) async {
    Reference reference =
    FirebaseStorage.instance.ref().child(imageFileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    String downloadUrl;
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL().then((fileURL) {
        downloadUrl = fileURL;
      });
    });
    return downloadUrl;
  }

  Future<Null> _onSendMessageButtonPressed(String text) async {
    if (_isComposing) {
      _textController.clear();
      setState(() {
        _isComposing = false;
      });
      // await _ensureLoggedIn();
      _sendMessage(text: text);
    }
  }

  void _sendMessage({String text, String imageUrl}) {
    _chatController.sendMessage(text);
    // analytics.logEvent(name: Analytics.SEND_MESSAGE_EVENT);
  }

  void _handleChanged(String text) {
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  String createImageFileName() {
    int random = new Random().nextInt(100000);
    return "image_$random.jpg";
  }
}

class ChatMessage extends StatelessWidget {
  final MessageModel message;
  final Animation animation;

  ChatMessage({this.message, this.animation});

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor:
        new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: buildMessageRow(context),
        ));
  }

  Row buildMessageRow(BuildContext context) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // new Container(
        //   margin: const EdgeInsets.only(right: 16.0),
        //   child: buildAvatar(),
        // ),
        new Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildSenderNameText(context),
              buildMessageBody()
            ],
          ),
        )
      ],
    );
  }

  CircleAvatar buildAvatar() {
    return new CircleAvatar(
      // backgroundImage:
      // new NetworkImage(message),
    );
  }

  Text buildSenderNameText(BuildContext context) {
    return new Text(message.sender,
        style: Theme.of(context).textTheme.subhead);
  }

  Container buildMessageBody() {
    return new Container(
      margin: const EdgeInsets.only(top: 5.0),
      child:
      // message.value[Message.IMAGE_URL] != null
      //     ? buildMessagePhoto():
      buildMessageText(),
    );
  }

  Text buildMessageText() => new Text(message.text);

// Widget buildMessagePhoto() =>
//     new Image.network(snapshot.value[Message.IMAGE_URL], width: 250.0);
}