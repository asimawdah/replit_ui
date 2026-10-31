import 'package:replit_ui/replit_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'open_docs.dart';
import '../../domain/models/playground_item.dart';
import 'shell_text.dart';

/// The 214px navigation rail: an Examples section, then the component
/// list, and — on the web, where the docs share the origin — a Docs link
/// pinned at the bottom.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.compact = false,
    this.width = 214,
  });

  final PlaygroundItem selected;
  final ValueChanged<PlaygroundItem> onSelect;
  final bool compact;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final examples = PlaygroundItem.values.where((i) => i.isExample);
    final components = PlaygroundItem.values.where((i) => !i.isExample);

    return Container(
      width: compact ? 72 : width,
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        border: Border(right: BorderSide(color: colors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
                vertical: 14,
              ),
              children: [
                if (!compact) const _SectionLabel('Examples', first: true),
                for (final item in examples)
                  _NavRow(
                    item: item,
                    active: item == selected,
                    compact: compact,
                    onTap: () => onSelect(item),
                  ),
                if (compact && examples.isNotEmpty && components.isNotEmpty)
                  const SizedBox(height: 8),
                if (!compact) const _SectionLabel('Components'),
                for (final item in components)
                  _NavRow(
                    item: item,
                    active: item == selected,
                    compact: compact,
                    onTap: () => onSelect(item),
                  ),
              ],
            ),
          ),
          // The playground is served from /playground/ on the docs origin;
          // off the web there is no docs site (or browser tab) to go to.
          if (kIsWeb)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              padding: compact
                  ? const EdgeInsets.symmetric(vertical: 8)
                  : const EdgeInsets.fromLTRB(10, 9, 10, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FooterLink(
                    icon: PhosphorIconsRegular.bookOpen,
                    label: 'Docs',
                    compact: compact,
                    onTap: openDocs,
                  ),
                  SizedBox(height: compact ? 4 : 1),
                  _FooterLink(
                    icon: PhosphorIconsRegular.package,
                    label: 'pub.dev',
                    compact: compact,
                    onTap: () =>
                        openExternal('https://pub.dev/packages/replit_ui'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A pinned footer row: same rhythm as a nav row, with the outbound
/// arrow that marks it as leaving the playground.
class _FooterLink extends StatefulWidget {
  const _FooterLink({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    final link = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.compact ? 48 : null,
        height: widget.compact ? 48 : null,
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 0 : 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: _hovered ? colors.surfaceContainerLow : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        alignment: widget.compact ? Alignment.center : null,
        child: Row(
          mainAxisAlignment: widget.compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              widget.icon,
              size: widget.compact ? 18 : 15,
              color: _hovered ? colors.primary : colors.onSurfaceMuted,
            ),
            if (!widget.compact) ...[
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shellText(
                    context,
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: _hovered
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(
                PhosphorIconsRegular.arrowUpRight,
                size: 13,
                color: colors.onSurfaceMuted,
              ),
            ],
          ],
        ),
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.compact
          ? Tooltip(message: widget.label, child: link)
          : link,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, {this.first = false});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, first ? 0 : 16, 10, 6),
      child: Text(
        label.toUpperCase(),
        style: shellText(
          context,
          size: 10.5,
          weight: FontWeight.w500,
          letterSpacing: 0.84,
          color: context.replitColors.onSurfaceMuted,
        ),
      ),
    );
  }
}

class _NavRow extends StatefulWidget {
  const _NavRow({
    required this.item,
    required this.active,
    required this.compact,
    required this.onTap,
  });

  final PlaygroundItem item;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    final Color background;
    if (widget.active) {
      background = colors.surfaceContainer;
    } else if (_hovered) {
      background = colors.surfaceContainerLow;
    } else {
      background = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.compact
          ? Tooltip(
              message: widget.item.label,
              child: _buildRow(context, colors, background),
            )
          : _buildRow(context, colors, background),
    );
  }

  Widget _buildRow(BuildContext context, ReplitColors colors, Color background) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.compact ? 48 : null,
        height: widget.compact ? 48 : null,
        margin: const EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 0 : 10,
          vertical: 7,
        ),
        alignment: widget.compact ? Alignment.center : null,
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: widget.compact
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Icon(
              widget.item.icon,
              size: widget.compact ? 19 : 15,
              color: widget.active ? colors.primary : colors.onSurfaceMuted,
            ),
            if (!widget.compact) ...[
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: shellText(
                    context,
                    size: 13.5,
                    weight: FontWeight.w500,
                    color: widget.active
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
