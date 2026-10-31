/// [Replit UI](https://replit.asimawdah.com/) is an open-source Flutter library for
/// chat interfaces, with optional streaming providers and tool execution.
///
/// The UI components render state and report intent through callbacks.
/// The optional SDK connects Gemini, OpenAI-compatible and Anthropic
/// providers when an application chooses to use them.
///
/// The UI's attachment picker opens the platform's own dialog — from the
/// composer's attach button or a host's own "+" menu — and on the web the
/// chat surface accepts drops and the field takes pasted images. All are
/// opt-in and hand back `ReplitAttachment`s for the host to hold. The
/// streaming providers also make requests only when an app uses them.
library;

export 'src/models/replit_attachment.dart';
export 'src/models/replit_attachment_options.dart';
export 'src/utils/replit_file_picker.dart' show showReplitAttachmentPicker;
export 'src/models/replit_message_data.dart';
export 'src/models/replit_message_part.dart';
export 'src/theme/replit_colors.dart';
export 'src/theme/replit_syntax_colors.dart';
export 'src/theme/replit_theme.dart';
export 'src/theme/replit_typography.dart';
export 'src/widgets/replit_attachment_group.dart';
export 'src/widgets/replit_attachment_preview.dart';
export 'src/widgets/replit_chat_view.dart';
export 'src/styles/replit_chat_view_style.dart';
export 'src/widgets/replit_code_block.dart';
export 'src/styles/replit_code_block_style.dart';
export 'src/widgets/replit_composer.dart';
export 'src/styles/replit_composer_style.dart';
export 'src/widgets/replit_confirmation.dart';
export 'src/styles/replit_confirmation_style.dart';
export 'src/widgets/replit_drop_target.dart';
export 'src/widgets/replit_error_state.dart';
export 'src/styles/replit_error_state_style.dart';
export 'src/widgets/replit_greeting.dart';
export 'src/widgets/replit_markdown.dart';
export 'src/styles/replit_markdown_style.dart';
export 'src/widgets/replit_menu.dart';
export 'src/styles/replit_menu_style.dart';
export 'src/widgets/replit_message.dart';
export 'src/widgets/replit_message_actions.dart';
export 'src/styles/replit_message_actions_style.dart';
export 'src/styles/replit_message_style.dart';
export 'src/widgets/replit_model_selector.dart';
export 'src/widgets/replit_pill.dart';
export 'src/styles/replit_pill_style.dart';
export 'src/widgets/replit_shimmer_text.dart';
export 'src/widgets/replit_streaming_text.dart';
export 'src/widgets/replit_suggestion.dart';
export 'src/styles/replit_suggestion_style.dart';
export 'src/widgets/replit_thinking_indicator.dart';
export 'src/widgets/replit_thread.dart';
export 'src/widgets/replit_thread_list.dart';
export 'src/styles/replit_thread_list_style.dart';
export 'src/widgets/replit_toast.dart';
export 'src/styles/replit_toast_style.dart';
export 'src/utils/replit_toast_layer.dart'
    show showReplitToast, ReplitToastHandle;
export 'src/widgets/replit_tool.dart';
export 'src/styles/replit_tool_style.dart';
export 'src/ui_design/chat/chat_state.dart';
export 'src/ui_design/chat/ui_design_chat.dart';
export 'src/ui_design/chat/ui_design_chat_view.dart';
export 'src/ui_design/errors.dart';
export 'src/ui_design/providers/anthropic_provider.dart' show AnthropicProvider;
export 'src/ui_design/providers/gemini_provider.dart' show GeminiProvider;
export 'src/ui_design/providers/openai_provider.dart' show OpenAIProvider;
export 'src/ui_design/providers/provider.dart';
export 'src/ui_design/strings.dart';
export 'src/ui_design/tools/tool.dart';
export 'src/ui_design/tools/tool_loop.dart'
    show ToolApprover, ToolCallObserver, runToolLoop;
export 'src/ui_design/transport/error_codes.dart';
export 'src/ui_design/transport/sse_events.dart';
export 'src/ui_design/transport/turn_ids.dart';
export 'src/ui_design/transport/turn_request.dart';
export 'src/ui_design/transport/turn_transport.dart';
