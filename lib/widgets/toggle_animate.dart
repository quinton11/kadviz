import 'package:flutter/material.dart';

class ToggleAnimate extends StatelessWidget {
  final bool animate;
  final Function toggleAnimate;
  final bool stop;
  const ToggleAnimate(
      {super.key,
      required this.animate,
      required this.toggleAnimate,
      required this.stop});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: const ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll<Color>(Color.fromARGB(255, 61, 57, 57)),
        side: MaterialStatePropertyAll(BorderSide.none),
      ),
      icon: Icon(
        animate
            ? stop
                ? Icons.stop
                : Icons.pause
            : Icons.play_arrow,
        size: 20,
        color: const Color.fromARGB(255, 54, 168, 35),
      ),
      onPressed: () {
        toggleAnimate();
      },
      autofocus: true,
    );
  }
}
