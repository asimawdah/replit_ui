import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

String confirmationSnippet([String? variant]) => switch (variant) {
  'approved' => _approvedSnip,
  'rejected' => _rejectedSnip,
  'thread' => _threadSnip,
  _ => _pendingSnip,
};

const String _pendingSnip = '''
// The card renders state and reports intent; recording the decision —
// and re-rendering with the new status — is the host's business.
ReplitConfirmation(
  title: 'Approval required',
  message: 'Delete 3 files in drafts/. This cannot be undone.',
  approveLabel: 'Approve',
  rejectLabel: 'Reject',
  onApprove: () => respond(true),
  onReject: () => respond(false),
)''';

const String _approvedSnip = '''
// A settled card: the accent flips to success and the buttons collapse
// into the outcome's row, in the host's words.
ReplitConfirmation(
  title: 'Approval required',
  message: 'Delete 3 files in drafts/. This cannot be undone.',
  status: ReplitConfirmationStatus.approved,
  approvedLabel: 'Approved',
)''';

const String _rejectedSnip = '''
// The rejected outcome carries the error accent.
ReplitConfirmation(
  title: 'Approval required',
  message: 'Delete 3 files in drafts/. This cannot be undone.',
  status: ReplitConfirmationStatus.rejected,
  rejectedLabel: 'Rejected',
)''';

const String _threadSnip = '''
// In a thread the card renders on its own: a ReplitConfirmationPart in
// any turn becomes it, and the buttons hand the message, the part and
// the decision back so the host can settle the request.
ReplitThread(
  messages: messages,
  approveLabel: 'Approve',
  rejectLabel: 'Reject',
  approvedLabel: 'Approved',
  rejectedLabel: 'Rejected',
  onConfirmationRespond: (message, part, approved) =>
      record(message, part, approved),
)

ReplitMessageData(
  id: 'a1',
  role: ReplitMessageRole.assistant,
  parts: [
    ReplitTextPart('I can clear those drafts for you.'),
    ReplitConfirmationPart(
      title: 'Approval required',
      message: 'Delete 3 files in drafts/. This cannot be undone.',
    ),
  ],
)''';

const String _requestMessage =
    'Delete 3 files in drafts/. This cannot be undone.';

/// Stage demo for `ReplitConfirmation` — the live pending card whose
/// buttons actually settle it, the two settled forms, and a turn in a
/// thread where the decision lands the way a host would record it.
class ConfirmationDemo extends StatefulWidget {
  const ConfirmationDemo({super.key, this.variant});

  final String? variant;

  @override
  State<ConfirmationDemo> createState() => _ConfirmationDemoState();
}

class _ConfirmationDemoState extends State<ConfirmationDemo> {
  ReplitConfirmationStatus _status = ReplitConfirmationStatus.pending;

  void _respond(bool approved) {
    setState(
      () => _status = approved
          ? ReplitConfirmationStatus.approved
          : ReplitConfirmationStatus.rejected,
    );
  }

  /// Thread variant: the decision settles the card in place, and the
  /// reply continues past it — the shape of a tool gate in a real host.
  List<ReplitMessageData> get _messages => [
    ReplitMessageData.text(
      id: 'u1',
      role: ReplitMessageRole.user,
      text: 'Clear out my drafts folder.',
    ),
    ReplitMessageData(
      id: 'a1',
      role: ReplitMessageRole.assistant,
      parts: [
        const ReplitTextPart('I can clear those drafts for you.'),
        ReplitConfirmationPart(
          title: 'Approval required',
          message: _requestMessage,
          status: _status,
        ),
        if (_status == ReplitConfirmationStatus.approved)
          const ReplitTextPart('Done — the drafts folder is empty.'),
        if (_status == ReplitConfirmationStatus.rejected)
          const ReplitTextPart('Understood — I left the drafts untouched.'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final child = switch (widget.variant) {
      'approved' => const ReplitConfirmation(
        title: 'Approval required',
        message: _requestMessage,
        status: ReplitConfirmationStatus.approved,
        approvedLabel: 'Approved',
      ),
      'rejected' => const ReplitConfirmation(
        title: 'Approval required',
        message: _requestMessage,
        status: ReplitConfirmationStatus.rejected,
        rejectedLabel: 'Rejected',
      ),
      'thread' => SizedBox(
        height: 420,
        child: ReplitThread(
          messages: _messages,
          approveLabel: 'Approve',
          rejectLabel: 'Reject',
          approvedLabel: 'Approved',
          rejectedLabel: 'Rejected',
          onConfirmationRespond: (message, part, approved) =>
              _respond(approved),
        ),
      ),
      _ => ReplitConfirmation(
        title: 'Approval required',
        message: _requestMessage,
        status: _status,
        approveLabel: 'Approve',
        rejectLabel: 'Reject',
        approvedLabel: 'Approved',
        rejectedLabel: 'Rejected',
        onApprove: () => _respond(true),
        onReject: () => _respond(false),
      ),
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.variant == 'thread' ? 560 : 480,
        ),
        child: child,
      ),
    );
  }
}
