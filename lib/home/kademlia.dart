import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:kademlia2d/widgets/k_network.dart';
import 'package:kademlia2d/widgets/k_routing.dart';
import 'package:provider/provider.dart';

class KademliaHome extends StatelessWidget {
  const KademliaHome({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double sectionHeight = (height / 2) - 10;
    final bool notpastLimit = height > 710 ? true : false;
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.networkSize = networkProvider.networkSize;
    //if height is 710 show a warning else show component
    return Scaffold(
      body: Center(
        child: notpastLimit
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 32, 32, 32)),
                child: Column(
                  children: <Widget>[
                    KademliaNetwork(
                        width: width, sectionHeight: sectionHeight - 100),
                    const Divider(
                      height: 5,
                      indent: 50,
                      endIndent: 50,
                      thickness: 3,
                      color: Color.fromARGB(255, 84, 178, 232),
                    ),
                    KademliaRouting(
                        width: width, sectionHeight: sectionHeight + 100),
                  ],
                ),
              )
            : Container(
                decoration: const BoxDecoration(color: Colors.indigo),
              ),
      ),
    );
  }
}
