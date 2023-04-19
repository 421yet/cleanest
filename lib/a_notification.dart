import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/current_user.dart';

import 'chat_room.dart';
import 'constants.dart';

class ANotification extends StatefulWidget {
  final Map data;
  final bool isEmbed;

  const ANotification(this.data, {super.key, this.isEmbed = false});

  @override
  State<ANotification> createState() => _ANotificationState();
}

class _ANotificationState extends State<ANotification> {
  DatabaseReference ref =
      FirebaseDatabase.instance.ref("Notifications").child("");
  CurrentUser currentUser = CurrentUser();
  @override
  Widget build(BuildContext context) {
    String date =
        DateFormat.yMMMMd().format(DateTime.parse(widget.data['date']));
    String title = widget.data['title'];
    String body = widget.data['body'];

    return Scaffold(
      appBar: AppBar(
        title: Text('On $date,'),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (DragEndDetails ded) {
          if (ded.primaryVelocity! < 0) {
            // if shit is going up?
            // TODO throw sunflower! (seeds?)
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 32, right: 32, top: 32, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: DEFAULT_BORDER),
                              borderRadius: BorderRadius.circular(50),
                              color: DEFAULT_BGwHILITE),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: DEFAULT_BORDER),
                              borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Text(body))
                    ],
                  ),
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                          "Have questions or concerns about this notification?",
                          style: TextStyle(
                              color: DEFAULT_FADEDTXT,
                              fontStyle: FontStyle.italic)),
                    ),
                    OutlinedButton(
                        onPressed: (currentUser.getUser()!.uid == ADMIN_UID) ||
                                (widget.isEmbed)
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ChatRoom(concern: widget.data)));
                              },
                        child: const Text("Message us about it!",
                            style: TextStyle())),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
