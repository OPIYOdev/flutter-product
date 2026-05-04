// lib/services/ai_service.dart (rename from grok_service.dart)

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AiApiException implements Exception {
  final String message;
  final int? statusCode;
  AiApiException(this.message, {this.statusCode});
  @override
  String toString() => 'AiApiException: $message (status: $statusCode)';
}

// Preset providers — add more as needed
class AiProvider {
  final String name;
  final String baseUrl;
  final String defaultModel;

  const AiProvider({
    required this.name,
    required this.baseUrl,
    required this.defaultModel,
  });

  static const xai = AiProvider(
    name: 'xAI Grok',
    baseUrl: 'https://api.x.ai/v1',
    defaultModel: 'grok-3-mini',
  );

  static const openai = AiProvider(
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModel: 'gpt-4o-mini',
  );

  static const openrouter = AiProvider(
    name: 'OpenRouter',
    baseUrl: 'https://openrouter.ai/api/v1',
    defaultModel: 'mistralai/mistral-7b-instruct',
  );

  static const groq = AiProvider(
    name: 'Groq',
    baseUrl: 'https://api.groq.com/openai/v1',
    defaultModel: 'llama3-8b-8192',
  );

  static const List<AiProvider> all = [xai, openai, openrouter, groq];
}

class AiService {
  final String apiKey;
  final String model;
  final String baseUrl;
  final String systemPrompt;
  final int maxTokens;
  final double temperature;

  AiService({
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.systemPrompt =
        'You are a helpful, concise, and friendly AI assistant. Respond clearly and accurately.',
    this.maxTokens = 1024,
    this.temperature = 0.7,
  });

  /// Convenience constructor from a preset provider
  factory AiService.fromProvider({
    required AiProvider provider,
    required String apiKey,
    String? model,
    String? systemPrompt,
  }) {
    return AiService(
      apiKey: apiKey,
      baseUrl: provider.baseUrl,
      model: model ?? provider.defaultModel,
      systemPrompt: systemPrompt ??
          'You are a helpful, concise, and friendly AI assistant.',
    );
  }

  /// One-shot completion
  Future<String> complete(List<ChatMessage> messages) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat/completions'),
          headers: _headers,
          body: jsonEncode(_buildBody(messages, stream: false)),
        )
        .timeout(const Duration(seconds: 30));

    _checkStatus(response);
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'] as String;
  }

  /// Streaming completion
  Stream<String> stream(List<ChatMessage> messages) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'))
      ..headers.addAll(_headers)
      ..body = jsonEncode(_buildBody(messages, stream: true));

    final response = await request.send().timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw AiApiException(_parseError(body), statusCode: response.statusCode);
    }

    await for (final chunk in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (chunk.startsWith('data: ')) {
        final data = chunk.substring(6).trim();
        if (data == '[DONE]') break;
        try {
          final json = jsonDecode(data);
          final delta = json['choices']?[0]?['delta']?['content'];
          if (delta != null && delta is String && delta.isNotEmpty) {
            yield delta;
          }
        } catch (_) {}
      }
    }
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

  Map<String, dynamic> _buildBody(List<ChatMessage> messages,
      {required bool stream}) {
    return {
      'model': model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages
            .where((m) => m.role != MessageRole.system)
            .map((m) => m.toApiJson()),
      ],
      'max_tokens': maxTokens,
      'temperature': temperature,
      'stream': stream,
    };
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      throw AiApiException(_parseError(response.body),
          statusCode: response.statusCode);
    }
  }

  String _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['error']?['message'] ?? 'Unknown API error';
    } catch (_) {
      return 'API request failed';
    }
  }
}
