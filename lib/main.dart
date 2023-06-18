// import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'current_user.dart';
// import 'modules/gradient_progress_indicator.dart';
import 'gate.dart';
// import 'admin.dart';
// import 'login.dart';
import 'config/palette.dart';

final Palette appPalette = Palette(const Color.fromARGB(255, 255, 185, 35));

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) print("Handling a background message: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // redundant
  await Firebase.initializeApp(); // app connecgted & initialized to firebase
  await FirebaseMessaging.instance
      .getInitialMessage(); // grab background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  final Future<FirebaseApp> fbApp = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ThemeData themeData = ThemeData(
    colorSchemeSeed: const Color.fromARGB(255, 4, 130, 255),
    useMaterial3: true,
  );

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final CurrentUser currentUser = CurrentUser(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          '/gate': (context) => const Gate(),
          // '/login': (context) => Login(currentUser, context),
        },
        title: 'Sunshine Cleanest',
        theme: widget.themeData,
        // theme: FlexThemeData.light(
        //   scheme: FlexScheme.gold,
        //   surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        //   blendLevel: 20,
        //   appBarOpacity: 0.95,
        //   subThemesData: const FlexSubThemesData(
        //     blendOnLevel: 20,
        //     blendOnColors: false,
        //   ),
        //   visualDensity: FlexColorScheme.comfortablePlatformDensity,
        //   useMaterial3: true,
        //   // fontFamily: GoogleFonts.notoSans().fontFamily,
        // ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.gold,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 15,
          appBarOpacity: 0.90,
          subThemesData: const FlexSubThemesData(
            blendOnLevel: 30,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          useMaterial3: true,
          // To use the playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
        themeMode: ThemeMode.system,
        home: FutureBuilder(
          future: widget.fbApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              // print('error!');
              return const Center(child: Text('Oops! Something went wrong!'));
            } else if (snapshot.hasData) {
              return const Gate();
            } else {
              // loading screen
              return const LinearProgressIndicator();
            }
          },
        ));
  }
}
