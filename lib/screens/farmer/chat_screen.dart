import 'package:flutter/material.dart';
import 'dart:io';

import '../../services/chat_service.dart';
import '../../services/media_service.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../profile_screen.dart';
import '../../widgets/location_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  final MediaService _mediaService = MediaService();

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
    _mediaService.dispose();
    super.dispose();
  }

  // Handle image selection from camera
  Future<void> _handleCameraImage() async {
    final File? imageFile = await _mediaService.pickImageFromCamera();
    if (imageFile != null) {
      final mediaAttachment = _mediaService.createMediaAttachment(
        imageFile,
        MediaType.image,
      );
      await ChatService.instance.sendMessage(
        'Image captured',
        mediaAttachment: mediaAttachment,
      );
      _scrollToBottom();
    }
  }

  // Handle image selection from gallery
  Future<void> _handleGalleryImage() async {
    final File? imageFile = await _mediaService.pickImageFromGallery();
    if (imageFile != null) {
      final mediaAttachment = _mediaService.createMediaAttachment(
        imageFile,
        MediaType.image,
      );
      await ChatService.instance.sendMessage(
        'Image selected from gallery',
        mediaAttachment: mediaAttachment,
      );
      _scrollToBottom();
    }
  }

  // Handle voice recording
  Future<void> _handleVoiceRecording() async {
    if (_mediaService.isRecording) {
      // Stop recording
      final File? audioFile = await _mediaService.stopVoiceRecording();
      if (audioFile != null) {
        final mediaAttachment = _mediaService.createMediaAttachment(
          audioFile,
          MediaType.voice,
        );
        await ChatService.instance.sendMessage(
          'Voice message recorded',
          mediaAttachment: mediaAttachment,
        );
        _scrollToBottom();
      }
    } else {
      // Start recording
      await _mediaService.startVoiceRecording();
    }
  }

  // Scroll to bottom of chat
  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('Agri Sahayak'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LocationIndicator(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
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
              mediaService: _mediaService,
              onSend: (String text) async {
                if (text.trim().isEmpty) return;
                await ChatService.instance.sendMessage(text.trim());
                _textController.clear();
                await _scrollToBottom();
              },
              onCameraTap: _handleCameraImage,
              onGalleryTap: _handleGalleryImage,
              onVoiceTap: _handleVoiceRecording,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.mediaService,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onVoiceTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final MediaService mediaService;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onVoiceTap;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> with TickerProviderStateMixin {
  late AnimationController _micController;
  late AnimationController _cameraController;
  late AnimationController _galleryController;
  late Animation<double> _micAnimation;
  late Animation<double> _cameraAnimation;
  late Animation<double> _galleryAnimation;

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
    _galleryController = AnimationController(
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

    _galleryAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _galleryController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _micController.dispose();
    _cameraController.dispose();
    _galleryController.dispose();
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
              // Voice recording button
              GestureDetector(
                onTapDown: (_) => _micController.forward(),
                onTapUp: (_) => _micController.reverse(),
                onTapCancel: () => _micController.reverse(),
                onTap: widget.onVoiceTap,
                child: AnimatedBuilder(
                  animation: _micAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _micAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.mediaService.isRecording
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.mediaService.isRecording
                              ? Icons.stop
                              : Icons.mic_none,
                          color: widget.mediaService.isRecording
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Camera button
              GestureDetector(
                onTapDown: (_) => _cameraController.forward(),
                onTapUp: (_) => _cameraController.reverse(),
                onTapCancel: () => _cameraController.reverse(),
                onTap: widget.onCameraTap,
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

              // Gallery button
              GestureDetector(
                onTapDown: (_) => _galleryController.forward(),
                onTapUp: (_) => _galleryController.reverse(),
                onTapCancel: () => _galleryController.reverse(),
                onTap: widget.onGalleryTap,
                child: AnimatedBuilder(
                  animation: _galleryAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _galleryAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library_outlined,
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
