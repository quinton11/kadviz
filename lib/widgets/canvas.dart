import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';

class RouterCanvas extends StatelessWidget {
  final double height;
  final double width;
  const RouterCanvas({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final routerProvider = Provider.of<RouterProvider>(context);
    routerProvider.setCanvas(width, height,
        netSize: networkProvider.networkSize);

    return CustomPaint(
      painter: RouterPainter(
          routerProvider: routerProvider, networkProvider: networkProvider),
      child: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
    );
  }
}

class RouterPainter extends CustomPainter {
  final RouterProvider routerProvider;
  final NetworkProvider networkProvider;
  RouterPainter({required this.routerProvider, required this.networkProvider});
  @override
  void paint(Canvas canvas, Size size) {
    //print('Painting...');
    // where you draw, canvas to draw on and the size of that canvas
    drawTree(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    print('Repainting...');
    return false;
  }

  void drawTree(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    routerProvider.drawTree(paint, canvas, networkProvider.hostIds);
  }
}
