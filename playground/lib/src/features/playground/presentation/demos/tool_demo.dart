import 'dart:async';
import 'dart:math' as math;

import 'package:replit_ui/replit_ui.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

String toolSnippet([String? variant]) => switch (variant) {
  'complete' => _completeSnip,
  'running' => _runningSnip,
  'error' => _errorSnip,
  'thread' => _threadSnip,
  _ => _liveSnip,
};

const String _liveSnip = '''
// The card renders state and never advances on its own: the host
// re-renders the part as its provider reports each step.

// 1. Staged: the arguments still arriving, the input block streaming.
ReplitTool(
  name: 'search_docs',
  title: 'Searching the docs',
  status: ReplitToolStatus.pending,
  input: '{"query": "draft pers',
)

// 2. Executing: the asterisk turns and the title shimmers.
ReplitTool(
  name: 'search_docs',
  title: 'Searching the docs',
  detail: 'draft persistence',
  status: ReplitToolStatus.running,
  input: '{"query": "draft persistence"}',
)

// 3. Settled: the check lands and the output joins the disclosure.
ReplitTool(
  name: 'search_docs',
  title: 'Searched the docs',
  detail: 'draft persistence',
  status: ReplitToolStatus.complete,
  input: '{"query": "draft persistence"}',
  output: '{"count": 2, "best": "/components/composer#drafts"}',
  inputLabel: 'Input',
  outputLabel: 'Output',
)''';

const String _completeSnip = '''
// The full anatomy, landed open: the settled check, the host's title
// and the call's primary argument on the row, then the input and
// output as code blocks behind the disclosure. Copy hands back a
// ReplitCodePart, the same contract as any code block.
ReplitTool(
  name: 'search_docs',
  title: 'Searched the docs',
  detail: 'draft persistence',
  status: ReplitToolStatus.complete,
  input: '{"query": "draft persistence"}',
  output: '{"count": 2, "best": "/components/composer#drafts"}',
  inputLabel: 'Input',
  outputLabel: 'Output',
  initiallyExpanded: true,
  codeCopyTooltip: 'Copy',
  copiedCodePart: copied,
  onCodeCopy: (part) => copy(part),
)''';

const String _runningSnip = '''
// Executing: the thinking line's asterisk turns and the title shimmers.
// Status is the mark, never words, so there is nothing to localize.
ReplitTool(
  name: 'search_docs',
  title: 'Searching the docs',
  detail: 'draft persistence',
  status: ReplitToolStatus.running,
  input: '{"query": "draft persistence"}',
  inputLabel: 'Input',
)''';

const String _errorSnip = '''
// A failed call: the error glyph, and the host's message under the
// header where it reads without a tap. The input stays behind the
// disclosure for whoever wants to see what was asked.
ReplitTool(
  name: 'fetch_weather',
  title: 'Fetching the forecast',
  detail: 'Berlin',
  status: ReplitToolStatus.error,
  input: '{"city": "Berlin", "units": "metric"}',
  errorMessage: 'The weather service timed out after 10 seconds.',
  inputLabel: 'Input',
)''';

const String _threadSnip = '''
// In a thread the card renders on its own: a ReplitToolPart in any turn
// becomes it. The section labels are thread-level, copy goes through
// the same handler as every code block, and the part's id keys the
// card so its disclosure survives the turn growing.
ReplitThread(
  messages: messages,
  toolInputLabel: 'Input',
  toolOutputLabel: 'Output',
  codeCopyTooltip: 'Copy',
  copiedCodePart: copied,
  onCodeCopy: (part) => copy(part),
)

ReplitMessageData(
  id: 'a1',
  role: ReplitMessageRole.assistant,
  parts: [
    ReplitTextPart('Let me check the docs and the forecast.'),
    ReplitToolPart(
      id: 'call_1',
      name: 'search_docs',
      title: 'Searched the docs',
      detail: 'draft persistence',
      status: ReplitToolStatus.complete,
      input: '{"query": "draft persistence"}',
      output: '{"count": 2, "best": "/components/composer#drafts"}',
    ),
    ReplitToolPart(
      id: 'call_2',
      name: 'fetch_weather',
      title: 'Fetching the forecast',
      detail: 'Berlin',
      status: ReplitToolStatus.error,
      input: '{"city": "Berlin", "units": "metric"}',
      errorMessage: 'The weather service timed out after 10 seconds.',
    ),
    ReplitTextPart('Drafts persist per thread. I could not reach the '
        'weather service.'),
  ],
)''';

const String _searchInput = '''
{
  "query": "draft persistence",
  "limit": 5
}''';

const String _searchOutput = '''
{
  "count": 2,
  "results": [
    {"title": "Composer drafts", "path": "/components/composer#drafts"},
    {"title": "Restoring a thread", "path": "/components/message-thread#restore"}
  ]
}''';

const String _weatherInput = '''
{
  "city": "Berlin",
  "units": "metric"
}''';

const String _weatherError = 'The weather service timed out after 10 seconds.';

/// Stage demo for `ReplitTool` — a live run replayed on a loop, the three
/// settled forms, and a turn in a thread carrying two calls, one of which
/// failed.
class ToolDemo extends StatefulWidget {
  const ToolDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ToolDemo> createState() => _ToolDemoState();
}

class _ToolDemoState extends State<ToolDemo> {
  /// The live run's clock: the input fed three characters a beat while
  /// staged, then the two settles, a pause, and around again.
  static const Duration _feedTick = Duration(milliseconds: 45);
  static const int _feedStep = 3;
  static const Duration _runDelay = Duration(milliseconds: 600);
  static const Duration _settleDelay = Duration(milliseconds: 1400);
  static const Duration _restartDelay = Duration(milliseconds: 2400);
  static const Duration _copiedHold = Duration(milliseconds: 1500);

  ReplitToolStatus _status = ReplitToolStatus.pending;
  int _fed = 0;
  Timer? _feed;
  Timer? _step;
  Timer? _copiedReset;
  ReplitCodePart? _copied;

  bool get _live => widget.variant == null || widget.variant == 'live';

  @override
  void initState() {
    super.initState();
    if (_live) _startRun();
  }

  @override
  void dispose() {
    _feed?.cancel();
    _step?.cancel();
    _copiedReset?.cancel();
    super.dispose();
  }

  void _startRun() {
    _feed?.cancel();
    _step?.cancel();
    _status = ReplitToolStatus.pending;
    _fed = 0;
    _feed = Timer.periodic(_feedTick, (timer) {
      if (!mounted) return;
      setState(() => _fed = math.min(_fed + _feedStep, _searchInput.length));
      if (_fed < _searchInput.length) return;
      timer.cancel();
      _step = Timer(_runDelay, () {
        if (!mounted) return;
        setState(() => _status = ReplitToolStatus.running);
        _step = Timer(_settleDelay, () {
          if (!mounted) return;
          setState(() => _status = ReplitToolStatus.complete);
          _step = Timer(_restartDelay, () {
            if (mounted) setState(_startRun);
          });
        });
      });
    });
  }

  void _copy(ReplitCodePart part) {
    Clipboard.setData(ClipboardData(text: part.code));
    _copiedReset?.cancel();
    setState(() => _copied = part);
    _copiedReset = Timer(_copiedHold, () {
      if (mounted) setState(() => _copied = null);
    });
  }

  /// Thread variant: a turn that made two calls, one of which failed,
  /// and the prose that follows them — the shape of an agent's turn.
  List<ReplitMessageData> get _messages => [
    ReplitMessageData.text(
      id: 'u1',
      role: ReplitMessageRole.user,
      text:
          'Do drafts persist between sessions? And is it raining in '
          'Berlin?',
    ),
    const ReplitMessageData(
      id: 'a1',
      role: ReplitMessageRole.assistant,
      parts: [
        ReplitTextPart('Let me check the docs and the forecast.'),
        ReplitToolPart(
          id: 'call_1',
          name: 'search_docs',
          title: 'Searched the docs',
          detail: 'draft persistence',
          status: ReplitToolStatus.complete,
          input: _searchInput,
          output: _searchOutput,
        ),
        ReplitToolPart(
          id: 'call_2',
          name: 'fetch_weather',
          title: 'Fetching the forecast',
          detail: 'Berlin',
          status: ReplitToolStatus.error,
          input: _weatherInput,
          errorMessage: _weatherError,
        ),
        ReplitTextPart(
          'Drafts persist per thread: the composer keeps what you typed '
          'and restores it when you come back. I could not reach the '
          'weather service, so I cannot say whether it is raining.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final complete = _status == ReplitToolStatus.complete;
    final pending = _status == ReplitToolStatus.pending;
    final child = switch (widget.variant) {
      'complete' => ReplitTool(
        name: 'search_docs',
        title: 'Searched the docs',
        detail: 'draft persistence',
        status: ReplitToolStatus.complete,
        input: _searchInput,
        output: _searchOutput,
        inputLabel: 'Input',
        outputLabel: 'Output',
        initiallyExpanded: true,
        codeCopyTooltip: 'Copy',
        copiedCodePart: _copied,
        onCodeCopy: _copy,
      ),
      'running' => const ReplitTool(
        name: 'search_docs',
        title: 'Searching the docs',
        detail: 'draft persistence',
        status: ReplitToolStatus.running,
        input: _searchInput,
        inputLabel: 'Input',
      ),
      'error' => const ReplitTool(
        name: 'fetch_weather',
        title: 'Fetching the forecast',
        detail: 'Berlin',
        status: ReplitToolStatus.error,
        input: _weatherInput,
        errorMessage: _weatherError,
        inputLabel: 'Input',
      ),
      'thread' => SizedBox(
        height: 420,
        child: ReplitThread(
          messages: _messages,
          toolInputLabel: 'Input',
          toolOutputLabel: 'Output',
          codeCopyTooltip: 'Copy',
          copiedCodePart: _copied,
          onCodeCopy: _copy,
        ),
      ),
      _ => ReplitTool(
        name: 'search_docs',
        title: complete ? 'Searched the docs' : 'Searching the docs',
        detail: pending ? null : 'draft persistence',
        status: _status,
        input: !pending
            ? _searchInput
            : _fed == 0
            ? null
            : _searchInput.substring(0, _fed),
        output: complete ? _searchOutput : null,
        inputLabel: 'Input',
        outputLabel: 'Output',
        codeCopyTooltip: 'Copy',
        copiedCodePart: _copied,
        onCodeCopy: _copy,
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.variant == 'thread' ? 560 : 480,
        ),
        child: child,
      ),
    );
  }
}
