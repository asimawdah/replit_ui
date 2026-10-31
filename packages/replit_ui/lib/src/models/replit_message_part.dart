import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show ImageProvider;

import 'replit_attachment.dart';

/// One piece of content inside a `ReplitMessageData`.
///
/// Sealed so renderers can switch exhaustively. Each part type arrives
/// alongside its component; [ReplitCustomPart] is how hosts inject anything
/// else.
@immutable
sealed class ReplitMessagePart {
  const ReplitMessagePart();
}

/// Plain text content.
class ReplitTextPart extends ReplitMessagePart {
  const ReplitTextPart(this.text);

  final String text;
}

/// Image attachments, rendered as a group of thumbnail tiles.
///
/// Parts render in the order given, so a sent turn's layout is however
/// the host composed the list. The convention is attachments above and
/// the caption under them — put this part ahead of the [ReplitTextPart]:
///
/// ```dart
/// ReplitMessageData(
///   id: 'm1',
///   role: ReplitMessageRole.user,
///   parts: [
///     ReplitAttachmentPart(sent),
///     ReplitTextPart('What is the peak on the left?'),
///   ],
/// )
/// ```
class ReplitAttachmentPart extends ReplitMessagePart {
  const ReplitAttachmentPart(this.attachments);

  final List<ReplitAttachment> attachments;
}

/// A large-format image in a turn — a generated picture presented as
/// content, unlike [ReplitAttachmentPart]'s thumbnail tiles.
///
/// A null [image] renders the generating placeholder: a shimmering block
/// at [aspectRatio]. Generation is data, as everywhere — the host
/// re-renders with [image] set when the picture arrives, and the block
/// becomes it.
class ReplitImagePart extends ReplitMessagePart {
  const ReplitImagePart({
    this.image,
    this.aspectRatio = 1,
    this.semanticLabel,
    this.bytes,
    this.mimeType,
  }) : assert(aspectRatio > 0, 'aspectRatio must be positive');

  /// The picture; any `ImageProvider`. Null while still generating.
  final ImageProvider? image;

  /// Width over height — shapes the placeholder and the picture's frame
  /// alike, so nothing jumps when the image lands. Defaults to square.
  final double aspectRatio;

  /// Host-written description, read to assistive tech for both the
  /// placeholder and the picture.
  final String? semanticLabel;

  /// The picture as the host received it, and its type — the same pair
  /// [ReplitAttachment] carries, and for the same reason: a generated image
  /// is only half rendered if the conversation cannot go on about it, and
  /// reaching back through the [ImageProvider] for the bytes is not an
  /// API. Nothing in replit_ui reads either; a host that has them should
  /// pass them so the next turn can send the picture back.
  final Uint8List? bytes;

  /// The type of [bytes], e.g. 'image/png'.
  final String? mimeType;
}

/// Fenced code, rendered by a `ReplitCodeBlock`.
class ReplitCodePart extends ReplitMessagePart {
  const ReplitCodePart(this.code, {this.language, this.filename});

  /// The source, verbatim.
  final String code;

  /// `ReplitCodeLanguage` id or alias — usually the fence info string, e.g.
  /// `'dart'`. Null or unknown renders plain.
  final String? language;

  /// The block's header label, e.g. a file hint beside the fence. Null
  /// falls back to [language].
  final String? filename;
}

/// A failure surfaced in the turn, rendered by a `ReplitErrorState`.
class ReplitErrorPart extends ReplitMessagePart {
  const ReplitErrorPart({this.message, this.retryable = true});

  /// Host-written and sentence-case. Null renders the card without one —
  /// the package ships no strings.
  final String? message;

  /// False suppresses the retry affordance even when the host wires
  /// retry — for failures retrying can't fix.
  final bool retryable;
}

/// Where a confirmation request stands.
///
/// The host owns the transition: a tap on the card reports intent, and the
/// card renders settled only when the host passes the new status back.
enum ReplitConfirmationStatus { pending, approved, rejected }

/// A request for the user's go-ahead, rendered by a `ReplitConfirmation`.
///
/// Runtime chrome, not model content: the host — a tool gate, a
/// destructive-action guard — constructs it from facts it resolved itself,
/// and flips [status] when the user answers. The buttons' labels are
/// thread-level (`ReplitThread.approveLabel` and friends), since they are
/// the same words on every card.
class ReplitConfirmationPart extends ReplitMessagePart {
  const ReplitConfirmationPart({
    this.title,
    this.message,
    this.status = ReplitConfirmationStatus.pending,
  });

  /// Host-localized header label, e.g. 'Approval required'. Null renders
  /// the asterisk alone.
  final String? title;

  /// What is being asked, host-written and sentence-case. Announced as a
  /// live region, since requests arrive unprompted.
  final String? message;

  /// Pending shows the buttons; approved and rejected settle the card.
  ///
  /// Keep the message's own status `complete` while the confirmation is
  /// pending — the wait belongs to this part, and a `pending` message
  /// renders the thinking indicator instead of its parts.
  final ReplitConfirmationStatus status;
}

/// Where a tool call stands.
///
/// The host owns every transition and re-renders the part; the card never
/// advances on its own. [pending] is staged — the arguments still
/// arriving, or an approval outstanding (a call that needs one is a
/// [ReplitConfirmationPart] beside it, not a tool state); [running] is
/// executing; [complete] and [error] are settled. A cancelled call is the
/// host's to map: [error] with a message, or [complete].
enum ReplitToolStatus { pending, running, complete, error }

/// One tool invocation, rendered by a `ReplitTool` card.
///
/// A record of the runtime's work, composed by the host from what its
/// provider reports: the tool's [name], the call's [status], the raw
/// [input] and [output] as text, and a [title] and [detail] in the host's
/// words. The card carries status as a mark, never as words, so nothing
/// here needs localizing beyond what the host writes itself. The section
/// labels over the input and output are thread-level
/// (`ReplitThread.toolInputLabel` and friends), since they are the same
/// words on every card.
class ReplitToolPart extends ReplitMessagePart {
  const ReplitToolPart({
    required this.name,
    this.id,
    this.title,
    this.detail,
    this.input,
    this.inputLanguage = 'json',
    this.output,
    this.outputLanguage,
    this.status = ReplitToolStatus.pending,
    this.errorMessage,
    this.semanticLabel,
  });

  /// The tool's identifier as the model called it, e.g. 'search_docs'.
  /// Shown in the code face when there is no [title].
  final String name;

  /// The provider's stable id for this call. Keys the card in a thread so
  /// its disclosure survives the turn's parts changing shape — and the
  /// thread remounting — so pass one where the provider has one. Unique
  /// within the conversation.
  final String? id;

  /// Host-written label, e.g. 'Searching the docs'. The host re-renders
  /// with a settled tense — 'Searched the docs' — when the call lands.
  /// Null shows [name].
  final String? title;

  /// A one-line summary of the input, usually its primary argument (the
  /// query, the path), shown as a chip beside the title so a collapsed
  /// card still says what the call was about.
  final String? detail;

  /// The arguments as raw text, usually JSON — partial while [pending],
  /// rendered streaming. Null renders no input block.
  final String? input;

  /// `ReplitCodeLanguage` id or alias for [input]. Defaults to `'json'`;
  /// `'plain'` for no highlighting.
  final String inputLanguage;

  /// The result as raw text. Null renders no output block.
  final String? output;

  /// `ReplitCodeLanguage` id or alias for [output]. Null renders plain.
  final String? outputLanguage;

  /// Drives the header's mark and the blocks' streaming treatment.
  ///
  /// Keep the message's own status `complete` while a tool is pending or
  /// running — the wait belongs to this part, and a `pending` message
  /// renders the thinking indicator instead of its parts.
  final ReplitToolStatus status;

  /// Why the call failed, host-written and sentence-case, to pair with
  /// [ReplitToolStatus.error]. Rendered under the header whenever set —
  /// outside the disclosure, so a failure reads without a tap — and
  /// announced as a live region.
  final String? errorMessage;

  /// Read to assistive tech in place of the title, e.g. 'Searched the
  /// docs, complete'. The mark carries status with no words, so this is
  /// the only spoken form of it; null reads [title], then [name].
  final String? semanticLabel;
}

/// Host-defined content, rendered through a `ReplitCustomPartBuilder`.
class ReplitCustomPart extends ReplitMessagePart {
  const ReplitCustomPart({required this.type, this.data});

  /// Discriminator the host's builder switches on.
  final String type;

  /// Arbitrary payload for the builder.
  final Object? data;
}
