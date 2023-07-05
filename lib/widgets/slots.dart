import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:hovering/hovering.dart';

class Slot extends StatelessWidget {
  final int index;
  final String id;
  final bool active;
  final Function triggerState;
  const Slot(
      {super.key,
      required this.index,
      required this.id,
      required this.active,
      required this.triggerState});

  @override
  Widget build(BuildContext context) {
    const double containerWidth = 70;
    const svgPath = "assets/svg/laptop-kz.svg";
    return Container(
      width: containerWidth,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            id,
            style: TextStyle(
              fontFamily: "RobotoMono",
              color: active
                  ? const Color.fromARGB(255, 54, 168, 35)
                  : const Color.fromARGB(225, 125, 125, 125),
            ),
          ),
          const SizedBox(
            height: 15,
            width: containerWidth,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 5,
                  left: 0,
                  width: containerWidth,
                  height: 5,
                  child: Divider(
                    height: 5,
                    thickness: 2,
                    color: Color.fromARGB(255, 54, 168, 35),
                  ),
                ),
                Positioned(
                  top: 2.5,
                  left: containerWidth / 2,
                  width: 5,
                  height: 10,
                  child: VerticalDivider(
                    width: 5,
                    thickness: 2,
                    color: Color.fromARGB(255, 54, 168, 35),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$index",
            style: const TextStyle(
                fontFamily: "RobotoMono",
                color: Color.fromARGB(255, 54, 168, 35)),
          ),
          GestureDetector(
            onTap: () {
              triggerState(index);
            },
            child: HoverWidget(
              onHover: (event) {},
              hoverChild: SvgPicture.asset(
                svgPath,
                colorFilter: ColorFilter.mode(
                    active
                        ? const Color.fromARGB(255, 54, 168, 35)
                        : const Color.fromARGB(255, 84, 178, 232),
                    BlendMode.srcIn),
                height: 40,
                width: 40,
              ),
              child: SvgPicture.asset(
                svgPath,
                colorFilter: ColorFilter.mode(
                    active
                        ? const Color.fromARGB(255, 54, 168, 35)
                        : const Color.fromARGB(225, 125, 125, 125),
                    BlendMode.srcIn),
                height: 40,
                width: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
