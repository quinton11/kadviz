import 'dart:ui';

import 'package:flutter/material.dart';

class TopDrawer extends StatefulWidget {
  final double height;
  final double width;
  const TopDrawer({super.key, required this.height, required this.width});

  @override
  State<TopDrawer> createState() => _TopDrawerState();
}

class _TopDrawerState extends State<TopDrawer> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(seconds: 2),
      left: 0,
      top: 0,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(13, 6, 6, 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HeaderBar(widget: widget),
                StackDrawer(widget: widget)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StackDrawer extends StatelessWidget {
  const StackDrawer({
    super.key,
    required this.widget,
  });

  final TopDrawer widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height - 80,
      child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  height: widget.height - widget.height / 4,
                  width: widget.width - widget.width / 3,
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return const CallStackInfoBar();
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                          height: 20,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                          ));
                    },
                    itemCount: 10,
                    scrollDirection: Axis.vertical,
                  ),
                ),
              ),
              const CallStackCount(),
            ],
          )),
    );
  }
}

class CallStackInfoBar extends StatelessWidget {
  const CallStackInfoBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: Color.fromRGBO(32, 32, 32, 1),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(61, 57, 57, 1),
                    borderRadius: BorderRadius.all(Radius.circular(3))),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    "FIND-NODE",
                    style: TextStyle(
                        color: Color.fromARGB(255, 84, 178, 232),
                        fontFamily: 'RobotoMono',
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Text(
              "/{id}/PING",
              style: TextStyle(
                  color: Color.fromARGB(255, 84, 178, 232),
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SourceTargetCard(
              type: "Source",
              id: "0001",
            ),
            SourceTargetCard(
              type: "Target",
              id: "0011",
            ),
          ],
        ),
      ),
    );
  }
}

class SourceTargetCard extends StatelessWidget {
  const SourceTargetCard({
    super.key,
    required this.type,
    required this.id,
  });

  final String type;
  final String id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "$type:",
            style: const TextStyle(
                color: Color.fromARGB(255, 54, 168, 35),
                fontFamily: 'RobotoMono',
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          Text(
            id,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMono',
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CallStackCount extends StatelessWidget {
  const CallStackCount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      bottom: 5,
      left: 5,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          width: 100,
          child: Row(
            children: [
              Text(
                "Calls",
                style: TextStyle(
                    color: Color.fromARGB(255, 84, 178, 232),
                    fontFamily: 'RobotoMono',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
                width: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 3,
                      height: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 54, 168, 35),
                        ),
                      ),
                    ),
                    Text(
                      "3",
                      style: TextStyle(
                        color: Color.fromARGB(255, 54, 168, 35),
                        fontFamily: 'RobotoMono',
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.widget,
  });

  final TopDrawer widget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 50,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "RPC Call Stack",
              style: TextStyle(
                  color: Color.fromARGB(255, 84, 178, 232),
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              "FIND RESOURCE",
              style: TextStyle(
                  fontFamily: "RobotoMono",
                  color: Color.fromARGB(255, 54, 168, 35),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
