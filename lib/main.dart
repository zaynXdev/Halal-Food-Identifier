import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HalalVisionApp());
}

class HalalVisionApp extends StatelessWidget {
  const HalalVisionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halal Vision',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
