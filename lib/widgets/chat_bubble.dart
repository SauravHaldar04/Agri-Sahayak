import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import 'components/chart_component.dart';
import 'components/diagnosis_card.dart';
import 'components/policy_card.dart';
import 'components/community_prompt.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _contentController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );

    _bubbleController.forward();
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = widget.message.sender == ChatSender.user;
    final Color bubbleColor = isUser ? Colors.green.shade100 : Colors.white;
    final Color borderColor = isUser
        ? Colors.green.shade300
        : Colors.green.shade200;

    Widget child;
    if (widget.message.isTyping) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Typing...',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    } else {
      switch (widget.message.componentType) {
        case ChatComponentType.none:
          child = Text(
            widget.message.text,
            style: TextStyle(
              color: isUser ? Colors.green.shade800 : Colors.green.shade700,
              fontSize: 16,
            ),
          );
          break;
        case ChatComponentType.chart:
          child = ChartComponent(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.diagnosisCard:
          child = DiagnosisCard(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.policyCard:
          child = PolicyCard(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
        case ChatComponentType.communityPrompt:
          child = CommunityPrompt(
            data: widget.message.componentData ?? <String, dynamic>{},
          );
          break;
      }
    }

    return AnimatedBuilder(
      animation: _bubbleAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: _bubbleAnimation.value,
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 20),
                ),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _contentAnimation.value,
                    child: child,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
