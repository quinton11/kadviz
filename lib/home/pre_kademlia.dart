import 'package:flutter/material.dart';
import 'package:kademlia2d/providers/network.dart';
import 'package:kademlia2d/providers/router.dart';
import 'package:provider/provider.dart';

class ConfigureNetwork extends StatelessWidget {
  const ConfigureNetwork({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    final networkProvider =
        Provider.of<NetworkProvider>(context, listen: false);
    final routerProvider = Provider.of<RouterProvider>(context, listen: false);
    routerProvider.networkSize = networkProvider.networkSize;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
          child: SizedBox(
        height: height,
        width: width,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Kadviz",
                style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'JetBrainsMono',
                    color: Color.fromARGB(255, 84, 178, 232))),
            SizedBox(
              height: 10,
            ),
            ConfigBox(),
            SizedBox(
              height: 30,
            ),
            Text(
              "Select network size",
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'JetBrainsMono',
                  color: Color.fromARGB(255, 84, 178, 232)),
            ),
          ],
        ),
      )),
    );
  }
}

class ConfigBox extends StatefulWidget {
  const ConfigBox({
    super.key,
  });

  @override
  State<ConfigBox> createState() => _ConfigBoxState();
}

class _ConfigBoxState extends State<ConfigBox> {
  final largestNumber = 5;
  final smallestNumber = 4;
  int _selectedOption = 4; // Initial selected option

  void _updateSelectedOption(int newValue) {
    setState(() {
      _selectedOption = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 180,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.amber),
        child: Row(
          children: [
            SizedBox(
              height: 40,
              width: 150,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: const Color.fromARGB(255, 84, 178, 232),
                      width: 2,
                    )),
                child: Center(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        color: const Color.fromARGB(255, 84, 178, 232),
                        onPressed: () => {
                          if (_selectedOption + 1 > largestNumber)
                            {_updateSelectedOption(smallestNumber)}
                          else
                            {_updateSelectedOption(_selectedOption + 1)}
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "$_selectedOption",
                            style: const TextStyle(
                                fontSize: 17,
                                fontFamily: 'JetBrainsMono',
                                color: Color.fromARGB(255, 54, 168, 35)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final networkProvider =
                    Provider.of<NetworkProvider>(context, listen: false);
                networkProvider.setNetworkSize(_selectedOption);
                Navigator.pushNamed(context, '/home');
              },
              child: const SizedBox(
                height: 40,
                width: 30,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(255, 54, 168, 35)),
                  child: Center(
                    child: Text(
                      "Go",
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
