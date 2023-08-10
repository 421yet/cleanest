import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sunshine_cleanest/current_user.dart';

class UserManagement {
  final String _last4digits;
  CurrentUser currentUser;

  UserManagement(this._last4digits, this.currentUser);

  bool validate() {
    if (_last4digits.length != 4) {
      return false;
    }
    // print("Validating pin length is 4");
    return true;
  }

  Future<String> authenticate() async {
    if (!validate()) {
      throw Exception("Something is very wrong here");
    }

    StreamSubscription<User?> sub = currentUser.logIn();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$_last4digits@sunshine.com",
        password: "000000", // TODO street number
      );
      if (currentUser.getUser() == credential.user) {
        if (kDebugMode) {
          print(
              "LOGIN.DART (UserManagement.authenticate): Successful login by ${credential.user?.uid}");
        }
        // TODO auth change steam subscription... never cancel?
        // Future<void> subOffSuccess = sub.cancel();
        // if (kDebugMode) {
        //   subOffSuccess.then((void value) =>
        //       print("Subscription to Auth Stream properly cancelled."));
        // }
        return 'success';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return _last4digits;
      }
      if (e.code == 'network-request-failed' || e.code == 'timeout') {
        throw Exception(// change these to print when debugging offline
            "Couldn't sign in (timeout or request failed): ${e.code}");
      } // something to the effect of: no connection
      // else if (e.code == 'wrong-password') {
      //   // TODO handle "wrong passwrod" scenarios
      // }
      else {
        throw Exception("Couldn't sign in (?): ${e.code}");
      }
    }

    return 'failure';
  }
}

// Future<UserCredential?> createAccount(
//     String last4digits, String password) async {
//   try {
//     final credential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: "$last4digits@gmail.com",
//       password: "000000",
//     );
//     return credential;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'email-already-in-use') {
//       print('The account already exists for that email.');
//     }
//     return null;
//   } catch (e) {
//     print(e);
//     return null;
//   }
// }
