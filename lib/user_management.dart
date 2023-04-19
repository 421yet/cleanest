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

  Future<String?> authenticate() async {
    if (!validate()) {
      return null;
    }
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "$_last4digits@sunshine.com",
        password: "000000", // street number
      );
      if (kDebugMode) {
        print(
            "LOGIN.DART (UserManagement.authenticate): Successful login by ${credential.user?.uid}");
      }
      currentUser.logIn(credential.user!);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return _last4digits;
      }
      if (e.code == 'network-request-failed' || e.code == 'timeout') {
        throw Exception(// change these to print when debugging offline
            "Couldn't sign in (timeout or request failed): ${e.code}");
      } // something to the effect of: no connection
      else {
        throw Exception("Couldn't sign in (?): ${e.code}");
      }
      // if (e.code == 'wrong-password') {
      //   print('Wrong password provided for that customer.');
      // }
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
}
