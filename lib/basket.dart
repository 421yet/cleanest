import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    }
    return Scaffold(
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      // backgroundColor: appPalette.mainColor,
                      // side: BorderSide(width: 5, color: appPalette.mainColor),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      fixedSize: const Size(200, 200)),
                  onPressed: () {},
                  // child: ,
                  child: Ink(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(colors: [
                        Colors.yellowAccent,
                        Colors.yellow,
                        Colors.lightBlue.withAlpha(16)
                      ], radius: .5),
                      shape: BoxShape.circle,
                    ),
                    // child: Image.asset(
                    //   "assets/basket_edit.png",
                    //   scale: 5,
                    //   // opacity: const AlwaysStoppedAnimation(67),
                    //   filterQuality: FilterQuality.high,
                    // ),
                    child: const Icon(Icons.airport_shuttle_rounded,
                        size: 100, color: Colors.black),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(8),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: <Widget>[
              //       Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: DropdownButtonHideUnderline(
              //           child: DropdownButton<String>(
              //             borderRadius: BorderRadius.circular(15),
              //             menuMaxHeight: 200,
              //             value: typeDD,
              //             hint: const Text(
              //               "Select care type",
              //               style: TextStyle(color: Colors.black38),
              //             ),
              //             items: itemsList
              //                 .map<DropdownMenuItem<String>>((String value) {
              //               return DropdownMenuItem<String>(
              //                 value: value,
              //                 child: Text(value),
              //               );
              //             }).toList(),
              //             onChanged: (String? newValue) {
              //               if (mounted) {
              //                 setState(() {
              //                   typeDD = newValue;
              //                 });
              //               }
              //             },
              //           ),
              //         ),
              //       ),
              //       OutlinedButton(
              //           onPressed: (typeDD != null) ? _add2Basket : null,
              //           child: const Text('Add to Basket')),
              //     ],
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.all(2),
              //   child: ListView(
              //     padding: const EdgeInsets.all(1),
              //     scrollDirection: Axis.vertical,
              //     shrinkWrap: true,
              //     children: widget.basket.entries.map((e) {
              //       // TODO tidy this up (using Table widget?)
              //       return Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(e.key),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 16),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: <Widget>[
              //                 SizedBox.square(
              //                   dimension: 20,
              //                   child: ElevatedButton(
              //                     style: ElevatedButton.styleFrom(
              //                         padding: EdgeInsets.zero),
              //                     onPressed: _incrementLaundry,
              //                     child: const Icon(Icons.add, size: 15),
              //                   ),
              //                 ),
              //                 Padding(
              //                   padding:
              //                       const EdgeInsets.symmetric(horizontal: 8),
              //                   child: Text(e.value.toString()),
              //                 ),
              //                 SizedBox.square(
              //                   dimension: 20,
              //                   child: ElevatedButton(
              //                     style: ElevatedButton.styleFrom(
              //                         padding: EdgeInsets.zero),
              //                     onPressed:
              //                         (e.value <= 1) ? null : _decrementLaundry,
              //                     child: const Icon(Icons.remove, size: 15),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           SizedBox.square(
              //             dimension: 30,
              //             child: ElevatedButton(
              //               style: ElevatedButton.styleFrom(
              //                   padding: EdgeInsets.zero),
              //               onPressed: () => _deleteLaundry(e.key),
              //               child: const Icon(Icons.delete, size: 20),
              //             ),
              //           ),
              //         ],
              //       );
              //     }).toList(),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 40, bottom: 1),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(250, 36),
                      side: BorderSide(color: DEFAULT_BGwHILITE)),
                  onPressed: (!widget.currentUser.userExists())
                      ? null
                      : () {
                          confirmDays(context, widget.currentUser);
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text("View "),
                      Text("Existing",
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      Text(" Pickup Requests")
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 1, bottom: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(250, 36),
                      side: BorderSide(color: DEFAULT_BGwHILITE)),
                  onPressed: (!widget.currentUser.userExists())
                      ? null
                      : () {
                          confirmDays(context, widget.currentUser);
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text("Request "),
                      Text("New",
                          style: TextStyle(fontWeight: FontWeight.w900)),
                      Text(" Pickup")
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
                constraints: const BoxConstraints(minHeight: 75, minWidth: 75),
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
                      ? Colors.grey.shade400
                      : const FloatingActionButtonThemeData().backgroundColor,
                  tooltip: 'Chat with the Owner',
                  shape:
                      CircleBorder(side: BorderSide(color: DEFAULT_BGwHILITE)),
                  enableFeedback: true,
                  disabledElevation: 0,
                  child: Icon(Icons.chat_rounded,
                      color: (!widget.currentUser.userExists())
                          ? Colors.black26
                          : Colors.black),
                ))));
  }
}
