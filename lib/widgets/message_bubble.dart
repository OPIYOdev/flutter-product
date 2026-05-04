import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            _AvatarIcon(isUser: false),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: _isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _BubbleBody(message: message, isUser: _isUser),
                const SizedBox(height: 4),
                _Timestamp(message: message),
              ],
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 10),
            _AvatarIcon(isUser: true),
          ],
        ],
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const _BubbleBody({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: message.content));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.userBubble : AppTheme.aiBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(
            color: isUser ? AppTheme.border : AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: message.isStreaming && message.content.isEmpty
            ? _TypingIndicator()
            : isUser
                ? SelectableText(
                    message.content,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      code: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        backgroundColor: Color(0xFF1A1A2E),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF0D0D1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      blockquoteDecoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppTheme.accent, width: 3),
                        ),
                      ),
                      h1: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                      h2: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      h3: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      strong: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600),
                      em: const TextStyle(color: AppTheme.textSecondary),
                      listBullet:
                          const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final bool isUser;
  const _AvatarIcon({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isUser ? AppTheme.surfaceElevated : AppTheme.accentGlow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUser ? AppTheme.border : AppTheme.accent,
          width: 1,
        ),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
        size: 16,
        color: isUser ? AppTheme.textMuted : AppTheme.accent,
      ),
    );
  }
}

class _Timestamp extends StatelessWidget {
  final ChatMessage message;
  const _Timestamp({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isStreaming) {
      return const Text('generating…',
          style: TextStyle(fontSize: 11, color: AppTheme.accent));
    }
    if (message.status == MessageStatus.error) {
      return const Text('failed — tap to retry',
          style: TextStyle(fontSize: 11, color: AppTheme.error));
    }
    final t = message.timestamp;
    final time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Text(time,
        style:
            const TextStyle(fontSize: 11, color: AppTheme.textMuted));
  }
}
