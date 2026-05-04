# Grok Chat — Flutter AI Chat App Template

A production-ready Flutter chat application template powered by the **xAI Grok API**. Clean, dark UI. Streaming responses. Conversation history. Fully customizable. Ready to ship to clients or publish to app stores.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Streaming responses** | Real-time token-by-token output, just like ChatGPT |
| **Conversation history** | Persisted locally via SharedPreferences |
| **Markdown rendering** | Code blocks, bold, lists, headings — all rendered beautifully |
| **Typing indicator** | Animated dots while AI is thinking |
| **Swipe to delete** | Dismiss conversations from history drawer |
| **System prompt editor** | Customize the AI personality in Settings |
| **API key management** | Secure onboarding + settings update flow |
| **Error handling** | Retry failed messages with one tap |
| **Long-press to copy** | Copy any message to clipboard |
| **Dark theme** | Polished dark-first UI, no light mode distractions |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # Entry point + router
├── theme/
│   └── app_theme.dart         # Colors, typography, ThemeData
├── models/
│   └── chat_message.dart      # ChatMessage, Conversation models
├── services/
│   ├── grok_service.dart      # xAI API — streaming + one-shot
│   ├── storage_service.dart   # Local persistence (SharedPreferences)
│   └── chat_controller.dart   # ChangeNotifier state manager
├── screens/
│   ├── setup_screen.dart      # API key onboarding
│   ├── chat_screen.dart       # Main chat UI
│   ├── history_drawer.dart    # Conversation list sidebar
│   └── settings_screen.dart   # System prompt + key management
└── widgets/
    ├── message_bubble.dart    # User + AI message rendering
    └── chat_input_bar.dart    # Animated input field + send button
```

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter 3.x (`flutter --version`)
- An xAI API key from [console.x.ai](https://console.x.ai) (free $175/month credits)

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run
```bash
flutter run
```

On first launch, enter your xAI API key. It's stored securely on-device.

---

## 🔑 Getting a Free API Key

1. Go to [console.x.ai](https://console.x.ai)
2. Sign up / log in
3. Navigate to **API Keys** → **Create Key**
4. Copy the key (starts with `xai-`)
5. Paste it into the app on first launch

> **Free tier**: xAI gives new developers up to **$175/month** in free credits. At Grok 3 Mini pricing ($0.30/$0.50 per 1M tokens), this covers millions of messages — more than enough for a real app.

---

## 🎨 Customization Guide

### Change the AI model
In `lib/services/grok_service.dart`:
```dart
static const String _defaultModel = 'grok-3-mini'; // cheapest
// Options: 'grok-3-mini', 'grok-3', 'grok-4-fast', 'grok-4'
```

### Change the default system prompt
In `lib/services/chat_controller.dart`:
```dart
String _systemPrompt = 'You are a helpful assistant...';
```

### Change the app name
In `pubspec.yaml`:
```yaml
name: your_app_name
```
And update `AndroidManifest.xml` / `Info.plist`.

### Change colors/theme
All colors are in `lib/theme/app_theme.dart`. The entire app uses these constants — change once, updates everywhere.

### Add your own suggestion chips
In `lib/screens/chat_screen.dart` → `_EmptyState`:
```dart
static const _suggestions = [
  'Your custom prompt here',
  ...
];
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `http` | API requests + streaming |
| `shared_preferences` | Local persistence |
| `flutter_markdown` | Markdown rendering in chat |
| `uuid` | Unique message/conversation IDs |
| `provider` | State management |
| `intl` | Date formatting |

---

## 🏗 Build for Production

### Android
```bash
flutter build apk --release
# or for Play Store:
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 📄 License

This template is sold for **single-project use**. You may use it in one commercial app. Do not resell or redistribute the source code.

---

## 💬 Support

Questions about customization? Reply to your purchase receipt for support.

---

*Made with Flutter + xAI Grok API*
