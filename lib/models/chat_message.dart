import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant, system }
enum MessageStatus { sending, sent, error }

class ChatMessage {
  final String id;
  final MessageRole role;
  String content;
  final DateTime timestamp;
  MessageStatus status;
  bool isStreaming;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    this.isStreaming = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String content) => ChatMessage(
        role: MessageRole.user,
        content: content,
        status: MessageStatus.sending,
      );

  factory ChatMessage.assistant(String content, {bool isStreaming = false}) =>
      ChatMessage(
        role: MessageRole.assistant,
        content: content,
        isStreaming: isStreaming,
      );

  Map<String, dynamic> toApiJson() => {
        'role': role == MessageRole.user ? 'user' : 'assistant',
        'content': content,
      };

  Map<String, dynamic> toStorageJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
      };

  factory ChatMessage.fromStorageJson(Map<String, dynamic> json) =>
      ChatMessage(
        id: json['id'],
        role: MessageRole.values.firstWhere((e) => e.name == json['role']),
        content: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
        status: MessageStatus.values.firstWhere(
            (e) => e.name == (json['status'] ?? 'sent'),
            orElse: () => MessageStatus.sent),
      );
}

class Conversation {
  final String id;
  String title;
  List<ChatMessage> messages;
  final DateTime createdAt;
  DateTime updatedAt;

  Conversation({
    String? id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toStorageJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'],
        title: json['title'],
        messages: (json['messages'] as List)
            .map((m) => ChatMessage.fromStorageJson(m))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
