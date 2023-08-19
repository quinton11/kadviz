import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/widgets/dht_radio_toggle.dart';
import 'package:kademlia2d/widgets/disc_radio_toggle.dart';
import 'package:kademlia2d/widgets/router_format_toggle.dart';
import 'package:kademlia2d/widgets/toggle_animate.dart';
import 'package:provider/provider.dart';

class RightDrawer extends StatefulWidget {
  final double height;
  final double width;

  const RightDrawer({super.key, required this.height, required this.width});

  @override
  State<RightDrawer> createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  String _selected = 'Default';
  @override
  Widget build(BuildContext context) {
    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    _selected = networkProvider.selectedFormat;
    return Positioned(
      right: 0,
      top: 0,
      child: ClipRect(
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                  color: Color.fromRGBO(13, 6, 6, 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: widget.height - 30,
                  width: widget.width - 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Select Operation - ${_selected}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 84, 178, 232),
                          fontFamily: "RobotoMono",
                        ),
                      ),
                      _selected == networkProvider.formats[1]
                          ? DiscRadioToggle(
                              height: widget.height, width: widget.width)
                          : DhtRadioToggle(
                              height: widget.height, width: widget.width),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ToggleAnimate(
                              animate: networkProvider.animate,
                              toggleAnimate: () {
                                setState(() {
                                  networkProvider.toggleAnimate();
                                });
                              }),
                          RouterFormatToggle(
                            triggerChange: (value) {
                              setState(() {
                                _selected = value.toString();
                                networkProvider.selectedFormat = _selected;
                                networkProvider.animate = false;
                              });
                            },
                            selected: _selected,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
