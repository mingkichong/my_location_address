import 'package:flutter/material.dart';

import './home_page.dart';

void main() => runApp(MyLocationAddressApp());

class MyLocationAddressApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Location Address',
      theme: ThemeData(
        fontFamily: 'century_gothic',
        primarySwatch: Colors.blueGrey,
        accentColor: Colors.amberAccent,
      ),
      home: HomePage(),
    );
  }
}
