import 'package:flutter/material.dart';

class RightDrawerButton extends StatelessWidget {
  final double sectionHeight;
  final bool isActive;
  final Function triggerActive;
  const RightDrawerButton(
      {super.key,
      required this.sectionHeight,
      required this.isActive,
      required this.triggerActive});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      top: sectionHeight / 2 - 30,
      child: IconButton(
        onPressed: () {
          print('Extract left drawer');
          triggerActive();
        },
        icon: Icon(
          isActive ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left,
          color: isActive
              ? const Color.fromARGB(255, 54, 168, 35)
              : const Color.fromARGB(255, 84, 178, 232),
          size: 15,
        ),
      ),
    );
  }
}
