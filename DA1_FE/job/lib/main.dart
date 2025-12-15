import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/message_screen.dart';

void main() {
  runApp(JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Finder',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LoginScreen(), // Đặt LoginScreen làm màn hình đầu tiên
      debugShowCheckedModeBanner: false,
    );
  }
}

