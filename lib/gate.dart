// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'admin.dart';
import 'basket.dart';
import 'current_user.dart';
import 'constants.dart';

class Gate extends StatefulWidget {
  final CurrentUser currentUser = const CurrentUser();

  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  CurrentUser get currentUser => widget.currentUser;

  final FlutterLocalNotificationsPlugin flnp =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // if (Platform.isIOS)
    super.initState();
    requestPermission();
    // if (!currentUser.userExists()) {
    //   FirebaseAuth.instance.authStateChanges().listen((User? user) {
    //     if (user != null) {
    //       if (mounted) {
    //         setState(() {
    //           currentUser.logIn(user);
    //         });
    //       }
    //     }
    //   });
    // }
    handleToken(); // firebase console connection confirmed
    initInfo();
  }

  void handleToken() async {
    // ignore: void_checks
    // return FirebaseMessaging.instance.getToken().then((token) {
    //   if (token == null) {
    //     throw Exception("gate.dart/getToken(): Token irretrievable");
    //   }
    //   setState(() {
    //     deviceToken = token;
    //   }); // put things in here
    // });
    await FirebaseMessaging.instance.getToken().then((token) {
      if (kDebugMode) {
        print("Device token is $token");
      }
      if (currentUser.userLoggedIn()) {
        saveToken(token!, currentUser);
      } else {
        // user not logged in...
        // TODO: handle token as soon as new login. extract method?
      }
    });
    return;
  }

  void saveToken(String token, CurrentUser currentUser) async {
    if (!currentUser.userLoggedIn()) return;
    final FirebaseDatabase fbdb = FirebaseDatabase.instance;
    String uid = currentUser.getUser()!.uid;
    DatabaseReference ref;
    if (currentUser.getUser()?.uid != ADMIN_UID) {
      ref = fbdb.ref('Sonnims').child(uid);
    } else {
      ref = fbdb.ref('Tools').child('Ad');
    }
    DatabaseEvent event =
        await ref.child('token').once(DatabaseEventType.value);
    String? savedToken = event.snapshot.value as String?;
    if (savedToken != null) {
      if (token != savedToken) {
        // handle accordingly
        if (kDebugMode) {
          print('gate.dart (69 nice): '
              'User has logged in on a different device.');
          ref.update({'token': token});
        } else {
          // TODO man... how do i handle different device?
          // TODO: save new device token only if we can verify... how?
          throw Exception(
              'gate.dart (69 nice): UNHANDLED EXCEPTION (yet) (uh-oh!). '
              'User has logged in on a different device.');
        }
      } else {
        if (kDebugMode) {
          print('Current device token matches the one in the db. ');
        }
        return;
      }
    } else {
      // first time logging in (probably) (hopefully)
      if (kDebugMode) {
        print('Setting up device token in DB (First time ever).');
      }
      ref.update({'token': token});
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false, // hmm...
      badge: true,
      carPlay: false,
      criticalAlert: false, // ???
      provisional: false,
      sound: true,
    );
    if (kDebugMode) {
      print(settings
          .authorizationStatus); // often (falsely) says denied for android
    }
  }

  void initInfo() {
    AndroidInitializationSettings androidInit = const AndroidInitializationSettings(
        '@mipmap/ic_launcher'); // \android\app\src\main\res\mipmap-hdpi\ic_launcher.png
    // transparent notif icon. edit this png file directly
    DarwinInitializationSettings darwinInit =
        const DarwinInitializationSettings();
    InitializationSettings initSet =
        InitializationSettings(android: androidInit, iOS: darwinInit);
    flnp.initialize(
      initSet,
      onDidReceiveNotificationResponse: (payload) async {
        // "handles" notif when app is in foreground
        // try {
        //   if (payload != null && payload.isNotEmpty) {
        //   } else {}
        // } catch (e) {
        //   if (kDebugMode) print(e);
        // }
        // return;
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification notif = message.notification!;
      if (kDebugMode) {
        print('>>>>>>>>>>>>>>>>>>>> Incoming Message from Firebase Server');
        print('${notif.title}\n${notif.body}');
      }

      // _local now
      BigTextStyleInformation btsi = BigTextStyleInformation(
        notif.body.toString(),
        htmlFormatBigText: true,
        contentTitle: notif.title.toString(),
        htmlFormatContentTitle: true,
      );
      AndroidNotificationDetails and = AndroidNotificationDetails(
        'notif_channel',
        'notif_channel',
        importance: Importance.high,
        styleInformation: btsi,
        priority: Priority.high,
        playSound: true,
      );
      NotificationDetails notifDetails = NotificationDetails(
        android: and,
        iOS: const DarwinNotificationDetails(),
      );
      await flnp.show(
        0,
        notif.title,
        notif.body,
        notifDetails,
        payload: message.data['body'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) print("Starting to build Gate");
    if (kIsWeb) {
      // TODO web environment, handle token for notifications?
    }

    if (currentUser.getUser()?.uid == ADMIN_UID) {
      // TODO: admin uid hard set; temporary (bad?) solution
      // UID saved in db? match token?
      return Admin(currentUser);
    }
    return Basket(currentUser);
  }
}
