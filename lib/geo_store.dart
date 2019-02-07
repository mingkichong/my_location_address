import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'constant.dart';

class GeoStore {
  static Future<double> _readLatitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(Constant.SHARED_PREF_GEO_LAT) ?? Constant.DEFAULT_GEO_LAT;
  }

  static void writeLatitude(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(Constant.SHARED_PREF_GEO_LAT, value);
  }

  static Future<double> _readLongitude() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(Constant.SHARED_PREF_GEO_LONG) ?? Constant.DEFAULT_GEO_LONG;
  }

  static void writeLongitude(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(Constant.SHARED_PREF_GEO_LONG, value);
  }

  static Future<LatLng> readLatLng() async {
    double lat = await _readLatitude();
    double lng = await _readLongitude();
    return LatLng(lat, lng);
  }
}
