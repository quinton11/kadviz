class PathInfo {
  final int hop;
  final String srcId;
  final String destId;
  final int path;

  PathInfo(
      {required this.hop,
      required this.srcId,
      required this.destId,
      required this.path});
}
