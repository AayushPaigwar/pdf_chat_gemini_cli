import 'dart:convert';
import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Using gemini-1.5-flash for speed and efficiency.
  // You can change this to 'gemini-pro' or other available models.
  static const String _modelName = 'gemini-2.5-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent';

  /// Sends a prompt to the Gemini API and returns the generated text.
  ///
  /// [prompt] is the full text input (including context and question).
  static Future<String?> sendMessage(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'Error: API Key not found. Please check your .env file.';
    }

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parse the response structure of Gemini API
        // candidates -> content -> parts -> text
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return 'Error: API returned status ${response.statusCode}.';
      }
    } catch (e) {
      log('Network Error: $e');
      return 'Error: Failed to connect to the API.';
    }
    return 'Error: No valid response from AI.';
  }
}
