import 'dart:async';
import 'dart:math';

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// The canned reply, per the design prototype.
const String _reply =
    'I can assist you with most tasks across this app — changing your name, '
    'booking a hotel, or getting a cab. What else can I do for you today? '
    'If you need anything else, just type it out.';

/// The zero state's starters, per the design.
const List<(IconData, String)> _starters = [
  (
    PhosphorIconsRegular.articleNyTimes,
    'Write an essay about life and enjoyment',
  ),
  (
    PhosphorIconsRegular.calendarCheck,
    'Create a Monday briefing about my tasks and meetings',
  ),
  (PhosphorIconsRegular.magnifyingGlass, 'Suggest a new venture for me'),
];

/// The Full Chat example: a whole conversation surface on [ReplitChatView],
/// live — starts in the zero state, sends for real, streams a canned reply
/// behind the thinking indicator, and carries the add and model menus.
class FullChatDemo extends StatefulWidget {
  const FullChatDemo({super.key});

  @override
  State<FullChatDemo> createState() => _FullChatDemoState();
}

class _FullChatDemoState extends State<FullChatDemo> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _input = TextEditingController();
  final Random _random = Random();
  List<ReplitMessageData> _messages = const [];
  bool _generating = false;
  Timer? _timer;
  bool _researchOn = true;
  bool _webSearchOn = false;
  String _modelId = 'opus-5-1';
  String _effortId = 'extra';
  int _nextId = 0;

  /// Picked and dropped images waiting to be sent. The package decodes
  /// them; holding them is still the host's job.
  final List<ReplitAttachment> _pending = [];
  String? _rejection;

  /// One cap for every way in — the menu's dialog, a drop, a paste — so
  /// a file gets the same answer whichever it takes.
  static const ReplitAttachmentOptions _attachmentOptions = ReplitAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _addAttachments(List<ReplitAttachment> attachments) {
    setState(() {
      _rejection = null;
      _pending.addAll(attachments);
    });
  }

  /// 'Add Files or Photos' in the "+" menu: the package's own dialog,
  /// opened from the host's control. Called synchronously from the
  /// menu's onSelected so the web keeps the tap's user activation.
  Future<void> _pickFiles() async {
    final picked = await showReplitAttachmentPicker(
      options: _attachmentOptions,
      onRejected: _reject,
    );
    if (!mounted || picked.isEmpty) return;
    _addAttachments(picked);
  }

  /// The package has no copy for a refusal, by design — this is the
  /// host's wording, on the composer's error banner until its cross clears it.
  void _reject(String name, ReplitAttachmentRejection reason) {
    final why = switch (reason) {
      ReplitAttachmentRejection.tooLarge => 'is larger than 10 MB',
      ReplitAttachmentRejection.unsupportedType => 'is not an image',
      ReplitAttachmentRejection.unreadable => 'could not be read',
    };
    setState(() => _rejection = '$name $why');
  }

  void _send(String text) {
    _timer?.cancel();
    final id = 'sent${_nextId++}';
    final sent = List.of(_pending);
    setState(() {
      _pending.clear();
      _rejection = null;
      _messages = [
        ..._messages,
        ReplitMessageData(
          id: id,
          role: ReplitMessageRole.user,
          parts: [
            // Attachments above, caption below — parts render in order,
            // so this list is the layout.
            if (sent.isNotEmpty) ReplitAttachmentPart(sent),
            if (text.isNotEmpty) ReplitTextPart(text),
          ],
        ),
        ReplitMessageData(
          id: '$id-reply',
          role: ReplitMessageRole.assistant,
          status: ReplitMessageStatus.pending,
        ),
      ];
      _generating = true;
    });

    // A thinking beat, then the reply streams in word chunks.
    _timer = Timer(const Duration(milliseconds: 1500), () {
      final words = _reply.split(' ');
      var index = 0;
      var streamed = '';
      _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (index >= words.length) {
          timer.cancel();
          _finish();
          return;
        }
        final take = min(1 + _random.nextInt(3), words.length - index);
        streamed += '${words.sublist(index, index + take).join(' ')} ';
        index += take;
        setState(() {
          _messages = [
            ..._messages.sublist(0, _messages.length - 1),
            _messages.last.copyWith(
              parts: [ReplitTextPart(streamed)],
              status: ReplitMessageStatus.streaming,
            ),
          ];
        });
      });
    });
  }

  void _finish() {
    setState(() {
      _generating = false;
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        _messages.last.copyWith(status: ReplitMessageStatus.complete),
      ];
    });
  }

  void _stop() {
    _timer?.cancel();
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return ReplitChatView(
      // Real drag-and-drop — the playground runs on the web, the one
      // platform the SDK gives file drop. The pinned treatment lives on
      // the Attachments stage.
      onAttachmentsDropped: _addAttachments,
      onAttachmentRejected: _reject,
      attachmentOptions: _attachmentOptions,
      dropLabel: 'Drop files to add to chat',
      empty: _messages.isEmpty,
      
      suggestions: ReplitSuggestionGroup(
        layout: ReplitSuggestionLayout.column,
        suggestions: [
          for (final (icon, prompt) in _starters)
            ReplitSuggestion(
              label: prompt,
              icon: icon,
              onTap: () => _input.text = prompt,
            ),
        ],
      ),
      thread: ReplitThread(
        messages: _messages,
        controller: _controller,
        thinkingLabel: 'thinking..',
      ),
      threadController: _controller,
      jumpToLatestTooltip: 'Jump to latest',
      composer: ReplitComposer(
        controller: _input,
        placeholder: 'How can I help you today?',
        isStreaming: _generating,
        onSend: _send,
        onStop: _stop,
        sendTooltip: 'Send',
        stopTooltip: 'Stop',
        // Picking goes through the "+" menu below; paste lands here.
        onAttachmentsPasted: _addAttachments,
        onAttachmentRejected: _reject,
        attachmentOptions: _attachmentOptions,
        errorMessage: _rejection,
        onErrorDismiss: () => setState(() => _rejection = null),
        errorDismissTooltip: 'Dismiss',
        attachments: List.of(_pending),
        removeAttachmentTooltip: 'Remove',
        previewCloseTooltip: 'Close',
        onRemoveAttachment: (id) =>
            setState(() => _pending.removeWhere((a) => a.id == id)),
        leadingActions: [
          ReplitMenu(
            icon: PhosphorIconsRegular.plus,
            tooltip: 'Add to chat',
            sheetTitle: 'Add to Chat',
            entries: [
              const ReplitMenuOption(
                id: 'files',
                icon: PhosphorIconsRegular.file,
                label: 'Add Files or Photos',
              ),
              const ReplitMenuDivider(),
              const ReplitMenuOption(
                id: 'skills',
                icon: PhosphorIconsRegular.scroll,
                label: 'Skills',
              ),
              const ReplitMenuOption(
                id: 'connectors',
                icon: PhosphorIconsRegular.lightning,
                label: 'Connectors',
              ),
              const ReplitMenuDivider(),
              ReplitMenuOption(
                id: 'research',
                icon: PhosphorIconsRegular.graduationCap,
                label: 'Research',
                selected: _researchOn,
              ),
              ReplitMenuOption(
                id: 'web-search',
                icon: PhosphorIconsRegular.globe,
                label: 'Web Search',
                selected: _webSearchOn,
              ),
            ],
            onSelected: (id) {
              switch (id) {
                case 'files':
                  unawaited(_pickFiles());
                case 'research':
                  setState(() => _researchOn = !_researchOn);
                case 'web-search':
                  setState(() => _webSearchOn = !_webSearchOn);
              }
            },
          ),
          if (_researchOn)
            ReplitPill(
              icon: PhosphorIconsRegular.graduationCap,
              label: 'Research',
              removeTooltip: 'Turn off Research',
              onRemove: () => setState(() => _researchOn = false),
            ),
          if (_webSearchOn)
            ReplitPill(
              icon: PhosphorIconsRegular.globe,
              label: 'Web Search',
              removeTooltip: 'Turn off Web Search',
              onRemove: () => setState(() => _webSearchOn = false),
            ),
        ],
        trailingActions: [
          ReplitModelSelector(
            tooltip: 'Choose model',
            sheetTitle: 'Select model',
            models: const [
              ReplitModelOption(
                id: 'fable-5',
                label: 'Fable 5',
                description: 'Our flagship model',
              ),
              ReplitModelOption(
                id: 'opus-5-1',
                label: 'Opus 5.1',
                description: 'For complex & thinking tasks',
              ),
              ReplitModelOption(
                id: 'haiku-4-5',
                label: 'Haiku 4.5',
                description: 'Fastest for quick answers',
              ),
            ],
            selectedId: _modelId,
            onSelected: (id) => setState(() => _modelId = id),
            efforts: const [
              ReplitEffortOption(
                id: 'medium',
                label: 'Medium',
                description: 'Light & casual tasks',
              ),
              ReplitEffortOption(
                id: 'high',
                label: 'High',
                description: 'Balance between speed & complexity',
              ),
              ReplitEffortOption(
                id: 'extra',
                label: 'Extra',
                description: 'Extended thinking for hard problems',
              ),
            ],
            selectedEffortId: _effortId,
            onEffortSelected: (id) => setState(() => _effortId = id),
          ),
        ],
      ),
    );
  }
}
