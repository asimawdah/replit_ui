import 'package:material_ui/material_ui.dart';

import '../theme/replit_theme.dart';

// Shared failure treatment for host-supplied attachment images.
// Not exported from the package barrel.

/// Drawn in place of an image whose provider failed.
///
/// One treatment for the thumbnail and the full-screen preview, so a dead
/// provider reads as the same failure in both. Never the framework's red
/// error box, which is a debug artefact rather than a user-facing state.
class ReplitAttachmentError extends StatelessWidget {
  const ReplitAttachmentError({
    super.key,
    this.iconSize = 24,
    this.filled = true,
  });

  final double iconSize;

  /// Fills the slot with a placeholder surface. False over chrome that
  /// already has a background of its own, such as the preview's scrim.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.replitColors;
    final icon = Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: iconSize,
        color: colors.onSurfaceVariant,
      ),
    );
    if (!filled) return icon;
    return ColoredBox(color: colors.surfaceContainerHighest, child: icon);
  }
}

/// [ReplitAttachmentError] as an [ImageErrorWidgetBuilder].
ImageErrorWidgetBuilder replitAttachmentErrorBuilder({
  double iconSize = 24,
  bool filled = true,
}) =>
    (context, error, stackTrace) =>
        ReplitAttachmentError(iconSize: iconSize, filled: filled);
