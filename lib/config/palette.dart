//palette.dart
import 'package:flutter/material.dart';

class Palette {
  /// Class with one function `.getShades()` that produces a `MaterialColor`
  /// object that can be used as a `primarySwatch` for `ThemeData` in
  /// `MaterialApp`.
  ///
  /// The `mainColor` argument must be a `Color` object.

  final Color mainColor;

  Palette(this.mainColor);

  MaterialColor getShades() {
    int r = mainColor.red ~/ 10;
    int g = mainColor.green ~/ 10;
    int b = mainColor.blue ~/ 10;
    return MaterialColor(
      mainColor.value,
      <int, Color>{
        50: Color.fromARGB(255, r * 9, g * 9, b * 9), //10%
        100: Color.fromARGB(255, r * 8, g * 8, b * 8), //20%
        200: Color.fromARGB(255, r * 7, g * 7, b * 7), //30%
        300: Color.fromARGB(255, r * 6, g * 6, b * 6), //40%
        400: Color.fromARGB(255, r * 5, g * 5, b * 5), //50%
        500: Color.fromARGB(255, r * 4, g * 4, b * 4), //60%
        600: Color.fromARGB(255, r * 3, g * 3, b * 3), //70%
        700: Color.fromARGB(255, r * 2, g * 2, b * 2), //80%
        800: Color.fromARGB(255, r * 1, g * 1, b * 1), //90%
        900: Color.fromARGB(255, r * 0, g * 0, b * 0), //100%
      },
    );
  }
}
