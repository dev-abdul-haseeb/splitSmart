import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class colorProvider extends ChangeNotifier {
  final lightColors = {
    'Primary': Color.fromRGBO(99, 102, 241, 1),
    'Accent': Color.fromRGBO(16, 185, 129, 1),
    'Button': Color.fromRGBO(249, 115, 22, 1),
    'Success': Color.fromRGBO(132, 204, 22, 1),
    'Error': Color.fromRGBO(239, 68, 68, 1),
    'Background': Color.fromRGBO(249, 250, 251, 1),
    'Surface': Color.fromRGBO(229, 231, 235, 1),
    'Text Primary': Color.fromRGBO(31, 41, 55, 1),
    'Text Secondary': Color.fromRGBO(107, 114, 128, 1),
    'Divider': Color.fromRGBO(209, 213, 219, 1),
  };
  final darkColors = {
    'Primary': Color.fromRGBO(129, 140, 248, 1),
    'Accent': Color.fromRGBO(52, 211, 153, 1),
    'Button': Color.fromRGBO(251, 146, 60, 1),
    'Success': Color.fromRGBO(163, 230, 53, 1),
    'Error': Color.fromRGBO(248, 113, 113, 1),
    'Background': Color.fromRGBO(30, 41, 59, 1),
    'Surface': Color.fromRGBO(51, 65, 85, 1),
    'Text Primary': Color.fromRGBO(241, 245, 249, 1),
    'Text Secondary': Color.fromRGBO(156, 163, 175, 1),
    'Divider': Color.fromRGBO(71, 85, 105, 1),
  };
  late Map<String, Color> presentTheme;
  bool whiteTheme = true;
  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    whiteTheme = prefs.getBool('isLightTheme') ?? false;
    presentTheme = whiteTheme ? lightColors : darkColors;

    // If no value stored, store light theme by default
    if (!prefs.containsKey('isLightTheme')) {
      await prefs.setBool('isLightTheme', false);
    }
    notifyListeners();
  }
  Future<void> changeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    whiteTheme = !whiteTheme;
    presentTheme = whiteTheme ? lightColors : darkColors;
    await prefs.setBool('isLightTheme', whiteTheme);
    notifyListeners();
  }


}