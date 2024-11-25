import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:bhub/screens/Getstarted.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GetStarted(), //first page
    );
  }
}
