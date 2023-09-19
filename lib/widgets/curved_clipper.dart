import 'package:flutter/material.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    int curveHeight = 20;
    double clipHeight = size.height;
    Offset controlPoint = Offset(size.width / 2, clipHeight + curveHeight);
    Offset endPoint = Offset(size.width, clipHeight - curveHeight);

    Path path = Path()
      ..lineTo(0, clipHeight - curveHeight)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
