class Node {
  final String id;
  final List<String> children;
  final int depth;
  final String parentId;
  final Map<String, dynamic> branches;
  Node(
      {required this.id,
      required this.children,
      required this.depth,
      required this.parentId,
      required this.branches});
}
