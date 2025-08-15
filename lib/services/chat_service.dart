import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import 'secrets.dart';

class ChatService {
  ChatService._internal();
  static final ChatService instance = ChatService._internal();

  final ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>(<ChatMessage>[]);

  // Gemini API configuration
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isInitialized = false;

  void initializeGemini() {
    if (_isInitialized) return;

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Secrets.geminiApiKey,
    );
    _chatSession = _model.startChat();
    _isInitialized = true;
  }

  Future<void> sendMessage(String text) async {
    if (!_isInitialized) {
      // Fallback response if Gemini is not initialized
      final ChatMessage fallback = ChatMessage(
        id: _generateId(),
        text: 'Please provide your Gemini API key to start chatting.',
        sender: ChatSender.agent,
      );
      messages.value = List<ChatMessage>.from(messages.value)..add(fallback);
      return;
    }

    final ChatMessage userMessage = ChatMessage(
      id: _generateId(),
      text: text,
      sender: ChatSender.user,
    );

    messages.value = List<ChatMessage>.from(messages.value)..add(userMessage);

    try {
      // Show typing indicator
      final ChatMessage typingMessage = ChatMessage(
        id: _generateId(),
        text: 'Typing...',
        sender: ChatSender.agent,
        isTyping: true,
      );
      messages.value = List<ChatMessage>.from(messages.value)
        ..add(typingMessage);

      // Get response from Gemini
      final response = await _chatSession.sendMessage(Content.text(text));
      final responseText =
          response.text ?? 'Sorry, I couldn\'t generate a response.';

      // Remove typing indicator
      messages.value = List<ChatMessage>.from(messages.value)
        ..removeWhere((msg) => msg.isTyping == true);

      // Check if response should include special components
      ChatMessage responseMessage;

      if (_shouldShowPriceChart(text, responseText)) {
        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
          componentType: ChatComponentType.chart,
          componentData: <String, dynamic>{
            'title': 'Market Price (₹/quintal)',
            'data': <Map<String, dynamic>>[
              <String, dynamic>{'label': 'Mon', 'value': 1800},
              <String, dynamic>{'label': 'Tue', 'value': 1850},
              <String, dynamic>{'label': 'Wed', 'value': 1750},
              <String, dynamic>{'label': 'Thu', 'value': 1900},
              <String, dynamic>{'label': 'Fri', 'value': 2000},
            ],
          },
        );
      } else if (_shouldShowPolicyCard(text, responseText)) {
        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
          componentType: ChatComponentType.policyCard,
          componentData: <String, dynamic>{
            'title': 'PM-KISAN Benefit',
            'summary':
                'Eligible small farmers get ₹6,000/year in 3 installments.',
            'cta': 'Learn more',
          },
        );
      } else if (_shouldShowDiagnosisCard(text, responseText)) {
        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
          componentType: ChatComponentType.diagnosisCard,
          componentData: <String, dynamic>{
            'issue': 'Plant Health Analysis',
            'probability': 0.85,
            'recommendation':
                'Based on your description, here are the recommended solutions.',
          },
        );
      } else if (_shouldShowCommunityPrompt(text, responseText)) {
        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
          componentType: ChatComponentType.communityPrompt,
          componentData: <String, dynamic>{
            'prompt':
                'Post your question to the community forum to get quick tips from fellow farmers.',
          },
        );
      } else {
        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
        );
      }

      messages.value = List<ChatMessage>.from(messages.value)
        ..add(responseMessage);
    } catch (e) {
      // Remove typing indicator
      messages.value = List<ChatMessage>.from(messages.value)
        ..removeWhere((msg) => msg.isTyping == true);

      // Show error message
      final ChatMessage errorMessage = ChatMessage(
        id: _generateId(),
        text: 'Sorry, I encountered an error. Please try again.',
        sender: ChatSender.agent,
      );
      messages.value = List<ChatMessage>.from(messages.value)
        ..add(errorMessage);
    }
  }

  bool _shouldShowPriceChart(String userInput, String response) {
    final lower = userInput.toLowerCase();
    return lower.contains('price') ||
        lower.contains('market') ||
        lower.contains('cost') ||
        lower.contains('trend');
  }

  bool _shouldShowPolicyCard(String userInput, String response) {
    final lower = userInput.toLowerCase();
    return lower.contains('policy') ||
        lower.contains('scheme') ||
        lower.contains('benefit') ||
        lower.contains('subsidy');
  }

  bool _shouldShowDiagnosisCard(String userInput, String response) {
    final lower = userInput.toLowerCase();
    return lower.contains('diagnose') ||
        lower.contains('disease') ||
        lower.contains('problem') ||
        lower.contains('sick') ||
        lower.contains('pest');
  }

  bool _shouldShowCommunityPrompt(String userInput, String response) {
    final lower = userInput.toLowerCase();
    return lower.contains('help') ||
        lower.contains('how to') ||
        lower.contains('advice') ||
        lower.contains('experience');
  }

  void clear() {
    messages.value = <ChatMessage>[];
    if (_isInitialized) {
      _chatSession = _model.startChat();
    }
  }

  String _generateId() {
    final int randomPart = Random().nextInt(999999);
    return '${DateTime.now().millisecondsSinceEpoch}_$randomPart';
  }
}
