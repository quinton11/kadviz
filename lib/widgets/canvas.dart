import 'package:flutter/material.dart';
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

class _RouterCanvasState extends State<RouterCanvas> {
  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final routerProvider = Provider.of<RouterProvider>(context);
    routerProvider.setCanvas(widget.width, widget.height,
        netSize: networkProvider.networkSize);

    return CustomPaint(
      painter: RouterPainter(
          routerProvider: routerProvider, networkProvider: networkProvider),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // TODO: IMPLEMENT PACKET STATE
    // If animate mode, set position of packet to position of source
    // then for each duration, increment packet dx,dy or position in the
    // direction of the destination path
    // When an event or animation is selected, then build path before animating
    // source and destination would be start and end of branches
  }
}

class RouterPainter extends CustomPainter {
  final RouterProvider routerProvider;
  final NetworkProvider networkProvider;
  RouterPainter({required this.routerProvider, required this.networkProvider});
  @override
  void paint(Canvas canvas, Size size) {
    print('Painting...');
    if (networkProvider.animate) {
      print("Animate operation");
      routerProvider.setAnimationPath();
    }
    // where you draw, canvas to draw on and the size of that canvas
    (networkProvider.nodeSelected && !networkProvider.animate)
        ? drawSpecificTree(canvas, size)
        : drawTree(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    print('Repainting...');
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
