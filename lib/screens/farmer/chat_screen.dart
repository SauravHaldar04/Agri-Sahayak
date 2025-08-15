import 'package:flutter/material.dart';

import '../../services/chat_service.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.agriculture,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Advisor Chat'),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.green.shade200,
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ValueListenableBuilder<List<ChatMessage>>(
                valueListenable: ChatService.instance.messages,
                builder:
                    (
                      BuildContext context,
                      List<ChatMessage> messages,
                      Widget? _,
                    ) {
                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.green.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start a conversation with your advisor',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ask about crops, prices, or farming techniques',
                                style: TextStyle(
                                  color: Colors.green.shade500,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimatedSlide(
                            duration: const Duration(milliseconds: 300),
                            offset: Offset.zero,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: 1.0,
                              child: ChatBubble(message: messages[index]),
                            ),
                          );
                        },
                      );
                    },
              ),
            ),
            _InputBar(
              controller: _textController,
              onSend: (String text) async {
                if (text.trim().isEmpty) return;
                await ChatService.instance.sendMessage(text.trim());
                _textController.clear();
                await Future<void>.delayed(const Duration(milliseconds: 50));
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final ValueChanged<String> onSend;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> with TickerProviderStateMixin {
  late AnimationController _micController;
  late AnimationController _cameraController;
  late Animation<double> _micAnimation;
  late Animation<double> _cameraAnimation;

  @override
  void initState() {
    super.initState();
    _micController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _cameraController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _micAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _micController, curve: Curves.easeInOut));

    _cameraAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _micController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTapDown: (_) => _micController.forward(),
                onTapUp: (_) => _micController.reverse(),
                onTapCancel: () => _micController.reverse(),
                child: AnimatedBuilder(
                  animation: _micAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _micAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mic_none,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTapDown: (_) => _cameraController.forward(),
                onTapUp: (_) => _cameraController.reverse(),
                onTapCancel: () => _cameraController.reverse(),
                child: AnimatedBuilder(
                  animation: _cameraAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _cameraAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: widget.onSend,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => widget.onSend(widget.controller.text),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade300,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
