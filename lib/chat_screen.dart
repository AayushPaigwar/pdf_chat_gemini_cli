import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf_chat_gemini/api_service.dart';
import 'package:pdf_chat_gemini/neo_box.dart';
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
  String? _extractedPdfText;
  String? _fileName;
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _uploadPdf() async {
    setState(() => _isLoading = true);
    File? file = await PdfHelper.pickPdfFile();

    if (file != null) {
      String text = await PdfHelper.extractTextFromPdf(file);
      setState(() {
        _extractedPdfText = text;
        _fileName = file.path.split('/').last;
        _messages.add(
          Message(
            text:
                "📄 PDF Loaded: $_fileName\n\nYou can now ask questions about this document.",
            isUser: false,
          ),
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF Text Extracted Successfully!'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _sendMessage() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    if (_extractedPdfText == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a PDF first.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _messages.add(Message(text: question, isUser: true));
      _isLoading = true;
    });
    _controller.clear();

    final prompt =
        "You are an AI assistant analyzing this PDF document. "
        "Content:\n\n$_extractedPdfText\n\n"
        "User Question: $question";

    final response = await ApiService.sendMessage(prompt);

    setState(() {
      _messages.add(
        Message(
          text: response ?? "Sorry, I encountered an error.",
          isUser: false,
        ),
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF0), // Off-white/Cream
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDF0),
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.black, height: 3),
        ),
        title: const Text(
          'GEMINI PDF CHAT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.5,
            color: Colors.black
          ),
        ),
        actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.black),
                onPressed: () {},
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // File Info Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: NeoBox(
              color: const Color(0xFFB4F8C8), // Neo Mint
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: const Icon(
                      Icons.description,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _fileName ?? 'NO PDF SELECTED',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _fileName != null
                              ? 'READY TO CHAT'
                              : 'UPLOAD TO START',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _uploadPdf,
                      icon: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'UPLOAD',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat Area
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: NeoBox(
                      width: 300,
                      height: 200,
                      color: Colors.white,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 40,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'UPLOAD A PDF\nTO START CHATTING',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: NeoBox(
                            color: message.isUser ? const Color(0xFFFFC900) : Colors.white, // Yellow vs White
                            shadowColor: Colors.black,
                            shadowOffset: const Offset(4, 4),
                            borderRadius: BorderRadius.circular(0), // Sharp edges
                            padding: const EdgeInsets.all(16),
                            // Limit width to 85% of screen
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!message.isUser)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.smart_toy,
                                          size: 16,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(width: 5),
                                        const Text(
                                          'GEMINI',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                MarkdownBody(
                                  data: message.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(color: Colors.black, fontSize: 15, height: 1.5),
                                    strong: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    code: TextStyle(
                                      backgroundColor: Colors.black.withValues(alpha: 0.1),
                                      color: Colors.black,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input Area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: NeoBox(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'TYPE HERE...',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold
                          ),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Container(
                      padding: const EdgeInsets.all(12),
                       decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle
                       ),
                      width: 48,
                      height: 48,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  else
                    Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: _sendMessage,
                        ),
                    ),
                ],
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
