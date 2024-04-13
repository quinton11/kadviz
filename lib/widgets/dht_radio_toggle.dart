import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/widgets/radio_toggle.dart';
import 'package:provider/provider.dart';

class DhtRadioToggle extends StatelessWidget {
  final double height;
  final double width;
  final String selectedOperation;
  final Function toggleState;
  const DhtRadioToggle(
      {super.key,
      required this.height,
      required this.width,
      required this.selectedOperation,
      required this.toggleState});

  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    return SizedBox(
      height: height - 100,
      width: width - 60,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.dhtOperations[0],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }),
              RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.dhtOperations[1],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }),
/*               RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.dhtOperations[2],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }),
              RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.dhtOperations[3],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }) */
            ],
          ),
        ),
      ),
    );
  }
}
