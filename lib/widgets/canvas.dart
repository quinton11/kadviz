import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';

class RouterCanvas extends StatelessWidget {
  final double height;
  final double width;
  const RouterCanvas({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    final routerProvider = Provider.of<RouterProvider>(context);
    routerProvider.setCanvas(width, height);

    return CustomPaint(
      painter: RouterPainter(routerProvider: routerProvider),
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
  RouterPainter({required this.routerProvider});
  @override
  void paint(Canvas canvas, Size size) {
    print('Painting...');
    // TODO: implement paint
    // where you draw, canvas to draw on and the size of that canvas
    drawTree(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    print('Repainting...');
    return false;
  }

  void drawTree(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    routerProvider.drawTree(paint, canvas);
    /* canvas.drawImage(image, offset, paint) */
  }
}
