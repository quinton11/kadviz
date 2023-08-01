class Host {
  final String id;
  bool isActive;
  late Map<String, List<String>> kBuckets = {};
  late int k = 2;
  Host({required this.id, required this.isActive});

  /// Adds a discovered node to the k-bucket
  void populateBucket(String id) {
    //  check proximity
    //  check which bucket id belongs to
    //  is the bucket full
    //  if so discard for not
    //  else add to bucket
  }
}
