part of shared;

class Polygon {
  List<Vector2> vertices;
  Polygon(List<double> points) {
    vertices = new List(points.length ~/ 2);
    for (int i = 0; i < points.length; i += 2) {
      vertices[i ~/ 2] =
          new Vector2(points[i].toDouble(), points[i + 1].toDouble());
    }
  }
}
