# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What this is

**replit_ui** is a chat/assistant UI component library for Flutter — the presentation layer for AI assistant interfaces. It is a plain Flutter package (no codegen) at `packages/replit_ui/`, inside a pub workspace driven by melos. Downstream packages depend on the public API exported from `lib/replit_ui.dart`, so treat it as a compatibility surface.

Two hard constraints shape everything here:

- **Dependencies are deliberate.** `dependencies:` in `packages/replit_ui/pubspec.yaml` holds Flutter, Flutter-published `material_ui` and `file_selector`, and `http` for the optional Gemini, OpenAI-compatible and Anthropic streaming providers. `http` adds no host permissions or platform setup; provider requests only happen when an app constructs a provider. The file picker needs the documented macOS `com.apple.security.files.user-selected.read-only` entitlement. Dev dependencies (`flutter_test`, `flutter_lints`) are fine.
- **The library does not redistribute the brand font.** Diatype is licensed for Replit-branded materials and is bundled by the Replit-branded app, docs, playground, and examples. `replit_ui` typography inherits the host's text face, and hosts that cannot bundle Diatype keep the platform fallback. No fonts are fetched at runtime.
- **UI remains model-neutral.** UI components render state and report intent through callbacks. The optional streaming SDK is the separate layer in this same package that owns provider calls, prompts, wire types and tool execution.

The theme, the conversation components (message, thread, streaming text, actions, loading), the composer and its menus, attachments with their preview, suggestions, and the chat surface are implemented; the roadmap below tracks the rest. Message content is modeled as typed parts (`lib/src/models/`) — sealed `ReplitMessagePart` subtypes rendered by `ReplitMessage`, with `ReplitCustomPart` + `ReplitCustomPartBuilder` as the extension seam for host-injected content.

## Layout

- Root `pubspec.yaml` is the pub workspace (members under `workspace:`) with the melos scripts; root `analysis_options.yaml` (very_good_analysis) governs workspace tools without a nearer configuration.
- `packages/replit_ui/` — the published package: UI components in `lib/src/`, the optional streaming SDK in `lib/src/ui_design/`, `example/`, assets, maintainer tools under `tool/`, and its own flutter_lints configuration.
- `playground/` — the Replit UI Playground: a full Flutter app and workspace member depending on `replit_ui: ^0.4.0`. Use it to demo and manually exercise components (every component has a stage demo, with variant pills and code snippets).
- `docs/` — the Astro site behind replit.asimawdah.com. `contracts/` — the SDK wire contract.

## Commands

**Don't write comments unless asked.** No doc comments, file headers or inline explanations in new or edited code; the code and the commit message carry the intent. The one exception is a comment a lint requires (for example `document_ignores` above an `// ignore`), kept to one line. Public API dartdoc is written only when the user asks for it.

From the repo root:

```bash
flutter pub get                    # resolves the whole workspace
dart run melos run analyze         # dart analyze --fatal-infos in every member
dart run melos run format
dart run melos run test
cd packages/replit_ui && flutter analyze && flutter pub publish --dry-run
```

Playground app:

```bash
cd playground
flutter pub get
flutter run -d chrome    # or any device
```

## Streaming SDK

The optional streaming SDK ships inside `replit_ui`. Its public API is exported by `package:replit_ui/replit_ui.dart`; implementation lives under `lib/src/ui_design/`. `UiDesignChat` owns state and turns, `UiDesignChatView` renders them, provider adapters normalize Gemini/OpenAI/Anthropic streams, and the tool loop handles dispatch, approvals, cancellation and continuation segments.

- Adapters emit `SseEvent`: `start` first, one `done` last, with `seq` from 0. The shared `turn_runner.dart` owns HTTP, aborts, timeouts, API-key scrubbing and tool-call bookkeeping; adapters map provider frames and replay provider-specific content when needed.
- `tool_loop.dart` owns dispatch, approval, timeouts, abort and continuation segments. The controller renders calls into parts and answers confirmations.
- API keys stay in a private field and are sent in one header, never in URLs, logs, `toString` or error text.
- Verify with `dart analyze --fatal-infos`, the smoke utility (`cd packages/replit_ui && dart run --define=PROVIDER=gemini --define=GEMINI_API_KEY=... tool/ui_design_smoke.dart`; also `anthropic` and `openai`; `--define=ABORT_AFTER_FIRST_DELTA=true`, `--define=IMAGE=path.png`, and `--define=TOOLS=true` cover the relevant flows), and the example at `packages/replit_ui/example`.

`contracts/` is the streaming wire contract, kept as prose and JSON Schema. The corresponding hand-written Dart types are under `packages/replit_ui/lib/src/ui_design/transport/`; update them together when changing a contract.

## Releases

The `replit_ui-v<version>` tag publishes `packages/replit_ui` and deploys the docs site (`.github/workflows/publish.yml`). Before tagging, bump `version:` in `packages/replit_ui/pubspec.yaml`, the `replit_ui:` constraints in its example and `playground`, and `CHANGELOG.md`. The pana gate wants a perfect score.

## Commits

Commit messages are conventional commits with a brief summary line:
`feat: <brief-commit-message>` — `fix:`, `refactor:`, `docs:`, `chore:` as
appropriate. Add a body only when a decision genuinely needs recording, and
never any AI attribution.

## Component roadmap

Status legend: ⬜ Todo · ✅ Done

### Theme (build first)

`ThemeExtension`-based design tokens for **colors and typography**; every component consumes these two token sets (no hardcoded colors or text styles). Spacing and corner radii are deliberately *not* tokens: following Material's structure, each component bakes its own metrics from the Figma file as private spec constants and exposes per-widget overrides (`padding:`, `borderRadius:`) where hosts retheme.

| # | Component | Notes | Status |
|---|-----------|-------|--------|
| 1 | Design tokens | colors, typography; metrics are per-component spec values | ✅ |
| 2 | Light/dark themes | | ✅ |

### Basic elements

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 3 | Avatar | default, with icon, group, group count, group icon | ⬜ |
| 4 | Button | primary, secondary, outline, text, icon, destructive | ⬜ |
| 5 | Text | | ⬜ |
| 6 | Chip | | ⬜ |
| 7 | Badge | | ⬜ |

### AI elements

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 8 | Message & Thread | ink-wash user bubble; plain assistant | ✅ |
| 9 | Thread List | host-labeled sections; unread dot, pinned glyph, leading icon slot; single selection by id | ✅ |
| 10 | Message actions | | ✅ |
| 11 | Streaming text | | ✅ |
| 12 | Message composer | full card; compact single-row pill that opens into the card as the draft grows; expands to fill a fixed height | ✅ |
| 13 | Model selector | effort & overflow submenus; sheet on phones | ✅ |
| 14 | Menu | icon-trigger menu: groups, submenus, toggles; sheet on phones | ✅ |
| 15 | Attachments | images and files, type pill; built-in picker and web file drop; videos pending | ✅ |
| 16 | Preview | full-screen image viewer: zoom, paging | ✅ |
| 17 | Tool | pending, running, complete, error; morphing status mark; collapsible input/output blocks; parts render in a thread | ✅ |
| 18 | Suggestion & Suggestion Group | plain & outlined rows; scroll, wrap, column | ✅ |
| 19 | Confirmation | pending, approved, rejected; approve/reject buttons; parts render in a thread | ✅ |
| 20 | Error state | failure card + retry pill; failed assistant turns render it automatically | ✅ |
| 21 | Code block | built-in synchronous highlighter; languages host-extensible | ✅ |
| 22 | Thinking indicator | turning, breathing asterisk + shimmer label; active & settled | ✅ |
| 23 | Shimmer | text only; sweeping highlight, static when settled | ✅ |
| 24 | Pill | removable tool/mode pill for the composer's action row; label auto-drops on phones | ✅ |
| 25 | Markdown | built-in parser + renderer; assistant text parts render it by default; fences compose Code block; tables, links, streaming reveal | ✅ |

### Surfaces

| # | Component | Variants / notes | Status |
|---|-----------|------------------|--------|
| 26 | Chat View | centred 760 rail; zero state (greeting, lifted composer, starters); jump to latest | ✅ |
| 27 | SidePanel | | ⬜ |
| 28 | Modal | | ⬜ |
| 29 | Toast | floating notice: icon, message, cross on a frosted card; showReplitToast floats it in the nearest Overlay, stacked, auto-dismissing, hover-paused, with a handle to dismiss | ✅ |
