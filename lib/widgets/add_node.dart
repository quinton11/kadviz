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
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll<Color>(
                Color.fromARGB(255, 61, 57, 57)),
            side: MaterialStatePropertyAll(BorderSide.none),
          ),
          icon: const Icon(
            Icons.add,
            size: 15,
            color: Color.fromARGB(255, 84, 178, 232),
          ),
          onPressed: () {
            networkProvider.addNode();
          },
          autofocus: true,
          label: const Text(
            'Node',
            style: TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: Color.fromARGB(255, 84, 178, 232)),
          )),
    );
  }
}
