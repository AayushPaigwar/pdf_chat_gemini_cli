import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_chat_gemini/main.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is present.
    expect(find.text('Gemini PDF Chat'), findsOneWidget);
    
    // Verify that the upload button text is present (might be inside the glass box)
    // Note: Text might be split or styled differently, but 'Upload' is likely there.
    expect(find.textContaining('Upload'), findsWidgets);
  });
}