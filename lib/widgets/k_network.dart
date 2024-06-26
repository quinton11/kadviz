import 'package:flutter/material.dart';
import 'package:kademlia2d/home/pre_kademlia.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:kademlia2d/widgets/add_node.dart';
import 'package:kademlia2d/widgets/right_drawer.dart';
import 'package:kademlia2d/widgets/top_drawer.dart';
import 'package:kademlia2d/widgets/top_drawer_button.dart';
import 'package:kademlia2d/widgets/network_map.dart';
import 'package:kademlia2d/widgets/right_drawer_button.dart';
import 'package:provider/provider.dart';

class KademliaNetwork extends StatefulWidget {
  final double width, sectionHeight;
  const KademliaNetwork(
      {super.key, required this.width, required this.sectionHeight});

  @override
  State<KademliaNetwork> createState() => _KademliaNetworkState();
}

class _KademliaNetworkState extends State<KademliaNetwork> {
  bool _rightisActive = false;
  bool _topisActive = false;
  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    if (networkProvider.animate) {
      _topisActive = true;
    }
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          width: widget.width,
          height: widget.sectionHeight,
          child: Center(
            child: SizedBox(
              height: widget.sectionHeight - 150,
              width: widget.width / 2,
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
        ),
        Positioned(
          top: 20,
          left: widget.width - 250,
          child: SizedBox(
            height: 30,
            width: 150,
            child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const ConfigureNetwork();
                    }),
                  );
                },
                child: const Text(
                  "Configure Network",
                  style: TextStyle(
                      color: Color.fromARGB(255, 54, 168, 35),
                      fontFamily: 'RobotoMono',
                      fontSize: 12),
                )),
          ),
        ),
        const NewNodeButton(),
        if (_rightisActive)
          RightDrawer(height: widget.sectionHeight, width: widget.width / 4),
        RightDrawerButton(
          sectionHeight: widget.sectionHeight,
          isActive: _rightisActive,
          triggerActive: () {
            setState(() {
              if (!_topisActive) {
                _rightisActive = !_rightisActive;
              }
            });
          },
        ),
        if (_topisActive)
          TopDrawer(height: widget.sectionHeight, width: widget.width),
        TopDrawerButton(
          width: widget.width,
          isActive: _topisActive,
          triggerActive: () {
            setState(() {
              _rightisActive = false;
              _topisActive = !_topisActive;
              if (!_topisActive) {
                routerProvider.clearAnimPaths();
              }
            });
          },
        ),
        Positioned(
          bottom: 20,
          left: 100,
          child: AnimatedOpacity(
            opacity: networkProvider.isOperationActive ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.transparent, // Background color of the container
                constraints: const BoxConstraints(
                  maxWidth: 200.0, // Limit the width of the container
                ),
                child: Text(
                  networkProvider.operationText,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 54, 168, 35),
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12),
                )),
          ),
        )
      ],
    );
  }
}
