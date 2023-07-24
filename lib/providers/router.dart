import 'dart:math';

//import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/branch.dart';
import 'package:kademlia2d/models/node.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter/material.dart';

class RouterProvider extends ChangeNotifier {
  List<Node> nodes = [];
  Map<String, Node> nodesId = {};
  Map<String, dynamic> branches = {};
  int networkSize = 4;
  double canvasWidth = 0;
  double canvasHeight = 0;

  RouterProvider();

  void setCanvas(double cW, double cH) {
    // to prevent rebuilding tree
    if (cW == canvasWidth && cH == canvasHeight) {
      print('Canvas sizes are the same');
      return;
    }

    if (nodes.isNotEmpty) {
      //rebuild branches not nodes
      print('Rebuilding branch positions');
    }
    canvasWidth = cW;
    canvasHeight = cH;
    setRoutingTree(networkSize);
  }

  void setRoutingTree(int networkBitSize) {
    //populate nodes and nodesId
    nodes.clear();

    buildTree(networkBitSize, 0, parentIds: []);
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
    Vector2 startingPoint = Vector2(canvasWidth / 2, 80); // if root node
    if (id != 'root') {
      String branchId = id[id.length - 1];
      startingPoint = (branches[parentId][branchId] as Branch).endPoint;
    }

    //calc end points
    Vector2 relative = Vector2(0, length);

    // 0
    double xrotatedzero = -relative.y * sin(radians(angle)) + startingPoint.x;
    double yrotatedzero = relative.y * cos(radians(angle)) + startingPoint.y;
    Vector2 endPointZero = Vector2(xrotatedzero, yrotatedzero);

    // 1
    double xrotatedone = -relative.y * sin(radians(symangle)) + startingPoint.x;
    double yrotatedone = relative.y * cos(radians(symangle)) + startingPoint.y;
    Vector2 endPointOne = Vector2(xrotatedone, yrotatedone);

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
      dims['angle'] = 80;
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

  void drawTree(Paint paint, Canvas canvas) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].depth != networkSize) {
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

        canvas.drawLine(startPointZero, endPointZero, paint);
        canvas.drawLine(startPointOne, endPointOne, paint);
        //draw node branches
      }
    }
  }
}
