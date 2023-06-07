// ignore: constant_identifier_names
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Color CORNFLOWER_BLUE = Color.fromARGB(255, 100, 149, 237);

Color DEFAULT_FADEDTXT = Colors.black.withAlpha(192);
Color DEFAULT_BORDER = Colors.black.withAlpha(128);
Color DEFAULT_BGwHILITE = Colors.black.withAlpha(32);

double GET_MAX_HEIGHT(BuildContext context) {
  return MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.vertical;
}

double GET_MAX_WIDTH(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

const String ADMIN_UID = "VB1lEL9YrHgOJukgiYjK30FIjD02";
const String ADMIN_TOKEN =
    "ffe0Ul-BTcmuiZXJZFf-Ug:APA91bEYGQg4d8EcFT8aZXmsziVXa7RWguw849guhAx0SfJLOCU"
    "ZidWY_J5SbXtw5JoljH99-nWb1Stsgod6B69iF4hZ58_ScJNb7tFxnbnAZ1Hu-wMfToEcTlBvY"
    "Nz1SlDKmsqjxhs4";
ElevatedButton DEVICE_TOKEN = ElevatedButton(
    onPressed: (!kDebugMode)
        ? null
        : () {
            FirebaseMessaging.instance.getToken().then((token) {
              if (kDebugMode) {
                print("DEVICE TOKEN: $token");
              }
            });
          },
    child: const Text("DEVICE\nTOKEN"));
Positioned RED_DOT = Positioned(
  // Stolen from Leandro Carvalho
  right: 20,
  top: 15,
  child: Container(
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(7),
    ),
    constraints: const BoxConstraints(
      minWidth: 10,
      minHeight: 10,
    ),
    child: const SizedBox(
      width: 1,
      height: 1,
    ),
  ),
);
