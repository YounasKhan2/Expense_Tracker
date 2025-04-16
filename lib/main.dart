import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import SplashScreen
import 'home_screen.dart'; // Import MyHomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Locator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}
