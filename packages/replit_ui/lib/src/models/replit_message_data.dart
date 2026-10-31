import 'package:flutter/foundation.dart';

import 'replit_message_part.dart';

/// Who authored a message.
enum ReplitMessageRole { user, assistant, system }

/// Lifecycle of a message.
enum ReplitMessageStatus {
  /// Waiting for the first content (renders a loading indicator).
  pending,

  /// Content is still arriving; the last text part animates its reveal.
  streaming,

  /// Settled; renders statically.
  complete,

  /// Failed. An assistant turn keeps its parts in normal ink and closes
  /// with an error card; a user bubble recolors to the error container.
  error,
}

/// One turn in a conversation.
///
/// A pure, immutable view model — hosts map their own transport/domain
/// models into this. Streaming is data, not streams: while a reply arrives,
/// rebuild with a [copyWith] carrying the grown text and
/// [ReplitMessageStatus.streaming].
@immutable
class ReplitMessageData {
  const ReplitMessageData({
    required this.id,
    required this.role,
    this.parts = const [],
    this.status = ReplitMessageStatus.complete,
    this.timestamp,
  });

  /// Convenience for a message with a single text part.
  ReplitMessageData.text({
    required String id,
    required ReplitMessageRole role,
    required String text,
    ReplitMessageStatus status = ReplitMessageStatus.complete,
    DateTime? timestamp,
  }) : this(
         id: id,
         role: role,
         parts: [ReplitTextPart(text)],
         status: status,
         timestamp: timestamp,
       );

  /// Stable identity — drives list keys and reveal restarts on replacement.
  final String id;

  final ReplitMessageRole role;

  /// Ordered content. Treat as immutable; create a new list to change it.
  final List<ReplitMessagePart> parts;

  final ReplitMessageStatus status;

  final DateTime? timestamp;

  ReplitMessageData copyWith({
    String? id,
    ReplitMessageRole? role,
    List<ReplitMessagePart>? parts,
    ReplitMessageStatus? status,
    DateTime? timestamp,
  }) {
    return ReplitMessageData(
      id: id ?? this.id,
      role: role ?? this.role,
      parts: parts ?? this.parts,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
