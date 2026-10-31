import 'dart:math' as math;

import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/playground_item.dart';
import '../demos/demo_registry.dart';
import 'shell_text.dart';

/// The canvas: the theme's page ground with the demo stage centred on it —
/// and, for items with variants, the floating pill switcher over the top
/// edge.
class Stage extends StatelessWidget {
  const Stage({
    super.key,
    required this.item,
    this.variant,
    this.onVariantChanged,
  });

  final PlaygroundItem item;
  final String? variant;
  final ValueChanged<String>? onVariantChanged;

  /// The object rail's top padding, which clears the pill switcher. A
  /// full-surface demo with variants learns of the pills the same way,
  /// as a top inset its SafeArea clears — the way a screen learns of its
  /// status bar — so anything it anchors to the top edge (a toast) lands
  /// below them.
  static const double _chromeInset = 56;

  @override
  Widget build(BuildContext context) {
    final demo = demoFor(item, variant: variant);
    final variants = variantsFor(item);

    final Widget content;
    if (demoFillsStage(item, variant: variant)) {
      final padding = MediaQuery.paddingOf(context);
      content = variants.isEmpty
          ? demo
          : MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: padding.copyWith(
                  top: math.max(padding.top, _chromeInset),
                ),
              ),
              child: demo,
            );
    } else {
      content = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, _chromeInset, 28, 52),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: demo,
          ),
        ),
      );
    }

    return ColoredBox(
      color: context.replitColors.surface,
      child: Stack(
        children: [
          Positioned.fill(child: content),
          if (variants.isNotEmpty)
            Positioned(
              top: 14,
              left: 0,
              right: 0,
              child: Center(
                child: _VariantPills(
                  variants: variants,
                  selected: variant ?? variants.first.$1,
                  onSelect: onVariantChanged ?? (_) {},
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The design's floating variant switcher, over the canvas top edge.
class _VariantPills extends StatelessWidget {
  const _VariantPills({
    required this.variants,
    required this.selected,
    required this.onSelect,
  });

  final List<(String, String)> variants;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.surfaceBright,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, (id, label)) in variants.indexed) ...[
            if (i > 0) const SizedBox(width: 2),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onSelect(id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: id == selected
                        ? colors.surfaceContainer
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(7)),
                  ),
                  child: Text(
                    label,
                    style: shellText(
                      context,
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: id == selected
                          ? colors.onSurface
                          : colors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
