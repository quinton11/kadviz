import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/host.dart';
import 'package:binary_counter/binary_counter.dart';

class NetworkProvider with ChangeNotifier {
  late List<Host> hosts;
  late List<String> _hostIds;
  late int _activeIndex = 0;
  late bool _nodeSelected = false;
  late int networkSize = 4;
  late String _activeHost = '';
  NetworkProvider() {
    populateHosts();
  }

  /// Generates random nodes to populate network
  void populateHosts() {
    _hostIds = generateRandomNodes();

    hosts = _hostIds.map((id) {
      return Host(id: id, isActive: false);
    }).toList();
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
    notifyListeners();
  }

  /// sets nodeSelected to false to control if a node has been selected
  void nodeSelect(bool inactive) {
    _nodeSelected = inactive;
    notifyListeners();
  }

  bool get nodeSelected => _nodeSelected;

  String get activeHost => _activeHost;

  List<String> get hostIds => _hostIds;

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
      print('Network full');
      return;
    }

    bool unique = false;
    while (!unique) {
      String id = generateRandomBinaryNumber(length: networkSize);
      if (_hostIds.contains(id)) {
        continue;
      }

      _hostIds.add(id);
      hosts.add(Host(id: id, isActive: false));
      unique = true;
    }
    hosts.sort((na, nb) => (na.id).compareTo(nb.id));
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
    }

    hostIds.sort();
    return hostIds;
  }
}
