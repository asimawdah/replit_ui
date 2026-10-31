import 'package:replit_ui/replit_ui.dart';

/// Shared demo content, per the design prototype — the same model roster
/// appears in the composer, the model selector, and the attachments demos.
const List<ReplitModelOption> demoModels = [
  ReplitModelOption(
    id: 'fable-5',
    label: 'Fable 5',
    description: 'Our flagship model',
  ),
  ReplitModelOption(
    id: 'opus-5-1',
    label: 'Opus 5.1',
    description: 'For complex & thinking tasks',
  ),
  ReplitModelOption(
    id: 'haiku-4-5',
    label: 'Haiku 4.5',
    description: 'Fastest for quick answers',
  ),
];

/// A couple of older models so the "More models" submenu has a page.
const List<ReplitModelOption> demoMoreModels = [
  ReplitModelOption(
    id: 'sonnet-5',
    label: 'Sonnet 5',
    description: 'Balanced for everyday work',
  ),
  ReplitModelOption(
    id: 'haiku-4',
    label: 'Haiku 4',
    description: 'Previous fast model',
  ),
];

const List<ReplitEffortOption> demoEfforts = [
  ReplitEffortOption(
    id: 'medium',
    label: 'Medium',
    description: 'Light & casual tasks',
  ),
  ReplitEffortOption(
    id: 'high',
    label: 'High',
    description: 'Balance between speed & complexity',
  ),
  ReplitEffortOption(
    id: 'extra',
    label: 'Extra',
    description: 'Extended thinking for hard problems',
  ),
];
