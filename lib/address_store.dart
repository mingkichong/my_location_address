import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import './constant.dart';

class AddressStore {
  static Future<String> readAddress(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constant.SHARED_PREF_ADDRESS) ?? Constant.DEFAULT_ADDRESS;
  }

  static void writeAddress(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constant.SHARED_PREF_ADDRESS, value);
  }
}
