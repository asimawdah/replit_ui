import 'dart:async';

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

String errorStateSnippet([String? variant]) => switch (variant) {
  'minimal' => _minimalSnip,
  'thread' => _threadSnip,
  _ => _cardSnip,
};

const String _cardSnip = '''
// The card renders state and reports one intent; what retry means —
// re-run the turn, refetch, reconnect — is the host's business.
ReplitErrorState(
  title: 'Connection error',
  message: 'The API is overloaded right now. Retry in a moment.',
  retryLabel: 'Retry',
  onRetry: resend,
)''';

const String _minimalSnip = '''
// The message-only form: no title, no retry pill — for failures
// retrying can't fix.
ReplitErrorState(
  message: 'The API is overloaded right now. Retry in a moment.',
)''';

const String _threadSnip = '''
// In a thread the card renders on its own: parts a failed turn already
// delivered keep their ink, and its ReplitErrorPart closes the turn.
ReplitThread(
  messages: messages,
  errorTitle: 'Connection error',
  retryLabel: 'Retry',
  onRetry: (message) => rerun(message),
)

ReplitMessageData(
  id: 'a2',
  role: ReplitMessageRole.assistant,
  status: ReplitMessageStatus.error,
  parts: [
    ReplitErrorPart(message: 'This conversation exceeds the context window.'),
  ],
)''';

const String _partialReply =
    'ReplitThread lays the conversation out as a reversed list, so the newest '
    'message sits at the bottom and history loads';

const String _fullReply =
    '$_partialReply upward. Messages keep their identity by id, which is '
    'what makes streaming updates cheap.';

const String _failureMessage =
    'The API is overloaded right now. Retry in a moment.';

/// Stage demo for `ReplitErrorState` — the full card, the message-only
/// minimal form, and a failed turn in a thread whose retry actually
/// re-runs the reply, the way a host would.
class ErrorStateDemo extends StatefulWidget {
  const ErrorStateDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ErrorStateDemo> createState() => _ErrorStateDemoState();
}

class _ErrorStateDemoState extends State<ErrorStateDemo> {
  static const Duration _feedTick = Duration(milliseconds: 30);
  static const int _feedStep = 3;

  /// Thread variant: the failed reply's lifecycle. Retry resumes the
  /// stream from the partial text and completes it.
  ReplitMessageStatus _replyStatus = ReplitMessageStatus.error;
  int _fed = _partialReply.length;
  Timer? _feed;

  @override
  void dispose() {
    _feed?.cancel();
    super.dispose();
  }

  void _retry() {
    if (_replyStatus == ReplitMessageStatus.streaming) return;
    setState(() => _replyStatus = ReplitMessageStatus.streaming);
    _feed = Timer.periodic(_feedTick, (timer) {
      setState(() {
        _fed = (_fed + _feedStep).clamp(0, _fullReply.length);
        if (_fed == _fullReply.length) {
          _replyStatus = ReplitMessageStatus.complete;
          timer.cancel();
        }
      });
    });
  }

  List<ReplitMessageData> get _messages => [
    ReplitMessageData.text(
      id: 'u1',
      role: ReplitMessageRole.user,
      text: 'What does ReplitThread actually do?',
    ),
    ReplitMessageData(
      id: 'a1',
      role: ReplitMessageRole.assistant,
      status: _replyStatus,
      parts: [
        ReplitTextPart(_fullReply.substring(0, _fed)),
        // The failure closes the turn; once retry re-runs it, the part
        // goes with it.
        if (_replyStatus == ReplitMessageStatus.error)
          const ReplitErrorPart(message: _failureMessage),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.variant) {
      'minimal' => const ReplitErrorState(message: _failureMessage),
      'thread' => SizedBox(
        height: 420,
        child: ReplitThread(
          messages: _messages,
          errorTitle: 'Connection error',
          retryLabel: 'Retry',
          onRetry: (_) => _retry(),
        ),
      ),
      _ => ReplitErrorState(
        title: 'Connection error',
        message: _failureMessage,
        retryLabel: 'Retry',
        onRetry: () {},
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: child,
      ),
    );
  }
}
