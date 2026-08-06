import 'package:flutter/material.dart';
import 'page/home_screen.dart';

void main() {
  runApp(const GPIFleetApp());
}

class GPIFleetApp extends StatelessWidget {
  const GPIFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPI Fleet',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E8E3E),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E8E3E)),
      ),
      home: const HomeScreen(),
    );
  }
}
