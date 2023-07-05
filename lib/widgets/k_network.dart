import 'package:flutter/material.dart';
import 'package:kademlia2d/widgets/network_map.dart';

class KademliaNetwork extends StatelessWidget {
  final double width, sectionHeight;
  final List<Map<String, bool>> items = [
    {"0000": false},
    {"0001": false},
    {"0010": false},
    {"0011": false},
    {"0100": false},
    {"0101": false},
    {"0110": false},
    {"0111": false},
    {"1000": false},
    {"1001": false},
    {"1010": false},
    {"1011": false},
    {"1100": false},
    {"1101": false},
    {"1110": false},
    {"1111": false},
  ];
  KademliaNetwork(
      {super.key, required this.width, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      width: width,
      height: sectionHeight,
      child: Center(
        child: SizedBox(
          height: sectionHeight - 150,
          width: width - 50,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Align(
              alignment: Alignment.center,
              child: NetworkMap(items: items),
            ),
          ),
        ),
      ),
    );
  }
}
