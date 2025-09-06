import 'package:flutter/material.dart';
import 'pages/main_screen.dart'; // Import your MainScreen

void main() {
  runApp(const MangoTrackApp());
}

class MangoTrackApp extends StatelessWidget {
  const MangoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropChaser',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MainScreen(), // <-- Use MainScreen for tab navigation
      debugShowCheckedModeBanner: false,
    );
  }
}
