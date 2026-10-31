import 'dart:async';

import 'package:replit_ui/replit_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

String threadSnippet([String? variant]) => switch (variant) {
  'streaming' => _streaming,
  'short' => _short,
  _ => _default,
};

const String _streaming = '''
// Streaming is data: rebuild with the newest message grown and the
// thread stays anchored to it. Status walks
// pending → streaming → complete.
ReplitThread(
  messages: [
    ...history,
    ReplitMessageData(
      id: 'reply',
      role: ReplitMessageRole.assistant,
      parts: [ReplitTextPart(streamedSoFar)],
      status: ReplitMessageStatus.streaming,
    ),
  ],
)''';

const String _short = '''
// A conversation that still fits its viewport reads from the top, the
// AI-app convention; the thread flips to bottom-anchored only once it
// outgrows the viewport.
SizedBox(
  height: 480,
  child: ReplitThread(messages: fewMessages),
)''';

const String _default = '''
// A scrollable conversation — reads from the top, anchoring to the
// newest message once it outgrows the viewport. Give it
// bounded height; inside ReplitChatView that comes for free. Text selects
// across turns; selectable: false leaves that to the host.
SizedBox(
  height: 480,
  child: ReplitThread(
    messages: messages,
    controller: scroll,
    thinkingLabel: 'thinking..',
    // Code parts render ReplitCodeBlocks; copy hands the part back, and
    // the host passes it along while its confirmation lasts.
    codeCopyTooltip: 'Copy code',
    copiedCodePart: copiedPart,
    onCodeCopy: copyPart,
  ),
)''';

const String _reply =
    'ReplitThread reads from the top while the conversation fits, then '
    'anchors to the newest message once it outgrows the viewport — '
    'history loads upward. Messages keep their identity by id, which is '
    'what makes streaming updates cheap. Give it bounded height and it '
    'does the rest:';

const String _replyCode = '''
SizedBox(
  height: 480,
  child: ReplitThread(
    messages: messages,
    controller: scroll,
  ),
)''';

List<ReplitMessageData> _seed(bool streaming) => [
  ReplitMessageData.text(
    id: 'u1',
    role: ReplitMessageRole.user,
    text: 'What does ReplitThread actually do?',
  ),
  ReplitMessageData.text(
    id: 'a1',
    role: ReplitMessageRole.assistant,
    text:
        'It renders the conversation: user bubbles on the ink wash, plain '
        'assistant prose, 32px apart.',
  ),
  ReplitMessageData.text(
    id: 'u2',
    role: ReplitMessageRole.user,
    text: 'And when a reply is still coming in?',
  ),
  ReplitMessageData(
    id: 'a2',
    role: ReplitMessageRole.assistant,
    // Prose then code: the reveal plays on the text part, while the code
    // part renders whole — and hides its copy affordance mid-stream.
    parts: const [
      ReplitTextPart(_reply),
      ReplitCodePart(_replyCode, language: 'dart'),
    ],
    status: streaming
        ? ReplitMessageStatus.streaming
        : ReplitMessageStatus.complete,
  ),
];

/// The conversation list on its own, at a bounded height, closing on a
/// reply that carries a code part. The Streaming variant mounts that
/// reply mid-stream, so the text reveal plays above the code block; the
/// Short variant fits its viewport, showing the conversation reading
/// from the top. The demo owns the clipboard write and the copied
/// confirmation, the way a host would.
class ThreadDemo extends StatefulWidget {
  const ThreadDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ThreadDemo> createState() => _ThreadDemoState();
}

class _ThreadDemoState extends State<ThreadDemo> {
  ReplitCodePart? _copiedPart;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy(ReplitCodePart part) async {
    await Clipboard.setData(ClipboardData(text: part.code));
    if (!mounted) return;
    setState(() => _copiedPart = part);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copiedPart = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SizedBox(
          height: 480,
          child: ReplitThread(
            messages: widget.variant == 'short'
                ? _seed(false).take(2).toList()
                : _seed(widget.variant == 'streaming'),
            codeCopyTooltip: 'Copy code',
            copiedCodePart: _copiedPart,
            onCodeCopy: _copy,
          ),
        ),
      ),
    );
  }
}
