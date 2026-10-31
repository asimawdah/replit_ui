## 0.4.0 (unreleased)

- Integrates the optional streaming chat SDK into replit_ui, including Gemini, OpenAI-compatible and Anthropic providers, tool execution, and the `UiDesignChat` controller and view.
- Breaking: renames the streaming chat API to `UiDesignChat`, `UiDesignChatView` and `UiDesignProvider`.
- Breaking: moves the streaming SDK into `replit_ui`; replace the former standalone package dependency with `replit_ui` and update imports to `package:replit_ui/replit_ui.dart`.
- Breaking: renames the pub package to `replit_ui`; update dependencies and imports to `package:replit_ui/replit_ui.dart`.
- Bundles Google Sans and Google Sans Code with the package instead of fetching them through google_fonts, which is dropped as a dependency. Nothing is fetched at runtime, so hosts no longer need android.permission.INTERNET or com.apple.security.network.client, and there is no fallback face on the first frame. Google Sans ships as a Latin subset; the scripts it leaves out fall back to the platform face, as CJK already did.
- Makes `ReplitTypography.standard` and `ReplitTheme.typography` `const` again, and `ReplitTypography.code` / `codeInline` plain fields with const defaults.
- Deprecates `ReplitTypography.recut` in favour of `copyWith(fontWeight:, fontStyle:)` — the bundled families declare every cut, so the engine resolves it from the weight on the style. Removed in 0.6.0.
- Adds ReplitTool, the tool-call card: one mark morphs with the call's status (a still asterisk while staged, turning while it runs, a check or an error glyph once settled), the host's title and primary argument sit on the row, and the input and output render as code blocks behind a disclosure, with a failure readable without a tap. ReplitToolPart renders it in a thread, keyed by the provider's call id and copying through ReplitThread.onCodeCopy; ReplitToolStyle joins the component styles with a ReplitTheme.toolStyle default. Metrics are provisional pending a design frame.
- Adds a compact layout to ReplitComposer: `layout: ReplitComposerLayout.compact` folds the card into a single-row pill, with the attach button, `leadingActions`, the field, `trailingActions` and send inline, no action row, and nothing drawn for what is not wired. Pending attachments sit in a strip above the row, the field still inline. It opens into the full card by itself once the draft wraps past one line, and folds back when the draft is empty, keeping the field's focus and draft through both. `ReplitComposerLayout.expanded`, the default, is unchanged. Metrics are provisional pending a design frame.
- Tightens the full ReplitComposer card: the field no longer keeps a 38px floor under a one-line draft, and the gap above the action row drops from 16 to 12, so an empty card stands at about 95px instead of 116.
- Adds ReplitComposer.expands for a composer at a fixed height: the card fills the height its parent gives it, and the field takes the space above the action row and scrolls inside it. Like TextField.expands it needs a bounded height, and it works with the full card only.
- Adds ReplitComposer.sendTooltip and stopTooltip, host-localized names for the send and stop buttons. Both now read as buttons with their enabled state, so a disabled send button no longer drops out of the accessibility tree.
- Fixes Enter sending the draft while an input method is still composing: Enter now confirms the composition, as in any text field.
- Enter no longer adds a newline while a reply streams, or when held down after a send; Shift+Enter still inserts one.
- Keeps the composer's focus when ReplitChatView leaves its wide zero state. The view rebuilt the composer as it moved from the centre to the bottom edge, so the field lost focus on the first send; it now moves the same composer, state and all.

## 0.3.0

- Adds ReplitToast and showReplitToast, a floating notice that stacks as a deck, dismisses itself after four seconds and pauses under the pointer.
- Makes text in a ReplitThread selectable, the way a chat in a browser is, keeping line breaks on copy; ReplitThread.selectable turns it off.
- Adds ReplitConfirmation, the approval card, and ReplitConfirmationPart to render it in a thread, answering through ReplitThread.onConfirmationRespond.
- Adds ReplitThreadList, the side panel's conversation history, with labeled sections, single selection, unread and pinned markers and a leading icon slot.
- Adds ReplitImagePart, a large-format picture in a turn that shimmers until the image lands, opens the preview on tap and carries its bytes and mimeType.
- Adds built-in attachment input: the attach button opens the platform's file picker, on the web files drop onto the chat view and images paste into the field, ReplitAttachmentOptions filters what is accepted and attachmentsEnabled switches it all off. A picture with no caption now sends on its own, so onSend can fire with empty text.
- Adds a style object to every major widget (ReplitComposerStyle, ReplitMessageStyle, ReplitChatViewStyle and more), each with an app-wide default on ReplitTheme.
- Switches to Google Sans and Google Sans Code, fetched at runtime by google_fonts, which needs android.permission.INTERNET and com.apple.security.network.client in a sandboxed macOS app.
- Adds file_selector (flutter.dev) as a dependency for the built-in picker; macOS apps that use it need the com.apple.security.files.user-selected.read-only entitlement.
- Breaking: outline and outlineVariant swap meaning, outline now the faint hairline and outlineVariant the firm one; ReplitColors gains nine required roles, and markdown links default to secondary.
- Breaking: ReplitMessagePart is sealed, so an exhaustive switch needs ReplitImagePart and ReplitConfirmationPart cases.
- Breaking: ReplitTypography.standard is built at runtime, so use ReplitTypography.recut instead of copyWith(fontWeight:); hosts naming Figtree or GeistMono should update.

## 0.2.0

- Adds ReplitCodeBlock and a ReplitCodePart message part with built-in highlighting for Dart, JSON, JavaScript, TypeScript, Python, shell, YAML, HTML, CSS and SQL; ReplitCodeLanguage.register adds more.
- Adds ReplitSyntaxColors theme tokens for the highlighting, and code and codeInline typography roles on a bundled Geist Mono.
- Adds ReplitMarkdown, a built-in parser and renderer for assistant prose: headings, emphasis, inline code, links, lists, quotes, rules, tables and fenced code.
- Reveals streaming markdown through one sequenced frontier, so a thread pinned to the newest message moves continuously; reduced motion renders statically.
- Adds ReplitErrorState and a ReplitErrorPart message part, with onRetry, errorTitle and retryLabel on ReplitMessage and ReplitThread.
- Adds ReplitPill, a removable pill for an enabled tool or mode in the composer's action row, dropping to icon-only on phones.
- Adds ReplitThread.messageFooter to fill each message's footer slot without replacing the whole message.
- Adds emphasised cuts to the title and label typography roles and retunes sizes and line heights to the design file.
- Dismisses the keyboard on taps on the chat surface and on thread scroll (ReplitThread.keyboardDismissBehavior).
- Reads a conversation that fits its viewport from the top instead of hugging the composer.
- Moves the chat view's scrollbar to the surface's edge and puts the jump-to-latest button on an outlined disc.
- Breaking: renames ReplitChatScreen to ReplitChatView; the API is unchanged.
- Breaking: assistant text parts render as markdown by default; pass `markdown: false` for literal text.
- Breaking: ReplitTypography requires the new emphasised styles, and label sizes step up one rung to 16, 14 and 12.
- Breaking: ReplitComposer.placeholder defaults to "How can I help you today?"; pass `placeholder: null` for an empty field.
- Breaking: ReplitChatView.composer is required, still nullable, so a read-only surface passes `composer: null`.
- Breaking: a failed assistant turn keeps its normal ink and closes with an error card instead of an errorContainer bubble.
- Breaking: migrates from flutter/material.dart to material_ui; hosts run `dart fix --apply --code=migrate_design_widgets` on Flutter 3.44 or newer, or pin replit_ui 0.1.x.

## 0.1.0

- First public release: the assistant UI component library for Flutter, with no third-party dependencies and nothing model-facing.
- Adds ReplitTheme design tokens as a ThemeExtension, with light and dark presets and a bundled Figtree typeface.
- Adds ReplitMessage and ReplitThread: an ink-wash user bubble, a plain assistant turn, typed content parts and a ReplitCustomPart extension seam.
- Adds streaming text, a thinking indicator and shimmer text.
- Adds message actions with copy, regenerate, edit and feedback presets.
- Adds ReplitComposer, a multiline input with send and stop, an attachments strip and action slots.
- Adds ReplitMenu and ReplitModelSelector, an anchored card on desktop and a sheet on phones.
- Adds attachment tiles for images and files, with a full-screen preview.
- Adds suggestions in scroll, wrap and column layouts, with ReplitGreeting for the zero state.
- Adds ReplitChatScreen, the composed surface with a centred rail, a zero state and jump-to-latest.

## 0.0.1

- Initial scaffold.
