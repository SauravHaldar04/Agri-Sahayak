enum ChatSender { user, agent }

enum ChatComponentType {
  none,
  chart,
  diagnosisCard,
  policyCard,
  communityPrompt,
  weatherCard,
  soilAnalysisCard,
  cropReportCard,
  visualDiagnosisCard,
  contactAdvisorCard,
  timeSeriesChartCard,
  comparisonTableCard,
  stepByStepGuideCard,
  interactiveChecklistCard,
  pdfPreviewCard,
}

enum MediaType { none, image, voice }

class MediaAttachment {
  final String id;
  final MediaType type;
  final String filePath;
  final String? thumbnailPath;
  final Duration? duration; // For voice recordings
  final DateTime timestamp;

  const MediaAttachment({
    required this.id,
    required this.type,
    required this.filePath,
    this.thumbnailPath,
    this.duration,
    required this.timestamp,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final DateTime timestamp;
  final MediaAttachment? mediaAttachment;
  final String? markdown;
  final ChatComponentType componentType;
  final Map<String, dynamic>? componentData;
  final Map<String, dynamic>? jsonResponse;
  final bool isTyping;
  final Map<String, dynamic>? locationData; // Added location data

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.mediaAttachment,
    this.markdown,
    this.componentType = ChatComponentType.none,
    this.componentData,
    this.jsonResponse,
    this.isTyping = false,
    this.locationData, // Added location data parameter
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? text,
    ChatSender? sender,
    DateTime? timestamp,
    MediaAttachment? mediaAttachment,
    String? markdown,
    ChatComponentType? componentType,
    Map<String, dynamic>? componentData,
    Map<String, dynamic>? jsonResponse,
    bool? isTyping,
    Map<String, dynamic>? locationData, // Added location data
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      mediaAttachment: mediaAttachment ?? this.mediaAttachment,
      markdown: markdown ?? this.markdown,
      componentType: componentType ?? this.componentType,
      componentData: componentData ?? this.componentData,
      jsonResponse: jsonResponse ?? this.jsonResponse,
      isTyping: isTyping ?? this.isTyping,
      locationData: locationData ?? this.locationData, // Added location data
    );
  }
}
