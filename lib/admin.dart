import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sunshine_cleanest/chat_rooms_list.dart';
import 'package:sunshine_cleanest/constants.dart';
import 'package:sunshine_cleanest/view_notifs.dart';
import 'package:sunshine_cleanest/sunshine_drawer.dart';

import 'check_requests.dart';
import 'current_user.dart';
import 'gate.dart';
import 'notify_select.dart';
// import 'basket.dart';

class Admin extends StatefulWidget {
  // final BuildContext context;
  final CurrentUser currentUser;

  const Admin(this.currentUser, {super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  CurrentUser get currentUser => widget.currentUser;
  // bool signedOut = false;

  @override
  Widget build(BuildContext context) {
    if (!currentUser.userLoggedIn()) {
      return const Gate();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome, Jeon.",
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 17,
                fontWeight: FontWeight.w300)),
        actions: <Widget>[
          if (kDebugMode) DEVICE_TOKEN,
        ],
      ),
      drawer: SunshineDrawer(
        context,
        currentUser,
        // onResult: (bool shouldLogOut) {
        //   setState(() {
        //     if (shouldLogOut) {
        //       currentUser.logOut();
        //     }
        //   });
        // },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 25,
                mainAxisSpacing: 25,
                crossAxisCount: 2,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  GridTile(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          side: BorderSide(color: DEFAULT_BGwHILITE)),
                      onPressed: () {
                        Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckRequests()));
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.airport_shuttle_rounded,
                              size: 30,
                            ),
                          ),
                          Text(
                            "Check Pickup Requests",
                            style: TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  GridTile(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 3,
                              side: BorderSide(color: DEFAULT_BGwHILITE)),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.notifications_on_rounded,
                                  size: 25,
                                ),
                              ),
                              Text(
                                "Notify Select",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          onPressed: () {
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NotifySelect()));
                          })),
                  GridTile(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              elevation: 3,
                              side: BorderSide(color: DEFAULT_BGwHILITE)),
                          onPressed: () {
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ViewNotifs()));
                          },
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit_notifications_rounded,
                                    size: 30,
                                  ),
                                ),
                                Text("Notifications",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center),
                              ]))),
                  GridTile(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 3,
                              side: BorderSide(color: DEFAULT_BGwHILITE)),
                          onPressed: () {
                            Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatRoomsList()));
                          },
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.chat_rounded,
                                    size: 30,
                                  ),
                                ),
                                Text("All Chats",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center),
                              ]))),
                ],
              ),
            ),
            /*
             * Replaced with drawer
             */
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           //TODO wrap under alert dialog (see basket helper)
            //           FirebaseAuth.instance.signOut();
            //           setState(() {
            //             currentUser.logOut();
            //           });
            //           Navigator.pushReplacement(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (BuildContext context) => const Gate()));
            //         },
            //         child: const Text(
            //           "Sign Out",
            //           style: TextStyle(
            //             fontSize: 20,
            //             fontStyle: FontStyle.italic,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
