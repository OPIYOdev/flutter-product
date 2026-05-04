import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chat_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import 'history_drawer.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const HistoryDrawer(),
      appBar: _AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          
          return Consumer<ChatController>(
            builder: (context, ctrl, _) {
              final messages = ctrl.messages;

              if (messages.isNotEmpty) _scrollToBottom();

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 800 : double.infinity,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: messages.isEmpty
                            ? _EmptyState(
                                onSuggestionTap: (s) => ctrl.sendMessage(s),
                              )
                            : ListView.builder(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                itemCount: messages.length,
                                itemBuilder: (_, i) {
                                  final msg = messages[i];
                                  return GestureDetector(
                                    onTap: msg.status == MessageStatus.error
                                        ? ctrl.retryLastMessage
                                        : null,
                                    child: MessageBubble(message: msg),
                                  );
                                },
                              ),
                      ),

              // Error banner
              if (ctrl.errorMessage.isNotEmpty)
                _ErrorBanner(
                  message: ctrl.errorMessage,
                  onRetry: ctrl.retryLastMessage,
                ),

                      ChatInputBar(
                        isGenerating: ctrl.isGenerating,
                        onSend: ctrl.sendMessage,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();
    return AppBar(
      backgroundColor: AppTheme.background,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textSecondary),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Column(
        children: [
          Text(
            ctrl.model.contains('grok') ? 'Grok' : 'AI Chat',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            ctrl.isGenerating ? 'thinking…' : 'ready',
            style: TextStyle(
              fontSize: 11,
              color: ctrl.isGenerating ? AppTheme.accent : AppTheme.textMuted,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: AppTheme.textSecondary),
          tooltip: 'New chat',
          onPressed: () {
            ctrl.newConversation();
            Scaffold.of(context).closeDrawer();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined,
              color: AppTheme.textSecondary),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const _EmptyState({required this.onSuggestionTap});

  static const _suggestions = [
    'Explain quantum computing simply',
    'Write a Flutter widget from scratch',
    'Help me debug this error',
    'What can you do?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.accent),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppTheme.accent, size: 24),
          ),
          const SizedBox(height: 20),
          const Text(
            'How can I help?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Consumer<ChatController>(
            builder: (context, ctrl, _) => Text(
              'Ask me anything — I\'m powered by ${ctrl.model.contains('grok') ? 'Grok' : 'AI'}.',
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestions
                .map((s) => _SuggestionChip(
                    label: s, onTap: () => onSuggestionTap(s)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x22FF6B6B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: AppTheme.error, fontSize: 13)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppTheme.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
