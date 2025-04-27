import 'package:flutter/material.dart';

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 0);

    path.quadraticBezierTo(size.width * 0.35, size.height * 0.5,
        size.width * 0.7, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.1, size.width, size.height * 0.2);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
