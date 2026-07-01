import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand logo that swaps its artwork to match the current theme brightness:
/// a dark envelope on light backgrounds, a light envelope on dark ones.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 96, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = Theme.of(context).brightness == Brightness.dark
        ? 'assets/logo/logo_dark.svg'
        : 'assets/logo/logo_light.svg';
    return SvgPicture.asset(asset, width: size, height: size);
  }
}
