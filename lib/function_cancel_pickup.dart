import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void confirmCancelPickup(
  BuildContext context,
  DatabaseReference reqRef,
  String uid,
  String date,
) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("You are about to Cancel a Pickup Request."),
              Text("This action cannot be undone. "),
            ],
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Confirm Cancellation"),
              onPressed: () {
                Navigator.of(context).pop();
                try {
                  cancelPickup(
                    reqRef,
                    uid,
                    date,
                  );
                } catch (error) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                            title: const Text("Oops!"),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text(
                                    "There was a problem cancelling this Pickup Request. Try contacting Sunshine Cleaners directly. "),
                                Text("Error code: $error")
                              ],
                            ),
                            actions: <Widget>[
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              )
                            ]);
                      });
                }

                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: const Text("Hooray!"),
                          content: Text(
                              "Pickup Request for $date was successfully cancelled. "),
                          actions: <Widget>[
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"))
                          ]);
                    });
              },
            )
          ],
        );
      });
}

Future<void> cancelPickup(
    DatabaseReference reqRef, String uid, String date) async {
  DatabaseReference reqsRef =
      FirebaseDatabase.instance.ref("Requests").child(date).child(uid);
  try {
    await reqsRef.remove();
  } catch (error) {
    throw Exception(
        "Error: $error, while removing from list of All requests. ");
  }
  try {
    await reqRef.child(date).remove();
  } catch (error) {
    throw Exception(
        "Error: $error, while removing from Client's list of requests.");
  }
  return;
}
