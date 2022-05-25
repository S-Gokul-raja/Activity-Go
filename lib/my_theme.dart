import 'package:flutter/material.dart';

class MyTheme {
  static const List<Color> colors = [
    Colors.brown,
    Colors.deepOrange,
    Colors.pink,
    Colors.amber,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.tealAccent,
    Colors.deepPurpleAccent,
    Colors.purple,
    Colors.grey,
    Colors.blueGrey,
  ];
  static const TextStyle title1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle title2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle title3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static BoxDecoration boxDecoration = BoxDecoration(
    border: Border.all(width: 2),
    borderRadius: BorderRadius.circular(10),
  );
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      iconTheme: IconThemeData(
        size: 30,
      ),
      backgroundColor: Colors.transparent,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.grey,
      secondary: Colors.grey,
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    iconTheme: const IconThemeData(
      size: 30,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.grey,
      secondary: Colors.grey,
    ),
  );
}
