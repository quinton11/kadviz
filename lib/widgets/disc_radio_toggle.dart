import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/widgets/radio_toggle.dart';
import 'package:provider/provider.dart';

class DiscRadioToggle extends StatefulWidget {
  final double height;
  final double width;
  const DiscRadioToggle({super.key, required this.height, required this.width});

  @override
  State<DiscRadioToggle> createState() => _DiscRadioToggleState();
}

class _DiscRadioToggleState extends State<DiscRadioToggle> {
  String _selected = 'Default';

  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    _selected = networkProvider.selectedOperation;
    return SizedBox(
      height: widget.height - 100,
      width: widget.width - 60,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RadioToggle(
                  groupValue: _selected,
                  value: networkProvider.operations[0],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    setState(() {
                      _selected = value.toString();
                      networkProvider.selectedOperation = _selected;
                      networkProvider.animate = false;
                    });
                  }),
              RadioToggle(
                  groupValue: _selected,
                  value: networkProvider.operations[1],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    setState(() {
                      _selected = value.toString();
                      networkProvider.selectedOperation = _selected;
                      networkProvider.animate = false;
                    });
                  }),
              RadioToggle(
                  groupValue: _selected,
                  value: networkProvider.operations[2],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    setState(() {
                      _selected = value.toString();
                      networkProvider.selectedOperation = _selected;
                      networkProvider.animate = false;
                    });
                  }),
              RadioToggle(
                  groupValue: _selected,
                  value: networkProvider.operations[3],
                  animate: networkProvider.animate,
                  triggerChange: (value) {
                    setState(() {
                      _selected = value.toString();
                      networkProvider.selectedOperation = _selected;
                      networkProvider.animate = false;
                    });
                  })
            ],
          ),
        ),
      ),
    );
  }
}
