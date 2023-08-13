import 'package:flutter/material.dart';

class TopDrawerButton extends StatelessWidget {
  final double width;
  final bool isActive;
  final Function triggerActive;
  const TopDrawerButton(
      {super.key,
      required this.width,
      required this.isActive,
      required this.triggerActive});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: width / 2 - 10,
      child: IconButton(
        onPressed: () {
          triggerActive();
        },
        icon: Icon(
          isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: isActive
              ? const Color.fromARGB(255, 54, 168, 35)
              : const Color.fromARGB(255, 84, 178, 232),
          size: 15,
        ),
      ),
    );
  }
}
