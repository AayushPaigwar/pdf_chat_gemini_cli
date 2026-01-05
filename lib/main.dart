import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf_chat_gemini/chat_screen.dart';

Future<void> main() async {
  // Load environment variables from .env file
  // Ensure the file exists and is added to assets in pubspec.yaml if building for release,
  // but for local dev with flutter_dotenv it reads from root.
  // Note: For Flutter apps, usually assets must be declared.
  // We will handle the assets declaration in pubspec.yaml next.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    log("Warning: .env file not found. Please create one with GEMINI_API_KEY.");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini PDF Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
