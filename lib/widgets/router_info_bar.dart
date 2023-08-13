import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:provider/provider.dart';

class RouterInfoBar extends StatelessWidget {
  const RouterInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final networkProvider = Provider.of<NetworkProvider>(context);
    final isSelected = networkProvider.nodeSelected;
    final animate = networkProvider.animate;
    const TextStyle textStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 12,
      color: Color.fromARGB(255, 84, 178, 232),
    );
    return SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Routing Table / ${(isSelected && !animate) ? 'K-bucket' : 'General'}',
                style: textStyle,
              ),
              (isSelected && !animate)
                  ? SizedBox(
                      height: 40,
                      width: 250,
                      child: DecoratedBox(
                        decoration:
                            const BoxDecoration(color: Colors.transparent),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                'Host Id#',
                                style: textStyle,
                              ),
                              SizedBox(
                                height: 40,
                                width: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(
                                      width: 3,
                                      height: 3,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              Color.fromARGB(255, 54, 168, 35),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      networkProvider.activeHost,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 54, 168, 35),
                                        fontFamily: 'RobotoMono',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ]),
                      ),
                    )
                  : const SizedBox(
                      height: 40,
                      width: 250,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
