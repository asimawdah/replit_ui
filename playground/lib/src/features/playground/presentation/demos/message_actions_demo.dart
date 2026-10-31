import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

const String messageActionsSnippet = '''
ReplitMessageActions(
  actions: [
    ReplitMessageAction.copy(tooltip: 'Copy', onPressed: copy),
    ReplitMessageAction.thumbUp(
      tooltip: 'Good response',
      selected: liked, // selected actions render filled
      onPressed: like,
    ),
    ReplitMessageAction.thumbDown(
      tooltip: 'Bad response',
      selected: disliked,
      onPressed: dislike,
    ),
    ReplitMessageAction.regenerate(tooltip: 'Retry', onPressed: retry),
  ],
)''';

/// The actions strip on its own — every button live, thumbs mutually
/// exclusive, the way it sits under an assistant message.
class MessageActionsDemo extends StatefulWidget {
  const MessageActionsDemo({super.key});

  @override
  State<MessageActionsDemo> createState() => _MessageActionsDemoState();
}

class _MessageActionsDemoState extends State<MessageActionsDemo> {
  bool _liked = false;
  bool _disliked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ReplitMessageActions(
        actions: [
          ReplitMessageAction.copy(tooltip: 'Copy', onPressed: () {}),
          ReplitMessageAction.thumbUp(
            tooltip: 'Good response',
            selected: _liked,
            onPressed: () => setState(() {
              _liked = !_liked;
              if (_liked) _disliked = false;
            }),
          ),
          ReplitMessageAction.thumbDown(
            tooltip: 'Bad response',
            selected: _disliked,
            onPressed: () => setState(() {
              _disliked = !_disliked;
              if (_disliked) _liked = false;
            }),
          ),
          ReplitMessageAction.regenerate(tooltip: 'Retry', onPressed: () {}),
        ],
      ),
    );
  }
}
