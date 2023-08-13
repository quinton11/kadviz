import 'dart:ui';

import 'package:kademlia2d/utils/enums.dart';

class RequestPacket {
  late String src = '';
  late String dest = '';
  late RPCRequest req;
  late dynamic data;
  RequestPacket({required this.src, required this.dest, required this.req});

  set srcId(String id) {
    src = id;
  }

  set destId(String id) {
    dest = id;
  }

  set request(RPCResponse req) {
    req = req;
  }
}

class ResponsePacket {
  late String src = '';
  late String dest = '';
  late RPCResponse res;
  late dynamic data = [];
  ResponsePacket({required this.src, required this.dest, required this.res});

  set srcId(String id) {
    src = id;
  }

  set destId(String id) {
    dest = id;
  }

  void setresponse(RPCResponse r) {
    res = r;
  }
}

class APacket {
  late double radius;
  late double dX;
  late double dY;
  late Offset pos;

  APacket(
      {required this.radius,
      required this.dX,
      required this.dY,
      required this.pos});
}
