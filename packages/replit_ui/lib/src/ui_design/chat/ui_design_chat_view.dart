import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:replit_ui/src/models/replit_attachment.dart';
import 'package:replit_ui/src/models/replit_message_data.dart';
import 'package:replit_ui/src/models/replit_message_part.dart';
import 'package:replit_ui/src/styles/replit_chat_view_style.dart';
import 'package:replit_ui/src/styles/replit_composer_style.dart';
import 'package:replit_ui/src/utils/replit_toast_layer.dart'
    show showReplitToast;
import 'package:replit_ui/src/widgets/replit_chat_view.dart';
import 'package:replit_ui/src/widgets/replit_composer.dart';
import 'package:replit_ui/src/widgets/replit_message_actions.dart';
import 'package:replit_ui/src/widgets/replit_model_selector.dart';
import 'package:replit_ui/src/widgets/replit_suggestion.dart';
import 'package:replit_ui/src/widgets/replit_thread.dart';
import 'package:replit_ui/src/ui_design/chat/chat_state.dart';
import 'package:replit_ui/src/ui_design/chat/ui_design_chat.dart';
import 'package:replit_ui/src/ui_design/strings.dart';
import 'package:replit_ui/src/ui_design/tools/tool.dart';

/// Builds the content shown under a tool card for [record], or null for
/// none; called for every call in every status.
typedef ToolBodyBuilder = Widget? Function(
  BuildContext context,
  ToolCallRecord record,
);

/// The finished chat screen for a [UiDesignChat]: thread, composer,
/// attachments, message actions, tool cards and model selector. Body-only;
/// put it in a Scaffold under material_ui's MaterialApp.
class UiDesignChatView extends StatefulWidget {
  const UiDesignChatView({
    required this.chat,
    super.key,
    this.greeting,
    this.suggestions = const <String>[],
    this.suggestionsLayout = ReplitSuggestionLayout.column,
    this.header,
    this.strings,
    this.showModelSelector = true,
    this.showActions = true,
    this.showEditAction = false,
    this.onLinkTap,
    this.toolBodyBuilder,
    this.leadingActions = const <Widget>[],
    this.trailingActions = const <Widget>[],
    this.maxContentWidth = 760,
    this.style,
    this.composerStyle,
    this.composerLayout = ReplitComposerLayout.expanded,
  });

  /// The chat this screen shows and drives.
  final UiDesignChat chat;

  /// Renders content under a tool card, e.g. a table for a query result.
  final ToolBodyBuilder? toolBodyBuilder;

  /// Shown above the composer while the thread is empty.
  final Widget? greeting;

  /// Prompt starters shown while the thread is empty; a tap sends one.
  final List<String> suggestions;

  final ReplitSuggestionLayout suggestionsLayout;

  /// A full-width bar above the thread.
  final Widget? header;

  /// Overrides the chat's strings for this screen.
  final ReplitStrings? strings;

  /// Shows a model selector when the provider offers more than one model.
  final bool showModelSelector;

  /// Shows copy, feedback and regenerate under settled replies.
  final bool showActions;

  /// Shows an edit action under user turns; sending then replaces that
  /// turn and everything after it.
  final bool showEditAction;

  /// Called with the href of a tapped link; links render as prose when
  /// null.
  final ValueChanged<String>? onLinkTap;

  /// Extra composer actions before the attach button.
  final List<Widget> leadingActions;

  /// Extra composer actions before the model selector.
  final List<Widget> trailingActions;

  final double maxContentWidth;
  final ReplitChatViewStyle? style;
  final ReplitComposerStyle? composerStyle;
  final ReplitComposerLayout composerLayout;

  @override
  State<UiDesignChatView> createState() => _UiDesignChatViewState();
}

class _UiDesignChatViewState extends State<UiDesignChatView> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _text = TextEditingController();
  String? _editingId;

  UiDesignChat get _chat => widget.chat;

  ReplitStrings get _strings => widget.strings ?? _chat.strings;

  @override
  void initState() {
    super.initState();
    _text.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _text
      ..removeListener(_onTextChanged)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_editingId != null && _text.text.isEmpty) {
      setState(() => _editingId = null);
    }
  }

  void _send(String text) {
    final editingId = _editingId;
    if (editingId != null) {
      _editingId = null;
      unawaited(_chat.editAndResend(editingId, text));
    } else {
      unawaited(_chat.send(text));
    }
  }

  void _insertContent(KeyboardInsertedContent content) {
    final data = content.data;
    if (data == null || data.isEmpty) return;
    _chat.addAttachments([
      ReplitAttachment(
        id: 'kbd_${DateTime.now().microsecondsSinceEpoch}',
        thumbnail: MemoryImage(data),
        label: 'keyboard image',
        bytes: data,
        mimeType: content.mimeType,
      ),
    ]);
  }

  void _edit(ReplitMessageData message) {
    _text.text = [
      for (final part in message.parts)
        if (part is ReplitTextPart) part.text,
    ].join('\n');
    setState(() => _editingId = message.id);
  }

  void _copy(BuildContext context, ReplitMessageData message) {
    unawaited(_chat.copy(message));
    showReplitToast(
      context: context,
      icon: Icons.copy_outlined,
      message: _strings.copied,
      dismissTooltip: _strings.dismiss,
    );
  }

  Widget? _actions(
    BuildContext context,
    ChatState state,
    ReplitMessageData message,
  ) {
    final strings = _strings;
    if (message.role == ReplitMessageRole.user) {
      if (!widget.showEditAction) return null;
      return ReplitMessageActions(
        actions: [
          ReplitMessageAction.edit(
            tooltip: strings.edit,
            onPressed: state.isGenerating ? null : () => _edit(message),
          ),
        ],
      );
    }
    if (!widget.showActions ||
        message.role != ReplitMessageRole.assistant ||
        message.status != ReplitMessageStatus.complete) {
      return null;
    }
    final feedback = state.feedback[message.id];
    final isLatest = message.id == state.messages.last.id;
    return ReplitMessageActions(
      actions: [
        ReplitMessageAction.copy(
          tooltip: strings.copy,
          onPressed: () => _copy(context, message),
        ),
        ReplitMessageAction.thumbUp(
          tooltip: strings.goodResponse,
          selected: feedback == true,
          onPressed: () => _chat.setFeedback(message.id, positive: true),
        ),
        ReplitMessageAction.thumbDown(
          tooltip: strings.badResponse,
          selected: feedback == false,
          onPressed: () => _chat.setFeedback(message.id, positive: false),
        ),
        if (isLatest)
          ReplitMessageAction.regenerate(
            tooltip: strings.regenerate,
            onPressed: state.isGenerating
                ? null
                : () => unawaited(_chat.regenerate()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ChatState>(
    valueListenable: _chat.state,
    builder: (context, state, _) {
      final strings = _strings;
      final models = _chat.provider.models;
      final onLinkTap = widget.onLinkTap;
      return ReplitChatView(
        header: widget.header,
        empty: state.messages.isEmpty,
        greeting: widget.greeting,
        suggestions: widget.suggestions.isEmpty
            ? null
            : ReplitSuggestionGroup(
                layout: widget.suggestionsLayout,
                suggestions: [
                  for (final suggestion in widget.suggestions)
                    ReplitSuggestion(
                      label: suggestion,
                      onTap: () => _send(suggestion),
                    ),
                ],
              ),
        thread: ReplitThread(
          messages: state.messages,
          controller: _scroll,
          thinkingLabel: strings.thinking,
          errorTitle: strings.errorTitle,
          retryLabel: strings.retry,
          onRetry: (message) => unawaited(_chat.retry(message)),
          onLinkTap: onLinkTap == null
              ? null
              : (message, href) => onLinkTap(href),
          onCodeCopy: (part) => unawaited(_chat.copyCode(part)),
          copiedCodePart: state.copiedCodePart,
          codeCopyTooltip: strings.copyCode,
          onConfirmationRespond: (message, part, approved) =>
              _chat.respondToConfirmation(message, part, approved: approved),
          approveLabel: strings.approve,
          rejectLabel: strings.reject,
          approvedLabel: strings.approved,
          rejectedLabel: strings.rejected,
          toolInputLabel: strings.toolInput,
          toolOutputLabel: strings.toolOutput,
          customPartBuilder: (context, message, part) {
            if (part.type != UiDesignChat.toolPartType) return null;
            final record = part.data;
            return record is ToolCallRecord
                ? widget.toolBodyBuilder?.call(context, record)
                : null;
          },
          messageFooter: widget.showActions || widget.showEditAction
              ? (message) => _actions(context, state, message)
              : null,
        ),
        threadController: _scroll,
        jumpToLatestTooltip: strings.jumpToLatest,
        maxContentWidth: widget.maxContentWidth,
        onAttachmentsDropped: _chat.addAttachments,
        onAttachmentRejected: _chat.rejectAttachment,
        attachmentOptions: _chat.attachmentOptions,
        dropLabel: strings.dropFiles,
        style: widget.style,
        composer: ReplitComposer(
          layout: widget.composerLayout,
          isStreaming: state.isGenerating,
          onSend: _send,
          onStop: _chat.stop,
          sendTooltip: strings.send,
          stopTooltip: strings.stop,
          controller: _text,
          placeholder: strings.placeholder,
          attachments: state.pendingAttachments,
          onRemoveAttachment: _chat.removeAttachment,
          removeAttachmentTooltip: strings.removeAttachment,
          onAttachmentsPicked: _chat.addAttachments,
          onAttachmentsDropped: _chat.addAttachments,
          onAttachmentsPasted: _chat.addAttachments,
          onAttachmentRejected: _chat.rejectAttachment,
          attachmentOptions: _chat.attachmentOptions,
          attachTooltip: strings.attach,
          errorMessage: state.attachmentError,
          onErrorDismiss: _chat.dismissAttachmentError,
          errorDismissTooltip: strings.dismiss,
          onContentInserted: _insertContent,
          leadingActions: widget.leadingActions,
          trailingActions: [
            ...widget.trailingActions,
            if (widget.showModelSelector && models.length > 1)
              ReplitModelSelector(
                models: [
                  for (final option in models)
                    ReplitModelOption(
                      id: option.id,
                      label: option.label,
                      description: option.description,
                    ),
                ],
                selectedId: state.model,
                onSelected: _chat.selectModel,
              ),
          ],
          style: widget.composerStyle,
        ),
      );
    },
  );
}
