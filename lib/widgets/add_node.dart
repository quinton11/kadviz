import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';

class NewNodeButton extends StatelessWidget {
  const NewNodeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    return Positioned(
      bottom: 20,
      right: 100,
      child: OutlinedButton.icon(
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll<Color>(
                Color.fromARGB(255, 61, 57, 57)),
            side: const MaterialStatePropertyAll(BorderSide.none),
            shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 54, 168, 35), width: 1.0))),
          ),
          icon: const Icon(
            Icons.add,
            size: 15,
            color: Color.fromARGB(255, 54, 168, 35),
          ),
          onPressed: () {
            networkProvider.addNode();
          },
          autofocus: true,
          label: const Text(
            'Node',
            style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                color: Color.fromARGB(255, 54, 168, 35)),
          )),
    );
  }
}
