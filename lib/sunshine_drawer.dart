import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sunshine_cleanest/constants.dart';

import 'login.dart';
import 'current_user.dart';

class SunshineDrawer extends StatefulWidget {
  final BuildContext context;
  final CurrentUser currentUser;
  // final void Function(bool) onResult;

  const SunshineDrawer(
    this.context,
    this.currentUser, {
    Key? key,
    /*required this.onResult*/
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SunshineDrawerState();
}

class _SunshineDrawerState extends State<SunshineDrawer> {
  // CurrentUser get currentUser => widget.currentUser;

  @override
  Widget build(context) {
    // if (!currentUser.userExists()) {
    //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //     if (user != null) {
    //       widget.currentUser.logIn(user);
    //     }
    //   });
    // }

    final List<Widget> entries = <Widget>[
      DrawerHeader(
        child: (widget.currentUser.userLoggedIn())
            ? const Text("Cleanest\u2122\nfor\nSunshine Cleaners\n\nv. 1.0.0")
            : ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context, widget.currentUser);
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => Login(context),
                    ),
                  );
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Sign In",
                      style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "for full features",
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                ),
              ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 2),
        onPressed: () {},
        child: const Text("FAQs"),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 2),
        onPressed: () {
          // TODO: Write about myself
          // Navigator.push()...
        },
        child: const Text("About"),
      ),
      if (widget.currentUser.userLoggedIn())
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: CORNFLOWER_BLUE.darken(),
          ),
          onPressed: () {
            setState(() {
              widget.currentUser.logOut(); // redundant?
            });
            // widget.onResult(true);
            Navigator.pop(context);
          },
          child: const Text(
            "Sign Out",
            style: TextStyle(color: Colors.white),
          ),
        )
    ];

    return Drawer(
        width: MediaQuery.of(context).size.width / 5 * 3,
        child: ListView.builder(
          itemBuilder: (context, int index) {
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: entries[index]);
          },
          itemCount: entries.length,
        ));
  }
}
