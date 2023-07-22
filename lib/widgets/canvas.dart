import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kademlia2d/providers/router.dart';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart' as vmath;

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
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    Offset startingPoint = Offset(size.width / 2, 10);
    Offset endPoint = Offset(size.width / 2, 300);
    print(startingPoint.dy);
    print(startingPoint.dx);
    //75 for left rotation and 285 for right rotation
    //double relativex = endPoint.dx - startingPoint.dx;

    /* NB - 0 + 75 degrees gives 0 branch and 360 - 75 gives 1 branch */
    // first depth
    double relativey = endPoint.dy - startingPoint.dy;
    double xrotatedzero =
        -relativey * sin(vmath.radians(80)) + startingPoint.dx;
    double yrotatedzero = relativey * cos(vmath.radians(80)) + startingPoint.dy;
    Offset rotatedendPointZero = Offset(xrotatedzero, yrotatedzero);

    double xrotatedone =
        -relativey * sin(vmath.radians(280)) + startingPoint.dx;
    double yrotatedone = relativey * cos(vmath.radians(280)) + startingPoint.dy;
    Offset rotatedendPointOne = Offset(xrotatedone, yrotatedone);

    // second depth
    // - first branch
    Offset startingPoint2zero =
        Offset(rotatedendPointZero.dx, rotatedendPointZero.dy /* + ygap */);
    Offset endPoint2zero =
        Offset(rotatedendPointZero.dx, startingPoint2zero.dy + 180);

    double relativey2 = endPoint2zero.dy - startingPoint2zero.dy;
    double xrotatedzero2 =
        -relativey2 * sin(vmath.radians(70)) + startingPoint2zero.dx;
    double yrotatedzero2 =
        relativey2 * cos(vmath.radians(70)) + startingPoint2zero.dy;
    Offset rotatedendPoint2Zero = Offset(xrotatedzero2, yrotatedzero2);

    double xrotatedone2 =
        -relativey2 * sin(vmath.radians(290)) + startingPoint2zero.dx;
    double yrotatedone2 =
        relativey2 * cos(vmath.radians(290)) + startingPoint2zero.dy;
    Offset rotatedendPoint2One = Offset(xrotatedone2, yrotatedone2);

    // - second branch
    Offset startingPoint2one =
        Offset(rotatedendPointOne.dx, rotatedendPointOne.dy /* + ygap */);
    Offset endPoint2one =
        Offset(rotatedendPointOne.dx, startingPoint2one.dy + 180);

    double relativey2one = endPoint2one.dy - startingPoint2one.dy;
    double xrotatedzero22 =
        -relativey2one * sin(vmath.radians(70)) + startingPoint2one.dx;
    double yrotatedzero22 =
        relativey2 * cos(vmath.radians(70)) + startingPoint2one.dy;
    Offset rotatedendPoint22Zero = Offset(xrotatedzero22, yrotatedzero22);

    double xrotatedone22 =
        -relativey2one * sin(vmath.radians(290)) + startingPoint2one.dx;
    double yrotatedone22 =
        relativey2one * cos(vmath.radians(290)) + startingPoint2one.dy;
    Offset rotatedendPoint22One = Offset(xrotatedone22, yrotatedone22);

    canvas.drawLine(startingPoint, rotatedendPointZero, paint);
    canvas.drawLine(startingPoint, rotatedendPointOne, paint);
    canvas.drawLine(startingPoint2zero, rotatedendPoint2Zero, paint);
    canvas.drawLine(startingPoint2zero, rotatedendPoint2One, paint);
    canvas.drawLine(startingPoint2one, rotatedendPoint22Zero, paint);
    canvas.drawLine(startingPoint2one, rotatedendPoint22One, paint);
  }
}
