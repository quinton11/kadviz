import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kademlia2d/models/packet.dart';
//import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:provider/provider.dart';

class TopDrawer extends StatefulWidget {
  final double height;
  final double width;
  const TopDrawer({super.key, required this.height, required this.width});

  @override
  State<TopDrawer> createState() => _TopDrawerState();
}

class _TopDrawerState extends State<TopDrawer> {
  late List<APacket> groupedPackets = [];
  @override
  Widget build(BuildContext context) {
    final routerProvider = Provider.of<RouterProvider>(context);
    populateCallStack(routerProvider.animPackets, routerProvider.currentHop);
    //final networkProvider = Provider.of<NetworkProvider>(context);
    print("TopDrawer:::Current Hop: ${routerProvider.currentHop}");
    print("Call Stack elements");
    return AnimatedPositioned(
      duration: const Duration(seconds: 2),
      left: 0,
      top: 0,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(13, 6, 6, 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HeaderBar(
                    widget: widget, operation: routerProvider.currentOperation),
                StackDrawer(
                  widget: widget,
                  calls: groupedPackets,
                  currentOperation: routerProvider.currentOperation,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void populateCallStack(List<APacket> packets, int currentHop) {
    groupedPackets.clear();
    var currentStackPackets =
        packets.where((packet) => packet.hop <= currentHop).toList();

    currentStackPackets.sort((pktA, pktB) => pktB.hop.compareTo(pktA.hop));

    groupedPackets.addAll(currentStackPackets);
  }
}

class StackDrawer extends StatefulWidget {
  const StackDrawer(
      {super.key,
      required this.widget,
      required this.calls,
      required this.currentOperation});

  final TopDrawer widget;
  final List<APacket> calls;
  final String currentOperation;

  @override
  State<StackDrawer> createState() => _StackDrawerState();
}

class _StackDrawerState extends State<StackDrawer> {
  late String _selectedIndex = "";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.widget.width,
      height: widget.widget.height - 80,
      child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: widget.widget.height - widget.widget.height / 4,
                  width: widget.widget.width - widget.widget.width / 3,
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      var packet = widget.calls[index];
                      return GestureDetector(
                        child: CallStackInfoBar(
                          hop: packet.hop,
                          src: packet.src,
                          dest: packet.dest,
                          paint: packet.pathPaint,
                          isSelected: _selectedIndex == index.toString(),
                          currentOperation: widget.currentOperation,
                        ),
                        onTap: () {
                          setState(() {
                            if (_selectedIndex != index.toString()) {
                              _selectedIndex = index.toString();
                              return;
                            }
                            _selectedIndex = "";
                          });
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                          height: 20,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                          ));
                    },
                    itemCount: widget.calls.length,
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ),
              CallStackCount(calls: widget.calls.length),
            ],
          )),
    );
  }
}

class CallStackInfoBar extends StatelessWidget {
  const CallStackInfoBar(
      {super.key,
      required this.hop,
      required this.src,
      required this.dest,
      required this.paint,
      required this.isSelected,
      required this.currentOperation});

  final int hop;
  final String src;
  final String dest;
  final Paint paint;
  final bool isSelected;
  final String currentOperation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: const Color.fromRGBO(32, 32, 32, 1),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(
                width: 3,
                color: isSelected
                    ? paint.color
                    : const Color.fromRGBO(32, 32, 32, 1))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: paint.color,
                    borderRadius: const BorderRadius.all(Radius.circular(3))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    currentOperation.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Text(
              "/$dest/PING",
              style: const TextStyle(
                  color: Color.fromARGB(255, 84, 178, 232),
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SourceTargetCard(
              type: "Source",
              id: src,
              paint: paint,
            ),
            SourceTargetCard(
              type: "Target",
              id: dest,
              paint: paint,
            ),
            Text(
              "HOP - $hop",
              style: const TextStyle(
                  color: Color.fromARGB(255, 84, 178, 232),
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SourceTargetCard extends StatelessWidget {
  const SourceTargetCard(
      {super.key, required this.type, required this.id, required this.paint});

  final String type;
  final String id;
  final Paint paint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "$type:",
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMono',
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          Text(
            id,
            style: TextStyle(
                color: paint.color,
                fontFamily: 'RobotoMono',
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CallStackCount extends StatelessWidget {
  const CallStackCount({super.key, required this.calls});

  final int calls;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5,
      left: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          width: 100,
          child: Row(
            children: [
              const Text(
                "Calls",
                style: TextStyle(
                    color: Color.fromARGB(255, 84, 178, 232),
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
                width: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(
                      width: 3,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 54, 168, 35),
                        ),
                      ),
                    ),
                    Text(
                      "$calls",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 54, 168, 35),
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.widget,
    required this.operation,
  });

  final TopDrawer widget;
  final String operation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 50,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "RPC Call Stack",
              style: TextStyle(
                  color: Color.fromARGB(255, 84, 178, 232),
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              operation.toUpperCase(),
              style: const TextStyle(
                  fontFamily: "RobotoMono",
                  color: Color.fromARGB(255, 54, 168, 35),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
