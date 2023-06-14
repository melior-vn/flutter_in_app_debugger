import 'package:flutter/material.dart';

import '../enums.dart';

class InAppIconEndpoint {
  final Offset endpoint;
  final ScreenEdge? screenEdge;

  InAppIconEndpoint({
    required this.endpoint,
    this.screenEdge,
  });
}
