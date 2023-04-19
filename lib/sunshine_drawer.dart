import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';
import 'current_user.dart';

class SunshineDrawer extends StatefulWidget {
  final BuildContext context;
  final CurrentUser currentUser;
  final void Function(CurrentUser) onResult;

  const SunshineDrawer(this.context, this.currentUser,
      {Key? key, required this.onResult})
      : super(key: key);

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
        child: (widget.currentUser.userExists())
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
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
      OutlinedButton(
        onPressed: () {
          // TODO: Write about myself
          // Navigator.push()...
        },
        child: const Text("About"),
      ),
      OutlinedButton(
        onPressed: (!widget.currentUser.userExists())
            ? null
            : () {
                setState(() {
                  FirebaseAuth.instance.signOut();
                  widget.currentUser.logOut();
                });
                widget.onResult(widget.currentUser);
                Navigator.pop(context, widget.currentUser);
              },
        child: const Text("Sign Out"),
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
