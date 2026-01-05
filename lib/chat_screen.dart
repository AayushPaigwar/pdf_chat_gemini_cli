import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf_chat_gemini/api_service.dart';
import 'package:pdf_chat_gemini/pdf_helper.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Stores the extracted text from the PDF
  String? _extractedPdfText;
  
  // Name of the uploaded file to show in UI
  String? _fileName;

  // List of chat messages
  final List<Message> _messages = [];

  // Controller for the text input
  final TextEditingController _controller = TextEditingController();

  // Loading state
  bool _isLoading = false;

  /// Pick a PDF file and extract its text
  Future<void> _uploadPdf() async {
    setState(() => _isLoading = true);
    
    File? file = await PdfHelper.pickPdfFile();
    
    if (file != null) {
      String text = await PdfHelper.extractTextFromPdf(file);
      setState(() {
        _extractedPdfText = text;
        _fileName = file.path.split('/').last;
        
        // Add a system message to chat indicating success
        _messages.add(Message(
          text: "PDF Loaded: $_fileName\nYou can now ask questions about it.",
          isUser: false,
        ));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Text Extracted Successfully!')), 
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancelled file picker')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  /// Send message to Gemini API
  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    // Check if PDF is loaded
    if (_extractedPdfText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF first.')),
      );
      return;
    }

    // Add user message to UI
    setState(() {
      _messages.add(Message(text: question, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    // Construct the prompt
    // We combine the PDF content and the user question.
    // NOTE: Gemini has a context window limit. Very large PDFs might need truncation or chunking.
    // For this simple example, we send the whole text.
    final prompt = "You are an AI that answers questions based on this PDF. "
        "Here is the PDF content:\n\n$_extractedPdfText\n\n"
        "Question: $question";

    // Call API
    final response = await ApiService.sendMessage(prompt);

    // Add AI response to UI
    setState(() {
      _messages.add(Message(text: response ?? "Error getting response", isUser: false));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini PDF Chat'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Info Section: Show loaded file or instruction
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fileName != null 
                        ? 'Current File: $_fileName' 
                        : 'No PDF uploaded yet.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadPdf,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Upload a PDF and ask questions!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser 
                            ? Alignment.centerRight 
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75
                          ),
                          decoration: BoxDecoration(
                            color: message.isUser 
                                ? Colors.deepPurple[100] 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                              )
                            ]
                          ),
                          child: MarkdownBody(
                            data: message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: message.isUser ? Colors.black87 : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input Area
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 5
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question...', 
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
          // Add safe area for bottom devices (like iPhone X+) 
          SizedBox(height: MediaQuery.of(context).padding.bottom), 
        ],
      ),
    );
  }
}
