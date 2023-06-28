import 'package:flutter/material.dart';
import 'package:kademlia2d/home/kademlia.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 84, 178, 232),
            onBackground: const Color.fromARGB(255, 32, 32, 32)),
        useMaterial3: true,
      ),
      home: const KademliaHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}
