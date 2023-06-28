import 'package:flutter/material.dart';

class KademliaRouting extends StatelessWidget {
  final double width, sectionHeight;
  const KademliaRouting(
      {super.key, required this.width, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      width: width,
      height: sectionHeight,
      child: const Center(
        child: Text(
          'Kademlia Routing',
          style: TextStyle(
              color: Color.fromARGB(255, 84, 178, 232),
              fontFamily: 'RobotoMono'),
        ),
      ),
    );
  }
}
