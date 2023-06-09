import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/chat_room.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/view_notifs.dart';
import 'current_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'basket_helper.dart';
import 'sunshine_drawer.dart';

final List<String> itemsList = ["Launder", "Dry Clean"];

class Basket extends StatefulWidget {
  Basket(this.currentUser, {Key? key}) : super(key: key);

  final Map<String, int> basket = <String, int>{};
  final CurrentUser currentUser;

  @override
  State<Basket> createState() => _BasketState();
}

class _BasketState extends State<Basket> {
  // ignore: avoid_init_to_null
  String? typeDD = null;
  // CurrentUser get currentUser =>
  //     widget.currentUser; // making this mutable state

  _add2Basket() {
    if (mounted) {
      setState(() {
        if (typeDD.runtimeType != String) {
          throw Exception("whatever you're trying ain't gonna work buddy");
        } // some sanity checks
        if (itemsList.contains(typeDD)) {
          if (mounted) {
            setState(() {
              widget.basket
                  .update(typeDD!, (value) => value + 1, ifAbsent: () => 1);
            });
          }
        } else {
          throw Exception("What?! How did $typeDD get here??");
        }
        // print(widget.basket);
      });
    }
    return;
  }

  _incrementLaundry() {
    if (mounted) {
      setState(() {
        widget.basket.update(typeDD!, (value) => value + 1);
      });
    }
    return;
  }

  _decrementLaundry() {
    if (widget.basket.keys.contains(typeDD)) {
      if (mounted) {
        setState(() {
          widget.basket.update(typeDD!, (value) => value - 1);
        });
      }
    }
    return;
  }

  _deleteLaundry(String entryKey) {
    if (mounted) {
      setState(() {
        widget.basket.remove(entryKey);
      });
    }
    return;
  }

  @override
  Widget build(context) {
    if (!widget.currentUser.userExists()) {
      if (mounted) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            if (mounted) {
              setState(() {
                widget.currentUser.logIn(user);
              });
            }
          }
        });
      }
    } else {
      // user exists
      if (mounted) {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user == null) {
            if (mounted) {
              setState((() {
                widget.currentUser.logOut();
              }));
            }
          }
        });
      }
    } // resolve login (for some reason)
    DatabaseReference requestRef = FirebaseDatabase.instance.ref('Sonnims');
    if (widget.currentUser.userExists()) {
      String uid = widget.currentUser.getUser()!.uid;
      requestRef = requestRef.child(uid).child('request');
    }
    // REDUNDANT?
    int nowHour = DateTime.now().hour;
    int adaptiveAlpha = 255;
    if (16 <= nowHour && nowHour <= 18) {
      adaptiveAlpha = 192;
    } else if (18 < nowHour && nowHour <= 20) {
      adaptiveAlpha = 128;
    } else if (20 < nowHour || nowHour <= 4) {
      adaptiveAlpha = 64;
    } else if (4 < nowHour && nowHour <= 6) {
      adaptiveAlpha = 128;
    } else if (6 < nowHour && nowHour <= 8) {
      adaptiveAlpha = 192;
    }

    return Scaffold(
        backgroundColor: Color.fromARGB(
            adaptiveAlpha, 100, 149, 237), // TODO extremely tentative
        appBar: AppBar(
            title: FutureBuilder<String>(
                future: widget.currentUser.getName(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text("Hello, ${snapshot.data as String}!");
                  } else if (snapshot.hasError) {
                    return const Text("ERROR");
                  } else {
                    return const Text("Hello!");
                  }
                }),
            actions: <Widget>[
              if (kDebugMode) DEVICE_TOKEN,
              Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        minimumSize: const Size(50, 50),
                        side: BorderSide(color: DEFAULT_BGwHILITE)),
                    onPressed: (!widget.currentUser.userExists())
                        ? null
                        : () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ViewNotifs()));
                          },
                    child: const Icon(Icons.notifications_active_rounded),
                  )),
            ]),
        drawer: SunshineDrawer(context, widget.currentUser,
            onResult: (CurrentUser currentUser) {
          if (mounted) {
            if (currentUser.getUser() != widget.currentUser.getUser()) {
              setState(() {
                widget.currentUser.logOut();
              });
            }
          }
        }),
        body: Stack(
          children: [
            Positioned(
              // TODO: moving sun?
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color.fromARGB(255, 255, 253, 184),
                      const Color.fromARGB(255, 255, 255, 158),
                      CORNFLOWER_BLUE.withAlpha(adaptiveAlpha),
                    ],
                    radius: .33,
                    focalRadius: 50,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                // alignment: Alignment.topCenter,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.currentUser.userExists())
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 8),
                          child: Container(
                            width: GET_MAX_WIDTH(context) * 9 / 10,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  spreadRadius: 1.5,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              // border: Border.all(color: DEFAULT_BORDER),
                            ),
                            child: FutureBuilder<DatabaseEvent>(
                              future: requestRef.once(DatabaseEventType.value),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  DatabaseEvent event = snapshot.data!;
                                  String date = event.snapshot.value as String;
                                  String pickupDay = "";
                                  String pickupDateMonth = "";
                                  if (date.isEmpty) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text("No pickup request"),
                                      ],
                                    );
                                  } else {
                                    DateTime pickupDate = DateTime.parse(date);
                                    pickupDay =
                                        DateFormat('EEEE').format(pickupDate);
                                    pickupDateMonth =
                                        DateFormat('yMMMMd').format(pickupDate);
                                  }
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const <Widget>[
                                          Text("Next pickup scheduled for")
                                        ],
                                      ),
                                      Text(pickupDay,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            // fontWeight: FontWeight.bold,
                                          )),
                                      Text(pickupDateMonth,
                                          style: const TextStyle(
                                            fontSize: 24,
                                            // fontWeight: FontWeight.bold,
                                          )),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8, top: 8),
                                            child: NeumorphicButton(
                                                style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(50)),
                                                    shape:
                                                        NeumorphicShape.concave,
                                                    color: Colors.white,
                                                    lightSource:
                                                        LightSource.top),
                                                onPressed: () {},
                                                child: const Text(
                                                    "Cancel Pickup")),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8, top: 8),
                                            child: NeumorphicButton(
                                                style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(BorderRadius
                                                            .circular(50)),
                                                    shape:
                                                        NeumorphicShape.concave,
                                                    color: Colors.white,
                                                    lightSource:
                                                        LightSource.top),
                                                onPressed: () {},
                                                child: const Text("See More")),
                                          )
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text(
                                      "Error fetching pickup request.");
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        backgroundColor: Colors.white,
                        minimumSize: const Size(88, 48),
                      ),
                      onPressed: (widget.currentUser.userExists())
                          ? () {
                              confirmDays(context, widget.currentUser);
                              setState(() {});
                            }
                          : null,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("REQUEST ",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 18)),
                            Text("NEW",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    fontSize: 18)),
                            Text(" PICKUP",
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 18)),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: (!widget.currentUser.userExists())
                  ? null
                  : () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ChatRoom();
                      }));
                    },
              backgroundColor: (!widget.currentUser.userExists())
                  ? Colors.grey.shade400.withAlpha(128)
                  : null,
              tooltip: 'Chat with the Owner',
              shape: CircleBorder(side: BorderSide(color: DEFAULT_BGwHILITE)),
              enableFeedback: true,
              disabledElevation: 0,
              child: Icon(Icons.chat_rounded,
                  color: (!widget.currentUser.userExists())
                      ? Colors.black26
                      : null),
            )));
  }
}
