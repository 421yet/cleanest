import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/send_push_message.dart';
// import 'package:flutter/foundation.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import 'current_user.dart';

// ignore: constant_identifier_names
const List<String> SEVENDAYS = <String>[
  'Sunday', // 0
  'Monday', // 1
  'Tuesday', // 2
  'Wednesday', // 3
  'Thursday', // 4
  'Friday', // 5
  'Saturday' // 6
];

Future<AlertDialog> _checknWrite(
    BuildContext context, CurrentUser currentUser, DateTime date) async {
  String uid = currentUser.getUser()!.uid;
  // String address = await currentUser.getAddress();
  // String name = await currentUser.getName();
  String dateString = date.toString().split(' ')[0];

  DatabaseReference preRef = FirebaseDatabase.instance.ref('Requests');
  DatabaseReference sonnimDateRef =
      FirebaseDatabase.instance.ref('Sonnims').child(uid);
  DatabaseEvent preEvent = await preRef.once(DatabaseEventType.value);
  Map<String, dynamic> preRequests =
      jsonDecode(jsonEncode(preEvent.snapshot.value)) as Map<String, dynamic>;
  preRef = preRef.child(dateString);
  if (preRequests.containsKey(dateString)) {
    preEvent = await preRef.once(DatabaseEventType.value);
    Map preUids = jsonDecode(jsonEncode(preEvent.snapshot.value)) as Map;
    preUids.remove(null);
    if (preUids.keys.contains(uid)) {
      return AlertDialog(
        title: const Text(
          'Hmm...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('A request already exists for'),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                child: Text(DateFormat('EEEE').format(date),
                    style: const TextStyle(fontSize: 30)),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Text(DateFormat('yMMMd').format(date),
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Please allow us some time to confirm your request.'),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'If you think this is a mistake, please give us a call.'),
            ),
          ],
        ),
        actions: <OutlinedButton>[
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    } // request already exists
  } // date is already populated
  await sonnimDateRef.update({'request': dateString});
  await preRef.update({uid: false});

  // now checking if DB actually updated . . .
  DatabaseReference postRef =
      FirebaseDatabase.instance.ref('Requests').child(dateString);
  DatabaseEvent postEvent = await postRef.once(DatabaseEventType.value);
  Map postUids = jsonDecode(jsonEncode(postEvent.snapshot.value)) as Map;
  postUids.remove(null);
  if (postUids.keys.contains(uid)) {
    return AlertDialog(
      title: const Text(
        'Hooray!',
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
      content: const Text('Your request was successful.'),
      actions: <OutlinedButton>[
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
    // TODO: check if there are any holidays
    // TODO: notify @owner
  } // found request
  return AlertDialog(
    title: const Text(
      'Hmm...',
      style: TextStyle(
        fontStyle: FontStyle.italic,
      ),
    ),
    content: const Text('Our system did not receive your request.\n'
        'If this error continues, please give us a call.'),
    actions: <OutlinedButton>[
      OutlinedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('OK'),
      ),
    ],
  );
}

Future<void> confirmDays(BuildContext context, CurrentUser currentUser) async {
  // read pick up days from server
  DatabaseReference ref = FirebaseDatabase.instance
      .ref('Sonnims')
      .child(currentUser.getUser()!.uid);
  final DatabaseEvent event =
      await ref.child('days').once(DatabaseEventType.value);
  List<String> days =
      (event.snapshot.value as String).split(','); // forcing strong cast

  // choose closest time
  DateTime now = DateTime.now();
  String today = DateFormat('EEEE').format(now);
  String day;
  String thenString;

  int dateCount = 0;
  if (days.contains(today) && now.hour < 11) {
    // TODO: consult owner about Friday deadline (9>?)
    day = today;
  } else {
    int index = SEVENDAYS.indexOf(today);
    for (;;) {
      index = (index + 1) % SEVENDAYS.length;
      dateCount++;
      if (days.contains(SEVENDAYS[index])) {
        break;
      }
      if (index == SEVENDAYS.indexOf(today)) {
        // dead code, probably, hopefully
        throw Exception(
            "There is something seriously, fundamentally wrong, and I wrote this exception myself");
      }
    }
    day = SEVENDAYS[index];
  }
  DateTime then = now.add(Duration(days: dateCount));
  if (day != DateFormat('EEEE').format(then)) {
    throw Exception("FUBAR, and I wrote this exception myself");
  }
  thenString = DateFormat('yMMMMd').format(then);
  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 150),
            content: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (day == today)
                        const Text("Setting up a pick-up request for today")
                      else
                        Column(mainAxisSize: MainAxisSize.min, children: <
                            Widget>[
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                                "Please confirm the date\nfor your Pick-Up Request"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 8),
                            child: Text(
                              day,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 8),
                            child: Text(
                              thenString,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextButton(
                              onPressed: () {
                                // flutter DatePickerDialog
                                DateTime today = DateTime.now();

                                // flutter ListWheelScrollView
                                List<Text> candiDays = [];
                                for (int index = 1;
                                    index < 30;
                                    index = index + 1) {
                                  DateTime day = DateTime(
                                      then.year, then.month, then.day + index);
                                  if (days.contains(
                                      DateFormat('EEEE').format(day))) {
                                    candiDays.add(Text(
                                        "${DateFormat('EEEE').format(day)}\n${DateFormat('yMMMMd').format(day)}"));
                                  }
                                }
                                Future<DateTime?> newDateFuture =
                                    showDatePicker(
                                  context: context,
                                  initialDate: then,
                                  firstDate: then,
                                  lastDate: DateTime(
                                      today.year, today.month, today.day + 30),
                                  currentDate: today,
                                  selectableDayPredicate: (DateTime day) => days
                                      .contains(DateFormat('EEEE').format(day)),
                                  errorInvalidText:
                                      "This date is neither ${days[0]} nor ${days[1]}.",
                                );
                                newDateFuture.then((DateTime? newDate) {
                                  if (newDate != null) {
                                    setState(() {
                                      then = newDate;
                                      thenString =
                                          DateFormat('yMMMMd').format(newDate);
                                      day = DateFormat('EEEE').format(newDate);
                                    });
                                  }
                                });
                              },
                              child: const Text("Select another date"),
                            ),
                          )
                        ])
                    ])),
            actions: <Widget>[
              Row(children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox.square(dimension: 10),
                Expanded(
                    // confirm button
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog<void>(
                              context: context,
                              builder: (context) {
                                try {
                                  return FutureBuilder<AlertDialog>(
                                      future: _checknWrite(
                                          context, currentUser, then),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          currentUser
                                              .getName()
                                              .then((String name) {
                                            sendPushMessage(
                                              'ffe0Ul-BTcmuiZXJZFf-Ug:APA91bEYGQg4d8EcFT8aZXmsziVXa7RWguw849guhAx0SfJLOCUZidWY_J5SbXtw5JoljH99-nWb1Stsgod6B69iF4hZ58_ScJNb7tFxnbnAZ1Hu-wMfToEcTlBvYNz1SlDKmsqjxhs4',
                                              'New Pick-Up Request',
                                              '$name has requested pick-up',
                                            );
                                          });
                                          return snapshot.data!;
                                        } else if (snapshot.hasError) {
                                          // print(snapshot.error);
                                          return Dialog(
                                              child: AlertDialog(
                                                  title: const Text(
                                                    'Oops!',
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: const <Widget>[
                                                      Text(
                                                          'There has been an error setting up your request. If this continues, please give us a call.'),
                                                    ],
                                                  ),
                                                  actions: <OutlinedButton>[
                                                OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('OK'),
                                                )
                                              ]));
                                        } else {
                                          return Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const <Widget>[
                                                    CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                    )
                                                  ]));
                                        }
                                      });
                                } catch (error) {
                                  return Column(children: [
                                    Text("There's been an error:\n$error")
                                  ]);
                                }
                              });
                        },
                        child: const Text("Confirm")))
              ])
            ]);
      });
    },
  );
  // TODO: notify @owner
  return;
}
