import 'dart:collection';

import 'package:kademlia2d/models/packet.dart';
import 'package:kademlia2d/utils/enums.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  level: Level.debug,
  printer: PrettyPrinter(),
);

class Host {
  final String id;
  bool isActive;
  late Map<String, List<String>> kBuckets = {};
  late int k = 3;
  late int networkSize = 4;
  Host({required this.id, required this.isActive, required this.networkSize});

  List<String> getBucketIds() {
    List<String> ids = [];
    kBuckets.keys.toList().forEach((key) {
      final buck = kBuckets[key] as List<String>;

      for (var i in buck) {
        ids.add(i);
      }
    });
    return ids;
  }

  /// Adds a discovered node to the k-bucket
  bool populateBucket(String idk) {
    //  check proximity
    if (idk == id) return true;
    logger.i('Populating bucket for host - $id');
    int closeNess = int.parse(id, radix: 2) ^ int.parse(idk, radix: 2);
    logger.i(
        'CloseNess score for bucket - $idk in host - $id bucket ::: Closeness: $closeNess');
    String xor = closeNess.toRadixString(2);
    if (xor.length < networkSize) {
      xor = ('0' * (networkSize - xor.length)) + xor;
    }
    logger.i('XOR score: $xor');

    //  get bucket node id belongs to
    int indexOf = xor.indexOf('1');
    logger.i('Index of: $indexOf');
    String bucketId = (indexOf + 1).toString();
    logger.i('BucketId $bucketId');

    if (!kBuckets.containsKey(bucketId)) {
      //print('Bucket not created yet');

      kBuckets[bucketId] = [];
    }

    //  is the bucket full
    final bucket = kBuckets[bucketId] as List<String>;
    final exists = bucket.contains(idk);
    //print('Bucket: $bucket');
    //print('Does bucket exist: $exists');

    logger.i('K-Buckets $kBuckets in host $id');
    logger.i('Bucket $bucketId has ${bucket.length} nodes');
    logger.i('K value: $k');
    //bucket is full
    logger.i('Bucket is full? ${bucket.length == k}');
    if (bucket.length == k) return true;

    //id already in bucket
    logger.i('Node already in bucket? $exists');
    if (exists) return true;

    kBuckets[bucketId]!.add(idk);
    logger.i('Adding node to bucket');
    logger.i(kBuckets);

    return false;
  }

  /// checks if id matches host id
  bool destMatch(String i) {
    return id == i;
  }

  (List<dynamic>, bool) bucketCloseNess(String i,
      {List<String> dontInclude = const []}) {
    Map<String, int> closeNess = {};
    //find the most closest nodes
    //for each id in bucket
    kBuckets.keys.toList(growable: false).forEach((key) {
      List<String> ids = kBuckets[key] as List<String>;
      for (var idk in ids) {
        //if (idk != i) {
        final closeness = int.parse(idk, radix: 2) ^ int.parse(i, radix: 2);
        closeNess.addAll({idk: closeness});
        //}
      }
    });

    //if node id is closer to node than other nodes return converged true
    //final closeToMe = int.parse(id, radix: 2) ^ int.parse(i, radix: 2);
    //print('CLose to me: $closeToMe');

    var sortedKeys = closeNess.keys.toList(growable: false)
      ..sort((k1, k2) => closeNess[k1]!.compareTo(closeNess[k2]!.toInt()));
    LinkedHashMap sortedMap = LinkedHashMap.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => closeNess[k]);

    final sortedMapTolist = sortedMap.keys.toList();
    logger.i(
        "Bucket of $id, these are the nodes I have closest to $i: $sortedMapTolist");

    final filteredList = sortedMapTolist
        .where((element) => !dontInclude.contains(element))
        .toList();
    logger.i(
        "Bucket of $id, these are the nodes I have closest to $i: $filteredList that aren't in the dontInclude list");

    final kClosest = filteredList.take(k).toList();

    return (kClosest, false);
  }

  ResponsePacket handleRequest(RequestPacket req) {
    //based on request type perform functionality
    String src = req.src;
    String dest = req.dest;
    logger.i('Source: $src');
    logger.i('Dest: $dest');

    if (!destMatch(dest)) {
      return ResponsePacket(src: id, dest: src, res: RPCResponse.wrongDest);
    }

    ResponsePacket res =
        ResponsePacket(src: dest, dest: src, res: RPCResponse.bootNode);

    switch (req.req) {
      case RPCRequest.bootNode:
        //check k-bucket
        //check for closeness in kbucket
        //find the k closest nodes except for exact match
        final (closeNodes, converged) = bucketCloseNess(req.src);
        populateBucket(req.src);

        if (converged) res.setresponse(RPCResponse.bootNodeConverge);
        res.data = closeNodes;
        //check if src is in bucket, if not add src to bucket
        //if closest nodes found send nodes as response
        logger.i('BootNode Request');
      default:
        logger.i('Default case');
    }

    return res;
  }
}
