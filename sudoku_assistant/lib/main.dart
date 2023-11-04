import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:sudoku_assistant/views/home_screen.dart';
import 'package:sudoku_assistant/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures plugin services are initialized
  // await Firebase.initializeApp(); // Initialize Firebase
  await LocalStorageService.initialize(); // Initialize local storage service

  runApp(const SudokuAssistantApp());
}

class SudokuAssistantApp extends StatelessWidget {
  const SudokuAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(), // The first screen displayed when the app is launched
    );
  }
}
