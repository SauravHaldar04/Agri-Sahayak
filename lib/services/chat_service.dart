import 'dart:math';
import 'dart:convert'; // Added for json.decode

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_message.dart';
import 'secrets.dart';
import 'location_service.dart';

class ChatService {
  ChatService._internal();
  static final ChatService instance = ChatService._internal();

  final ValueNotifier<List<ChatMessage>> messages =
      ValueNotifier<List<ChatMessage>>(<ChatMessage>[]);

  // Gemini API configuration
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  bool _isInitialized = false;

  // Location service
  final LocationService _locationService = LocationService();

  void initializeGemini() {
    if (_isInitialized) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: Secrets.geminiApiKey,
      );
      _chatSession = _model.startChat();
      _isInitialized = true;
      if (kDebugMode) {
        print('Gemini initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Gemini: $e');
      }
      _isInitialized = false;
    }
  }

  Future<void> sendMessage(
    String text, {
    MediaAttachment? mediaAttachment,
  }) async {
    // Initialize Gemini if not already initialized
    if (!_isInitialized) {
      initializeGemini();
    }

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

    // Get current location
    Map<String, dynamic>? locationData;
    try {
      await _locationService.getCurrentLocation();
      locationData = _locationService.getLocationData();
      if (locationData != null && kDebugMode) {
        print(
          '📍 Location data: ${locationData['latitude']}, ${locationData['longitude']}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to get location: $e');
      }
    }

    final ChatMessage userMessage = ChatMessage(
      id: _generateId(),
      text: text,
      sender: ChatSender.user,
      mediaAttachment: mediaAttachment,
      locationData: locationData, // Include location data
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

      // Prepare prompt based on media type and location
      String prompt = text;
      String locationContext = '';

      if (locationData != null) {
        locationContext =
            '\n\nUser Location: ${locationData['latitude']}, ${locationData['longitude']}';
        if (locationData['address'] != null) {
          locationContext += '\nAddress: ${locationData['address']}';
        }
      }

      if (mediaAttachment != null) {
        switch (mediaAttachment.type) {
          case MediaType.image:
            prompt =
                'User sent an image with the message: "$text". Please analyze the image and provide agricultural advice.$locationContext';
            break;
          case MediaType.voice:
            prompt =
                'User sent a voice message with the text: "$text". Please provide agricultural advice based on their voice message.$locationContext';
            break;
          case MediaType.none:
            prompt = '$text$locationContext';
            break;
        }
      } else {
        prompt = '$text$locationContext';
      }

      // Check if this is a PDF-related query
      bool isPdfQuery = _isPdfRelatedQuery(text);

      String finalPrompt;
      if (isPdfQuery) {
        finalPrompt = '''
        The user is asking about: $text
        
        Analyze this agricultural question and respond with a JSON object that includes a PDF component. Use this format:
        
        {
          "componentType": "pdfPreviewCard",
          "componentData": {
            "pdfAsset": "assets/pdf/agriculture.pdf",
            "title": "Complete Agriculture Guide",
            "description": "Comprehensive agricultural reference guide covering all aspects of farming, crop management, and best practices.",
            "voiceOverview": "This comprehensive agriculture guide covers essential farming practices including crop management, pest control, soil health, irrigation techniques, and sustainable farming methods. It serves as a complete reference for modern agricultural practices.",
            "category": "Reference Guide",
            "fileSize": "3.2 MB",
            "pages": "120"
          },
          "text": "I've found relevant information for your question. Please check the comprehensive agriculture guide below which covers this topic in detail.",
          "markdown": "I've found relevant information for your question. Please check the **Complete Agriculture Guide** below which covers this topic in detail."
        }
        
        Question: $prompt
        ''';
      } else {
        finalPrompt = '''
        You are an agricultural expert. Analyze the following question and respond with a JSON object that specifies the component type and required data. Use this format:
        
        {
          "componentType": "component_name",
          "componentData": {
            // specific data for the component
          },
          "text": "Human readable response text",
          "markdown": "Markdown formatted response"
        }
        
        Available component types:
        - weatherCard: for weather queries
        - cropReportCard: for crop status/reports
        - timeSeriesChartCard: for trend data
        - comparisonTableCard: for comparisons
        - soilAnalysisCard: for soil health
        - visualDiagnosisCard: for plant problems
        - stepByStepGuideCard: for processes
        - interactiveChecklistCard: for task lists
        - policyCard: for government schemes
        - contactAdvisorCard: for expert contact
        - pdfPreviewCard: for documents with voice overview
        - none: for general responses
        
        Question: $prompt
        ''';
      }

      // Get response from Gemini
      final response = await _chatSession.sendMessage(Content.text(finalPrompt));
      final responseText =
          response.text ?? 'Sorry, I couldn\'t generate a response.';

      // Remove typing indicator
      messages.value = List<ChatMessage>.from(messages.value)
        ..removeWhere((msg) => msg.isTyping == true);

      // Try to parse JSON response
      ChatMessage responseMessage;
      try {
        final jsonData = _parseGeminiResponse(responseText);
        final componentType = _getComponentTypeFromJson(jsonData);

        // Log the component type being generated
        if (kDebugMode) {
          print('🎯 Gemini generated component type: ${componentType.name}');
          print('📊 Component data: ${jsonData['componentData']}');
          print('📝 Text field: ${jsonData['text']}');
          print('📝 Markdown field: ${jsonData['markdown']}');
          print('🔧 About to create ChatMessage with:');
          print('  - id: ${_generateId()}');
          print('  - text: ${jsonData['text'] ?? responseText}');
          print('  - sender: ${ChatSender.agent.name}');
          print('  - markdown: ${jsonData['markdown']}');
          print('  - componentType: ${componentType.name}');
          print('  - componentData: ${jsonData['componentData']}');
          print('  - jsonResponse: $jsonData');
        }

        responseMessage = ChatMessage(
          id: _generateId(),
          text: jsonData['text'] ?? responseText,
          sender: ChatSender.agent,
          markdown: jsonData['markdown'],
          componentType: componentType,
          componentData: jsonData['componentData'],
          jsonResponse: jsonData,
        );

        if (kDebugMode) {
          print('✅ ChatMessage created successfully');
        }
      } catch (e, stackTrace) {
        // Fallback to default markdown response
        if (kDebugMode) {
          print('⚠️ JSON parsing failed, falling back to markdown: $e');
          print('📝 Full response text: $responseText');
          print('🔍 Stack trace: $stackTrace');
        }

        responseMessage = ChatMessage(
          id: _generateId(),
          text: responseText,
          sender: ChatSender.agent,
          markdown: responseText,
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

  Map<String, dynamic> _parseGeminiResponse(String response) {
    try {
      if (kDebugMode) {
        print('🔍 Attempting to parse response: ${response.length} characters');
        print('🔍 Full response text: "$response"');
      }

      // Try to extract JSON from the response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (kDebugMode) {
        print('🔍 JSON start: $jsonStart, JSON end: $jsonEnd');
      }

      if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd + 1);
        if (kDebugMode) {
          print('🔍 Extracted JSON string: "$jsonString"');
          print(
            '🔍 Extracted JSON string length: ${jsonString.length} characters',
          );
        }

        final parsed = json.decode(jsonString) as Map<String, dynamic>;
        if (kDebugMode) {
          print('✅ JSON parsed successfully');
          print('✅ Parsed data: $parsed');
        }
        return parsed;
      }

      if (kDebugMode) {
        print('⚠️ No JSON brackets found in response');
      }
      // If no JSON found, return default structure
      return {
        'componentType': 'none',
        'text': response,
        'markdown': response,
        'componentData': null,
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ JSON parsing error: $e');
        print('🔍 Stack trace: $stackTrace');
      }
      // Return default structure on parse error
      return {
        'componentType': 'none',
        'text': response,
        'markdown': response,
        'componentData': null,
      };
    }
  }

  ChatComponentType _getComponentTypeFromJson(Map<String, dynamic> jsonData) {
    final componentType = jsonData['componentType']?.toString().toLowerCase();

    switch (componentType) {
      case 'weathercard':
        return ChatComponentType.weatherCard;
      case 'cropreportcard':
        return ChatComponentType.cropReportCard;
      case 'timeserieschartcard':
        return ChatComponentType.timeSeriesChartCard;
      case 'comparisontablecard':
        return ChatComponentType.comparisonTableCard;
      case 'soilanalysiscard':
        return ChatComponentType.soilAnalysisCard;
      case 'visualdiagnosiscard':
        return ChatComponentType.visualDiagnosisCard;
      case 'stepbystepguidecard':
        return ChatComponentType.stepByStepGuideCard;
      case 'interactivechecklistcard':
        return ChatComponentType.interactiveChecklistCard;
      case 'policycard':
        return ChatComponentType.policyCard;
      case 'contactadvisorcard':
        return ChatComponentType.contactAdvisorCard;
      case 'pdfpreviewcard':
        return ChatComponentType.pdfPreviewCard;
      case 'chart':
        return ChatComponentType.chart;
      case 'diagnosiscard':
        return ChatComponentType.diagnosisCard;
      case 'communityprompt':
        return ChatComponentType.communityPrompt;
      default:
        return ChatComponentType.none;
    }
  }

  // Check if message is asking about a PDF or document
  bool _isPdfRelatedQuery(String message) {
    final lowerMessage = message.toLowerCase();
    final pdfKeywords = [
      'pdf', 'document', 'guide', 'manual', 'guideline', 'handbook', 
      'brochure', 'report', 'policy', 'scheme details', 'application form',
      'organic farming', 'crop rotation', 'pest management', 'soil health',
      'fertilizer guide', 'irrigation manual', 'seed treatment', 'harvesting guide',
      'farming guide', 'agriculture guide', 'help document', 'reference'
    ];
    
    return pdfKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
}
