import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

/// Helper class to handle PDF file picking and text extraction.
class PdfHelper {
  /// Picks a PDF file from the device storage.
  /// Returns the [File] object if a file is picked, or null if canceled.
  static Future<File?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      log('Error picking file: $e');
    }
    return null;
  }

  /// Extracts text from the given PDF [file].
  /// Returns the full extracted text as a String.
  static Future<String> extractTextFromPdf(File file) async {
    try {
      // Extract text from the PDF file
      String text = await ReadPdfText.getPDFtext(file.path);

      // Return cleaned text (optional: trim whitespace)
      return text.trim();
    } catch (e) {
      log('Error extracting text: $e');
      return 'Error extracting text from PDF.';
    }
  }
}
