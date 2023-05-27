import 'package:flutter/material.dart';

Offset? calculateIntersectionPointOnScreenEdge({
  required Offset endPoint,
  required Offset startPoint,
  required double width,
  required double height,
}) {
  // 1. vector pháp tuyến
  // 1.1. (a, b) = (x1 - x2, y1 - y2)

  // 2. phương trình đường thẳng
  // 2.1. b*(x - x1) - a*(y - y1) = 0
  // 2.2. => b*x - a*y - (b*x1 - a*y1) = 0
  // 2.3. => y = (-(b*x1 - a*y1) + b*x) / a
  // 2.4.   x = ((b*x1 - a*y1) + a*y) / b

  // 3. 4 điểm cắt tương ứng 4 đường của cạnh màn hình
  // 3.1. case x = 0
  // 3.2. case y = 0
  // 3.3. case x = width
  // 3.4. case y = height

  // 4. NOTE*: Cần check song song nhưng song song thì vẫn cắt 2 điểm bình thường
  // 4.1 Case cắt 2 góc màn hình => 4 điểm giao nhau => cần check trùng
  // 4.2 Điểm cắt duy nhất là điểm có cùng hướng với vector pháp tuyến.
  final normalVector = Offset(
    endPoint.dx - startPoint.dx,
    endPoint.dy - startPoint.dy,
  );

  // 4. NOTE*: Cần check song song
  final isParallelToDx = normalVector.dx == 0;
  final isParallelToDy = normalVector.dy == 0;

  // 3. 4 điểm cắt tương ứng 4 đường của cạnh màn hình
  final allIntersectionPoints = <Offset>[];
  if (isParallelToDx) {
    late Offset point;
    if (endPoint.dy > startPoint.dy) {
      point = Offset(endPoint.dx, height);
    } else {
      point = Offset(endPoint.dx, 0);
    }
    allIntersectionPoints.addAll([point]);
  } else if (isParallelToDy) {
    late Offset point;
    if (endPoint.dx > startPoint.dx) {
      point = Offset(width, endPoint.dy);
    } else {
      point = Offset(0, endPoint.dy);
    }
    allIntersectionPoints.addAll([point]);
  } else {
    // 3.1. case x = 0
    final topPoint = Offset(
      0,
      _calculateDyFromNormalVectorAndPoint(
        normalVector,
        endPoint.dx,
        endPoint.dy,
        0,
      ),
    );
    // 3.3. case x = width
    final bottomPoint = Offset(
      width,
      _calculateDyFromNormalVectorAndPoint(
        normalVector,
        endPoint.dx,
        endPoint.dy,
        width,
      ),
    );
    // 3.2. case y = 0
    final leftPoint = Offset(
      _calculateDxFromNormalVectorAndPoint(
        normalVector,
        endPoint.dx,
        endPoint.dy,
        0,
      ),
      0,
    );
    // 3.4. case y = height
    final rightPoint = Offset(
      _calculateDxFromNormalVectorAndPoint(
        normalVector,
        endPoint.dx,
        endPoint.dy,
        height,
      ),
      height,
    );
    allIntersectionPoints.addAll([
      topPoint,
      bottomPoint,
      leftPoint,
      rightPoint,
    ]);
  }

  // Remove point out off screen
  final intersectionPointsInScreen = allIntersectionPoints
      .where(
        (element) =>
            element.dx >= 0 &&
            element.dx <= width &&
            element.dy >= 0 &&
            element.dy <= height,
      )
      .toList();
  // 4.1 Case cắt 2 góc màn hình => 4 điểm giao nhau => cần check trùng

  final distinctIntersectionPointsInScreen =
      intersectionPointsInScreen.toSet().toList();
  // 4.2 Điểm cắt duy nhất là điểm có cùng hướng với vector pháp tuyến.
  // nếu tính đúng thì luôn thu được 2 điểm
  Offset? intersectionPoint;
  if (distinctIntersectionPointsInScreen.length == 2) {
    final firstPoint = distinctIntersectionPointsInScreen[0];

    if (((firstPoint.dx - startPoint.dx) / normalVector.dx) > 0 &&
        ((firstPoint.dy - startPoint.dy) / normalVector.dy) > 0) {
      intersectionPoint = distinctIntersectionPointsInScreen[0];
    } else {
      intersectionPoint = distinctIntersectionPointsInScreen[1];
    }
  } else if (distinctIntersectionPointsInScreen.isNotEmpty) {
    intersectionPoint = distinctIntersectionPointsInScreen.first;
  }
  return intersectionPoint;
}

double _calculateDyFromNormalVectorAndPoint(
  Offset normalVector,
  double x1,
  double y1,
  double x,
) {
  // 2.3. => y = ((b*x1 - a*y1) + b*x) / a
  final a = normalVector.dx;
  final b = normalVector.dy;
  return ((-(b * x1 - a * y1) + b * x) / a).floorToDouble();
}

double _calculateDxFromNormalVectorAndPoint(
  Offset normalVector,
  double x1,
  double y1,
  double y,
) {
  // 2.4.   x = (-(b*x1 - a*y1) - a*y) / b
  final a = normalVector.dx;
  final b = normalVector.dy;
  return (((b * x1 - a * y1) + a * y) / b).floorToDouble();
}
