import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GeoGuideApp());
}

class GeoGuideApp extends StatelessWidget {
  const GeoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GeoGuide',
      home: const HomeScreen(),
    );
  }
}
