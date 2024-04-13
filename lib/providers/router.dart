import 'dart:math';

//import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kademlia2d/models/branch.dart';
import 'package:kademlia2d/models/node.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/utils/constants.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class RouterProvider extends ChangeNotifier {
  List<Node> nodes = [];
  List<Map<String, vmath.Vector2>> animPaths = [];
  List<APacket> animPackets = [];
  int currentPath = 0;
  Map<String, Node> nodesId = {};
  Map<int, List<bool>> packetControl = {};
  Map<String, dynamic> branches = {};
  Map<int, List<Map<String, String>>> stackPaths = {};
  int currentHop = 0;
  int networkSize = 4;
  double canvasWidth = 0;
  double canvasHeight = 0;
  bool routerSet = false;
  String currentOperation = '';
  int currentPacket = 0;
  Path pathToDraw = parseSvgPathData(
      'M455.5,348H447V99.5c0-17.369-14.131-31.5-31.5-31.5h-368C30.131,68,16,82.131,16,99.5V348H7.5c-4.142,0-7.5,3.358-7.5,7.5v16C0,384.458,10.542,395,23.5,395h416c12.958,0,23.5-10.542,23.5-23.5v-16C463,351.358,459.642,348,455.5,348z M31,99.5C31,90.402,38.402,83,47.5,83h368c9.098,0,16.5,7.402,16.5,16.5V348H31V99.5zM448,371.5c0,4.687-3.813,8.5-8.5,8.5h-416c-4.687,0-8.5-3.813-8.5-8.5V363h169.025c-0.011,0.166-0.025,0.331-0.025,0.5c0,4.142,3.358,7.5,7.5,7.5h80c4.142,0,7.5-3.358,7.5-7.5c0-0.169-0.014-0.334-0.025-0.5H448V371.5z');

  RouterProvider();

  void setCanvas(double cW, double cH, {int netSize = 4}) {
    pathToDraw.addPath(
        parseSvgPathData(
            'M407.5,100h-352c-4.142,0-7.5,3.358-7.5,7.5v216c0,4.142,3.358,7.5,7.5,7.5h352c4.142,0,7.5-3.358,7.5-7.5v-216C415,103.358,411.642,100,407.5,100z M400,316H63V115h337V316z'),
        const Offset(0, 0));

    // to prevent rebuilding tree
    /* if (routerSet) {
      //print('Canvas sizes are the same');
      return;
    } */
    /* if (cW == canvasWidth && cH == canvasHeight) {
      print('Canvas sizes are the same');
      return;
    } */

    canvasWidth = cW;
    canvasHeight = cH;
    networkSize = netSize;
    setRoutingTree(netSize);
  }

  void setActivePacket(String src, String dest, int hop) {
    var idx = getAnimPacketIndex(src, dest, hop);
    currentPacket = idx;
  }

  APacket getCurrentPacket() {
    return animPackets[currentPacket];
  }

  void setCurrentOperation(String op) {
    /*  print(op);
    print('here');
    print(currentOperation); */
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

  void nextHop() {
    currentHop += 1;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
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
        vmath.Vector2(canvasWidth / 2, 150); // if root node
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

    if (maxDepth == 4) {
      return get4BitLengthAndDegree(currentDepth);
    } else if (maxDepth == 5) {
      return get5BitLengthAndDegree(currentDepth);
    }

    return dims;
  }

  Map<String, double> get4BitLengthAndDegree(int currentDepth) {
    Map<String, double> dims = {};
    if (currentDepth == 0) {
      dims['length'] = 380;
      dims['angle'] = 80;
    } else if (currentDepth == 1) {
      dims['length'] = 160;
      dims['angle'] = 75;
    } else if (currentDepth == 2) {
      dims['length'] = 100;
      dims['angle'] = 55;
    } else if (currentDepth == 3) {
      dims['length'] = 60;
      dims['angle'] = 35;
    } else if (currentDepth == 4) {
      dims['length'] = 80;
      dims['angle'] = 30;
    }
    return dims;
  }

  Map<String, double> get5BitLengthAndDegree(int currentDepth) {
    Map<String, double> dims = {};
    if (currentDepth == 0) {
      dims['length'] = 450;
      dims['angle'] = 80;
    } else if (currentDepth == 1) {
      dims['length'] = 220;
      dims['angle'] = 82;
    } else if (currentDepth == 2) {
      dims['length'] = 110;
      dims['angle'] = 75;
    } else if (currentDepth == 3) {
      dims['length'] = 55;
      dims['angle'] = 65;
    } else if (currentDepth == 4) {
      dims['length'] = 40;
      dims['angle'] = 40;
    } else if (currentDepth == 5) {
      dims['length'] = 20;
      dims['angle'] = 10;
    }
    return dims;
  }

  void drawSpecificTree(
      Paint paint, Canvas canvas, List<String> ids, String activeHost) {
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
      drawLeafs(laptopPaint, canvas, startPointZero, nd.id,
          isSpecific: true, activeHost: activeHost);
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
      drawLeafs(laptopPaint, canvas, startPointZero, nd.id);
    }
  }

  void drawLeafs(Paint paint, Canvas canvas, Offset nd, String id,
      {bool isSpecific = false, String activeHost = ''}) {
    canvas.drawCircle(Offset(nd.dx, nd.dy + 12), 5, paint);
    // Write ids of nodes under the leaf nodes
    if (isSpecific) {
      // if specific, convert id to original and write
      int reverseCloseNess =
          int.parse(id, radix: 2) ^ int.parse(activeHost, radix: 2);
      String reverseXor = reverseCloseNess.toRadixString(2);
      id = reverseXor;
      if (reverseXor.length < networkSize) {
        id = ('0' * (networkSize - reverseXor.length)) + reverseXor;
      }
    }
    paintId(id, canvas, Offset(nd.dx - 15, nd.dy + 30), paint.color);
  }

  void paintId(String id, Canvas canvas, Offset start, Color color) {
    final textSpan = TextSpan(
        text: id,
        style: TextStyle(color: color, fontFamily: 'RobotoMono', fontSize: 12));

    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    textPainter.layout(minWidth: 0, maxWidth: 50);
    textPainter.paint(canvas, start);
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

// add the respomse to the paths object
// then pass it to the packet, along with added meta information
  void setAnimationPath(Map<int, List<Map<String, String>>> paths,
      String operationMode, String operation) {
    // use switch case to check if dht or swarm, then run respective animation
    //algorithms
    if (animPackets.isNotEmpty) {
      return;
    }
    switch (operationMode) {
      case (dhtFormat):
        dhtSetAnimationPath(paths);
      case (swarmFormat):
        if (operation == swarmHIVE) {
          dhtSetAnimationPath(paths);
          break;
        }
        swarmSetAnimationPath(paths);
    }

    print("PACKET CONTROL $packetControl");
  }

  void dhtSetAnimationPath(Map<int, List<Map<String, String>>> paths) {
    print('DHT Animating..');
    print(paths);
    stackPaths = paths;

    //get keys in map
    //loop through keys
    // for each key get the length of the paths
    //initialize a false done array for each hop with length equal to the length src dest pairs
    final keys = paths.keys.toList();
    for (var k in keys) {
      final path = paths[k] as List<Map<String, String>>;
      List<bool> done = List.filled(path.length, false);
      packetControl.addAll({k: done});
      int doneid = 0;

      //for each path create a sourceToDest to simulate a request response
      //src to destination
      for (var p in path) {
        //request
        sourceToDest(p["src"] as String, p["dest"] as String);

        //response
        sourceToDest(p["dest"] as String, p["src"] as String);

        vmath.Vector2 st = animPaths[0]["from"] as vmath.Vector2;
        animPackets.add(APacket(
            pos: vmath.Vector2(st.x, st.y),
            paths: [...animPaths],
            hop: k,
            doneIdx: doneid,
            src: p["src"] as String,
            dest: p["dest"] as String,
            networkSize: networkSize));
        print(animPackets.length);
        doneid += 1;
        animPaths.clear();
      }
    }
  }

  void swarmSetAnimationPath(Map<int, List<Map<String, String>>> paths) {
    print('SWARM Animating..');
    print(paths);
    stackPaths = paths;

    //get keys in map
    //loop through keys
    // for each key get the length of the paths
    //initialize a false done array for each hop with length equal to the length src dest pairs
    final keys = paths.keys.toList();
    for (var k in keys) {
      final path = paths[k] as List<Map<String, String>>;
      List<bool> done = List.filled(path.length, false);
      packetControl.addAll({k: done});
      int doneid = 0;

      //for each path create a sourceToDest to simulate a request response
      //src to destination

      /* 
        What we can do is this,
        - In this, there are no "dest" to "src" responses
        - Responses are treated as request, hence we create packets for each request
        - So say we have 3 hops, since each response is treated as a request, in actual fact,
          we'll have 3*2 hops. So we   */
      for (var p in path) {
        //request
        sourceToDest(p["src"] as String, p["dest"] as String);

        vmath.Vector2 st = animPaths[0]["from"] as vmath.Vector2;
        animPackets.add(APacket(
            pos: vmath.Vector2(st.x, st.y),
            paths: [...animPaths],
            hop: k,
            doneIdx: doneid,
            src: p["src"] as String,
            dest: p["dest"] as String,
            networkSize: networkSize));
        print(animPackets.length);
        doneid += 1;
        animPaths.clear();
      }
    }

    // reversal or response
    final keyOrder = (keys.length * 2) - 1;
    for (int i = keys.length - 1; i >= 0; i--) {
      var k = keys[i];
      final path = paths[k] as List<Map<String, String>>;
      List<bool> done = List.filled(path.length, false);
      final hop = keyOrder - k;
      packetControl.addAll({hop: done});
      /* 3*2 = 6, since its counting down, and say the max key is 2 and min 0 we can do 
       - 6-1 - 2 == 5-2 =3
       - 6-1 - 1 == 5 -1 = 4
       - 6-1-0 == 5-0 = 5 */
      int doneId = 0;

      for (var p in path) {
        //response
        sourceToDest(p["dest"] as String, p["src"] as String);

        vmath.Vector2 st = animPaths[0]["from"] as vmath.Vector2;
        animPackets.add(APacket(
            pos: vmath.Vector2(st.x, st.y),
            paths: [...animPaths],
            hop: hop,
            doneIdx: doneId,
            src: p["dest"] as String,
            dest: p["src"] as String,
            networkSize: networkSize));
        print(animPackets.length);
        doneId += 1;
        animPaths.clear();
      }
    }
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
    /*  print("Calc");
    print("Src: ${requestSrc.id}");
    print("Dest: ${requestDest.id}");
    print("Xor: $xor"); */
    int common = (xor.indexOf('1'));

/*     print(
        "Common parent: ${common == 0 ? "root" : requestSrc.id.substring(0, common)}"); */
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
      /* print("Start node - $start - point - ${startBranch}");
      print("End node - $end - point - ${endBranch}"); */

      animPaths.add({"from": startBranch, "to": endBranch});
      start = end;
    }
    //print(animPaths);

    //common to end loop
    /* print("");
    print("Narrowing down"); */
    for (int i = cPLoop; i > 0; i--) {
      String end = start + requestDest.id[requestDest.id.length - i];
      if (i == networkSize) {
        //if common node is root node
        end = requestDest.id[0];
      }
      final startBranch = branches[start]["0"].startPoint;
      final endBranch = branches[end]["0"].startPoint;
      /* print("Start node - $start - point - ${startBranch}");
      print("End node - $end - point - ${endBranch}"); */
      animPaths.add({"from": startBranch, "to": endBranch});
      start = end;
    }
    currentPath = 0;
    // set anim packets in array
  }

  bool checkPacketControlIsDone() {
    //print("Checking if animation is done");
    //print(packetControl);
    for (var key in packetControl.keys) {
      for (var value in packetControl[key]!) {
        if (!value) {
          return false;
        }
      }
    }
    print("Done with animation");

    return true;
  }

  void clearAnimPaths() {
    animPaths.clear();
    animPackets.clear();
    packetControl.clear();
    stackPaths.clear();
    currentHop = 0;
  }

  int getAnimPacketIndex(String src, String dest, int hop) {
    return animPackets.indexOf(animPackets.firstWhere(
        (pkt) => pkt.src == src && pkt.dest == dest && pkt.hop == hop));
  }

  void resetPacket() {
    animPackets[currentPacket].resetPacket();
    currentHop = animPackets[currentPacket].hop;
  }
}
