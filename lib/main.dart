import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_chat_gemini/chat_screen.dart';

Future<void> main() async {
  // Load environment variables from .env file
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE0E7FF), // Periwinkle Blue background
        primaryColor: Colors.black,
        textTheme: GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
          primary: Colors.black,
          secondary: const Color(0xFFFF90E8), // Pink
          tertiary: const Color(0xFFFFC900), // Yellow
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
