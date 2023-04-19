import 'package:flutter/material.dart';
import 'current_user.dart';

class Account extends StatefulWidget {
  final BuildContext context;
  final CurrentUser currentUser;

  const Account(this.context, this.currentUser, {super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  CurrentUser get currentUser => widget.currentUser;

  @override
  Widget build(BuildContext context) {
    List<Widget> entries = [
      OutlinedButton(
        onPressed: (currentUser.userExists())
            ? () {
                // TODO: Implement Change Dates Function
              }
            : null,
        child: const Text("Change Pick-Up Dates"),
      ),
      OutlinedButton(
        onPressed: (currentUser.userExists())
            ? () {
                // TODO: Implement Change Address Function
                // Navigator.push()...
              }
            : null,
        child: const Text("Change Address"),
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
        children: entries,
      ),
    );
  }
}
