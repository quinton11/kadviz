import 'dart:ui';

import 'package:kademlia2d/utils/enums.dart';
import 'package:vector_math/vector_math.dart';

class RequestPacket {
  late String src = '';
  late String dest = '';
  late RPCRequest req;
  late dynamic data;
  RequestPacket({required this.src, required this.dest, required this.req});

  set srcId(String id) {
    src = id;
  }

  set destId(String id) {
    dest = id;
  }

  set request(RPCResponse req) {
    req = req;
  }
}

class ResponsePacket {
  late String src = '';
  late String dest = '';
  late RPCResponse res;
  late dynamic data = [];
  ResponsePacket({required this.src, required this.dest, required this.res});

  set srcId(String id) {
    src = id;
  }

  set destId(String id) {
    dest = id;
  }

  void setresponse(RPCResponse r) {
    res = r;
  }
}

class APacket {
  final double radius = 3;
  final double outerRadius = 8;
  late Vector2 pos;
  late int currentPath = 0;
  late List<Map<String, Vector2>> paths = [];
  late Paint packetPaint;
  late Paint packetInnerPaint;
  late Paint pathPaint;
  late double speed = 1;
  double offset = 0.1;

  late bool done = false;
  final int hop;
  final int doneIdx;
  final String src;
  final String dest;
  final int networkSize;
  final int pathId;

  APacket(
      {required this.pos,
      required this.paths,
      required this.hop,
      required this.doneIdx,
      required this.src,
      required this.dest,
      required this.networkSize,
      this.pathId = 0}) {
    //packet paints
    packetPaint = Paint()
      ..color = const Color.fromARGB(255, 84, 178, 232)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    packetInnerPaint = Paint()
      ..color = const Color.fromARGB(255, 54, 168, 35)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    if (hop == 1) {
      packetInnerPaint = Paint()
        ..color = const Color.fromARGB(255, 123, 1, 62)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
    } else if (hop == 2) {
      packetInnerPaint = Paint()
        ..color = const Color.fromARGB(255, 185, 164, 56)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
    } else if (hop == 3) {
      packetInnerPaint = Paint()
        ..color = const Color.fromARGB(255, 232, 93, 117)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
    }
    pathPaint = packetInnerPaint;

    if (networkSize == 4) {
      offset = 0.01;
      speed = 2;
    } else {
      offset = 1;
      speed = 1.5;
    }
  }

  /// Draw packet on canvas
  void draw(Canvas canvas) {
    //draw inner and outer packet circles
    Offset position = Offset(pos.x, pos.y);
    canvas.drawCircle(position, outerRadius, packetPaint);
    canvas.drawCircle(position, radius, packetInnerPaint);
    drawTraversedPath(canvas, pathPaint);
  }

  /// Checks if packet should change path direction
  /// Returns false to continue moving, else true to stop at end
  bool changePath() {
    // check if current position is +- offset of the end point
    // if yes change path to the next
    Map<String, Vector2> p = paths[currentPath];
    bool stop = withinBounds(p["to"] as Vector2);
    return stop;
  }

  bool withinBounds(Vector2 bound) {
    double xnear = (bound.x - pos.x).abs();
    double ynear = (bound.y - pos.y).abs();
    if ((xnear <= offset) && (ynear <= offset)) {
      if (currentPath < paths.length - 1) {
        currentPath += 1; // change path

        pos.x = bound.x;
        pos.y = bound.y;
      } else {
        // last end
        done = true;
        return true;
      }
    }
    return false;
  }

  void update(Duration dt) {
    //[{"from":Vector2, "to":Vector2},{"from":Vector2, "to":Vector2},{"from":Vector2, "to":Vector2}]
    if (!changePath()) {
      Vector2 from = paths[currentPath]["from"] as Vector2;
      Vector2 end = paths[currentPath]["to"] as Vector2;

      Vector2 dir = (end - from);
      Vector2 direction = dir / dir.length;

      // update positions
      pos.x += direction.x * speed;
      pos.y += direction.y * speed;
    }
  }

  /// Colour path that has been traversed by the packet
  void drawTraversedPath(Canvas canvas, Paint paint) {
    // draw current path 'from' to packet's current position
    Vector2 from = (paths[currentPath]["from"] as Vector2);
    canvas.drawLine(Offset(from.x, from.y), Offset(pos.x, pos.y), paint);

    // if there are traversed paths, loop through them and draw 'from' to 'to'
    for (int i = 0; i < currentPath; i++) {
      Vector2 from = (paths[i]["from"] as Vector2);
      Vector2 to = (paths[i]["to"] as Vector2);

      canvas.drawLine(Offset(from.x, from.y), Offset(to.x, to.y), paint);
    }
  }

  void resetPacket() {
    currentPath = 0;
    done = false;
    Vector2 from = paths[currentPath]["from"] as Vector2;
    pos.x = from.x;
    pos.y = from.y;
  }
}
