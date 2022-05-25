import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyThemeProvider with ChangeNotifier {
  static const String isDarkModeBox = 'isDarkModeBox';
  Color get fontColor => isDarkMode ? Colors.white : Colors.black;
  Color get bgColor => isDarkMode ? Colors.black : Colors.white;
  bool isDarkMode = false;

  MyThemeProvider() {
    init();
  }
  init() async {
    Box box = await Hive.openBox(isDarkModeBox);
    isDarkMode = box.get('darkMode', defaultValue: false);
    notifyListeners();
  }

  void toggle() async {
    isDarkMode = !isDarkMode;
    Box box = await Hive.openBox(isDarkModeBox);
    box.put('darkMode', isDarkMode);
    log("darkMode: $isDarkMode");
    notifyListeners();
  }
}
