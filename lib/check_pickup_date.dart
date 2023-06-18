import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/send_push_message.dart';

class CheckPickupDate extends StatefulWidget {
  final DateTime date;
  const CheckPickupDate(this.date, {super.key});

  @override
  State<StatefulWidget> createState() => _CheckPickupDateState();
}

class _CheckPickupDateState extends State<CheckPickupDate> {
  // String get date = widget.date;
  Map _requests = {};
  Map<String, bool> reqPair = <String, bool>{};
  bool noRequests = false;
  bool checkState = false;
  String sonnimName = 'Error';

  // List<String> _uids = <String>[];

  Future<Map> _getRequests() async {
    try {
      // print(widget.date);
      final DatabaseEvent event = await FirebaseDatabase.instance
          .ref('Requests')
          .child(widget.date.toString().split(' ')[0])
          .once(DatabaseEventType.value);
      _requests = jsonDecode(jsonEncode(event.snapshot.value)) as Map;
      _requests.remove(null);
      if (_requests.isEmpty) {
        setState(() {
          noRequests = true;
        });
      }
      if (reqPair.isEmpty) {
        reqPair = {for (String uid in _requests.keys) uid: false};
      }
      // _uids = _requests.keys.toList();
      // print(_requests);
      // _uids.sort(); // TODO: sort in address order instead?
      // print(_requests);
    } catch (e) {
      throw Exception("check_pickup_date.dart: $e");
    }
    return _requests;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: _getRequests(),
      builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                DateFormat.yMMMMd('en_US').format(widget.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _requests.length + 1, // for buttons
                itemBuilder: (BuildContext context, int index) {
                  if (index == _requests.length) {
                    final DateTime today = DateTime.now();
                    final DateTime weekAgo =
                        DateTime(today.year, today.month, today.day - 7);
                    return Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          reqPair.updateAll(
                                              (key, value) => value = true);
                                        });
                                      },
                                      child: const Text('Check All'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          reqPair.updateAll(
                                              (key, value) => value = false);
                                        });
                                      },
                                      child: const Text('Uncheck all'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: ElevatedButton(
                                        onPressed: (reqPair.containsValue(true))
                                            ? () {
                                                try {
                                                  DatabaseReference ref =
                                                      FirebaseDatabase.instance
                                                          .ref('Requests')
                                                          .child(widget.date
                                                              .toString()
                                                              .split(' ')[0]);
                                                  reqPair.forEach(
                                                    (uid, checked) {
                                                      if (checked) {
                                                        ref.update({uid: true});

                                                        FirebaseDatabase
                                                            .instance
                                                            .ref('Sonnims')
                                                            .child(uid)
                                                            .child('token')
                                                            .once(
                                                                DatabaseEventType
                                                                    .value)
                                                            .then((DatabaseEvent
                                                                event) {
                                                          String token = event
                                                              .snapshot
                                                              .value as String;
                                                          sendPushMessage(
                                                            token,
                                                            "Confirmation: ${DateFormat.MMMMd('en_US').format(widget.date)} Pick-Up",
                                                            "Yay!",
                                                          );
                                                        });
                                                      }
                                                      if (mounted) {
                                                        setState(() {
                                                          reqPair[uid] = false;
                                                        });
                                                      }
                                                    },
                                                  );
                                                } catch (e) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                            "Uh-Oh...",
                                                            style: TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                          content: Text(
                                                              "Couldn't confirm request(s) at this time. Please contact Frank. \nError Code: $e"),
                                                          actions: [
                                                            ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                        "OK"))
                                                          ],
                                                        );
                                                      });
                                                }
                                              }
                                            : null,
                                        child: const Text(
                                            'Confirm Requests and Notify'),
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 88, height: 36),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  onPressed:
                                      (widget.date.compareTo(weekAgo) > 0)
                                          ? null
                                          : () {},
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.warning),
                                      Text(' Delete This Date'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  String uid = _requests.keys.toList()[index];
                  bool isConfirmed = _requests.values.toList()[index];
                  bool isChecked = reqPair[uid]!;
                  FirebaseDatabase.instance
                      .ref('Sonnims')
                      .child(uid)
                      .child('name')
                      .once(DatabaseEventType.value)
                      .then((DatabaseEvent event) {
                    if (mounted) {
                      setState(() {
                        sonnimName = event.snapshot.value as String;
                      });
                    }
                  });
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          sonnimName,
                          style: TextStyle(
                              decoration: (isConfirmed)
                                  ? TextDecoration.lineThrough
                                  : null),
                        )),
                        (isConfirmed)
                            ? const SizedBox()
                            : Checkbox(
                                value: /*allChecked || */
                                    isChecked && !isConfirmed,
                                onChanged: (bool? value) {
                                  setState(() {
                                    reqPair[uid] = !isChecked;
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                              ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black.withAlpha(32),
                  height: 0,
                  indent: 5,
                  endIndent: 5,
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const SizedBox(
            width: 60,
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                )
              ],
            ),
          );
        }
      },
    );
  }
}
