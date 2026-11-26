import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/core/constants/app_constants.dart';

///// Uses Provider (ChangeNotifier) because this is simple UI state.
class ThemeProvider extends ChangeNotifier{
  final SharedPreferences _prefs;
  bool _isDark;

  ThemeProvider(this._prefs)
  //SharedPreferences.getBool(key) reads a boolean
  // (true or false) value stored locally on the device under key.
      : _isDark =_prefs.getBool(AppConstants.prefDarkMode)
      ?? false;

 bool get isDark => _isDark;

 ThemeMode get mode => _isDark
     ? ThemeMode.dark
     : ThemeMode.light;

 Future<void> toggle(bool value) async{
   _isDark = value;
   notifyListeners();

   await _prefs.setBool(AppConstants.prefDarkMode, value);
 }
}