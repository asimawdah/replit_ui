import 'package:replit_ui/replit_ui.dart';
import 'package:material_ui/material_ui.dart';

TextStyle shellText(
  BuildContext context, {
  double? size,
  FontWeight? weight,
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  final base = context.replitTypography.labelMedium;
  return base.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing ?? (size ?? base.fontSize!) * 0.05,
    height: height,
  );
}
