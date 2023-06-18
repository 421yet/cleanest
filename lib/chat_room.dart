import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sunshine_cleanest/current_user.dart';
import 'package:sunshine_cleanest/send_push_message.dart';

import 'constants.dart';
import 'error_page.dart';

class ChatRoom extends StatefulWidget {
  final String inputUID;
  final Map concern;
  const ChatRoom({super.key, this.inputUID = "", this.concern = const {}});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  CurrentUser currentUser = CurrentUser();
  TextEditingController tec = TextEditingController();
  bool isAdmin = false;
  List _chatLog = [];
  bool isFilled = false;
  String messageBody = "";
  String uid = "";
  late DatabaseReference chatsRef;
  late StreamSubscription<DatabaseEvent> listener;

  @override
  void initState() {
    uid = widget.inputUID;
    if (uid.isEmpty) {
      uid = currentUser.getUser()!.uid;
    } else {
      isAdmin = true;
    }

    chatsRef = FirebaseDatabase.instance.ref("Chats").child(uid);
    listener = chatsRef.onValue.listen((DatabaseEvent event) {
      final List chats = event.snapshot.value as List;
      if (mounted) {
        setState(() {
          _chatLog = chats;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.vertical;

    double chatHeight = height * 8.22 / 10;
    // double MESSAGE_HEIGHT = height - CHAT_HEIGHT;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              listener.cancel();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                    GET_MAX_HEIGHT(context) - AppBar().preferredSize.height),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                      future: chatsRef.once(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const ErrorPage("Chat Log");
                        } else if (snapshot.hasData) {
                          DatabaseEvent event = snapshot.data as DatabaseEvent;
                          _chatLog = event.snapshot.value as List;

                          return ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: chatHeight),
                            child: ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              shrinkWrap: true,
                              itemCount: _chatLog.length,
                              itemBuilder: (context, int index) {
                                Map chatData =
                                    _chatLog.reversed.toList()[index];
                                String senderUID =
                                    chatData['sender']; // TODO group by sender?
                                bool chatIsMine =
                                    senderUID == currentUser.getUser()!.uid;
                                String chatBody = chatData['body'];
                                EdgeInsets chatPadding =
                                    const EdgeInsets.all(8);
                                BoxDecoration chatDecoration =
                                    const BoxDecoration();
                                if (chatIsMine) {
                                  chatPadding = const EdgeInsets.only(
                                      left: 80, top: 8, bottom: 8);
                                  chatDecoration = BoxDecoration(
                                      border: Border.all(color: DEFAULT_BORDER),
                                      borderRadius: BorderRadius.circular(50));
                                } else {
                                  chatPadding = const EdgeInsets.only(
                                      right: 80, top: 8, bottom: 8);
                                  chatDecoration = BoxDecoration(
                                      border: Border.all(color: DEFAULT_BORDER),
                                      borderRadius: BorderRadius.circular(50),
                                      color: DEFAULT_BGwHILITE);
                                }
                                return Padding(
                                  padding: chatPadding,
                                  child: Container(
                                      decoration: chatDecoration,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(chatBody)),
                                );
                              },
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                        controller: tec,
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              if (value != "") {
                                isFilled = true;
                                messageBody = value;
                              } else {
                                isFilled = false;
                              }
                            });
                          }
                        },
                        // onTap: () { // TODO won't fix keyboard + textfield covering chat history
                        //   setState(() {
                        //     CHAT_HEIGHT -= MediaQuery.of(context).viewInsets.bottom;
                        //   });
                        // },
                        // onEditingComplete: () {
                        //   setState(() {
                        //     CHAT_HEIGHT += MediaQuery.of(context).viewInsets.bottom;
                        //   });
                        // },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding:
                              const EdgeInsets.only(left: 24, right: 24),
                          // labelText: "Message",
                          labelStyle: TextStyle(
                              color: Colors.black.withAlpha(128), fontSize: 15),
                          suffixIcon: IconButton(
                              onPressed: (messageBody.isEmpty)
                                  ? null
                                  : () {
                                      sendMessage(uid, messageBody,
                                          currentUser.getUser()!.uid);
                                      if (mounted) {
                                        setState(() {
                                          messageBody = "";
                                          tec.clear();
                                        });
                                      }
                                    },
                              icon: const Icon(Icons.send)),
                          suffixIconColor: Colors.cyan,
                          border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          )),
                        )),
                  )
                ]),
          ),
        ));
  }
}

void sendMessage(
    String chatOwnerUID, String messageBody, String senderUID) async {
  DatabaseReference chatRef =
      FirebaseDatabase.instance.ref("Chats").child(chatOwnerUID);
  int length = 0;
  await chatRef.once().then((DatabaseEvent event) {
    length = (event.snapshot.value as List).length;
  });
  await chatRef.update({
    length.toString(): {"body": messageBody, "sender": senderUID}
  });

  String token = ADMIN_TOKEN;
  String sender = "Sunshine Cleaners";
  DatabaseReference sonnimRef =
      FirebaseDatabase.instance.ref("Sonnims").child(chatOwnerUID);

  if (senderUID == ADMIN_UID) {
    DatabaseReference tokenRef = sonnimRef.child("token");
    await tokenRef.once().then((DatabaseEvent event) {
      token = event.snapshot.value as String;
    });
  } else {
    DatabaseReference nameRef = sonnimRef.child("name");
    await nameRef.once().then((DatabaseEvent event) {
      sender = event.snapshot.value as String;
    });
  }
  sendPushMessage(token, "New Message", "$sender has sent a new message.");
}
