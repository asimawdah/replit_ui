import 'dart:async';

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'demo_content.dart';

String attachmentsSnippet([String? variant]) => switch (variant) {
  'tiles' => _tilesSnip,
  'drop' => _dropSnip,
  _ => _composerSnip,
};

const String _composerSnip = '''
ReplitComposer(
  controller: input,
  attachments: [
    // No thumbnail: the tile draws the wash with the kind pill. A picked
    // image shows itself instead and carries no pill.
    ReplitAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
    ReplitAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
  ],
  onRemoveAttachment: remove,
  removeAttachmentTooltip: 'Remove',
  onSend: send,
  leadingActions: [
    ReplitMenu(
      icon: PhosphorIconsRegular.plus,
      sheetTitle: 'Add to Chat',
      entries: [ReplitMenuOption(id: 'files', label: 'Add Files or Photos')],
      // The package's own dialog, from the host's menu.
      onSelected: (id) {
        if (id == 'files') pickFiles();
      },
    ),
  ],
)

Future<void> pickFiles() async {
  final picked = await showReplitAttachmentPicker(onRejected: showRejection);
  setState(() => attachments.addAll(picked));
}''';

const String _dropSnip = '''
// onAttachmentsDropped turns on the surface's own drag-and-drop: it
// raises the treatment while a file is over the page and comes back
// with what landed, read and decoded. Web only — the SDK implements OS
// file drop nowhere else — so desktop hosts bring their own detection
// and flip dropActive, which stays writable for exactly that.
ReplitChatView(
  onAttachmentsDropped: (dropped) =>
      setState(() => pending.addAll(dropped)),
  onAttachmentRejected: showRejection,
  attachmentOptions: const ReplitAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  ),
  dropLabel: 'Drop files to add to chat',
  // An override, not a switch: the treatment is up while this is true
  // or a real drag is over the surface.
  dropActive: dragHovering,
  thread: ReplitThread(messages: messages),
  composer: ReplitComposer(
    onSend: send,
    attachments: pending,
    onRemoveAttachment: removePending,
  ),
)''';

const String _tilesSnip = '''
// The strip on its own, outside a composer.
ReplitAttachmentGroup(
  attachments: attachments,
  onRemove: remove,
)''';

const List<ReplitAttachment> _seed = [
  ReplitAttachment(id: 'spec', kind: 'PDF', label: 'sensor-spec.pdf'),
  ReplitAttachment(id: 'photo', kind: 'JPG', label: 'prototype.jpg'),
];

/// Attachments as the design stages them — kind-pill tiles in the
/// composer, prefilled with the mock's message, each removable, with the
/// "+" menu opening the real dialog. The Tiles-only variant shows the
/// standalone [ReplitAttachmentGroup]; Drop files pins the chat surface's
/// drag-and-drop treatment so it can be seen without a real drag.
class AttachmentsDemo extends StatefulWidget {
  const AttachmentsDemo({super.key, this.variant});

  final String? variant;

  @override
  State<AttachmentsDemo> createState() => _AttachmentsDemoState();
}

class _AttachmentsDemoState extends State<AttachmentsDemo> {
  late final TextEditingController _input = TextEditingController(
    text: 'Make the best sensor out there for me. Be the best',
  );
  List<ReplitAttachment> _attachments = _seed;
  String? _rejection;

  static const ReplitAttachmentOptions _attachmentOptions = ReplitAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _remove(String id) {
    setState(() {
      _attachments = [..._attachments.where((a) => a.id != id)];
    });
  }

  void _reject(String name, ReplitAttachmentRejection reason) {
    final why = switch (reason) {
      ReplitAttachmentRejection.tooLarge => 'is larger than 10 MB',
      ReplitAttachmentRejection.unsupportedType => 'is not an image',
      ReplitAttachmentRejection.unreadable => 'could not be read',
    };
    setState(() => _rejection = '$name $why');
  }

  /// The "+" menu's 'Add Files or Photos': the package's dialog, opened
  /// synchronously from the tap so the web keeps its user activation.
  Future<void> _pickFiles() async {
    final picked = await showReplitAttachmentPicker(
      options: _attachmentOptions,
      onRejected: _reject,
    );
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _rejection = null;
      _attachments = [..._attachments, ...picked];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == 'drop') return const _DropDemo();
    if (widget.variant == 'tiles') {
      return Center(
        child: ReplitAttachmentGroup(
          attachments: _attachments,
          onRemove: _remove,
          removeTooltip: 'Remove',
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ReplitComposer(
          controller: _input,
          placeholder: 'How can I help you today?',
          attachments: _attachments,
          onRemoveAttachment: _remove,
          removeAttachmentTooltip: 'Remove',
          onAttachmentRejected: _reject,
          attachmentOptions: _attachmentOptions,
          errorMessage: _rejection,
          onErrorDismiss: () => setState(() => _rejection = null),
          errorDismissTooltip: 'Dismiss',
          onSend: (_) {},
          leadingActions: [
            ReplitMenu(
              icon: PhosphorIconsRegular.plus,
              tooltip: 'Add to chat',
              sheetTitle: 'Add to Chat',
              entries: const [
                ReplitMenuOption(
                  id: 'files',
                  icon: PhosphorIconsRegular.file,
                  label: 'Add Files or Photos',
                ),
              ],
              // The real dialog, from the menu.
              onSelected: (id) {
                if (id == 'files') unawaited(_pickFiles());
              },
            ),
          ],
          trailingActions: [
            ReplitModelSelector(
              tooltip: 'Choose model',
              sheetTitle: 'Select model',
              models: demoModels,
              selectedId: 'opus-5-1',
              onSelected: (_) {},
              efforts: demoEfforts,
              selectedEffortId: 'extra',
              onEffortSelected: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

/// The chat surface with its drop treatment pinned up, so the stage and
/// the docs embed show it without anyone holding a file over the page.
/// A real drag works too — `dropActive` is an override, not a switch.
class _DropDemo extends StatefulWidget {
  const _DropDemo();

  @override
  State<_DropDemo> createState() => _DropDemoState();
}

class _DropDemoState extends State<_DropDemo> {
  static const ReplitAttachmentOptions _attachmentOptions = ReplitAttachmentOptions(
    maxFileSize: 10 * 1024 * 1024,
  );

  late final TextEditingController _input = TextEditingController(
    text: 'Make the best sensor out there for me. Be the best',
  );
  List<ReplitAttachment> _pending = _seed;
  String? _rejection;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _add(List<ReplitAttachment> attachments) {
    setState(() {
      _rejection = null;
      _pending = [..._pending, ...attachments];
    });
  }

  void _reject(String name, ReplitAttachmentRejection reason) {
    final why = switch (reason) {
      ReplitAttachmentRejection.tooLarge => 'is larger than 10 MB',
      ReplitAttachmentRejection.unsupportedType => 'is not an image',
      ReplitAttachmentRejection.unreadable => 'could not be read',
    };
    setState(() => _rejection = '$name $why');
  }

  Future<void> _pickFiles() async {
    final picked = await showReplitAttachmentPicker(
      options: _attachmentOptions,
      onRejected: _reject,
    );
    if (!mounted || picked.isEmpty) return;
    _add(picked);
  }

  @override
  Widget build(BuildContext context) {
    return ReplitChatView(
      onAttachmentsDropped: _add,
      onAttachmentRejected: _reject,
      attachmentOptions: _attachmentOptions,
      dropActive: true,
      dropLabel: 'Drop files to add to chat',
      thread: const ReplitThread(messages: []),
      composer: ReplitComposer(
        controller: _input,
        placeholder: 'How can I help you today?',
        attachments: _pending,
        onRemoveAttachment: (id) => setState(() {
          _pending = [..._pending.where((a) => a.id != id)];
        }),
        removeAttachmentTooltip: 'Remove',
        onAttachmentsPasted: _add,
        onAttachmentRejected: _reject,
        attachmentOptions: _attachmentOptions,
        errorMessage: _rejection,
        onErrorDismiss: () => setState(() => _rejection = null),
        errorDismissTooltip: 'Dismiss',
        onSend: (_) {},
        leadingActions: [
          ReplitMenu(
            icon: PhosphorIconsRegular.plus,
            tooltip: 'Add to chat',
            sheetTitle: 'Add to Chat',
            entries: const [
              ReplitMenuOption(
                id: 'files',
                icon: PhosphorIconsRegular.file,
                label: 'Add Files or Photos',
              ),
            ],
            onSelected: (id) {
              if (id == 'files') unawaited(_pickFiles());
            },
          ),
        ],
      ),
    );
  }
}
