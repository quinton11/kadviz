import 'package:flutter/material.dart';
import 'package:kademlia2d/widgets/slots.dart';

class NetworkMap extends StatefulWidget {
  final List<Map<String, bool>> items;
  const NetworkMap({super.key, required this.items});

  @override
  State<NetworkMap> createState() => _NetworkMapState();
}

class _NetworkMapState extends State<NetworkMap> {
  int _activeIndex = 0;
  void triggerState(int index) {
    setState(() {
      // setting previous host inactive
      final skey = widget.items[_activeIndex].keys.elementAt(0);
      widget.items[_activeIndex][skey] = false;
      _activeIndex = index;
      //setting current host active
      final nkey = widget.items[_activeIndex].keys.elementAt(0);
      widget.items[_activeIndex][nkey] = true;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int idx) {
        final skey = widget.items[idx].keys.elementAt(0);
        return Slot(
          id: skey,
          index: idx,
          active: widget.items[idx][skey]!,
          triggerState: triggerState,
        );
      },
      itemCount: widget.items.length,
      scrollDirection: Axis.horizontal,
    );
  }
}
