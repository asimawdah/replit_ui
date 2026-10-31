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
    required this.onBrowse,
    required this.onShowCode,
    required this.onThemeModeChanged,
    required this.codeOpen,
    required this.onToggleCode,
  });

  final bool mobile;
  final VoidCallback onBrowse;
  final VoidCallback onShowCode;
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? colors.onSurface
                    : null,
              ),
              variant: MEButtonVariant.text,
              onPressed: () => onThemeModeChanged(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              ),
              size: MEButtonSize.extraSmall,
              tooltip: Theme.of(context).brightness == Brightness.dark
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
            ),
          if (mobile)
            PopupMenuButton<_MobileMenuAction>(
              tooltip: 'Open playground menu',
              icon: const Icon(Icons.menu_rounded),
              onSelected: (action) {
                switch (action) {
                  case _MobileMenuAction.browse:
                    onBrowse();
                  case _MobileMenuAction.code:
                    onShowCode();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MobileMenuAction.browse,
                  child: _MobileMenuItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Browse components',
                  ),
                ),
                PopupMenuItem(
                  value: _MobileMenuAction.code,
                  child: _MobileMenuItem(
                    icon: Icons.code_rounded,
                    label: 'View code',
                  ),
                ),
              ],
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
            _CodeToggle(active: codeOpen, onTap: onToggleCode),
          ],
        ],
      ),
    );
  }
}

enum _MobileMenuAction { browse, code }

class _MobileMenuItem extends StatelessWidget {
  const _MobileMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [Icon(icon, size: 18), const SizedBox(width: 12), Text(label)],
  );
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
    final colors = context.replitColors;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, (option, label)) in options.indexed) ...[
            if (index > 0) const SizedBox(width: 2),
            _Segment(
              label: label,
              selected: option == value,
              onTap: () => onChanged(option),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(7)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: selected
                  ? (dark
                        ? colors.surfaceContainerHighest
                        : colors.surfaceBright)
                  : Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: dark
                            ? const Color(0x59000000)
                            : const Color(0x1A000000),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: shellText(
                context,
                size: 12.5,
                weight: FontWeight.w500,
                color: selected ? colors.onSurface : colors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeToggle extends StatefulWidget {
  const _CodeToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  State<_CodeToggle> createState() => _CodeToggleState();
}

class _CodeToggleState extends State<_CodeToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final label = widget.active ? 'Hide code' : 'Show code';

    return Semantics(
      button: true,
      selected: widget.active,
      label: label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: InkWell(
            onTap: widget.onTap,
            onHover: (hovered) {
              if (_hovered != hovered) setState(() => _hovered = hovered);
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.active || _hovered
                    ? colors.surfaceContainer
                    : Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Icon(
                PhosphorIconsRegular.code,
                size: 17,
                color: widget.active ? colors.onSurface : colors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
