import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';

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
    /*  Duration duration = const Duration(milliseconds: 1000 ~/ 60);
    timer = Timer.periodic(duration, (timer) {}); */
    _ticker = createTicker((elapsed) {
      setState(() {
        for (var element in packets) {
          // check for current hop
          //update elements in current hop
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
    //called to start timer
    //if timer is already started then skip else initialize timer
    //print('Start Timer');
    if (_ticker.isActive) {
      //print('isactive');
      return;
    }

    _ticker.start();
  }

  void cancelTimer() {
    if (_ticker.isActive) {
      //print('Cancelling timer...');
      //timer.cancel();
      _ticker.stop();
      //print('Cancelled timer...');
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

    if (networkProvider.animate) {
      networkProvider.simulateOperation();
      routerProvider.setAnimationPath(networkProvider.animPaths);

      for (var element in routerProvider.animPackets) {
        //print("Position: ${element.pos}");
        element.draw(canvas);
        //print(routerProvider.currentHop);
        //print(element.hop);
        if(element.hop!=routerProvider.currentHop){
          continue;
        }
        routerProvider.packetControl[routerProvider.currentHop]
              ?[element.doneIdx] = element.done;

        /* if (element.hop == routerProvider.currentHop) {
          routerProvider.packetControl[routerProvider.currentHop]
              ?[element.doneIdx] = element.done;
        } */
        //print(routerProvider.packetControl[routerProvider.currentHop]);
        if (!routerProvider.packetControl[routerProvider.currentHop]!
            .contains(false)) {
          /* print('Done with current hop');
          print(routerProvider.packetControl.keys.length);
          print(routerProvider.packetControl);
          print(routerProvider.currentHop); */
          if (routerProvider.packetControl.keys.length !=
              routerProvider.currentHop + 1) {
            /* print('Done with current hop moving to next');
            print(routerProvider.packetControl);
            print(routerProvider.animPackets); */
            routerProvider.currentHop += 1;
          }
        }

        /* print('Element hop: ${element.hop}');
        print('Element idx in hop: ${element.doneIdx}'); */
      }

      startTimer();
    } else {
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

    routerProvider.drawSpecificTree(
        paint, canvas, networkProvider.activeHostBucketIds);
  }
}
