import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/branch.dart';
import 'package:kademlia2d/models/node.dart';
import 'package:vector_math/vector_math.dart';

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
    String parentId = node.parentId;
    String branchId = id[id.length - 1];
    Vector2 startingPoint = (branches[parentId][branchId] as Branch).endPoint;
    double angle = branchId == '0' ? 75 : 285;

    /* 

      At different depths create branches with decreasing
      length and narrower angles between them

      calculate and pass to node
      
       */

    //calc end points
    Vector2 relative = Vector2(0, 100);

    // 0
    double xrotatedzero = -relative.y * sin(radians(75)) + startingPoint.x;
    double yrotatedzero = relative.y * cos(radians(angle)) + startingPoint.y;
    Vector2 endPointZero = Vector2(xrotatedzero, yrotatedzero);

    // 1
    double xrotatedone = -relative.y * sin(radians(285)) + startingPoint.x;
    double yrotatedone = relative.y * cos(radians(285)) + startingPoint.y;
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
    currentDepth += 1;
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
      addBranch({
        "root": {
          "0": Branch(startPoint: Vector2(0, 0), endPoint: Vector2(0, 0)),
          "1": Branch(startPoint: Vector2(0, 0), endPoint: Vector2(0, 0))
        }
      });
    }

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

    print("Depth $currentDepth - ${[...nodes]}");

    if (currentDepth != maxDepth) {
      buildTree(maxDepth, currentDepth, parentIds: parentIdsPass);
    }
  }
}
