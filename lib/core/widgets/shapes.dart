import 'package:flutter/material.dart';

/// Flat-top hexagon matching the design's `clip-path`
/// polygon(25% 0, 75% 0, 100% 50%, 75% 100%, 25% 100%, 0 50%).
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    return Path()
      ..moveTo(s.width * 0.25, 0)
      ..lineTo(s.width * 0.75, 0)
      ..lineTo(s.width, s.height * 0.5)
      ..lineTo(s.width * 0.75, s.height)
      ..lineTo(s.width * 0.25, s.height)
      ..lineTo(0, s.height * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Diamond matching polygon(50% 0, 100% 50%, 50% 100%, 0 50%).
class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    return Path()
      ..moveTo(s.width * 0.5, 0)
      ..lineTo(s.width, s.height * 0.5)
      ..lineTo(s.width * 0.5, s.height)
      ..lineTo(0, s.height * 0.5)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
