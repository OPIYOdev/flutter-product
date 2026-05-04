import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/chat_controller.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/setup_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait (optional — remove if you want landscape)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.background,
  ));

  runApp(const GrokChatApp());
}

class GrokChatApp extends StatelessWidget {
  const GrokChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatController()..init(),
      child: MaterialApp(
        title: 'Grok Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();

    return switch (ctrl.appState) {
      AppState.loading => const _SplashScreen(),
      AppState.setup => const SetupScreen(),
      AppState.ready => const ChatScreen(),
    };
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: AppTheme.accent, size: 40),
            SizedBox(height: 20),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
