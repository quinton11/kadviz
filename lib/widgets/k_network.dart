import 'package:flutter/material.dart';
import 'package:kademlia2d/widgets/network_map.dart';

class KademliaNetwork extends StatelessWidget {
  final double width, sectionHeight;
  const KademliaNetwork(
      {super.key, required this.width, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          width: width,
          height: sectionHeight,
          child: Center(
            child: SizedBox(
              height: sectionHeight - 150,
              width: width - 50,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Align(
                  alignment: Alignment.center,
                  child: NetworkMap(),
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 20,
          left: 100,
          child: SizedBox(
            height: 40,
            width: 170,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Network - KeySpace',
                    style: TextStyle(
                        color: Color.fromARGB(255, 84, 178, 232),
                        fontFamily: 'RobotoMono',
                        fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
