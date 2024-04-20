import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:kademlia2d/widgets/toggle_animate.dart';
import 'package:kademlia2d/widgets/toggle_path_animate.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/utils/constants.dart';

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
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    populateCallStack(routerProvider.animPackets, routerProvider.currentHop,
        networkProvider.animationOption);
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
                HeaderBar(widget: widget),
                StackDrawer(
                  widget: widget,
                  calls: groupedPackets,
                  currentOperation: routerProvider.currentOperation,
                  resetPacket: routerProvider.resetPacket,
                  setCurrentPacket: routerProvider.setActivePacket,
                  setActivePath: routerProvider.setActivePath,
                  resetPacketsInPath: routerProvider.resetPacketsInActivePath,
                  currentHop: routerProvider.currentHop,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void populateCallStack(
      List<APacket> packets, int currentHop, String animationOption) {
    if (animationOption != singleOperationAnimation) return;
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
      required this.currentOperation,
      required this.resetPacket,
      required this.setCurrentPacket,
      required this.setActivePath,
      required this.resetPacketsInPath,
      required this.currentHop});

  final TopDrawer widget;
  final List<APacket> calls;
  final String currentOperation;
  final Function resetPacket;
  final Function setCurrentPacket;
  final Function setActivePath;
  final Function resetPacketsInPath;
  final int currentHop;
  @override
  State<StackDrawer> createState() => _StackDrawerState();
}

class _StackDrawerState extends State<StackDrawer> {
  late String _selectedIndex = "";
  late bool _callStackInfoSelected = false;
  late String srcId = "";
  late String destId = "";
  late int selectedPath = 0;

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final pathConvergedEmpty = networkProvider.pathConverged.isEmpty;
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
                          currentOperation: networkProvider.selectedOperation,
                          path: packet.pathId,
                          pathConverged: pathConvergedEmpty
                              ? false
                              : networkProvider.pathConverged[packet.pathId]!,
                        ),
                        onTap: () {
                          setState(() {
                            if (_selectedIndex != index.toString()) {
                              if (networkProvider.animate) return;
                              _selectedIndex = index.toString();
                              widget.setCurrentPacket(
                                  packet.src, packet.dest, packet.hop);
                              srcId = packet.src;
                              destId = packet.dest;
                              selectedPath = packet.pathId;

                              // pop open dialogue box
                              _callStackInfoSelected = true;

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
              if (_callStackInfoSelected)
                CallStackPopUpBox(
                    height: widget.widget.height,
                    width: widget.widget.width,
                    operation: networkProvider.selectedOperation,
                    triggerClose: () {
                      setState(() {
                        _callStackInfoSelected = false;
                      });
                    },
                    srcId: srcId,
                    destId: destId,
                    hop: widget.currentHop),
              if (networkProvider.animate || _selectedIndex != "")
                Positioned(
                  right: 50,
                  bottom: 20,
                  child: ToggleAnimate(
                    animate: networkProvider.animate,
                    toggleAnimate: () {
                      setState(() {
                        //routerProvider.clearAnimPaths();
                        // if animation is false
                        if (networkProvider.animate == false) {
                          // Set animation to single animation
                          // then trigger single animation action
                          widget.resetPacket();
                          networkProvider.singlePacketAnimate();
                        } else {
                          networkProvider.toggleAnimate();
                        }
                      });
                    },
                    stop: true,
                  ),
                ),
              if (_selectedIndex != '' &&
                  networkProvider.selectedOperation == swarmFINDNODE &&
                  !networkProvider.animate)
                Positioned(
                  right: 100,
                  bottom: 20,
                  child: TogglePathAnimate(
                    animate: networkProvider.animate,
                    toggleAnimate: () {
                      setState(() {
                        if (networkProvider.animate) return;

                        widget.setActivePath(selectedPath);
                        widget.resetPacketsInPath();
                        // reset packets in currentPath
                        networkProvider.singlePathAnimate();
                      });
                    },
                  ),
                ),
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
      required this.currentOperation,
      required this.path,
      required this.pathConverged});

  final int hop;
  final String src;
  final String dest;
  final Paint paint;
  final bool isSelected;
  final String currentOperation;
  final int path;
  final bool pathConverged;

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
              "/$dest/$currentOperation",
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
            Text(
              "PATH - $path",
              style: TextStyle(
                  color: paint.color,
                  fontFamily: 'RobotoMono',
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            if (currentOperation == swarmFINDNODE)
              pathConverged
                  ? const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 20,
                    )
                  : const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    )
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
  });

  final TopDrawer widget;

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
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
              "${networkProvider.selectedOperation.toUpperCase()}: ${networkProvider.nodeInQuestion}",
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

class CallStackPopUpBox extends StatelessWidget {
  const CallStackPopUpBox(
      {super.key,
      required this.height,
      required this.width,
      required this.operation,
      required this.triggerClose,
      required this.srcId,
      required this.destId,
      required this.hop});

  final double height;
  final double width;
  final String operation;
  final Function triggerClose;
  final String srcId;
  final String destId;
  final int hop;

  @override
  Widget build(BuildContext context) {
    final mainWidth = width - width / 2;
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: Color.fromRGBO(13, 6, 6, 0.5)),
            child: Center(
              child: SizedBox(
                height: height,
                width: mainWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        color: const Color.fromARGB(255, 84, 178, 232),
                        width: 2,
                      )),
                  child: Column(
                    children: [
                      SizedBox(
                        width: mainWidth,
                        height: 50,
                        child: DecoratedBox(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(operation,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 84, 178, 232),
                                        fontFamily: 'RobotoMono',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                    onPressed: () {
                                      triggerClose();
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color.fromARGB(255, 84, 178, 232),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: DecoratedBox(
                          decoration:
                              const BoxDecoration(color: Colors.transparent),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RequestBox(
                                srcId: srcId,
                                destId: destId,
                              ),
                              const VerticalDivider(
                                width: 5,
                                indent: 7,
                                endIndent: 7,
                                thickness: 2,
                                color: Color.fromARGB(255, 84, 178, 232),
                              ),
                              ResponseBox(destId: destId, hop: hop),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RequestBox extends StatelessWidget {
  const RequestBox({super.key, required this.srcId, required this.destId});

  final String srcId;
  final String destId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 400,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                height: 150,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              const Text(
                                "src:",
                                style: TextStyle(
                                    fontFamily: "RobotoMono",
                                    color: Color.fromARGB(255, 84, 178, 232),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                srcId,
                                style: const TextStyle(
                                    fontFamily: "RobotoMono",
                                    color: Color.fromARGB(255, 54, 168, 35),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 320,
                height: 150,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              const Text(
                                "dest:",
                                style: TextStyle(
                                    fontFamily: "RobotoMono",
                                    color: Color.fromARGB(255, 84, 178, 232),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                destId,
                                style: const TextStyle(
                                    fontFamily: "RobotoMono",
                                    color: Color.fromARGB(255, 54, 168, 35),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ResponseBox extends StatelessWidget {
  ResponseBox({super.key, required this.destId, required this.hop});
  final String destId;
  final int hop;

  late List<String> responseData = [];
  late Map<String, bool> responseVisited = {};

  void populateResponseData(int currentHop,
      Map<int, List<Map<String, Map<String, bool>>>> destResponse) {
    var hopResponses = destResponse[currentHop];
    if (hopResponses == null) return;
    Map<String, Map<String, bool>>? foundResponse = hopResponses.firstWhere(
        (map) => map.containsKey(destId),
        orElse: () => <String, Map<String, bool>>{});

    if (foundResponse.containsKey(destId)) {
      responseVisited = foundResponse[destId]!;
      responseData.addAll(foundResponse[destId]!.keys);
      print(responseData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    final bool noResponseData = networkProvider.destResponse.isEmpty;
    if (!noResponseData) {
      populateResponseData(hop, networkProvider.destResponse);
    }

    return SizedBox(
      width: 520,
      height: 400,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 500,
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      networkProvider.nodeInQuestion,
                      style: const TextStyle(
                          fontFamily: "RobotoMono",
                          color: Color.fromRGBO(54, 168, 35, 1),
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "nearest k nodes",
                      style: TextStyle(
                          color: Color.fromARGB(255, 84, 178, 232),
                          fontFamily: "RobotoMono",
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 500,
                height: 280,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: Colors.transparent),
                  child: noResponseData
                      ? const Center(
                          child: Text(
                            "No Response data",
                            style: TextStyle(
                                fontFamily: "RobotoMono",
                                color: Color.fromRGBO(54, 168, 35, 0.5),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                var id = responseData[index];
                                var visited = responseVisited[id];
                                return SizedBox(
                                  height: 30,
                                  child: DecoratedBox(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Color.fromRGBO(
                                                54, 168, 35, 0.5),
                                            width: 1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          id,
                                          style: TextStyle(
                                              fontFamily: "RobotoMono",
                                              color: visited!
                                                  ? const Color.fromRGBO(
                                                      54, 168, 35, 0.5)
                                                  : const Color.fromRGBO(
                                                      54, 168, 35, 1),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          visited ? "Visited" : "Not Visited",
                                          style: TextStyle(
                                              fontFamily: "RobotoMono",
                                              color: visited
                                                  ? const Color.fromRGBO(
                                                      54, 168, 35, 0.5)
                                                  : const Color.fromRGBO(
                                                      54, 168, 35, 1),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (BuildContext ctx, int index) {
                                return const SizedBox(
                                    height: 10,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                    ));
                              },
                              itemCount: responseData.length)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
