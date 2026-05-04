import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatInputBar extends StatefulWidget {
  final bool isGenerating;
  final ValueChanged<String> onSend;

  const ChatInputBar({
    super.key,
    required this.isGenerating,
    required this.onSend,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
        () => setState(() => _hasText = _controller.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isGenerating) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: const Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 10,
        bottom: 10 + bottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                ),
                decoration: const InputDecoration(
                  hintText: 'Message Grok…',
                  hintStyle:
                      TextStyle(color: AppTheme.textMuted, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            active: _hasText && !widget.isGenerating,
            loading: widget.isGenerating,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool active;
  final bool loading;
  final VoidCallback onPressed;

  const _SendButton({
    required this.active,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: active ? AppTheme.accent : AppTheme.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: active ? AppTheme.accent : AppTheme.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onPressed : null,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.accent,
                    ),
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    size: 20,
                    color: active ? Colors.white : AppTheme.textMuted,
                  ),
          ),
        ),
      ),
    );
  }
}
