import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../services/chat_controller.dart';
import '../theme/app_theme.dart';

class HistoryDrawer extends StatelessWidget {
  const HistoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ctrl.newConversation();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 18, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Conversation list
            Expanded(
              child: ctrl.conversations.isEmpty
                  ? const _EmptyHistory()
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: ctrl.conversations.length,
                      itemBuilder: (_, i) {
                        final conv = ctrl.conversations[i];
                        final isActive =
                            ctrl.activeConversation?.id == conv.id;
                        return _ConversationTile(
                          conversation: conv,
                          isActive: isActive,
                          onTap: () {
                            ctrl.openConversation(conv);
                            Navigator.pop(context);
                          },
                          onDelete: () => ctrl.deleteConversation(conv.id),
                        );
                      },
                    ),
            ),

            // Footer
            const Divider(height: 1, color: AppTheme.border),
            if (ctrl.conversations.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined,
                    size: 18, color: AppTheme.textMuted),
                title: const Text(
                  'Clear all history',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textMuted),
                ),
                onTap: () => _confirmClear(context, ctrl),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, ChatController ctrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Clear all chats?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('This cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear',
                  style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed == true) {
      ctrl.clearAllConversations();
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.error.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        selected: isActive,
        selectedColor: AppTheme.accent,
        selectedTileColor: AppTheme.accentGlow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(
          Icons.chat_bubble_outline_rounded,
          size: 18,
          color: isActive ? AppTheme.accent : AppTheme.textMuted,
        ),
        title: Text(
          conversation.title,
          style: TextStyle(
            fontSize: 14,
            color:
                isActive ? AppTheme.accent : AppTheme.textPrimary,
            fontWeight:
                isActive ? FontWeight.w500 : FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${conversation.messages.length} messages',
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 36, color: AppTheme.textMuted),
          SizedBox(height: 12),
          Text('No conversations yet',
              style: TextStyle(
                  color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
