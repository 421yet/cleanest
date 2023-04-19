import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sunshine_cleanest/chat_room.dart';
import 'package:sunshine_cleanest/error_page.dart';

class ChatRoomsList extends StatefulWidget {
  const ChatRoomsList({super.key});

  @override
  State<ChatRoomsList> createState() => _ChatRoomsListState();
}

class _ChatRoomsListState extends State<ChatRoomsList> {
  @override
  Widget build(BuildContext context) {
    DatabaseReference chatsRef = FirebaseDatabase.instance.ref("Chats");
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
          future: chatsRef.once(DatabaseEventType.value),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const ErrorPage(
                  "List of Chats: Probably due to connection?");
            }
            if (snapshot.hasData) {
              DatabaseEvent event = snapshot.data as DatabaseEvent;
              Map sonnims = event.snapshot.value as Map;
              return ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: sonnims.length,
                  itemBuilder: (context, int index) {
                    String sonnimUID = sonnims.keys.toList()[index];
                    DatabaseReference sonnimNameRef = FirebaseDatabase.instance
                        .ref("Sonnims")
                        .child(sonnimUID)
                        .child("name");
                    return ListTile(
                        title: FutureBuilder(
                            future: sonnimNameRef.once(DatabaseEventType.value),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const ErrorPage(
                                    "Couldn't load sonnim name.");
                              }
                              if (snapshot.hasData) {
                                DatabaseEvent event =
                                    snapshot.data as DatabaseEvent;
                                String sonnimName =
                                    event.snapshot.value as String;
                                return FilledButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return ChatRoom(inputUID: sonnimUID);
                                      }));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // const SizedBox(width: 20),
                                        Text(sonnimName),
                                        const Icon(
                                            Icons.keyboard_arrow_right_rounded)
                                      ],
                                    ));
                              } else {
                                return const Center(
                                    child: RefreshProgressIndicator());
                              }
                            }));
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
