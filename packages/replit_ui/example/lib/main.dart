import 'package:material_ui/material_ui.dart';
import 'package:replit_ui/replit_ui.dart';

import 'env.dart';

ReplitTheme _brandTheme(ReplitTheme theme) => theme.copyWith(
  typography: ReplitTypography.standard
      .withFontFamily('Diatype')
      .withCodeFontFamily('Diatype Semi-Mono'),
);

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeMode,
    builder: (context, mode, _) => MaterialApp(
      title: 'Replit UI example',
      theme: ThemeData(
        fontFamily: 'Diatype',
        extensions: [_brandTheme(ReplitTheme.light())],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Diatype',
        extensions: [_brandTheme(ReplitTheme.dark())],
      ),
      themeMode: mode,
      home: const ChatScreen(),
    ),
  );
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final UiDesignChat _chat = UiDesignChat(
    provider: GeminiProvider(
      apiKey: apiKey,
      models: const [
        ModelOption(id: 'gemini-3.6-flash', label: 'Gemini 3.6 Flash'),
        ModelOption(
          id: 'gemini-3.5-flash-lite',
          label: 'Gemini 3.5 Flash Lite',
        ),
      ],
    ),
    agent: const AgentConfig(instructions: 'You are a concise assistant.'),
    tools: [
      Tool(
        name: 'set_theme',
        description: 'Switches the app between light and dark mode.',
        parameters: const {
          'type': 'object',
          'properties': {
            'mode': {
              'type': 'string',
              'enum': ['light', 'dark', 'system'],
              'description': 'The theme to apply.',
            },
          },
          'required': ['mode'],
        },
        label: 'Set theme',
        detail: (args) => args['mode'] as String?,
        run: (call) {
          final mode = switch (call.args['mode']) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            'system' => ThemeMode.system,
            _ => throw const ToolException(
              'mode must be light, dark or system',
            ),
          };
          themeMode.value = mode;
          return {'mode': mode.name};
        },
      ),
    ],
  );

  @override
  void dispose() {
    _chat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Replit UI'),
      actions: [
        IconButton(
          tooltip: 'New chat',
          icon: const Icon(Icons.add_comment_outlined),
          onPressed: _chat.newConversation,
        ),
      ],
    ),
    body: UiDesignChatView(
      chat: _chat,
      greeting: const ReplitGreeting(text: 'What can I help with?'),
      suggestions: const [
        'Switch to dark mode',
        'Explain how streaming responses work',
        'What is the difference between const and final in Dart?',
      ],
      showEditAction: true,
    ),
  );
}
