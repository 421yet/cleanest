import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sunshine_cleanest/current_user.dart';

class SunshineAppBar {
  final Text titleText;
  final List<Widget> actions;

  SunshineAppBar(
    this.titleText,
    this.actions,
  );

  final CurrentUser currentUser = CurrentUser();

  AppBar builder() {
    return AppBar(
      title: titleText,
      actions: actions +
          [
            ElevatedButton(
                onPressed: () {
                  DatabaseReference ref = FirebaseDatabase.instance
                      .ref('Sonnims')
                      .child(currentUser.getUser()!.uid);
                  ref
                      .child('token')
                      .once(DatabaseEventType.value)
                      .then((DatabaseEvent event) {
                    if (kDebugMode) print(event.snapshot.value as String);
                  });
                  currentUser.getUser()!.uid;
                },
                child: const Text("DEVICE_TOKEN")),
          ],
    );
  }
}
