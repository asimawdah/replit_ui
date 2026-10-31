import 'dart:async';

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

String streamingMessageSnippet([String? variant]) => switch (variant) {
  'static' => _static,
  'image' => _image,
  _ => _animated,
};

const String _image = '''
// A generated picture is content, not a tile: ReplitImagePart renders
// large-format, and a null image is the generating state — a shimmering
// block at aspectRatio until the host re-renders with the picture set.
ReplitMessage(
  ReplitMessageData(
    id: 'a1',
    role: ReplitMessageRole.assistant,
    status: ReplitMessageStatus.streaming,
    parts: [
      ReplitTextPart('Here it is:'),
      ReplitImagePart(aspectRatio: 4 / 3), // generating
    ],
  ),
)

// When the picture lands, the block becomes it — same frame, no jump:
ReplitImagePart(
  image: MemoryImage(bytes),
  aspectRatio: 4 / 3,
  semanticLabel: 'A sunset over the sea',
)''';

const String _static = '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    ReplitMessage(
      ReplitMessageData.text(
        id: 'u1',
        role: ReplitMessageRole.user,
        text: 'Can you tell me more about what you can do?',
      ),
    ),
    const SizedBox(height: 30),
    // Settled: active: false parks the asterisk upright and stills
    // the shimmering label — the waiting moment, at rest.
    ReplitThinkingIndicator(
      label: 'thinking..',
      active: false,
    ),
  ],
)''';

const String _animated = '''
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    ReplitMessage(
      ReplitMessageData.text(
        id: 'u1',
        role: ReplitMessageRole.user,
        text: 'Can you tell me more about what you can do?',
      ),
    ),
    const SizedBox(height: 30),
    // The waiting state: a turning, breathing asterisk with a
    // shimmering label. `active: false` settles both.
    ReplitThinkingIndicator(
      label: 'thinking..',
      active: generating,
    ),
  ],
)''';

/// The waiting moment from the design: the user's bubble with the
/// thinking indicator beneath it. The Static variant settles the
/// asterisk and stills the label's shimmer; the Image variant cycles a
/// generating picture — shimmer block, then the landed image.
class StreamingMessageDemo extends StatelessWidget {
  const StreamingMessageDemo({super.key, this.variant});

  final String? variant;

  @override
  Widget build(BuildContext context) {
    if (variant == 'image') return const _GeneratedImageTurn();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReplitMessage(
              ReplitMessageData.text(
                id: 'u1',
                role: ReplitMessageRole.user,
                text: 'Can you tell me more about what you can do?',
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ReplitThinkingIndicator(
                label: 'thinking..',
                active: variant != 'static',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cycles the generated-image lifecycle: the shimmering placeholder for
/// a beat, then the landed picture, then around again — the host's
/// null → set re-render, on a loop.
class _GeneratedImageTurn extends StatefulWidget {
  const _GeneratedImageTurn();

  @override
  State<_GeneratedImageTurn> createState() => _GeneratedImageTurnState();
}

class _GeneratedImageTurnState extends State<_GeneratedImageTurn> {
  static const Duration _generating = Duration(milliseconds: 2800);
  static const Duration _landed = Duration(milliseconds: 2600);

  bool _hasImage = false;
  Timer? _cycle;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void dispose() {
    _cycle?.cancel();
    super.dispose();
  }

  void _arm() {
    _cycle = Timer(_hasImage ? _landed : _generating, () {
      setState(() => _hasImage = !_hasImage);
      _arm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReplitMessage(
              ReplitMessageData.text(
                id: 'u1',
                role: ReplitMessageRole.user,
                text: 'Paint me a sunset over the sea',
              ),
            ),
            const SizedBox(height: 30),
            ReplitMessage(
              ReplitMessageData(
                id: 'a1',
                role: ReplitMessageRole.assistant,
                status: _hasImage
                    ? ReplitMessageStatus.complete
                    : ReplitMessageStatus.streaming,
                parts: [
                  const ReplitTextPart('Here it is:'),
                  ReplitImagePart(
                    image: _hasImage
                        ? const AssetImage('assets/demo/generated.png')
                        : null,
                    aspectRatio: 4 / 3,
                    semanticLabel: 'A sunset over the sea',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
