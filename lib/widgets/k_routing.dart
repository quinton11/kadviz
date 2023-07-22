import 'package:flutter/material.dart';
import 'package:kademlia2d/widgets/canvas.dart';
/* import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart'; */

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
      child: Center(
        child: RouterCanvas(height: sectionHeight - 20, width: width - 20),
      ),
    );
  }
}
