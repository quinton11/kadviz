import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:kademlia2d/models/host.dart';
import 'package:binary_counter/binary_counter.dart';
import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/utils/constants.dart';
import 'package:kademlia2d/utils/enums.dart';

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
    swarmtSTORE,
    swarmRETRIEVE,
    swarmFINDNODE
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

    print("Network Provider:::toggleAnimate after done: $selectedOperation");
  }

  void singlePacketAnimate() {
    animate = true;
    animationOption = singlePacketAnimation;

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    print("Network Provider:::singlePacketAnimate");
  }

  void simulateOperation() {
    if (simulate) {
      return;
    }
    switch (selectedOperation) {
      case dhtPING:
        print(dhtPING);
        simulatePing();
      case dhtFINDNODE:
        print(dhtFINDNODE);
        simulateFindNode();
      case dhtFINDVALUE:
        print(dhtFINDVALUE);
        simulatePing();
      case dhtSTORE:
        print(dhtSTORE);
        simulatePing();
      case swarmFINDNODE:
        print(swarmFINDNODE);
        simulateSwarmFindNode();
      case swarmHIVE:
        print(swarmHIVE);
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
    print('Source: $srcId');
    print('Node to find $nodeToFind');
    print('Bucket Ids: $bucketIds');
    nodeInQuestion = nodeToFind;
    List<String> visitedNode = [];
    visitedNode.add(srcId);
    //run loop of checking for nodes till convergence
    List<dynamic> destNodes = [];
    // check for src's k nearest nodes
    (destNodes, _) = h.bucketCloseNess(nodeToFind);
    print('Dest Nodes: $destNodes');

    if (destNodes.contains(nodeToFind)) {
      destNodes = [nodeToFind];
    }

    bool converged = false;
    int currentHop = 0;

    while (!converged) {
      final contains =
          destNodes.where((element) => !visitedNode.contains(element)).toList();
      print('Nodes not visited $contains');
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
        print("*******************************************************");
        print("Source K-Buckets: ${srcHost.kBuckets}");
        print("Destination K-Buckets: ${destHost.kBuckets}");
        print("*******************************************************");

        animPaths[currentHop]!.add({"src": srcId, "dest": v});
        print('HOP: $currentHop src: $srcId, "dest": $v');
      }
      //animPaths.addAll(path);
      print('After hop: $animPaths');
      visitedNode.addAll([...destNodes]);
      visitedNode = visitedNode.toSet().toList();
      print('Visited Nodes: $visitedNode');
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
            print('');
            print('Dest Node: $v  close nodes: $nextNodes');
            print('');
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

    print('Anim Paths!!!');
    print(animPaths);
    print('Dest nodes and their responses!!!');
    print(destResponse);
  }

  void simulateSwarmFindNode() {
    // Generate src and node to find
    print("=================== SIMULATE SWARM FIND NODE ==================");
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
    print('Source: $srcId');
    print('Node to find $nodeToFind');
    print('Bucket Ids: $bucketIds');
    nodeInQuestion = nodeToFind;

    int currentHop = 0;
    List<String> visitedNodes = [];
    recursiveRequests(visitedNodes, srcId, nodeToFind, currentHop);

    // Since its swarm, calls are recursive

    /*
      Now suppose node A wants to find node E and node B,C and D are intermediate nodes
      between the path to D, To get to node D, A makes a request to B, B makes another request to
      C then C to D, when it gets to its intended destination, D creates a response to C, then C to B, then B to A
      Thus fulfilling the request response flow.

     */

    print(
        "=================== END OF SIMULATE SWARM FIND NODE ==================");
  }

  void recursiveRequests(List<String> visitedNodes, String srcId,
      String nodeToFind, int currentHop) {
    // get closest nodes to nodeTofind for srcId
    Host h = getHostFromId(srcId);
    List<dynamic> destNodes = [];
    if (srcId == nodeToFind) return;
    (destNodes, _) = h.bucketCloseNess(nodeToFind);

    if (destNodes.contains(nodeToFind)) {
      destNodes = [nodeToFind];
    }

    final contains =
        destNodes.where((element) => !visitedNodes.contains(element)).toList();
    if (contains.isEmpty) return;

    // If there are available nodes to be visited, i.e closest nodes are not in visitedNodes, then foreach node call the
    // recursiveRequest
    for (var nodeId in destNodes) {
      var srcHost = hosts.firstWhere((element) => element.id == srcId);
      var destHost = hosts.firstWhere((element) => element.id == nodeId);
      print("*******************************************************");
      print("Current Hop - $currentHop");
      print("Source: $srcId K-Buckets: ${srcHost.kBuckets}");
      print("Destination: $nodeId K-Buckets: ${destHost.kBuckets}");
      print("*******************************************************");
      if (animPaths[currentHop] == null) animPaths[currentHop] = [];
      animPaths[currentHop]!.add({"src": srcId, "dest": nodeId});
      visitedNodes.add(nodeId);
      if (visitedNodes.contains(nodeToFind)) continue;
      recursiveRequests([...visitedNodes], nodeId, nodeToFind, currentHop + 1);
      visitedNodes.clear();
    }
  }

  void simulateSwarmHive() {
    print("=================== SIMULATE SWARM HIVE ==================");
    // get src

    bool unique = false;
    String srcId = '';
    while (!unique) {
      srcId = generateRandomBinaryNumber(length: networkSize);
      if (_hostIds.contains(srcId)) {
        continue;
      }
      unique = true;
    }
    nodeInQuestion = srcId;
    int currentHop = 0;

    _hostIds.add(srcId);
    Host host = Host(id: srcId, isActive: false);
    hosts.add(host);

    var visitedNodes = [srcId];
    recursiveHiveCalls(srcId, bootNodeId, currentHop, visitedNodes);

    print("*******************************Host buckets after simulation:");
    print(host.kBuckets);

    hosts.sort((na, nb) => (na.id).compareTo(nb.id));
    if (_activeHost != '') populateActiveHostBucket();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    print("=================== END OF SIMULATE SWARM HIVE ==================");
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
      print('Node: $nodeId');
      if (nodeId == srcId) continue;
      if (src.populateBucket(nodeId)) continue;
      recursiveHiveCalls(srcId, nodeId, currentHop + 1, visitedNodes);
    }
  }

  /// Generates random nodes to populate network
  void populateHosts() {
    _hostIds = generateRandomNodes();

    //create boot Host
    Host bootHost = Host(id: bootNodeId, isActive: false);
    hosts.add(bootHost);

    for (var id in _hostIds) {
      if (id != bootNodeId) {
        Host host = Host(id: id, isActive: false);
        hosts.add(host);

        networkRequest(host, bootHost, RPCRequest.bootNode);
      }
    }

    //print("");
    //print("=====================================================");

    print(bootNodeId);
    for (var h in hosts) {
      print('Id: ${h.id} - ${h.kBuckets}');
    }
    //print("=====================================================");

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
  set setNetworkSize(int netSize) {
    if (netSize == networkSize) {
      return;
    }

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
    while (!unique) {
      String id = generateRandomBinaryNumber(length: networkSize);
      if (_hostIds.contains(id)) {
        continue;
      }

      _hostIds.add(id);
      Host host = Host(id: id, isActive: false);
      hosts.add(host);
      Host bootHost = getHostFromId(bootNodeId);

      networkRequest(host, bootHost, RPCRequest.bootNode);
      print(host.kBuckets);
      unique = true;
    }
    hosts.sort((na, nb) => (na.id).compareTo(nb.id));
    if (_activeHost != '') populateActiveHostBucket();
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
      if (bootNodeId == '') {
        bootNodeId = id;
      }
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
        print('Boot Node request');
        bootNodeHandler(src, dest);
      default:
        print('Default case');
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
    print("==============================================");
    print('RPC request');
    resPacket = dest.handleRequest(
        RequestPacket(src: src.id, dest: dest.id, req: RPCRequest.bootNode));
    print('Close nodes: ${resPacket.data}');
    print("==============================================");
    print(resPacket.res.toString());

    // add bootnode to src kbuckets
    src.populateBucket(dest.id);

    //populate node with returned bucket
    for (var cn in resPacket.data) {
      //print('Populating bucket for node ${src.id} with $cn');
      if (src.populateBucket(cn)) continue;
      //print('Done populating bucket for node ${src.id} with $cn');
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
