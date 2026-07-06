enum MessageRole { user, assistant }

class ChatMessageModel {
  final String id;
  final MessageRole role;
  String content; // mutable — we append streamed tokens
  final DateTime time;
  bool isStreaming;

  ChatMessageModel({
    required this.role,
    required this.content,
    this.isStreaming = false,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString(),
       time = DateTime.now();

  /// Converts to Claude API message format
  Map<String, String> toApiMap() => {
    'role': role == MessageRole.user ? 'user' : 'assistant',
    'content': content,
  };
}
