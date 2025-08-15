enum ChatSender { user, agent }

enum ChatComponentType {
  none,
  chart,
  diagnosisCard,
  policyCard,
  communityPrompt,
}

class ChatMessage {
  final String id;
  final String text;
  final ChatSender sender;
  final ChatComponentType componentType;
  final Map<String, dynamic>? componentData;
  final bool isTyping;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.componentType = ChatComponentType.none,
    this.componentData,
    this.isTyping = false,
  });
}
