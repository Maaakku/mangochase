import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // add this
import 'pages/main_screen.dart'; // your MainScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); // initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropChaser',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MainScreen(key: MainScreen.globalKey), 
      debugShowCheckedModeBanner: false,
    );
  }
}
