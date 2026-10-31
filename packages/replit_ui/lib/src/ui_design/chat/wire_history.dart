import 'dart:typed_data';

import 'package:replit_ui/src/models/replit_message_data.dart';
import 'package:replit_ui/src/models/replit_message_part.dart';
import 'package:replit_ui/src/ui_design/tools/tool.dart';
import 'package:replit_ui/src/ui_design/transport/turn_request.dart';

List<WireMessage> wireHistoryOf(
  List<ReplitMessageData> history, {
  Map<String, ToolCallRecord> toolCalls = const {},
}) {
  final messages = <WireMessage>[];
  for (final message in history) {
    if (message.role == ReplitMessageRole.system ||
        message.status != ReplitMessageStatus.complete) {
      continue;
    }
    if (message.role == ReplitMessageRole.assistant) {
      _appendAssistant(messages, message.parts, toolCalls);
    } else {
      _append(messages, WireRole.user, _wirePartsOf(message.parts));
    }
  }
  assert(
    messages.isEmpty || messages.last.role == WireRole.user,
    'the wire history must end with a user turn',
  );
  return messages;
}

void _append(List<WireMessage> messages, WireRole role, List<WirePart> parts) {
  if (parts.isEmpty) return;
  if (messages.isEmpty && role == WireRole.assistant) return;
  if (messages.isNotEmpty && messages.last.role == role) {
    final previous = messages.removeLast();
    messages.add(WireMessage(role: role, parts: [...previous.parts, ...parts]));
  } else {
    messages.add(WireMessage(role: role, parts: parts));
  }
}

void _appendAssistant(
  List<WireMessage> messages,
  List<ReplitMessagePart> parts,
  Map<String, ToolCallRecord> toolCalls,
) {
  var current = <WirePart>[];
  var calls = <ToolCallRecord>[];
  void flush() {
    if (messages.isNotEmpty) {
      _append(messages, WireRole.assistant, current);
      _append(messages, WireRole.user, [
        for (final record in calls) WireToolResultPart.of(record),
      ]);
    }
    current = [];
    calls = [];
  }

  for (var index = 0; index < parts.length; index++) {
    final part = parts[index];
    switch (part) {
      case ReplitToolPart(:final id?):
        final record = toolCalls[id];
        if (record == null) continue;
        if (calls.isNotEmpty && record.segment != calls.last.segment) flush();
        current.add(WireToolCallPart.of(record));
        calls.add(record);
      case ReplitToolPart():
      case ReplitConfirmationPart():
      case ReplitCustomPart():
      case ReplitErrorPart():
      case ReplitAttachmentPart():
        continue;
      case ReplitTextPart():
      case ReplitImagePart():
      case ReplitCodePart():
        if (calls.isNotEmpty &&
            !_callFollowsInSegment(
              parts,
              index,
              calls.last.segment,
              toolCalls,
            )) {
          flush();
        }
        current.addAll(_wirePartsOf([part]));
    }
  }
  flush();
}

bool _callFollowsInSegment(
  List<ReplitMessagePart> parts,
  int index,
  int segment,
  Map<String, ToolCallRecord> toolCalls,
) {
  for (var i = index + 1; i < parts.length; i++) {
    if (parts[i] case ReplitToolPart(:final id?)) {
      final record = toolCalls[id];
      if (record != null) return record.segment == segment;
    }
  }
  return false;
}

List<WirePart> _wirePartsOf(List<ReplitMessagePart> parts) {
  final out = <WirePart>[];
  for (final part in parts) {
    switch (part) {
      case ReplitTextPart(:final text) when text.isNotEmpty:
        out.add(WireTextPart(text));
      case ReplitAttachmentPart(:final attachments):
        for (final attachment in attachments) {
          final image = _imageOf(
            attachment.bytes,
            attachment.mimeType,
            attachment.label,
          );
          out.add(
            image ??
                WireTextPart(
                  unsentAttachmentText(attachment.label, attachment.mimeType),
                ),
          );
        }
      case ReplitImagePart(:final bytes, :final mimeType, :final semanticLabel):
        final image = _imageOf(bytes, mimeType, semanticLabel);
        out.add(
          image ?? WireTextPart(unsentAttachmentText(semanticLabel, mimeType)),
        );
      case ReplitCodePart(:final code, :final language):
        out.add(WireTextPart('```${language ?? ''}\n$code\n```'));
      case ReplitTextPart():
      case ReplitErrorPart():
      case ReplitConfirmationPart():
      case ReplitToolPart():
      case ReplitCustomPart():
        break;
    }
  }
  return out;
}

WireImagePart? _imageOf(Uint8List? bytes, String? mimeType, String? label) {
  if (bytes == null || mimeType == null || !mimeType.startsWith('image/')) {
    return null;
  }
  return WireImagePart(bytes: bytes, mimeType: mimeType, label: label);
}
