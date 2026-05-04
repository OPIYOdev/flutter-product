import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';

enum AppState { setup, ready, loading }

class ChatController extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppState _appState = AppState.loading;
  AppState get appState => _appState;

  String? _apiKey;
  String? get apiKey => _apiKey;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => List.unmodifiable(_conversations);

  Conversation? _activeConversation;
  Conversation? get activeConversation => _activeConversation;
  List<ChatMessage> get messages => _activeConversation?.messages ?? [];

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _systemPrompt =
      'You are a helpful, concise, and friendly AI assistant. Respond clearly and accurately.';
  String get systemPrompt => _systemPrompt;

  String get baseUrl => _aiService?.baseUrl ?? AiProvider.grok2.baseUrl;
  String get model => _aiService?.model ?? AiProvider.grok2.defaultModel;

  AiService? _aiService;

  // ── Init ─────────────────────────────────────────────────
  Future<void> init() async {
    _apiKey = await _storage.getApiKey();
    _systemPrompt = await _storage.getSystemPrompt() ?? _systemPrompt;
    _conversations = await _storage.loadConversations();

    if (hasApiKey) {
      _initService();
      _appState = AppState.ready;
    } else {
      _appState = AppState.setup;
    }
    notifyListeners();
  }

  Future<void> _initService() async {
    final config = await _storage.getProviderConfig();
    _aiService = AiService(
      apiKey: _apiKey!,
      baseUrl: config['baseUrl']!,
      model: config['model']!,
      systemPrompt: _systemPrompt,
    );
  }

  // ── API Key ──────────────────────────────────────────────
  Future<bool> setApiKey(String key) async {
    if (key.trim().isEmpty) return false;
    _apiKey = key.trim();
    await _storage.saveApiKey(_apiKey!);
    _initService();
    _appState = AppState.ready;
    notifyListeners();
    return true;
  }

  Future<void> clearApiKey() async {
    await _storage.clearApiKey();
    _apiKey = null;
    _aiService = null;
    _appState = AppState.setup;
    notifyListeners();
  }

  // ── System Prompt ────────────────────────────────────────
  Future<void> updateSystemPrompt(String prompt) async {
    _systemPrompt = prompt;
    await _storage.saveSystemPrompt(prompt);
    _initService();
    notifyListeners();
  }

  Future<void> updateProvider(AiProvider provider, {String? customModel}) async {
    await _storage.saveProvider(provider, customModel: customModel);
    await _initService();
    notifyListeners();
  }

  // ── Conversations ────────────────────────────────────────
  void newConversation() {
    _activeConversation = Conversation(title: 'New chat');
    _conversations.insert(0, _activeConversation!);
    _errorMessage = '';
    notifyListeners();
  }

  void openConversation(Conversation conversation) {
    _activeConversation = conversation;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> deleteConversation(String id) async {
    _conversations.removeWhere((c) => c.id == id);
    if (_activeConversation?.id == id) _activeConversation = null;
    await _storage.saveConversations(_conversations);
    notifyListeners();
  }

  Future<void> clearAllConversations() async {
    _conversations.clear();
    _activeConversation = null;
    await _storage.clearAll();
    notifyListeners();
  }

  // ── Messaging ────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (_aiService == null || text.trim().isEmpty || _isGenerating) return;

    _errorMessage = '';

    // Ensure an active conversation exists
    if (_activeConversation == null) newConversation();

    final userMsg = ChatMessage.user(text.trim());
    _activeConversation!.messages.add(userMsg);
    notifyListeners();

    // Auto-title after first user message
    if (_activeConversation!.messages.length == 1) {
      _activeConversation!.title = text.trim().length > 40
          ? '${text.trim().substring(0, 40)}…'
          : text.trim();
    }

    // Placeholder assistant message
    final assistantMsg = ChatMessage.assistant('', isStreaming: true);
    _activeConversation!.messages.add(assistantMsg);
    _isGenerating = true;
    notifyListeners();

    try {
      final history = _activeConversation!.messages
          .where((m) => m.id != assistantMsg.id)
          .toList();

      await for (final chunk in _aiService!.stream(history)) {
        assistantMsg.content += chunk;
        notifyListeners();
      }

      assistantMsg.isStreaming = false;
      userMsg.status = MessageStatus.sent;
      _activeConversation!.updatedAt = DateTime.now();
      await _storage.saveConversations(_conversations);
    } on AiApiException catch (e) {
      _activeConversation!.messages.remove(assistantMsg);
      userMsg.status = MessageStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _activeConversation!.messages.remove(assistantMsg);
      userMsg.status = MessageStatus.error;
      _errorMessage = 'Unexpected error. Please try again.';
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void retryLastMessage() {
    if (_activeConversation == null) return;
    final msgs = _activeConversation!.messages;
    if (msgs.isEmpty) return;

    final last = msgs.last;
    if (last.role == MessageRole.user && last.status == MessageStatus.error) {
      final text = last.content;
      msgs.remove(last);
      sendMessage(text);
    }
  }
}
