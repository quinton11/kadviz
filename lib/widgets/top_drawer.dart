import 'dart:ui';

import 'package:flutter/material.dart';

class TopDrawer extends StatefulWidget {
  final double height;
  final double width;
  const TopDrawer({super.key, required this.height, required this.width});

  @override
  State<TopDrawer> createState() => _TopDrawerState();
}

class _TopDrawerState extends State<TopDrawer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 2),
      left: 0,
      top: 0,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Color.fromRGBO(13, 6, 6, 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
