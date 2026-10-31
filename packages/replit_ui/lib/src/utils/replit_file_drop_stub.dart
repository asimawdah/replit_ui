import 'dart:ui';

import 'replit_attachment_intake.dart';

/// A live drop registration; [dispose] unhooks it.
///
/// Never constructed off the web — [replitRegisterDropTarget] returns null
/// there — but the type exists on every platform so the widget compiles
/// against one shape.
class ReplitDropRegistration {
  const ReplitDropRegistration._();

  /// Unhooks the registration. Safe to call more than once.
  void dispose() {}
}

/// Hooks a rectangle of the given Flutter view up to the platform's file
/// drop, returning null where the platform has none — which is
/// everywhere but the web.
ReplitDropRegistration? replitRegisterDropTarget({
  required int viewId,
  required Rect? Function() bounds,
  required bool Function() isEnabled,
  required void Function(bool hovering) onHover,
  required void Function(List<ReplitFileCandidate> files) onDrop,
}) => null;
