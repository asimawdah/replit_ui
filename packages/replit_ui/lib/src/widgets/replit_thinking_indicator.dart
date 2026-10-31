import 'package:material_ui/material_ui.dart';

import '../theme/replit_theme.dart';
import 'replit_shimmer_text.dart';

/// The thinking line shown while the assistant has not started responding:
/// a slowly turning, breathing asterisk beside a shimmering, host-supplied
/// label.
///
/// ```dart
/// ReplitThinkingIndicator(label: 'Thinking…')
/// ```
///
/// [label] is the whole text — the package ships no strings — and null
/// renders the glyph alone. [active] is the state switch: true animates the
/// asterisk — one slow revolution per cycle, swelling and settling as it
/// turns — and sweeps a [ReplitShimmerText] highlight through the label;
/// false holds the same line still in the muted ink, for a host that keeps
/// it on screen after thinking ends and swaps the label it already owns.
///
/// Respects the platform reduced-motion setting by rendering static.
class ReplitThinkingIndicator extends StatefulWidget {
  const ReplitThinkingIndicator({
    super.key,
    this.label,
    this.active = true,
    this.color,
    this.size = 14,
    this.duration = const Duration(milliseconds: 2400),
    this.semanticLabel,
  }) : assert(size > 0, 'size must be positive');

  /// Host-localized text beside the glyph, e.g. 'Thinking…'.
  /// Null renders the glyph alone.
  final String? label;

  /// Whether the asterisk turns and breathes. False holds it still — the
  /// settled state.
  final bool active;

  /// Glyph ink. Defaults to `onSurfaceMuted`; the label always draws in the
  /// muted ink, a step below it, as in the design.
  final Color? color;

  /// Edge of the square glyph.
  final double size;

  /// One full cycle: a revolution and a breath, in step.
  final Duration duration;

  /// Accessibility label for the glyph-only form (e.g. a localized
  /// "Thinking"). Ignored when [label] is set — the visible text already
  /// carries the meaning.
  final String? semanticLabel;

  @override
  State<ReplitThinkingIndicator> createState() => _ReplitThinkingIndicatorState();
}

class _ReplitThinkingIndicatorState extends State<ReplitThinkingIndicator>
    with SingleTickerProviderStateMixin {
  static const int _frameCount = 80;
  static const String _spritePath =
      'packages/replit_ui/assets/replit_thinking_sprite.png';
  static const double _labelGap = 4;

  late final AnimationController _controller;

  /// Null until first resolved, so the initial [didChangeDependencies]
  /// always syncs (starting the animation).
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only resync when reduced-motion actually changes — this fires for any
    // inherited update (e.g. theme toggles), and an unconditional repeat()
    // would restart the spin from upright and hitch it.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion != _reduceMotion) {
      _reduceMotion = reduceMotion;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(ReplitThinkingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration ||
        widget.active != oldWidget.active) {
      _controller.duration = widget.duration;
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.active && !(_reduceMotion ?? false)) {
      // (Re)start so a changed duration takes effect immediately.
      _controller.repeat();
    } else {
      // Settled: upright and exhaled rather than frozen mid-cycle.
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final label = widget.label;
    final tint = widget.color ?? (widget.active ? null : colors.onSurfaceMuted);
    final spriteWidth = widget.size * _frameCount;
    Widget sprite = Image.asset(
      _spritePath,
      width: spriteWidth,
      height: widget.size,
      filterQuality: FilterQuality.medium,
    );
    if (tint != null) {
      sprite = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
        child: sprite,
      );
    }
    final glyph = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: sprite,
        builder: (context, child) {
          final frame = (_controller.value * _frameCount).floor() % _frameCount;
          return SizedBox.square(
            dimension: widget.size,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: spriteWidth,
                maxWidth: spriteWidth,
                minHeight: widget.size,
                maxHeight: widget.size,
                child: Transform.translate(
                  offset: Offset(-widget.size * frame, 0),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );

    if (label == null) {
      final semanticLabel = widget.semanticLabel;
      if (semanticLabel == null) return glyph;
      return Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(child: glyph),
      );
    }

    // The visible text carries the meaning; announcing the glyph too would
    // only say it twice. The shimmer follows [active] on its own and rests
    // in the muted ink, so the settled line is exactly the design's static
    // one.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: glyph),
        const SizedBox(width: _labelGap),
        ReplitShimmerText(
          text: label,
          enabled: widget.active,
          style: const TextStyle(height: 1.3),
        ),
      ],
    );
  }
}
