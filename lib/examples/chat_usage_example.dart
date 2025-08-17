import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';

/// Example of how to use the updated ChatService with Gemini API
class ChatUsageExample {
  /// Initialize the chat service (call this when your app starts)
  static void initializeChat() {
    // Make sure you've updated lib/services/secrets.dart with your API key
    ChatService.instance.initializeGemini();
  }

  /// Example of sending different types of messages
  static Future<void> sendExampleMessages() async {
    // Price-related query (will show chart component with markdown response)
    await ChatService.instance.sendMessage(
      "What's the current price of wheat and what factors affect it?",
    );

    // Policy-related query (will show policy card with markdown response)
    await ChatService.instance.sendMessage(
      "Tell me about PM-KISAN benefits and eligibility criteria",
    );

    // Disease-related query (will show diagnosis card with markdown response)
    await ChatService.instance.sendMessage(
      "My tomato plants have yellow leaves, what diseases could this be and how do I treat them?",
    );

    // Help-related query (will show community prompt with markdown response)
    await ChatService.instance.sendMessage(
      "How do I improve soil fertility naturally? Give me step-by-step instructions",
    );

    // General query (will show regular markdown response)
    await ChatService.instance.sendMessage(
      "What crops are best for monsoon season? Include planting tips and care instructions",
    );
  }

  /// Example of listening to chat messages
  static void listenToMessages() {
    ChatService.instance.messages.addListener(() {
      final messages = ChatService.instance.messages.value;
      print('New message received: ${messages.last.text}');

      // Check if it's a typing indicator
      if (messages.last.isTyping) {
        print('Agent is typing...');
      }

      // Check component type
      switch (messages.last.componentType) {
        case ChatComponentType.chart:
          print('Message includes chart component');
          break;
        case ChatComponentType.diagnosisCard:
          print('Message includes diagnosis card');
          break;
        case ChatComponentType.policyCard:
          print('Message includes policy card');
          break;
        case ChatComponentType.communityPrompt:
          print('Message includes community prompt');
          break;
        case ChatComponentType.weatherCard:
          print('Message includes weather card');
          break;
        case ChatComponentType.soilAnalysisCard:
          print('Message includes soil analysis card');
          break;
        case ChatComponentType.cropReportCard:
          print('Message includes crop report card');
          break;
        case ChatComponentType.visualDiagnosisCard:
          print('Message includes visual diagnosis card');
          break;
        case ChatComponentType.contactAdvisorCard:
          print('Message includes contact advisor card');
          break;
        case ChatComponentType.timeSeriesChartCard:
          print('Message includes time series chart');
          break;
        case ChatComponentType.comparisonTableCard:
          print('Message includes comparison table');
          break;
        case ChatComponentType.stepByStepGuideCard:
          print('Message includes step-by-step guide');
          break;
        case ChatComponentType.interactiveChecklistCard:
          print('Message includes interactive checklist');
          break;
        case ChatComponentType.pdfPreviewCard:
          print('Message includes PDF preview card');
          break;
        case ChatComponentType.none:
          print('Regular text message');
          break;
      }
    });
  }

  /// Example of clearing chat history
  static void clearChat() {
    ChatService.instance.clear();
  }
}

/// Example widget showing how to integrate chat in a screen
class ChatExampleWidget extends StatelessWidget {
  const ChatExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Example')),
      body: Column(
        children: [
          // Example buttons
          ElevatedButton(
            onPressed: () => ChatUsageExample.initializeChat(),
            child: const Text('Initialize Chat Service'),
          ),
          ElevatedButton(
            onPressed: () => ChatUsageExample.sendExampleMessages(),
            child: const Text('Send Example Messages'),
          ),
          ElevatedButton(
            onPressed: () => ChatUsageExample.clearChat(),
            child: const Text('Clear Chat'),
          ),

          // Display messages
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: ChatService.instance.messages,
              builder: (context, messages, child) {
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.text),
                      subtitle: Text(message.sender.name),
                      trailing: message.isTyping
                          ? const CircularProgressIndicator()
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
