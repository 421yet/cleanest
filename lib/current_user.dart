import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

class CurrentUser {
  static User? _user = FirebaseAuth.instance.currentUser;
  // ValueKey<User?> _loggedOut = const ValueKey(null);
  static String _userName = 'Sunshine';

  const CurrentUser();

  bool userLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  User? getUser() {
    return _user;
  }

  Future<String> getAddress() async {
    if (!userLoggedIn()) {
      throw Exception("User doesn't exist (internal)");
    }
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref(_user!.uid)
          .child('address')
          .once(DatabaseEventType.value);
      return event.snapshot.value as String;
    } catch (error) {
      throw Exception("Couldn't fetch address: \n$error");
    }
  }

  Future<String> getName() async {
    if (userLoggedIn() && _userName == 'Sunshine') {
      try {
        final DatabaseEvent event = await FirebaseDatabase.instance
            .ref('Sonnims')
            .child(_user!.uid)
            .child('name')
            .once(DatabaseEventType.value);
        _userName = event.snapshot.value as String;
      } catch (e) {
        throw Exception("$_user, $_userName | error: $e");
      }
    }
    return _userName;
  }

  StreamSubscription<User?> logIn() {
    if (_user != null) {
      throw Exception("Sonnim already logged in.");
    }
    StreamSubscription<User?> userAuthStreamSub =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        FirebaseDatabase.instance
            .ref('Sonnims')
            .child(user.uid)
            .child('name')
            .once()
            .then((value) => _userName = value as String);
      }
      // TODO: Could user auth state changes when not explicitly logging in/out?
    });

    return userAuthStreamSub;
  }

  void logOut() {
    if (_user == null) {
      throw Exception("Sonnim already logged out.");
    }
    StreamSubscription<User?> streamSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        throw Exception("Sonnim couldn't log out via FirebaseAuth.");
      }
      _user = null;
    });
    FirebaseAuth.instance.signOut();
    _userName = 'Sunshine';
  }
}
