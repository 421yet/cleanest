import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';
import 'package:sunshine_cleanest/user_management.dart';
import 'current_user.dart';
import 'gate.dart';

class Login extends StatefulWidget {
  final BuildContext context;

  const Login(this.context, {Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String pin = '';
  final CurrentUser currentUser = CurrentUser.vacant();

  @override
  Widget build(context) {
    if (currentUser.userExists()) {
      return const Gate();
    }
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: <Widget>[
              Text("Please enter the",
                  style: TextStyle(color: Colors.black.withOpacity(.75))),
              const Text(
                "Last 4 Digits",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text("of the phone number",
                  style: TextStyle(color: Colors.black.withOpacity(.75))),
              Text("you've shared with us",
                  style: TextStyle(color: Colors.black.withOpacity(.75))),
            ]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                // width: 250,
                child: Pinput(
                  onCompleted: (pin) {
                    if (mounted) {
                      setState(() {
                        this.pin = pin;
                      });
                    }
                  },
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(275, 35),
              ),
              onPressed: (pin.length == 4)
                  ? () {
                      UserManagement userManagement =
                          UserManagement(pin, currentUser);
                      setState(() {
                        userManagement.authenticate().then(onError: (error) {
                          throw Exception(error);
                        }, (l4d) {
                          if (l4d == 'success') {
                            Navigator.of(context).pop();
                          } else if (l4d == null) {
                            throw Exception(
                                'User _somehow_ submitted pin length < 4. ABORT!');
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 190),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Text>[
                                          const Text("Sorry!\n",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontStyle: FontStyle.italic)),
                                          Text("$l4d is not in our system."),
                                          const Text(
                                              "Please give us a call to Sign Up."),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Center(child: Text("OK")),
                                      )
                                    ],
                                  );
                                });
                          }
                        });
                      });
                    }
                  : null,
              child: const Text("Sign In"),
            ),
          ],
        ),
      ), // on submit, pop navigator
    );
  }
}
