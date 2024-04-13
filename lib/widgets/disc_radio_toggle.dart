import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/widgets/radio_toggle.dart';
import 'package:provider/provider.dart';

class DiscRadioToggle extends StatelessWidget {
  final double height;
  final double width;
  final String selectedOperation;
  final Function toggleState;
  const DiscRadioToggle(
      {super.key,
      required this.height,
      required this.width,
      required this.selectedOperation,
      required this.toggleState});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
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
                value: networkProvider.operations[0],
                animate: networkProvider.animate,
                triggerChange: (value) {
                  toggleState(value);
                },
                isDisabled: networkProvider.networkFull(),
              ),
              RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.operations[1],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }),
              /*          RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.operations[2],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    toggleState(value);
                  }),
              RadioToggle(
                  groupValue: selectedOperation,
                  value: networkProvider.operations[3],
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
