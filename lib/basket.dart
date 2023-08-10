import 'package:firebase_database/firebase_database.dart';
// import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:sunshine_cleanest/chat_room.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/view_notifs.dart';
import 'current_user.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import 'basket_helper.dart';
import 'function_cancel_pickup.dart';
import 'sunshine_drawer.dart';

// final List<String> itemsList = ["Launder", "Dry Clean"];

class Basket extends StatefulWidget {
  const Basket(this.currentUser, {Key? key}) : super(key: key);

  // final Map<String, int> basket = <String, int>{};
  final CurrentUser currentUser;

  @override
  State<Basket> createState() => _BasketState();
}

class _BasketState extends State<Basket> {
  // ignore: avoid_init_to_null
  // String? typeDD = null;
  CurrentUser get currentUser => widget.currentUser;
  // _add2Basket() {
  //   if (mounted) {
  //     setState(() {
  //       if (typeDD.runtimeType != String) {
  //         throw Exception("whatever you're trying ain't gonna work buddy");
  //       } // some sanity checks
  //       if (itemsList.contains(typeDD)) {
  //         if (mounted) {
  //           setState(() {
  //             widget.basket
  //                 .update(typeDD!, (value) => value + 1, ifAbsent: () => 1);
  //           });
  //         }
  //       } else {
  //         throw Exception("What?! How did $typeDD get here??");
  //       }
  //       // print(widget.basket);
  //     });
  //   }
  //   return;
  // }
  // _incrementLaundry() {
  //   if (mounted) {
  //     setState(() {
  //       widget.basket.update(typeDD!, (value) => value + 1);
  //     });
  //   }
  //   return;
  // }
  // _decrementLaundry() {
  //   if (widget.basket.keys.contains(typeDD)) {
  //     if (mounted) {
  //       setState(() {
  //         widget.basket.update(typeDD!, (value) => value - 1);
  //       });
  //     }
  //   }
  //   return;
  // }
  // _deleteLaundry(String entryKey) {
  //   if (mounted) {
  //     setState(() {
  //       widget.basket.remove(entryKey);
  //     });
  //   }
  //   return;
  // }

  @override
  Widget build(context) {
    if (kDebugMode) print("Starting to build Basket");
    // if (!widget.currentUser.userLoggedIn()) {
    //   if (mounted) {
    //     FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //       if (user != null) {
    //         if (mounted) {
    //           setState(() {
    //             widget.currentUser.logIn();
    //           });
    //         }
    //       }
    //     });
    //   }
    // } else {
    //   // user exists
    //   if (mounted) {
    //     FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //       if (user == null) {
    //         if (mounted) {
    //           setState((() {
    //             widget.currentUser.logOut();
    //           }));
    //         }
    //       }
    //     });
    //   }
    // } // resolve login (for some reason)
    DatabaseReference requestRef = FirebaseDatabase.instance.ref('Sonnims');
    if (currentUser.userLoggedIn()) {
      String uid = widget.currentUser.getUser()!.uid;
      requestRef = requestRef.child(uid).child('requests');
      Future<DatabaseEvent> builderFuture =
          requestRef.once(DatabaseEventType.value);
    } else {
      Future<DatabaseEvent> builderFuture;
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
        backgroundColor: CORNFLOWER_BLUE
            .withAlpha(adaptiveAlpha), // TODO extremely tentative
        appBar: AppBar(
            title: FutureBuilder<String>(
                future: widget.currentUser.getName(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return Text("Hello, ${snapshot.data as String}!",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w300));
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
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      // backgroundColor: ,
                      elevation: 2,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      // minimumSize: const Size(50, 50),
                      // side: BorderSide(color: DEFAULT_BGwHILITE),
                    ),
                    onPressed: (!widget.currentUser.userLoggedIn())
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
        drawer: SunshineDrawer(
          context,
          widget.currentUser,
          // onResult: (bool shouldLogOut) {
          //   if (mounted) {
          //     if (shouldLogOut) {
          //       setState(() {
          //         widget.currentUser.logOut();
          //       });
          //     }
          //   }
          // },
        ),
        body: Stack(
          children: [
            Positioned(
              left: 10,
              top: 50,
              // TODO: EXTREMELY TENTATIVE; black backdrop to match app background backdrop
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(color: Colors.black),
              ),
            ),
            Positioned(
              left: 10,
              top: 50,
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
                      if (widget.currentUser.userLoggedIn())
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 8),
                          child: Container(
                            width: GET_MAX_WIDTH(context) * 9 / 10,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
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
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        elevation: 1,
                                        padding: EdgeInsets.zero,
                                        shape: const CircleBorder(),
                                      ),
                                      child: const Icon(Icons.refresh_rounded),
                                      onPressed: () {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                FutureBuilder<DatabaseEvent>(
                                  future: requestRef.once(DatabaseEventType
                                      .value), // TODO create dedicated variable for this but can't seem to work it out...
                                  builder: (context,
                                      AsyncSnapshot<DatabaseEvent> snapshot) {
                                    if (snapshot.hasData) {
                                      DatabaseEvent event = snapshot.data!;
                                      Map dates = event.snapshot.value as Map;
                                      if (dates.length == 1) {
                                        return const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "No upcoming Pickup Requests...",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        );
                                      } else {
                                        String date = dates.keys.toList()[1];
                                        // TODO: confirmation status

                                        DateTime pickupDate =
                                            DateTime.parse(date);
                                        String pickupDay = DateFormat('EEEE')
                                            .format(pickupDate);
                                        String pickupDateMonth =
                                            DateFormat('yMMMMd')
                                                .format(pickupDate);
                                        return Column(
                                          children: [
                                            const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    "Next pickup scheduled for")
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8, top: 8),
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        confirmCancelPickup(
                                                          context,
                                                          requestRef,
                                                          widget.currentUser
                                                              .getUser()!
                                                              .uid,
                                                          date,
                                                        );
                                                        // setState(() {
                                                        //   builderFuture =
                                                        //       requestRef.once(
                                                        //           DatabaseEventType
                                                        //               .value);
                                                        // });
                                                      },
                                                      child: const Text(
                                                          "Cancel Pickup")),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, top: 8),
                                                  child: ElevatedButton(
                                                      // style: NeumorphicStyle(
                                                      //     boxShape: NeumorphicBoxShape
                                                      //         .roundRect(BorderRadius
                                                      //             .circular(50)),
                                                      //     shape:
                                                      //         NeumorphicShape.concave,
                                                      //     color: Colors.white,
                                                      //     lightSource:
                                                      //         LightSource.top),
                                                      onPressed: () {},
                                                      child: const Text(
                                                          "See More...")),
                                                )
                                              ],
                                            ),
                                          ],
                                        );
                                      }
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                            "Error fetching pickup request."),
                                      );
                                    } else {
                                      return const CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ],
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
                        minimumSize: (widget.currentUser.userLoggedIn())
                            ? const Size(88, 48)
                            : const Size(200, 200),
                        shape: (widget.currentUser.userLoggedIn())
                            ? null
                            : const CircleBorder(),
                      ),
                      onPressed: (widget.currentUser.userLoggedIn())
                          ? () {
                              confirmDays(context, widget.currentUser);
                              setState(() {});
                            }
                          : null,
                      child: (widget.currentUser.userLoggedIn())
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                ])
                          : const Center(
                              child: Text("Please Sign In\nfor full features",
                                  textAlign: TextAlign.center)),
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
              onPressed: (!widget.currentUser.userLoggedIn())
                  ? null
                  : () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ChatRoom();
                      }));
                    },
              backgroundColor: (!widget.currentUser.userLoggedIn())
                  ? Colors.grey.shade400.withAlpha(128)
                  : null,
              tooltip: 'Chat with the Owner',
              shape: CircleBorder(side: BorderSide(color: DEFAULT_BGwHILITE)),
              enableFeedback: true,
              disabledElevation: 0,
              child: Icon(Icons.chat_rounded,
                  color: (!widget.currentUser.userLoggedIn())
                      ? Colors.black26
                      : null),
            )));
  }
}
