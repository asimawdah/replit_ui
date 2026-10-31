import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

String thinkingIndicatorSnippet([String? variant]) => switch (variant) {
  'settled' => _settledSnip,
  _ => _activeSnip,
};

const String _activeSnip = '''
ReplitThinkingIndicator(
  label: 'thinking..',
  active: true,
)''';

const String _settledSnip = '''
ReplitThinkingIndicator(
  label: 'thinking..',
  active: false,
)''';

class ThinkingIndicatorDemo extends StatelessWidget {
  const ThinkingIndicatorDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ReplitThinkingIndicator(
        label: 'thinking..',
        active: variant != 'settled',
      ),
    );
  }
}
