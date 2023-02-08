import 'package:flutter/material.dart';
import 'package:music_player/screens/bottom_navBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'S Player',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: BottomNavBar(),
    );
  }
}
