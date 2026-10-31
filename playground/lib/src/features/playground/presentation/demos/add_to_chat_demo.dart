import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

const String addToChatSnippet = '''
ReplitMenu(
  icon: PhosphorIconsRegular.plus,
  tooltip: 'Add to chat',
  // Anchored menu on desktop; a bottom sheet on phones, where
  // submenus push pages under this title.
  sheetTitle: 'Add to Chat',
  entries: [
    const ReplitMenuOption(
      id: 'files',
      icon: PhosphorIconsRegular.file,
      label: 'Add Files or Photos',
    ),
    const ReplitMenuDivider(),
    const ReplitMenuOption(
      id: 'skills',
      icon: PhosphorIconsRegular.scroll,
      label: 'Skills',
      children: [...], // a row with children opens a submenu
    ),
    const ReplitMenuOption(
      id: 'connectors',
      icon: PhosphorIconsRegular.lightning,
      label: 'Connectors',
      children: [...],
    ),
    const ReplitMenuDivider(),
    ReplitMenuOption(
      id: 'research',
      icon: PhosphorIconsRegular.graduationCap,
      label: 'Research',
      selected: researchOn, // draws the accent check
    ),
    ReplitMenuOption(
      id: 'web-search',
      icon: PhosphorIconsRegular.globe,
      label: 'Web Search',
      selected: webSearchOn,
    ),
  ],
  onSelected: toggleTool,
)''';

/// The add-to-chat menu behind its plus trigger, live: Skills and
/// Connectors open submenus, Research and Web Search toggle their checks.
class AddToChatDemo extends StatefulWidget {
  const AddToChatDemo({super.key});

  @override
  State<AddToChatDemo> createState() => _AddToChatDemoState();
}

class _AddToChatDemoState extends State<AddToChatDemo> {
  bool _researchOn = true;
  bool _webSearchOn = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ReplitMenu(
        icon: PhosphorIconsRegular.plus,
        tooltip: 'Add to chat',
        sheetTitle: 'Add to Chat',
        entries: [
          const ReplitMenuOption(
            id: 'files',
            icon: PhosphorIconsRegular.file,
            label: 'Add Files or Photos',
          ),
          const ReplitMenuDivider(),
          const ReplitMenuOption(
            id: 'skills',
            icon: PhosphorIconsRegular.scroll,
            label: 'Skills',
            children: [
              ReplitMenuOption(id: 'skill-writer', label: 'Blog Writer'),
              ReplitMenuOption(id: 'skill-review', label: 'Code Review'),
              ReplitMenuOption(id: 'skill-planner', label: 'Trip Planner'),
            ],
          ),
          const ReplitMenuOption(
            id: 'connectors',
            icon: PhosphorIconsRegular.lightning,
            label: 'Connectors',
            children: [
              ReplitMenuOption(id: 'conn-drive', label: 'Google Drive'),
              ReplitMenuOption(id: 'conn-github', label: 'GitHub'),
            ],
          ),
          const ReplitMenuDivider(),
          ReplitMenuOption(
            id: 'research',
            icon: PhosphorIconsRegular.graduationCap,
            label: 'Research',
            selected: _researchOn,
          ),
          ReplitMenuOption(
            id: 'web-search',
            icon: PhosphorIconsRegular.globe,
            label: 'Web Search',
            selected: _webSearchOn,
          ),
        ],
        onSelected: (id) {
          if (id == 'research') {
            setState(() => _researchOn = !_researchOn);
          } else if (id == 'web-search') {
            setState(() => _webSearchOn = !_webSearchOn);
          }
        },
      ),
    );
  }
}
