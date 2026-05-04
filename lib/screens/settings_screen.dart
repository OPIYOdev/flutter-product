import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_controller.dart';
import '../theme/app_theme.dart';
import 'setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _promptCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<ChatController>();
    _promptCtrl = TextEditingController(text: ctrl.systemPrompt);
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePrompt() async {
    await context.read<ChatController>().updateSystemPrompt(_promptCtrl.text);
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saved = false);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(color: AppTheme.textSecondary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('AI Behaviour'),
          const SizedBox(height: 12),
          _label('AI Provider & Model'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AiProvider>(
                value: AiProvider.all.firstWhere(
                  (p) => p.baseUrl == ctrl.baseUrl,
                  orElse: () => AiProvider.grok2,
                ),
                dropdownColor: AppTheme.surfaceElevated,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textMuted),
                items: AiProvider.all.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (p) async {
                  if (p != null) {
                    await context.read<ChatController>().updateProvider(p);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('System Prompt'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _promptCtrl,
              maxLines: 5,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.5),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: 'You are a helpful assistant…',
                hintStyle:
                    TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePrompt,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _saved ? AppTheme.success : AppTheme.surfaceElevated,
                foregroundColor: AppTheme.textPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(_saved ? '✓ Saved' : 'Save prompt'),
            ),
          ),

          const SizedBox(height: 32),
          _SectionHeader('Account'),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.vpn_key_outlined,
            label: 'API Key',
            value: ctrl.apiKey != null
                ? '${ctrl.apiKey!.substring(0, 8)}••••••••'
                : 'Not set',
            onTap: () => _showChangeKeyDialog(context),
          ),

          const SizedBox(height: 32),
          _SectionHeader('Danger Zone'),
          const SizedBox(height: 12),

          _DangerTile(
            icon: Icons.logout_rounded,
            label: 'Sign out & clear API key',
            onTap: () => _confirmSignOut(context, ctrl),
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'AI Chat Template v1.0.0',
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Built with Flutter + Multiple AI Providers',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeKeyDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Change API Key',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 17)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'xai-…',
            hintStyle: TextStyle(color: AppTheme.textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accent)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await context.read<ChatController>().setApiKey(ctrl.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save',
                style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
      BuildContext context, ChatController ctrl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Sign out?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
            'Your API key will be removed from this device.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign out',
                  style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ctrl.clearApiKey();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SetupScreen()),
          (_) => false,
        );
      }
    }
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textMuted,
          letterSpacing: 0.8,
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DangerTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.error.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.error),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.error, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
