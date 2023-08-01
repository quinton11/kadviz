import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/widgets/slots.dart';
import 'package:provider/provider.dart';

class NetworkMap extends StatelessWidget {
  const NetworkMap({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int idx) {
        final host = networkProvider.hosts[idx];
        return Slot(
          id: host.id,
          index: idx,
          active: host.isActive && networkProvider.nodeSelected,
          triggerState: networkProvider.updateActiveHost,
          disableSelect: networkProvider.nodeSelect
        );
      },
      itemCount: networkProvider.hosts.length,
      scrollDirection: Axis.horizontal,
    );
  }
}
