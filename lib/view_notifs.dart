import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/error_page.dart';
import 'package:sunshine_cleanest/a_notification.dart';

class ViewNotifs extends StatefulWidget {
  const ViewNotifs({super.key});

  @override
  State<ViewNotifs> createState() => _ViewNotifsState();
}

class _ViewNotifsState extends State<ViewNotifs> {
  DatabaseReference ref = FirebaseDatabase.instance.ref('Notifications');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DEVICE_TOKEN,
          )
        ],
      ),
      body: FutureBuilder(
          future: ref.once(DatabaseEventType.value),
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasData) {
              DatabaseEvent event = snapshot.data!;
              List notifications = event.snapshot.value as List;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, int index) {
                      Map notifData = notifications[index];
                      String notifTitle = notifData['title'];
                      String notifDate = notifData['date'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.black.withAlpha(128)),
                              borderRadius: BorderRadius.circular(50)),
                          child: FilledButton.tonal(
                              // style: FilledButton.styleFrom(shape:OutlinedBorder),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ANotification(notifData)));
                              },
                              // style: ButtonStyle(backgroundColor: FilledButtonTheme),
                              child: ListTile(
                                title: Text(notifTitle),
                                subtitle: Text(
                                    DateFormat.yMMMMd()
                                        .format(DateTime.parse(notifDate)),
                                    style: TextStyle(
                                        color: Colors.black.withAlpha(160))),
                                trailing: const Icon(
                                    Icons.keyboard_arrow_right_outlined),
                              )),
                        ),
                      );
                    },
                    separatorBuilder: (context, int index) =>
                        const Divider(height: 0),
                    itemCount: notifications.length),
              );
            } else if (snapshot.hasError) {
              return const ErrorPage("Notification List");
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
