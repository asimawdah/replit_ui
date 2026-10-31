import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReplitLogo extends StatelessWidget {
  const ReplitLogo({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/replit_ui_logo.svg',
      width: size,
      height: size,
    );
  }
}
