import 'package:flutter/material.dart';

class RadioToggle extends StatelessWidget {
  final String groupValue;
  final String value;
  final bool animate;
  final Function triggerChange;
  const RadioToggle(
      {super.key,
      required this.groupValue,
      required this.value,
      required this.triggerChange,
      required this.animate});

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;
    return ListTile(
      title: Text(
        value,
        style: TextStyle(
            color: isSelected
                ? const Color.fromARGB(255, 54, 168, 35)
                : const Color.fromARGB(255, 84, 178, 232),
            fontFamily: "RobotoMono",
            fontSize: 12),
      ),
      leading: Transform.scale(
        scale: 0.6,
        child: Radio<String>(
          activeColor: const Color.fromARGB(255, 54, 168, 35),
          overlayColor: const MaterialStatePropertyAll<Color>(
              Color.fromARGB(255, 84, 178, 232)),
          /* fillColor: const MaterialStatePropertyAll<Color>(
              Color.fromARGB(255, 84, 178, 232)), */
          hoverColor: const Color.fromARGB(255, 84, 178, 232),
          value: value,
          groupValue: groupValue,
          splashRadius: 2,
          onChanged: (value) {
            triggerChange(value);
          },
        ),
      ),
      trailing: (isSelected && animate)
          ? const SizedBox(
              height: 5,
              width: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 54, 168, 35),
                  shape: BoxShape.circle,
                ),
              ))
          : null,
    );
  }
}
