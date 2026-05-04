import 'dart:convert';
import 'package:grok_chat_template/services/grok_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static const _conversationsKey = 'conversations';
  static const _apiKeyKey = 'ai_api_key';
  static const _systemPromptKey = 'system_prompt';
  static const _providerKey = 'ai_provider';
  static const _modelKey = 'ai_model';
  static const _baseUrlKey = 'ai_base_url';

  // ── API Key ──────────────────────────────────────────────
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key);
  }

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  // ── System Prompt ────────────────────────────────────────
  Future<void> saveSystemPrompt(String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_systemPromptKey, prompt);
  }

  Future<String?> getSystemPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_systemPromptKey);
  }

  // ── Provider Config ──────────────────────────────────────
  Future<void> saveProvider(AiProvider provider, {String? customModel}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider.name);
    await prefs.setString(_baseUrlKey, provider.baseUrl);
    await prefs.setString(_modelKey, customModel ?? provider.defaultModel);
  }

  Future<Map<String, String>> getProviderConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'baseUrl': prefs.getString(_baseUrlKey) ?? AiProvider.xai.baseUrl,
      'model': prefs.getString(_modelKey) ?? AiProvider.xai.defaultModel,
    };
  }

  // ── Conversations ────────────────────────────────────────
  Future<List<Conversation>> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_conversationsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Conversation.fromJson(e)).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversations(List<Conversation> conversations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _conversationsKey,
      jsonEncode(conversations.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> deleteConversation(String id) async {
    final conversations = await loadConversations();
    conversations.removeWhere((c) => c.id == id);
    await saveConversations(conversations);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_conversationsKey);
  }
}
