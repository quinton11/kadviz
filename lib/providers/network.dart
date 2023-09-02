import 'dart:math';

import 'package:flutter/foundation.dart';
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
  late List<String> operations = const [
    swarmBOOTNODE,
    swarmtSTORE,
    swarmRETRIEVE,
    swarmPING
  ];
  late List<String> dhtOperations = const [
    dhtPING,
    dhtFINDNODE,
    dhtFINDVALUE,
    dhtSTORE
  ];
  late List<String> formats = const ['DHT (ipfs)', 'DISC (swarm)'];
  late String selectedOperation = 'Default';
  late String selectedFormat = formats[0];
  NetworkProvider() {
    populateHosts();
  }

  void toggleAnimate() {
    animate = !animate;
    notifyListeners();
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
    }
    simulate = true;
  }

  void setOperation(String op) {
    selectedOperation = op;
    simulate = false;
    animPaths.clear();
  }

  void simulatePing() {
    final random = Random();
    String srcId = _hostIds[random.nextInt(_hostIds.length)];
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
  }

  void simulateFindNode() {
    // get src
    final random = Random();
    String srcId = _hostIds[random.nextInt(_hostIds.length)];
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
    print('Node to findL $nodeToFind');
    print('Bucket Ids: $bucketIds');
    List<String> visitedNode = [];
    visitedNode.add(srcId);
    //run loop of checking for nodes till convergence
    List<dynamic> destNodes = [];
    // check for src's k nearest nodes
    (destNodes, _) = h.bucketCloseNess(nodeToFind);
    print('Dest Nodes: $destNodes');

    bool converged = false;
    int currentHop = 0;

    while (!converged) {
      final contains =
          destNodes.where((element) => !visitedNode.contains(element)).toList();
      print('Nodes not visited $contains');
      if (contains.isEmpty) {
        //converged, return list of hops
        converged = true;
        break;
      }

      animPaths[currentHop] = [];
      //add to anim object
      for (final v in contains) {
        //path[currentHop].add({"src": srcId, "dest": v});
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
      if (currentHop != 0) {
        final closeNodes = [];
        List<dynamic> nextNodes = [];
        for (var v in destNodes) {
          Host dst = getHostFromId(v);
          (nextNodes, _) = dst.bucketCloseNess(nodeToFind);
          print('');
          print('Dest Node: $v  close nodes: $nextNodes');
          print('');
          closeNodes.addAll(nextNodes);
        }
        destNodes = closeNodes.toSet().toList();
      }
    }

    print('Anim Paths!!!');
    print(animPaths);
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
