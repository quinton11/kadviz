import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kademlia2d/models/host.dart';
import 'package:binary_counter/binary_counter.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/utils/constants.dart';
import 'package:kademlia2d/utils/enums.dart';
import 'package:logger/logger.dart';

class NetworkProvider with ChangeNotifier {
  late List<Host> hosts = [];
  late List<String> _hostIds;
  final List<String> _activeHostBucketIds = [];
  late int _activeIndex = 0;
  late bool _nodeSelected = false;
  late int networkSize = 4;
  late String _activeHost = '';
  late String bootNodeId = '';
  late bool animate = false;
  late bool simulate = false;
  late Map<int, List<Map<String, String>>> animPaths = {};
  late Map<int, List<Map<String, Map<String, bool>>>> destResponse = {};
  late List<String> operations = const [
    swarmHIVE,
    swarmFINDNODE,
    swarmSTORE,
    swarmRETRIEVE,
  ];
  late List<String> dhtOperations = const [
    dhtPING,
    dhtFINDNODE,
    dhtFINDVALUE,
    dhtSTORE
  ];
  late List<String> formats = const [dhtFormat, swarmFormat];
  late String selectedOperation = 'Default';
  late String selectedFormat = formats[0];
  late String animationOption = 'Default';
  late String nodeInQuestion = '';
  late bool isOperationActive = false;
  late String operationText = '';
  var logger = Logger(
    level: Level.debug,
    printer: PrettyPrinter(),
  );
  NetworkProvider() {
    populateHosts();
  }

  void toggleAnimate() {
    animate = !animate;
    if (animate) {
      animationOption = singleOperationAnimation;
    } else {
      animationOption = 'Default';
    }

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    logger.i("Network Provider:::toggleAnimate after done: $selectedOperation");
  }

  void singlePacketAnimate() {
    animate = true;
    animationOption = singlePacketAnimation;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    logger.i("Network Provider:::singlePacketAnimate");
  }

  void deactivateOperation() {
    isOperationActive = false;
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void activateOperation(bool active, String operationTxt) {
    isOperationActive = active;
    operationText = operationTxt;

    Future.delayed(const Duration(milliseconds: 900), () {
      deactivateOperation();
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  void simulateOperation() {
    if (simulate) {
      return;
    }
    switch (selectedOperation) {
      case dhtPING:
        logger.i(dhtPING);
        simulatePing();
      case dhtFINDNODE:
        logger.i(dhtFINDNODE);
        simulateFindNode();
      case dhtFINDVALUE:
        logger.i(dhtFINDVALUE);
        simulatePing();
      case dhtSTORE:
        logger.i(dhtSTORE);
        simulatePing();
      case swarmFINDNODE:
        logger.i(swarmFINDNODE);
        simulateSwarmFindNode();
      case swarmHIVE:
        logger.i(swarmHIVE);
        simulateSwarmHive();
    }
    simulate = true;
    animationOption = singleOperationAnimation;
  }

  void setOperation(String op) {
    selectedOperation = op;
    simulate = false;
    animPaths.clear();
    destResponse.clear();
  }

// add extra info to the animPaths
  void simulatePing() {
    final random = Random();
    String srcId =
        _nodeSelected ? _activeHost : _hostIds[random.nextInt(_hostIds.length)];
    String destId = '';
    bool unique = false;
    while (!unique) {
      destId = _hostIds[random.nextInt(_hostIds.length)];
      if (srcId == destId) {
        continue;
      }
      unique = true;
    }
    animPaths[0] = [];
    animPaths[0]!.add({"src": srcId, "dest": destId});
    nodeInQuestion = destId;
  }

  Map<String, bool> createResponseMap(List<String> listA, List<String> listB) {
    var resultMap = <String, bool>{};

    for (var strB in listB) {
      resultMap[strB] = listA.contains(strB);
    }

    return resultMap;
  }

//add extra info to the animPaths
  void simulateFindNode() {
    // get src
    final random = Random();
    String srcId =
        _nodeSelected ? _activeHost : _hostIds[random.nextInt(_hostIds.length)];
    String nodeToFind = '';
    bool unique = false;
    Host h = getHostFromId(srcId);
    List<String> bucketIds = h.getBucketIds();
    int count = 0;
    while (!unique) {
      String id = _hostIds[random.nextInt(_hostIds.length)];
      if (count > 6) {
        nodeToFind = id;
        break;
      }
      if (bucketIds.contains(id) || id == srcId) {
        count += 1;
        continue;
      }

      nodeToFind = id;
      unique = true;
    }
    // get node to find
    logger.i('Source: $srcId');
    logger.i('Node to find $nodeToFind');
    logger.i('Bucket Ids: $bucketIds');
    nodeInQuestion = nodeToFind;
    List<String> visitedNode = [];
    visitedNode.add(srcId);
    //run loop of checking for nodes till convergence
    List<dynamic> destNodes = [];
    // check for src's k nearest nodes
    (destNodes, _) = h.bucketCloseNess(nodeToFind);
    logger.i('Dest Nodes: $destNodes');

    if (destNodes.contains(nodeToFind)) {
      destNodes = [nodeToFind];
    }

    bool converged = false;
    int currentHop = 0;

    while (!converged) {
      final contains =
          destNodes.where((element) => !visitedNode.contains(element)).toList();
      logger.i('Nodes not visited $contains');
      if (visitedNode.contains(nodeToFind)) break;
      if (contains.isEmpty) {
        //converged, return list of hops
        converged = true;
        break;
      }

      animPaths[currentHop] = [];
      //add to anim object
      for (final v in contains) {
        //path[currentHop].add({"src": srcId, "dest": v});
        var srcHost = hosts.firstWhere((element) => element.id == srcId);
        var destHost = hosts.firstWhere((element) => element.id == v);
        logger.i("*******************************************************");
        logger.i("Source K-Buckets: ${srcHost.kBuckets}");
        logger.i("Destination K-Buckets: ${destHost.kBuckets}");
        logger.i("*******************************************************");

        animPaths[currentHop]!.add({"src": srcId, "dest": v});
        logger.i('HOP: $currentHop src: $srcId, "dest": $v');
      }
      //animPaths.addAll(path);
      logger.i('After hop: $animPaths');
      visitedNode.addAll([...destNodes]);
      visitedNode = visitedNode.toSet().toList();
      logger.i('Visited Nodes: $visitedNode');
      // set current hop
      currentHop += 1;
      // if not create current hop, add src and dest keys to current hop
      destResponse[currentHop - 1] = [];
      if (currentHop != 0) {
        final closeNodes = [];
        var nodeFound = false;
        List<dynamic> nextNodes = [];

        // if node is found, it should be the last request made
        if (destNodes.contains(nodeToFind)) {
          closeNodes.add(nodeToFind);
          nodeFound = true;
        }

        if (!nodeFound) {
          for (var v in destNodes) {
            Host dst = getHostFromId(v);
            (nextNodes, _) = dst.bucketCloseNess(nodeToFind);
            logger.i('');
            logger.i('Dest Node: $v  close nodes: $nextNodes');
            logger.i('');
            // Add response, which is nextNodes for request to destNode
            List<String> nextNodesConvert = List<String>.from(nextNodes);
            var responseMap = createResponseMap(visitedNode, nextNodesConvert);
            destResponse[currentHop - 1]!.add({v: responseMap});
            closeNodes.addAll(nextNodes);
          }
        }

        destNodes = closeNodes.toSet().toList();
      }
    }

    logger.i('Anim Paths!!!');
    logger.i(animPaths);
    logger.i('Dest nodes and their responses!!!');
    logger.i(destResponse);
  }

  void simulateSwarmFindNode() {
    // Generate src and node to find
    logger.i("=================== SIMULATE SWARM FIND NODE ==================");
    // get src
    final random = Random();
    String srcId =
        _nodeSelected ? _activeHost : _hostIds[random.nextInt(_hostIds.length)];
    String nodeToFind = '';
    bool unique = false;
    Host h = getHostFromId(srcId);
    List<String> bucketIds = h.getBucketIds();
    int count = 0;
    while (!unique) {
      String id = _hostIds[random.nextInt(_hostIds.length)];
      if (count > 6) {
        nodeToFind = id;
        break;
      }
      if (bucketIds.contains(id) || id == srcId) {
        count += 1;
        continue;
      }

      nodeToFind = id;
      unique = true;
    }
    // get node to find
    logger.i('Source: $srcId');
    logger.i('Node to find $nodeToFind');
    logger.i('Bucket Ids: $bucketIds');
    nodeInQuestion = nodeToFind;

    int currentHop = 0;
    //List<String> visitedNodes = [];
    List<String> distinctPaths = [];
    Map<String, List<String>> distinctPathsDestMap = {};
    recursiveRequestss(
        srcId, nodeToFind, currentHop, distinctPaths, distinctPathsDestMap, 0);

    // Since its swarm, calls are recursive

    /*
      Now suppose node A wants to find node E and node B,C and D are intermediate nodes
      between the path to D, To get to node D, A makes a request to B, B makes another request to
      C then C to D, when it gets to its intended destination, D creates a response to C, then C to B, then B to A
      Thus fulfilling the request response flow.

     */

    logger.i(
        "=================== END OF SIMULATE SWARM FIND NODE ==================");
  }

/* Distinct paths dest map is to keep track of each path in the recursive requests starting from the initial
hop which is 0. In subsequent hops, we check for the path the node making the request is in then we add that node
to the appropriate path array, then we check if the destNodes are in that array. Basically speaking, if you've made a request in that
path, you cannot make another request */
  void recursiveRequests(
      List<String> visitedNodes,
      String srcId,
      String nodeToFind,
      int currentHop,
      List<String> distinctPaths,
      Map<String, List<String>> distinctPathsDestMap,
      {int distinctPathIndex = 0}) {
    // get closest nodes to nodeTofind for srcId
    Host h = getHostFromId(srcId);
    List<dynamic> destNodes = [];
    if (srcId == nodeToFind) return;
    (destNodes, _) = h.bucketCloseNess(nodeToFind);

    if (destNodes.contains(nodeToFind)) {
      destNodes = [nodeToFind];
    }

    if (currentHop == 10) return;
    final contains =
        destNodes.where((element) => !visitedNodes.contains(element)).toList();
    if (contains.isEmpty) return;
    if (currentHop != 0) {
      distinctPathsDestMap[distinctPaths[distinctPathIndex]]!.add(srcId);
    }

    // If there are available nodes to be visited, i.e closest nodes are not in visitedNodes, then foreach node call the
    // recursiveRequest
    for (var nodeId in contains) {
      if (currentHop == 0) {
        distinctPathsDestMap[nodeId] = [];
        distinctPathsDestMap[nodeId]!.add(nodeId);
        distinctPaths.add(nodeId);
        distinctPathIndex = distinctPaths.length - 1;
      }
      var srcHost = hosts.firstWhere((element) => element.id == srcId);
      var destHost = hosts.firstWhere((element) => element.id == nodeId);
      logger.i("*******************************************************");
      logger.i("Current Hop - $currentHop");
      logger.i("Source: $srcId K-Buckets: ${srcHost.kBuckets}");
      logger.i("Destination: $nodeId K-Buckets: ${destHost.kBuckets}");
      logger.i("*******************************************************");
      if (animPaths[currentHop] == null) animPaths[currentHop] = [];
      animPaths[currentHop]!.add({"src": srcId, "dest": nodeId});
      visitedNodes.add(nodeId);
      if (visitedNodes.contains(nodeToFind)) continue;
      if (distinctPathsDestMap[distinctPaths[distinctPathIndex]]!
          .contains(nodeToFind)) continue;
      recursiveRequests(visitedNodes, nodeId, nodeToFind, currentHop + 1,
          distinctPaths, distinctPathsDestMap,
          distinctPathIndex: distinctPathIndex);
      visitedNodes.clear();
    }
  }

  void recursiveRequestss(
      String srcId,
      String nodeToFind,
      int currentHop,
      List<String> distinctPaths,
      Map<String, List<String>> distinctPathsVisitedNodes,
      int distinctPathIndex) {
    logger.i(
        "***************************************Recursive Requestss*************************************** :");
    logger.i(
        "currentHop: $currentHop srcId: $srcId nodeToFind: $nodeToFind distinctPaths: $distinctPaths distinctPathsVisitedNodes: $distinctPathsVisitedNodes distinctPathIndex: $distinctPathIndex");
    // get closest nodes to nodeTofind for srcId
    Host h = getHostFromId(srcId);
    List<dynamic> destNodes = [];
    if (srcId == nodeToFind) return;
    (destNodes, _) = h.bucketCloseNess(nodeToFind);
    List<String> visitedNodes = [];
    if (currentHop != 0) {
      visitedNodes =
          distinctPathsVisitedNodes[distinctPaths[distinctPathIndex]]!;
    }

    if (currentHop > 6) return;

    if (destNodes.contains(nodeToFind)) {
      destNodes = [nodeToFind];
    }

    final contains =
        destNodes.where((element) => !visitedNodes.contains(element)).toList();
    if (contains.isEmpty) return;

    // If there are available nodes to be visited, i.e closest nodes are not in visitedNodes, then foreach node call the
    // recursiveRequest
    for (var nodeId in contains) {
      if (currentHop == 0) {
        distinctPathsVisitedNodes[nodeId] = [];
        distinctPathsVisitedNodes[nodeId]!.add(nodeId);
        distinctPaths.add(nodeId);
        distinctPathIndex = distinctPaths.length - 1;
        logger.i("Distinct Paths: $distinctPaths");
        logger.i("Distinct Paths Visited Nodes: $distinctPathsVisitedNodes");
        logger.i("Distinct Path Index: $distinctPathIndex");
      }
      var srcHost = hosts.firstWhere((element) => element.id == srcId);
      var destHost = hosts.firstWhere((element) => element.id == nodeId);

      logger.i("*******************************************************");
      logger.i("Current Hop - $currentHop");
      logger.i("Source: $srcId K-Buckets: ${srcHost.kBuckets}");
      logger.i("Destination: $nodeId K-Buckets: ${destHost.kBuckets}");
      logger.i("*******************************************************");

      if (animPaths[currentHop] == null) animPaths[currentHop] = [];
      animPaths[currentHop]!.add({"src": srcId, "dest": nodeId});
      if (nodeId == nodeToFind) continue;
      distinctPathsVisitedNodes[distinctPaths[distinctPathIndex]]!.add(nodeId);
      recursiveRequestss(nodeId, nodeToFind, currentHop + 1, distinctPaths,
          distinctPathsVisitedNodes, distinctPathIndex);
    }
  }

  void simulateSwarmHive() {
    logger.i("=================== SIMULATE SWARM HIVE ==================");
    // get src

// if node is selected, use that node as the source
// look to ensure convergence in find node
    bool unique = false;
    String srcId = _nodeSelected ? _activeHost : '';
    reselectBootNode(srcId);
    if (srcId == '') {
      srcId = _hostIds[Random().nextInt(_hostIds.length)];
      while (!unique) {
        srcId = generateRandomBinaryNumber(length: networkSize);
        if (_hostIds.contains(srcId)) {
          continue;
        }
        unique = true;
      }
      nodeInQuestion = srcId;

      _hostIds.add(srcId);
      Host host = Host(id: srcId, isActive: false);
      hosts.add(host);
    }

    int currentHop = 0;

    var visitedNodes = [srcId];
    recursiveHiveCalls(srcId, bootNodeId, currentHop, visitedNodes);

    logger.i("*******************************Host buckets after simulation:");

    hosts.sort((na, nb) => (na.id).compareTo(nb.id));
    if (_activeHost != '') populateActiveHostBucket();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    logger
        .i("=================== END OF SIMULATE SWARM HIVE ==================");
  }

  void recursiveHiveCalls(
      String srcId, String destId, int currentHop, List<String> visitedNodes) {
    Host src = getHostFromId(srcId);
    Host dest = getHostFromId(destId);
    if (animPaths[currentHop] == null) animPaths[currentHop] = [];
    animPaths[currentHop]!.add({"src": srcId, "dest": destId});
    visitedNodes.add(destId);
    src.populateBucket(destId);

    var (nodeIds, _) = dest.bucketCloseNess(srcId);
    List<String> nextNodesConvert = List<String>.from(nodeIds);
    var responseMap = createResponseMap(visitedNodes, nextNodesConvert);
    if (destResponse[currentHop] == null) destResponse[currentHop] = [];
    destResponse[currentHop]!.add({destId: responseMap});
    for (var nodeId in nodeIds) {
      logger.i('Node: $nodeId');
      if (nodeId == srcId) continue;
      if (src.populateBucket(nodeId)) continue;
      recursiveHiveCalls(srcId, nodeId, currentHop + 1, visitedNodes);
    }
  }

  void simulateSwarmStore() {
    // This is just like swarm FIND NODE,
  }

  void reselectBootNode(String notNode) {
    bool unique = false;
    while (unique) {
      bootNodeId = _hostIds[Random().nextInt(_hostIds.length)];
      if (bootNodeId != notNode) {
        unique = true;
      }
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  /// Generates random nodes to populate network
  void populateHosts() {
    _hostIds = generateRandomNodes();
    reselectBootNode('');

    //create boot Host
    Host bootHost = Host(id: bootNodeId, isActive: false);
    hosts.add(bootHost);

    for (var id in _hostIds) {
      if (id != bootNodeId) {
        Host host = Host(id: id, isActive: false);
        hosts.add(host);
        bootHost.populateBucket(id);
      }
    }

    for (var id in _hostIds) {
      if (id != bootNodeId) {
        Host host = getHostFromId(id);
        networkRequest(host, bootHost, RPCRequest.bootNode);
      }
    }
    //logger.i("");
    //logger.i("=====================================================");

    logger.i(bootNodeId);
    for (var h in hosts) {
      logger.i('Id: ${h.id} - ${h.kBuckets}');
    }
    //logger.i("=====================================================");

    notifyListeners();
  }

  /// sets the 'active' status of the previous host to false
  /// and that of the currently selected host to true
  void updateActiveHost(int index) {
    //deactivate previous host
    int idx = hosts.indexWhere((element) => element.id == _activeHost);
    if (idx != -1) {
      hosts[idx].isActive = false;
    }
    _activeIndex = index;
    //activate current host
    hosts[_activeIndex].isActive = true;
    _activeHost = hosts[_activeIndex].id;
    _nodeSelected = true;
    populateActiveHostBucket();
    notifyListeners();
  }

  /// sets nodeSelected to false to control if a node has been selected
  void nodeSelect(bool inactive) {
    _nodeSelected = inactive;
    notifyListeners();
  }

  /// Populates the network's active host bucket list
  /// with ids from the active host's k-bucket
  /// from the perspective of the active host
  void populateActiveHostBucket() {
    _activeHostBucketIds.clear();

    int idx = hosts.indexWhere((element) => element.id == _activeHost);
    List<String> bucket = hosts[idx].getBucketIds();
    _activeHostBucketIds
        .add('0' * networkSize); //xor of active host itself is 0
    for (var i in bucket) {
      //xor id with ids
      int closeNess = int.parse(_activeHost, radix: 2) ^ int.parse(i, radix: 2);
      String xor = closeNess.toRadixString(2);
      if (xor.length < networkSize) {
        xor = ('0' * (networkSize - xor.length)) + xor;
      }
      _activeHostBucketIds.add(xor);
    }
  }

  bool get nodeSelected => _nodeSelected;

  String get activeHost => _activeHost;

  List<String> get hostIds => _hostIds;
  List<String> get activeHostBucketIds => _activeHostBucketIds;

  /// Update the size of the network, default 2^4
  void setNetworkSize(int netSize) {
    if (netSize == networkSize) {
      return;
    }
    _hostIds.clear();
    hosts.clear();

    networkSize = netSize;
    populateHosts();
  }

  bool networkFull() {
    return _hostIds.length == pow(2, networkSize).toInt();
  }

  /// Add a new node with a unique id
  void addNode() {
    int maxHosts = pow(2, networkSize).toInt();

    if (_hostIds.length == maxHosts) {
      // network full
      return;
    }

    bool unique = false;
    String id = '';
    while (!unique) {
      id = generateRandomBinaryNumber(length: networkSize);
      if (_hostIds.contains(id)) {
        continue;
      }

      _hostIds.add(id);
      Host host = Host(id: id, isActive: false);
      hosts.add(host);
      Host bootHost = getHostFromId(bootNodeId);

      networkRequest(host, bootHost, RPCRequest.bootNode);
      logger.i(host.kBuckets);
      unique = true;
    }
    hosts.sort((na, nb) => (na.id).compareTo(nb.id));
    if (_activeHost != '') populateActiveHostBucket();
    activateOperation(true, "Node added: $id");
    notifyListeners();
  }

  /// Generates random nodes at half the network size
  List<String> generateRandomNodes() {
    int number = pow(2, networkSize) ~/ 2;
    List<String> hostIds = [];
    for (int i = 0; i < number; i++) {
      String id = generateRandomBinaryNumber(length: networkSize);
      if (hostIds.contains(id)) {
        i--;
        continue;
      }
      hostIds.add(id);

      //set first node to bootnode
      bootNodeId = id;
    }

    hostIds.sort();
    return hostIds;
  }

  /// Take two node ids and a network request
  /// and simulate a request
  /// simulation Involves making iterative requests in the
  /// case of an ipfs network and
  /// recursive requests in the case of the swarm network
  /// so for bootnode task, take two hosts and make requests
  /// processing response and taking the respective action
  void networkRequest(Host src, Host dest, RPCRequest req) {
    switch (req) {
      case RPCRequest.bootNode:
        logger.i('Boot Node request');
        bootNodeHandler(src, dest);
      default:
        logger.i('Default case');
    }
  }

  /// Handles the bootnode request
  void bootNodeHandler(Host src, Host dest) {
    // for iterative, source remains constant
    RPCResponse res = RPCResponse.bootNode;
    ResponsePacket resPacket =
        ResponsePacket(src: src.id, dest: dest.id, res: res);

    // source makes iterative requests to dest response ids/address
    // based on response, either make request again or stop there
    logger.i("==============================================");
    logger.i('RPC request');
    resPacket = dest.handleRequest(
        RequestPacket(src: src.id, dest: dest.id, req: RPCRequest.bootNode));
    logger.i('Close nodes: ${resPacket.data}');
    logger.i("==============================================");
    logger.i(resPacket.res.toString());

    // add bootnode to src kbuckets
    src.populateBucket(dest.id);

    //populate node with returned bucket
    for (var cn in resPacket.data) {
      //logger.i('Populating bucket for node ${src.id} with $cn');
      if (src.populateBucket(cn)) continue;
      //logger.i('Done populating bucket for node ${src.id} with $cn');
      Host destP = getHostFromId(cn);
      bootNodeHandler(src, destP);
    }
  }

  /// Takes an id and returns a host object with a match
  Host getHostFromId(String id) {
    return hosts.firstWhere((element) => element.id == id);
  }

  int getHostIndex(String id) {
    return hosts.indexWhere((element) => element.id == id);
  }
}
