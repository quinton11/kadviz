import 'package:flutter/foundation.dart';
import 'package:kademlia2d/models/host.dart';

class NetworkProvider with ChangeNotifier {
  late List<Host> hosts;
  late int _activeIndex = 0;
  NetworkProvider() {
    populateHosts();
  }

  void populateHosts() {
    final List<Map<String, bool>> items = [
      {"0000": false},
      {"0001": false},
      {"0010": false},
      {"0011": false},
      {"0100": false},
      {"0101": false},
      {"0110": false},
      {"0111": false},
      {"1000": false},
      {"1001": false},
      {"1010": false},
      {"1011": false},
      {"1100": false},
      {"1101": false},
      {"1110": false},
      {"1111": false},
    ];
    for (int i = 0; i <= items.length; i++) {}

    hosts = items.map((e) {
      final key = e.keys.elementAt(0);
      return Host(id: key, isActive: e[key]!);
    }).toList();
    notifyListeners();
  }

  void updateActiveHost(int index) {
    //deactivate previous host
    hosts[_activeIndex].isActive = false;
    _activeIndex = index;
    //activate current host
    hosts[_activeIndex].isActive = true;
    notifyListeners();
  }
}
