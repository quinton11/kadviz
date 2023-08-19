import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';

class RouterFormatToggle extends StatelessWidget {
  final String selected;
  final Function triggerChange;
  const RouterFormatToggle(
      {super.key, required this.triggerChange, required this.selected});

  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    return SizedBox(
      height: 30,
      width: 200,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.scale(
              scale: 0.6,
              child: Radio<String>(
                  fillColor:
                      const MaterialStatePropertyAll<Color>(Colors.orange),
                  activeColor: const Color.fromARGB(255, 54, 168, 35),
                  overlayColor:
                      const MaterialStatePropertyAll<Color>(Colors.orange),
                  //hoverColor: Colors.orange,
                  groupValue: selected,
                  splashRadius: 2,
                  value: networkProvider.formats[1],
                  onChanged: (value) {
                    triggerChange(value);
                  }),
            ),
            Transform.scale(
              scale: 0.6,
              child: Radio<String>(
                  fillColor: const MaterialStatePropertyAll<Color>(
                      Color.fromARGB(255, 84, 178, 232)),
                  activeColor: const Color.fromARGB(255, 54, 168, 35),
                  overlayColor: const MaterialStatePropertyAll<Color>(
                      Color.fromARGB(255, 84, 178, 232)),
                  groupValue: selected,
                  splashRadius: 2,
                  value: networkProvider.formats[0],
                  onChanged: (value) {
                    triggerChange(value);
                  }),
            )
          ],
        ),
      ),
    );
  }
}
