import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextFieldController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;
  String textMessage = '';

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;

      if (user == null) {
        signOut();
        return;
      }

      setState(() {
        loggedInUser = user;
      });
    } catch (error) {
      print('Error on getCurrentUser: $error');
    }
  }

  void signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushNamed(context, WelcomeScreen.id);
    } catch (error) {
      print('Error on signOut: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                signOut();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(user: loggedInUser),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextFieldController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        textMessage = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextFieldController.clear();

                      _firestore.collection('messages').add({
                        'text': textMessage,
                        'sender': loggedInUser!.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final User? user;

  MessagesStream({required this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        List<MessageBubble> messageWidgets = [];

        snapshot.data?.docs.forEach((item) {
          Map<String, dynamic> message = item.data() as Map<String, dynamic>;

          if (message['text'] != '' && message['text'] != null) {
            messageWidgets.add(
              MessageBubble(
                sender: message['sender'] ?? '',
                text: message['text'] ?? '',
                isMe: user?.email == message['sender'],
              ),
            );
          }
        });

        return Expanded(
          child: ListView(
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMe;

  MessageBubble({
    required this.text,
    required this.sender,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 8.0,
          left: isMe ? 120.0 : 8.0,
          right: isMe ? 8.0 : 120.0,
          top: 8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '$sender',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            textStyle: TextStyle(color: Colors.white),
            elevation: 2.0,
            borderRadius: BorderRadius.circular(12.0),
            color: isMe ? Colors.lightBlueAccent : Colors.grey,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '$text',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
