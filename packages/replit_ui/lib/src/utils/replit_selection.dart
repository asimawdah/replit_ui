import 'dart:math' as math;

import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:material_ui/material_ui.dart';

import '../theme/replit_theme.dart';

// Internal — not exported from the package barrel.

/// The highlight's strength over the accent — provisional, pending a
/// design frame for selection.
const double _selectionOpacity = 0.3;

/// The selection colours for a Replit surface: the host's explicit
/// [TextSelectionTheme] wins field by field, and the tokens fill in the
/// rest — the highlight is `primary` at [_selectionOpacity], the handles
/// and the caret are `primary` itself.
///
/// A [ThemeData.textSelectionTheme] left at its defaults reads as unset
/// (every field null), so a host that never touched it gets Replit's
/// colours, and one that themed selection app-wide keeps its own.
TextSelectionThemeData replitTextSelectionTheme(BuildContext context) {
  final host = TextSelectionTheme.of(context);
  final colors = context.replitColors;
  return TextSelectionThemeData(
    selectionColor:
        host.selectionColor ??
        colors.primary.withValues(alpha: _selectionOpacity),
    selectionHandleColor: host.selectionHandleColor ?? colors.primary,
    cursorColor: host.cursorColor ?? colors.primary,
  );
}

/// A [SelectionArea] in Replit's colours: the thread's, and a standalone
/// code block's. Installs [replitTextSelectionTheme] above the area so the
/// highlight, the handles and the toolbar all read it — Flutter builds the
/// handles and the menu inside captured inherited themes.
///
/// The blocks inside end their copied text in a newline whenever the
/// selection runs past them, which a selection drawn to the very end of
/// the content would carry into the clipboard; the area trims those, so a
/// copy never ends in a blank line.
class ReplitSelectionArea extends StatefulWidget {
  const ReplitSelectionArea({super.key, required this.child});

  final Widget child;

  @override
  State<ReplitSelectionArea> createState() => _ReplitSelectionAreaState();
}

class _ReplitSelectionAreaState extends State<ReplitSelectionArea> {
  final _ReplitSelectionTrimDelegate _delegate = _ReplitSelectionTrimDelegate();

  @override
  void dispose() {
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextSelectionTheme(
      data: replitTextSelectionTheme(context),
      child: SelectionArea(
        child: SelectionContainer(delegate: _delegate, child: widget.child),
      ),
    );
  }
}

/// The area's one container: the copied text without the trailing
/// newlines the last selected blocks appended.
class _ReplitSelectionTrimDelegate extends StaticSelectionContainerDelegate {
  static final RegExp _trailingNewlines = RegExp(r'\n+$');

  @override
  SelectedContent? getSelectedContent() {
    final content = super.getSelectedContent();
    if (content == null) return null;
    final text = content.plainText.replaceFirst(_trailingNewlines, '');
    if (text.length == content.plainText.length) return content;
    return SelectedContent(plainText: text);
  }
}

/// One block of selectable content — a paragraph, a code body, a whole
/// message — that copies with a line break after it.
///
/// Flutter joins the selected text of separate paragraphs with nothing
/// between them, so two selected paragraphs copy as one run-on line. A
/// block appends a newline whenever the selection runs past its end,
/// which is exactly when another block follows in the selection. Blocks
/// nest: a message block wraps its paragraphs, so its own newline lands
/// after theirs and turns copy a blank line apart.
///
/// Inert outside a selection area — and under [SelectionContainer.disabled]
/// — where it renders [child] as is.
class ReplitSelectionBlock extends StatefulWidget {
  const ReplitSelectionBlock({super.key, required this.child});

  final Widget child;

  @override
  State<ReplitSelectionBlock> createState() => _ReplitSelectionBlockState();
}

class _ReplitSelectionBlockState extends State<ReplitSelectionBlock> {
  // SelectionContainer does not dispose the delegate it is handed; the
  // block owns it for the container's lifetime.
  final _ReplitSelectionBlockDelegate _delegate = _ReplitSelectionBlockDelegate();

  @override
  void dispose() {
    _delegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SelectionContainer.maybeOf(context) == null) return widget.child;
    return SelectionContainer(delegate: _delegate, child: widget.child);
  }
}

/// The static delegate — it already tracks the selection's edges and
/// re-synthesizes them for a child that registers late, like a paragraph
/// whose text just grew mid-stream — with one change: the copied text
/// ends in a newline when the selection reaches past the block.
class _ReplitSelectionBlockDelegate extends StaticSelectionContainerDelegate {
  @override
  SelectedContent? getSelectedContent() {
    final content = super.getSelectedContent();
    final range = getSelection();
    if (content == null || range == null || content.plainText.isEmpty) {
      return content;
    }
    // The selection touches the block's last character only when it
    // continues into the next block — or was drawn to exactly its end,
    // where a trailing newline is what a browser gives too.
    final end = math.max(range.startOffset, range.endOffset);
    if (end < contentLength) return content;
    return SelectedContent(plainText: '${content.plainText}\n');
  }
}
