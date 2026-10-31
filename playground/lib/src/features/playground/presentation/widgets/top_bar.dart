import 'package:expressive_ui_kit/expressive_ui_kit.dart';
import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'replit_logo.dart';
import 'shell_text.dart';

/// The 54px chrome bar: logo cluster on the left, then the Light/Dark and
/// code-panel toggle on the right.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    this.mobile = false,
    required this.onThemeModeChanged,
    required this.codeOpen,
    required this.onToggleCode,
  });

  final bool mobile;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool codeOpen;
  final VoidCallback onToggleCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    return Container(
      height: 54,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        border: Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          const ReplitLogo(size: 16),
          SizedBox(width: mobile ? 8 : 9),
          Text(
            'Replit UI',
            style: shellText(
              context,
              size: 15,
              weight: FontWeight.w700,
              letterSpacing: -0.15,
              color: colors.onSurface,
            ),
          ),
          if (!mobile) ...[
            const SizedBox(width: 9),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                'Playground',
                style: shellText(
                  context,
                  size: 11.5,
                  weight: FontWeight.w500,
                  color: colors.onSurfaceMuted,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (mobile)
            MEIconButton(
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () => onThemeModeChanged(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
              size: MEButtonSize.extraSmall,
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
            )
          else ...[
            ShellSegmented<ThemeMode>(
              options: const [
                (ThemeMode.light, 'Light'),
                (ThemeMode.dark, 'Dark'),
              ],
              value: Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              onChanged: onThemeModeChanged,
            ),
            const SizedBox(width: 18),
            MEIconButton(
              icon: const Icon(PhosphorIconsRegular.code),
              selected: codeOpen,
              onPressed: onToggleCode,
              size: MEButtonSize.extraSmall,
              tooltip: codeOpen ? 'Hide code' : 'Show code',
            ),
          ],
        ],
      ),
    );
  }
}

class ShellSegmented<T> extends StatelessWidget {
  const ShellSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return MESegmentedButton<T>(
      segments: [
        for (final (option, label) in options)
          MESegment<T>(
            value: option,
            label: Text(
              label,
              style: shellText(context, size: 12.5, weight: FontWeight.w500),
            ),
          ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) onChanged(selection.first);
      },
      expanded: false,
      height: 32,
      showCheckmark: false,
    );
  }
}
