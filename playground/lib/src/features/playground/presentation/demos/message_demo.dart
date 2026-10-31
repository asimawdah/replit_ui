import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

String messageSnippet([String? variant]) => switch (variant) {
  'ai' => _assistant,
  'user' => _user,
  'image' => _image,
  _ => _pair,
};

const String _image = '''
// A sent image lifts out of the bubble into a card above it: the file,
// then what was said about it. Parts render in order, so the attachment
// part goes first. A picture with no caption draws no bubble at all.
ReplitMessage(
  ReplitMessageData(
    id: 'u1',
    role: ReplitMessageRole.user,
    parts: [
      ReplitAttachmentPart([
        ReplitAttachment(id: 'a1', thumbnail: picked, label: 'sunset.png'),
      ]),
      ReplitTextPart('Which font is used in this image?'),
    ],
  ),
)''';

const String _user = '''
// The user turn: an ink-wash bubble, trailing-aligned.
ReplitMessage(
  ReplitMessageData.text(
    id: 'u1',
    role: ReplitMessageRole.user,
    text: 'Can you tell me more about what you can do?',
  ),
)''';

const String _assistant = '''
// The assistant turn: plain on the page. ReplitCustomPart is the
// host-content seam — the builder renders this one as the heading.
ReplitMessage(
  const ReplitMessageData(
    id: 'a1',
    role: ReplitMessageRole.assistant,
    parts: [
      ReplitCustomPart(type: 'heading', data: 'Hello! I am AI chat :)'),
      ReplitTextPart('I can assist you with most tasks across...'),
    ],
  ),
  customPartBuilder: (context, message, part) =>
      part.type == 'heading' ? Heading(part.data as String) : null,
  footer: ReplitMessageActions(
    actions: [
      ReplitMessageAction.copy(onPressed: copy),
      ReplitMessageAction.thumbUp(selected: liked, onPressed: like),
      ReplitMessageAction.thumbDown(selected: disliked, onPressed: dislike),
      ReplitMessageAction.regenerate(onPressed: retry),
    ],
  ),
)''';

const String _pair = '''
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
    const SizedBox(height: 26),
    ReplitMessage(
      const ReplitMessageData(
        id: 'a1',
        role: ReplitMessageRole.assistant,
        parts: [
          // ReplitCustomPart is the host-content seam: the builder below
          // renders this one as the heading.
          ReplitCustomPart(type: 'heading', data: 'Hello! I am AI chat :)'),
          ReplitTextPart('I can assist you with most tasks across...'),
        ],
      ),
      customPartBuilder: (context, message, part) =>
          part.type == 'heading' ? Heading(part.data as String) : null,
      footer: ReplitMessageActions(
        actions: [
          ReplitMessageAction.copy(onPressed: copy),
          ReplitMessageAction.thumbUp(selected: liked, onPressed: like),
          ReplitMessageAction.thumbDown(selected: disliked, onPressed: dislike),
          ReplitMessageAction.regenerate(onPressed: retry),
        ],
      ),
    ),
  ],
)''';

const String _userText = 'Can you tell me more about what you can do?';
const String _heading = 'Hello! I am AI chat :)';
const String _body =
    'I can assist you with most tasks across this app — changing your name, '
    'booking a hotel, or getting a cab. What can I do for you today? If you '
    'need anything else, just type it out.';

/// The message pair from the design: ink-wash user bubble, plain assistant
/// message with a heading (rendered through the custom-part seam) and the
/// actions row. Variants show the conversation or either side alone.
class MessageDemo extends StatefulWidget {
  const MessageDemo({super.key, this.variant});

  final String? variant;

  @override
  State<MessageDemo> createState() => _MessageDemoState();
}

class _MessageDemoState extends State<MessageDemo> {
  bool _liked = false;
  bool _disliked = false;

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant ?? 'pair';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (variant == 'image')
              ReplitMessage(
                const ReplitMessageData(
                  id: 'u1',
                  role: ReplitMessageRole.user,
                  parts: [
                    ReplitAttachmentPart([
                      ReplitAttachment(
                        id: 'a1',
                        thumbnail: AssetImage('assets/demo/generated.png'),
                        label: 'sunset.png',
                      ),
                    ]),
                    ReplitTextPart('Which font is used in this image?'),
                  ],
                ),
                previewCloseTooltip: 'Close',
              )
            else if (variant != 'ai')
              ReplitMessage(
                ReplitMessageData.text(
                  id: 'u1',
                  role: ReplitMessageRole.user,
                  text: _userText,
                ),
              ),
            if (variant == 'pair') const SizedBox(height: 26),
            if (variant != 'user' && variant != 'image')
              ReplitMessage(
                const ReplitMessageData(
                  id: 'a1',
                  role: ReplitMessageRole.assistant,
                  parts: [
                    ReplitCustomPart(type: 'heading', data: _heading),
                    ReplitTextPart(_body),
                  ],
                ),
                customPartBuilder: (context, message, part) {
                  if (part.type != 'heading') return null;
                  return Text(
                    part.data as String,
                    style: context.replitTypography.titleMedium.copyWith(
                      color: context.replitColors.onSurface,
                    ),
                  );
                },
                footer: ReplitMessageActions(
                  actions: [
                    ReplitMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
                    ReplitMessageAction.thumbUp(
                      tooltip: 'Good response',
                      selected: _liked,
                      onPressed: () => setState(() {
                        _liked = !_liked;
                        if (_liked) _disliked = false;
                      }),
                    ),
                    ReplitMessageAction.thumbDown(
                      tooltip: 'Bad response',
                      selected: _disliked,
                      onPressed: () => setState(() {
                        _disliked = !_disliked;
                        if (_disliked) _liked = false;
                      }),
                    ),
                    ReplitMessageAction.regenerate(
                      tooltip: 'Retry',
                      onPressed: () {},
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
