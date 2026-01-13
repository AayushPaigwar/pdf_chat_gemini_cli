import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pdf_chat_gemini/api_service.dart';
import 'package:pdf_chat_gemini/glass_box.dart';
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
            backgroundColor: Colors.green,
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
    return Stack(
      children: [
        // 1. Background Layer
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF24243E),
                ],
              ),
            ),
          ),
        ),

        // 2. Ambient Color Blobs (to show off the glass effect)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purpleAccent.withValues(alpha: 0.4),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withValues(alpha: 0.4),
            ),
          ),
        ),

        // 3. Blur Filter for Blobs
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 4. Main Content
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    'Gemini PDF Chat',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              // Spacer for AppBar since we extended body behind it
              const SizedBox(height: 150),

              // File Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassBox(
                  height: 70,
                  opacity: 0.1,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _fileName ?? 'No PDF Selected',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _fileName != null
                                  ? 'Ready to chat'
                                  : 'Upload to start',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: TextButton.icon(
                          onPressed: _isLoading ? null : _uploadPdf,
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Upload',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
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
                        child: GlassBox(
                          width: 300,
                          height: 150,
                          padding: const EdgeInsets.all(20),
                          opacity: 0.05,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline,
                                size: 40,
                                color: Colors.white70,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload a PDF to start chatting',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Align(
                            alignment: message.isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassBox(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: message.isUser
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                  bottomRight: message.isUser
                                      ? Radius.zero
                                      : const Radius.circular(20),
                                ),
                                opacity: message.isUser ? 0.2 : 0.1,
                                padding: const EdgeInsets.all(16),
                                // Limit width to 80% of screen
                                width: MediaQuery.of(context).size.width * 0.8,
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
                                              Icons.auto_awesome,
                                              size: 16,
                                              color: Colors.cyanAccent,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Gemini',
                                              style: TextStyle(
                                                color: Colors.cyanAccent
                                                    .withValues(alpha: 0.8),
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
                                        p: const TextStyle(color: Colors.white),
                                        strong: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        code: TextStyle(
                                          backgroundColor: Colors.black
                                              .withValues(alpha: 0.3),
                                          color: Colors.amberAccent,
                                          fontFamily: 'monospace',
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
                child: GlassBox(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ask a question...',
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.cyanAccent,
                          ),
                          onPressed: _sendMessage,
                        ),
                    ],
                  ),
                ),
              ),

              // Safe area padding
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ],
    );
  }
}
