import 'package:vector_math/vector_math.dart';

class Branch {
  final Vector2 startPoint;
  final Vector2 endPoint;
  final double angle;
  Branch(
      {required this.startPoint, required this.endPoint, required this.angle});
}
