import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/branch.dart';
import 'package:kademlia2d/models/node.dart';
import 'package:vector_math/vector_math.dart';

class RouterProvider extends ChangeNotifier {
  List<Node> nodes = [];
  Map<String, Node> nodesId = {};
  int networkSize = 4;

  RouterProvider() {
    setRoutingTree(networkSize);
  }

  void setRoutingTree(int networkBitSize) {
    //populate nodes and nodesId
    nodes.clear();

    buildTree(networkBitSize, 0, parentIds: []);
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
          branches: {
            "0": Branch(
                startPoint: Vector2(0, 0), endPoint: Vector2(0, 0), angle: 120),
            "1": Branch(
                startPoint: Vector2(0, 0), endPoint: Vector2(0, 0), angle: 120),
            "deg": 120
          });
      nodes.add(root);
      parentIds.addAll(root.children);
    }

    // number of times loop should run
    int power = pow(2, currentDepth).toInt();
    for (int i = 0; i < power; i++) {
      String nodeId = parentIds[i];

      /* 

      At different depths create branches with decreasing
      length and narrower angles between them

      calculate and pass to node
      
       */
      Node node = Node(
          children: ["${nodeId}0", "${nodeId}1"],
          depth: currentDepth,
          parentId: currentDepth == 1
              ? "root"
              : nodeId.substring(0, nodeId.length - 1),
          id: nodeId,
          branches: {
            "0": Branch(
                startPoint: Vector2(0, 0), endPoint: Vector2(0, 0), angle: 120),
            "1": Branch(
                startPoint: Vector2(0, 0), endPoint: Vector2(0, 0), angle: 120),
            "deg": 120
          });

      //add nodes and next parent nodes for iteration
      nodes.addAll([node]);
      parentIdsPass.addAll([...node.children]);
    }

    print("Depth $currentDepth - ${[...nodes]}");

    if (currentDepth != maxDepth) {
      buildTree(maxDepth, currentDepth, parentIds: parentIdsPass);
    } /* else {
      for (int j = 0; j < nodes.length; j++) {
        print("Node at depth $currentDepth");
        print(
            "Node - ${nodes[j].id} .... children - '${nodes[j].children[0]}' , '${nodes[j].children[1]}' ");
        print("");
      }
    } */
  }
}
