import 'dart:math';

//import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/branch.dart';
import 'package:kademlia2d/models/node.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class RouterProvider extends ChangeNotifier {
  List<Node> nodes = [];
  List<Map<String, vmath.Vector2>> animPaths = [];
  List<APacket> animPackets = [];
  int currentPath = 0;
  Map<String, Node> nodesId = {};
  Map<String, dynamic> branches = {};
  int networkSize = 4;
  double canvasWidth = 0;
  double canvasHeight = 0;
  bool routerSet = false;
  String currentOperation = '';
  Path pathToDraw = parseSvgPathData(
      'M455.5,348H447V99.5c0-17.369-14.131-31.5-31.5-31.5h-368C30.131,68,16,82.131,16,99.5V348H7.5c-4.142,0-7.5,3.358-7.5,7.5v16C0,384.458,10.542,395,23.5,395h416c12.958,0,23.5-10.542,23.5-23.5v-16C463,351.358,459.642,348,455.5,348z M31,99.5C31,90.402,38.402,83,47.5,83h368c9.098,0,16.5,7.402,16.5,16.5V348H31V99.5zM448,371.5c0,4.687-3.813,8.5-8.5,8.5h-416c-4.687,0-8.5-3.813-8.5-8.5V363h169.025c-0.011,0.166-0.025,0.331-0.025,0.5c0,4.142,3.358,7.5,7.5,7.5h80c4.142,0,7.5-3.358,7.5-7.5c0-0.169-0.014-0.334-0.025-0.5H448V371.5z');

  RouterProvider();

  void setCanvas(double cW, double cH, {int netSize = 4}) {
    pathToDraw.addPath(
        parseSvgPathData(
            'M407.5,100h-352c-4.142,0-7.5,3.358-7.5,7.5v216c0,4.142,3.358,7.5,7.5,7.5h352c4.142,0,7.5-3.358,7.5-7.5v-216C415,103.358,411.642,100,407.5,100z M400,316H63V115h337V316z'),
        const Offset(0, 0));

    // to prevent rebuilding tree
    if (routerSet) {
      //print('Canvas sizes are the same');
      return;
    }
    /* if (cW == canvasWidth && cH == canvasHeight) {
      print('Canvas sizes are the same');
      return;
    } */

    canvasWidth = cW;
    canvasHeight = cH;
    networkSize = netSize;
    setRoutingTree(netSize);
  }

  void setCurrentOperation(String op) {
    if (op == currentOperation) {
      return;
    }
    animPackets.clear();
    animPaths.clear();
    currentOperation = op;
  }

  void setRoutingTree(int networkBitSize) {
    //populate nodes and nodesId
    nodes.clear();

    buildTree(networkBitSize, 0, parentIds: []);
    routerSet = true;
  }

  void addBranch(Map<String, dynamic> nbranch) {
    branches.addAll(nbranch);
  }

  Map<String, Branch> calcNodeBranch(
      Node node, int maxDepth, int currentDepth) {
    String id = node.id;

    Map<String, double> dims = getLengthAndDegree(currentDepth, maxDepth);
    double length = dims['length']!.toDouble();
    double angle = dims['angle']!.toDouble();
    double symangle = 360 - angle;

    String parentId = node.parentId;
    vmath.Vector2 startingPoint =
        vmath.Vector2(canvasWidth / 2, 80); // if root node
    if (id != 'root') {
      String branchId = id[id.length - 1];
      startingPoint = (branches[parentId][branchId] as Branch).endPoint;
    }

    //calc end points
    vmath.Vector2 relative = vmath.Vector2(0, length);

    // 0
    double xrotatedzero =
        -relative.y * sin(vmath.radians(angle)) + startingPoint.x;
    double yrotatedzero =
        relative.y * cos(vmath.radians(angle)) + startingPoint.y;
    vmath.Vector2 endPointZero = vmath.Vector2(xrotatedzero, yrotatedzero);

    // 1
    double xrotatedone =
        -relative.y * sin(vmath.radians(symangle)) + startingPoint.x;
    double yrotatedone =
        relative.y * cos(vmath.radians(symangle)) + startingPoint.y;
    vmath.Vector2 endPointOne = vmath.Vector2(xrotatedone, yrotatedone);

    Branch zero = Branch(
      startPoint: startingPoint,
      endPoint: endPointZero,
    );
    Branch one = Branch(startPoint: startingPoint, endPoint: endPointOne);
    return {"0": zero, "1": one};
  }

  /// Recursively sets and builds the binary tree
  void buildTree(int maxDepth, int currentDepth,
      {required List<String> parentIds}) {
    List<String> parentIdsPass = [];
    if (nodes.isEmpty) {
      //set root node
      Node root = Node(
        children: ["0", "1"],
        depth: 0,
        parentId: "root",
        id: "root",
      );
      nodes.add(root);
      nodesId.addAll({"root": root});
      parentIds.addAll(root.children);

      // root node children branches
      addBranch({"root": calcNodeBranch(root, maxDepth, currentDepth)});
    }
    currentDepth += 1;

    // number of times loop should run
    int power = pow(2, currentDepth).toInt();
    for (int i = 0; i < power; i++) {
      String nodeId = parentIds[i];

      Node node = Node(
        children: ["${nodeId}0", "${nodeId}1"],
        depth: currentDepth,
        parentId:
            currentDepth == 1 ? "root" : nodeId.substring(0, nodeId.length - 1),
        id: nodeId,
      );

      //add nodes and next parent nodes for iteration
      nodes.addAll([node]);
      nodesId.addAll({nodeId: node});
      parentIdsPass.addAll([...node.children]);

      //add child branches
      addBranch({nodeId: calcNodeBranch(node, maxDepth, currentDepth)});
    }

    //print("Depth $currentDepth - ${[...nodes]}");

    if (currentDepth != maxDepth) {
      buildTree(maxDepth, currentDepth, parentIds: parentIdsPass);
    }
  }

  /// Gets the length and angle of branches at each depth
  Map<String, double> getLengthAndDegree(int currentDepth, int maxDepth) {
    //currently handles max 4 depths
    Map<String, double> dims = {};
    if (currentDepth == 0) {
      dims['length'] = 380;
      dims['angle'] = 75;
    } else if (currentDepth == 1) {
      dims['length'] = 160;
      dims['angle'] = 75;
    } else if (currentDepth == 2) {
      dims['length'] = 100;
      dims['angle'] = 55;
    } else if (currentDepth == 3) {
      dims['length'] = 80;
      dims['angle'] = 35;
    } else if (currentDepth == 4) {
      dims['length'] = 80;
      dims['angle'] = 30;
    }

    return dims;
  }

  void drawSpecificTree(Paint paint, Canvas canvas, List<String> ids) {
    for (int i = 0; i < nodes.length; i++) {
      Node nd = nodes[i];

      //get branches of nodes
      Map<String, dynamic> nodeBranches = branches[nd.id];
      Branch zero = nodeBranches['0'];
      Branch one = nodeBranches['1'];
      // construct offset of node branches

      Offset startPointZero = Offset(zero.startPoint.x, zero.startPoint.y);
      Offset endPointZero = Offset(zero.endPoint.x, zero.endPoint.y);

      Offset startPointOne = Offset(one.startPoint.x, one.startPoint.y);
      Offset endPointOne = Offset(one.endPoint.x, one.endPoint.y);
      if (nodes[i].depth != networkSize) {
        canvas.drawLine(startPointZero, endPointZero, paint);
        paintText('0', canvas, startPointZero, endPointZero);
        canvas.drawLine(startPointOne, endPointOne, paint);
        paintText('1', canvas, startPointOne, endPointOne);

        continue;
      }

      // laptop svg at leaf node points
      Paint laptopPaint = Paint()
        ..color = nd.id == "0" * networkSize
            ? const Color.fromARGB(255, 54, 168, 35)
            : (ids.contains(nd.id)
                ? const Color.fromARGB(255, 84, 178, 232)
                : const Color.fromARGB(225, 86, 86, 86))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
      drawLeafs(laptopPaint, canvas, startPointZero);
    }
  }

  void drawTree(Paint paint, Canvas canvas, List<String> ids) {
    for (int i = 0; i < nodes.length; i++) {
      Node nd = nodes[i];

      //get branches of nodes
      Map<String, dynamic> nodeBranches = branches[nd.id];
      Branch zero = nodeBranches['0'];
      Branch one = nodeBranches['1'];
      // construct offset of node branches

      Offset startPointZero = Offset(zero.startPoint.x, zero.startPoint.y);
      Offset endPointZero = Offset(zero.endPoint.x, zero.endPoint.y);

      Offset startPointOne = Offset(one.startPoint.x, one.startPoint.y);
      Offset endPointOne = Offset(one.endPoint.x, one.endPoint.y);
      if (nodes[i].depth != networkSize) {
        canvas.drawLine(startPointZero, endPointZero, paint);
        paintText('0', canvas, startPointZero, endPointZero);
        canvas.drawLine(startPointOne, endPointOne, paint);
        paintText('1', canvas, startPointOne, endPointOne);

        continue;
      }

      // laptop svg at leaf node points
      Paint laptopPaint = Paint()
        ..color = ids.contains(nd.id)
            ? const Color.fromARGB(255, 84, 178, 232)
            : const Color.fromARGB(225, 86, 86, 86)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1;
      drawLeafs(laptopPaint, canvas, startPointZero);
    }
  }

  void drawLeafs(Paint paint, Canvas canvas, Offset nd) {
    //calc paths
    /* canvas.save();
    canvas.translate(nd.dx - 20, nd.dy); //where to start drawing svg
    canvas.scale(1 / 12); //scale svg to desired size
    canvas.translate(0, 0); //svg dx dy
    //draw path
    canvas.drawPath(pathToDraw, paint);
    canvas.restore(); */

    canvas.drawCircle(Offset(nd.dx, nd.dy + 12), 5, paint);
  }

  void paintText(String txt, Canvas canvas, Offset start, Offset end) {
    final textSpan = TextSpan(
        text: txt,
        style: const TextStyle(
            color: Colors.white, fontFamily: 'RobotoMono', fontSize: 12));

    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    textPainter.layout(minWidth: 0, maxWidth: 50);

    vmath.Vector2 midPoint =
        vmath.Vector2((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    //double mag = resultV.length;
    double xCenter = midPoint.x + 10;
    double yCenter = midPoint.y - 15;

    if (txt == '0') {
      xCenter = midPoint.x - 20;
      yCenter = midPoint.y - 15;
    }
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  void setAnimationPath() {
    if (animPaths.isNotEmpty) {
      return;
    }

    //based on operation coordinate response request objects
    // and create animation paths for each response, request

    // request
    sourceToDest('0000', '1011');

    //response
    sourceToDest('1011', '0000');
  }

  void sourceToDest(String src, String dest) {
    //get 0000 node and set as starting node
    Node requestSrc = nodes.firstWhere((element) => element.id == src);
    Node requestDest = nodes.firstWhere((element) => element.id == dest);
    //find common parent
    int closeNess = int.parse(requestSrc.id, radix: 2) ^
        int.parse(requestDest.id, radix: 2);
    String xor = closeNess.toRadixString(2);
    if (xor.length < networkSize) {
      xor = ('0' * (networkSize - xor.length)) + xor;
    }
    print("Calc");
    print("Src: ${requestSrc.id}");
    print("Dest: ${requestDest.id}");
    print("Xor: $xor");
    int common = (xor.indexOf('1'));

    print(
        "Common parent: ${common == 0 ? "root" : requestSrc.id.substring(0, common)}");
    int cPLoop = (requestSrc.id.length - common).toInt();
    /*  print("Loop for $cPLoop times");
    print("Done calc"); */
    // start to common
    String start = requestSrc.id;
    for (int i = 0; i < cPLoop; i++) {
      String end = start.substring(0, start.length - 1);
      if (i == cPLoop - 1 && cPLoop == networkSize) {
        //if common node is root node
        end = "root";
      }
      final startBranch = branches[start]["0"].startPoint;
      final endBranch = branches[end]["0"].startPoint;
      print("Start node - $start - point - ${startBranch}");
      print("End node - $end - point - ${endBranch}");

      animPaths.add({"from": startBranch, "to": endBranch});
      start = end;
    }
    //print(animPaths);

    //common to end loop
    print("");
    print("Narrowing down");
    for (int i = cPLoop; i > 0; i--) {
      String end = start + requestDest.id[requestDest.id.length - i];
      if (i == networkSize) {
        //if common node is root node
        end = requestDest.id[0];
      }
      final startBranch = branches[start]["0"].startPoint;
      final endBranch = branches[end]["0"].startPoint;
      print("Start node - $start - point - ${startBranch}");
      print("End node - $end - point - ${endBranch}");
      animPaths.add({"from": startBranch, "to": endBranch});
      start = end;
    }
    //print(animPaths);
    currentPath = 0;
    vmath.Vector2 st = animPaths[0]["from"] as vmath.Vector2;
    animPackets.add(APacket(pos: vmath.Vector2(st.x, st.y), paths: animPaths));
    // set anim packets in array
  }

  void clearAnimPaths() {
    animPaths.clear();
  }
}
