import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/chat_controller.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _keyController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Please enter your API key');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final ctrl = context.read<ChatController>();
    await ctrl.setApiKey(key);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),
                  // Logo mark
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGlow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.accent, width: 1),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Connect to\nAI Services',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your API key to get started.\nYour key is stored only on this device.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // API Key field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API KEY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              color: AppTheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _error != null
                                ? AppTheme.error
                                : AppTheme.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _keyController,
                                obscureText: _obscure,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.3,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'xai-••••••••••••••••••',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                ),
                                onSubmitted: (_) => _submit(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 14, color: AppTheme.error),
                            const SizedBox(width: 6),
                            Text(
                              _error!,
                              style: const TextStyle(
                                  color: AppTheme.error, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Get key hint
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: 'https://console.x.ai'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('URL copied — open in browser')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.open_in_new_rounded,
                              size: 16, color: AppTheme.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Get free API key at console.x.ai  (\$175/month credit)',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppTheme.accentDim,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Continue',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
