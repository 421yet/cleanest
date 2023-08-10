import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:sunshine_cleanest/sunshine_drawer.dart';

import 'check_pickup_date.dart';

class CheckRequests extends StatefulWidget {
  const CheckRequests({super.key});

  @override
  State<StatefulWidget> createState() => _CheckRequestsState();
}

class _CheckRequestsState extends State<CheckRequests> {
  Map<String, dynamic> _requests = <String, dynamic>{};
  List<String> _dates = <String>[];

  Future<Map?> _getRequests() async {
    try {
      final DatabaseEvent event = await FirebaseDatabase.instance
          .ref('Requests')
          .once(DatabaseEventType.value);
      _requests =
          jsonDecode(jsonEncode(event.snapshot.value)) as Map<String, dynamic>;
      _dates = _requests.keys.toList();
      _dates.sort();
      // print(_requests);
    } catch (e) {
      if (kDebugMode) {
        throw Exception("check_requests: $e");
      } else {
        return null;
      }
    }
    return _requests;
  }

  final ScrollController _scrollController = ScrollController();
  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _scrollDown());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup Requests"),
      ),
      // drawer: SunshineDrawer(context, currentUser, onResult: onResult),
      body: FutureBuilder<Map?>(
          future: _getRequests(),
          builder: (BuildContext context, AsyncSnapshot<Map?> snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: _requests.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime now = DateTime.now();
                    DateTime nowDate = DateTime(now.year, now.month, now.day);
                    DateTime date = DateTime.parse(_dates[index]);
                    String dateString = DateFormat.yMMMMd('en_US').format(date);
                    if (nowDate.isBefore(date)) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton(
                          onPressed: () {
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        CheckPickupDate(date)));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              const SizedBox.square(dimension: 25),
                              Text(dateString),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10),
                            ],
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push<void>(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      CheckPickupDate(date)));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            const SizedBox.square(dimension: 25),
                            Text(dateString),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                    // backgroundColor: Colors.transparent,
                    // color: Colors.transparent,
                    ),
              );
            }
          }),
    );
  }
}
