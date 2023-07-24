import 'package:flutter/material.dart';

class RouterInfoBar extends StatelessWidget {
  const RouterInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      fontFamily: 'RobotoMono',
      fontSize: 12,
      color: Color.fromARGB(255, 84, 178, 232),
    );
    return const SizedBox(
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Routing Table / K-bucket',
                style: textStyle,
              ),
              SizedBox(
                height: 40,
                width: 250,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Host Id#',
                          style: textStyle,
                        ),
                        SizedBox(
                          height: 40,
                          width: 80,
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
                                '0101',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 54, 168, 35),
                                  fontFamily: 'RobotoMono',
                                  fontSize: 13,
                                ),
                              ),
                              Text(''),
                            ],
                          ),
                        )
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
