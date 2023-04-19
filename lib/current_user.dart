import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

class CurrentUser {
  static User? _user;
  // ValueKey<User?> _loggedOut = const ValueKey(null);
  static String _userName = 'Sunshine';

  CurrentUser();
  CurrentUser.vacant() {
    _user = null;
  }

  bool userExists() {
    return _user != null;
  }

  User? getUser() {
    return _user;
  }

  Future<String> getAddress() async {
    if (!userExists()) {
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
    if (userExists() && _userName == 'Sunshine') {
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

  void logIn(User? newUser) {
    if (userExists()) {
      if (newUser == _user) {
        if (kDebugMode) {
          print("LOGIN Warning (current_user.dart): already logged in");
        }
      }
      return;
    }
    if (newUser == null) {
      throw Exception("LOGIN ERROR (current_user.dart): newUser null");
    }
    _user = newUser;
  }

  void logOut() {
    // TODO do FirebaseAuth.instance.signOut(); here?

    if (!userExists()) {
      // ignore: avoid_print
      print("LOGOUT Warning (current_user.dart): no user to log out");
    }
    _user = null;
    _userName = 'Sunshine';
  }
}
