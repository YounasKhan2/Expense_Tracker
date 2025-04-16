import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'home_screen.dart'; // Import MyHomePage

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to MyHomePage after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage(username: 'User')),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.monetization_on, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Expense Locator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
