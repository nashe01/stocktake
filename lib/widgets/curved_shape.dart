
import 'package:flutter/material.dart';

import 'curved_clipper.dart';

class CurvedShape extends StatelessWidget {
  final Color? color;
  final double? height;
  const CurvedShape({super.key, this.color, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurveClipper(),
      child: Container(
        color: color,
        height: height,
      ),
    );
  }
}
