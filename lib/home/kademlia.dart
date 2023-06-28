import 'package:flutter/material.dart';
import 'package:kademlia2d/widgets/k_network.dart';
import 'package:kademlia2d/widgets/k_routing.dart';

class KademliaHome extends StatelessWidget {
  const KademliaHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double sectionHeight = (height / 2) - 10;
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(6),
          decoration:
              const BoxDecoration(color: Color.fromARGB(255, 32, 32, 32)),
          child: Column(
            children: <Widget>[
              KademliaNetwork(width: width, sectionHeight: sectionHeight),
              const Divider(
                height: 5,
                indent: 50,
                endIndent: 50,
                thickness: 3,
                color: Color.fromARGB(255, 84, 178, 232),
              ),
              KademliaRouting(width: width, sectionHeight: sectionHeight),
            ],
          )),
    );
  }
}
