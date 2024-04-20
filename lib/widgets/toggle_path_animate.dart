import 'package:flutter/material.dart';

class TogglePathAnimate extends StatelessWidget {
  final bool animate;
  final Function toggleAnimate;
  const TogglePathAnimate(
      {super.key, required this.animate, required this.toggleAnimate});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: const ButtonStyle(
        backgroundColor:
            MaterialStatePropertyAll<Color>(Color.fromARGB(255, 61, 57, 57)),
        side: MaterialStatePropertyAll(BorderSide.none),
      ),
      icon: Icon(
        animate ? Icons.stop : Icons.fast_forward,
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
