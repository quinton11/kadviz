import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:kademlia2d/utils/constants.dart';

class RouterCanvas extends StatefulWidget {
  final double height;
  final double width;
  const RouterCanvas({super.key, required this.height, required this.width});

  @override
  State<RouterCanvas> createState() => _RouterCanvasState();
}

class _RouterCanvasState extends State<RouterCanvas>
    with SingleTickerProviderStateMixin {
  late List<APacket> packets = [];
  late Map<int, List<bool>> packetCtrl = {};
  late int currentHop = 0;
  late final Ticker _ticker;

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);

    packets = routerProvider.animPackets;
    packetCtrl = routerProvider.packetControl;
    routerProvider.setCurrentOperation(networkProvider.selectedOperation);
    currentHop = routerProvider.currentHop;

    return CustomPaint(
      painter: RouterPainter(
          routerProvider: routerProvider,
          networkProvider: networkProvider,
          startTimer: startTimer,
          cancelTimer: cancelTimer),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  late Timer timer;
  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        for (var element in packets) {
          if (element.hop == currentHop) {
            element.update(elapsed);
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ticker.dispose();
  }

  void startTimer() {
    if (_ticker.isActive) {
      return;
    }

    _ticker.start();
  }

  void cancelTimer() {
    if (_ticker.isActive) {
      _ticker.stop();
    }
  }
}

class RouterPainter extends CustomPainter {
  final RouterProvider routerProvider;
  final NetworkProvider networkProvider;
  final Function startTimer;
  final Function cancelTimer;
  RouterPainter(
      {required this.routerProvider,
      required this.networkProvider,
      required this.startTimer,
      required this.cancelTimer});
  @override
  void paint(Canvas canvas, Size size) {
    routerProvider.setCanvas(size.width, size.height,
        netSize: networkProvider.networkSize);

    (networkProvider.nodeSelected && !networkProvider.animate)
        ? drawSpecificTree(canvas, size)
        : drawTree(canvas, size);

    switch (networkProvider.animationOption) {
      case (singleOperationAnimation):
        animateOperation(canvas);
        break;
      case (singlePacketAnimation):
        animatePacket(canvas);
        break;

      default:
        cancelTimer();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  void drawTree(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    routerProvider.drawTree(paint, canvas, networkProvider.hostIds);
  }

  void drawSpecificTree(Canvas canvas, Size size) {
    //swath of colours
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    routerProvider.drawSpecificTree(paint, canvas,
        networkProvider.activeHostBucketIds, networkProvider.activeHost);
  }

  void animateOperation(Canvas canvas) {
    networkProvider.simulateOperation();
    routerProvider.setAnimationPath(networkProvider.animPaths,
        networkProvider.selectedFormat, networkProvider.selectedOperation);

    for (var element in routerProvider.animPackets) {
      element.draw(canvas);

      if (element.hop != routerProvider.currentHop) {
        continue;
      }
      routerProvider.packetControl[routerProvider.currentHop]
          ?[element.doneIdx] = element.done;

      //if(routerProvider.packetControl[])
      if (routerProvider.checkPacketControlIsDone()) {
        if (networkProvider.animate) {
          networkProvider.toggleAnimate();
        }
      }

      if (!routerProvider.packetControl[routerProvider.currentHop]!
          .contains(false)) {
        if (routerProvider.packetControl.keys.length !=
            routerProvider.currentHop + 1) {
          routerProvider.nextHop();
        }
      }
    }

    startTimer();
  }

  void animatePacket(Canvas canvas) {
    routerProvider.getCurrentPacket().draw(canvas);
    if (routerProvider.getCurrentPacket().done) {
      networkProvider.toggleAnimate();
    }
    startTimer();
  }
}
