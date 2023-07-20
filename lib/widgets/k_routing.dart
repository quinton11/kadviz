import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';

class KademliaRouting extends StatelessWidget {
  final double width, sectionHeight;
  const KademliaRouting(
      {super.key, required this.width, required this.sectionHeight});

  @override
  Widget build(BuildContext context) {
    /*  final routerProvider =  */ Provider.of<RouterProvider>(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.indigo),
      width: width,
      height: sectionHeight,
      child: Center(
        child: CustomPaint(
          child: Container(
            height: sectionHeight - 20,
            width: width - 20,
            decoration: const BoxDecoration(color: Colors.green),
            child: const Text('hello'),
          ),
        ),
      ),
    );
  }
}


/* SizedBox(height: 30, width: 50, child: Text('Hello')) */