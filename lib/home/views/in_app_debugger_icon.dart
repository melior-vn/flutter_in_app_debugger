import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../enums.dart';

class InAppDebuggerIcon extends StatelessWidget {
  const InAppDebuggerIcon({
    Key? key,
    required ScreenEdge? currentEdge,
    required this.iconSize,
    required this.isShowingFunctions,
    required this.setIsShowingFunctions,
  })  : _currentEdge = currentEdge,
        super(key: key);

  final ScreenEdge? _currentEdge;
  final double iconSize;
  final bool isShowingFunctions;
  final void Function(bool newValue) setIsShowingFunctions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: iconSize,
      height: iconSize,
      color: Colors.green,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: _calculateMargin(),
        decoration: BoxDecoration(
          borderRadius: _calculateBorderRadius(),
          color: Colors.black.withOpacity(
            0.6,
          ),
        ),
        padding: _calculatePadding(),
        child: isShowingFunctions
            ? const Text('functions')
            : SvgPicture.asset(
                'assets/flutter_logo.svg',
                package: 'flutter_in_app_debugger',
                color: Colors.white,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  EdgeInsets _calculatePadding() {
    return EdgeInsets.only(
      left: _currentEdge == ScreenEdge.left || _currentEdge == ScreenEdge.right
          ? iconSize / 20
          : iconSize / 60,
      right: iconSize / 20,
      top: iconSize / 14,
      bottom: iconSize / 14,
    );
  }

  BorderRadius _calculateBorderRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(
        _currentEdge == ScreenEdge.left
            ? 0.0
            : _currentEdge == ScreenEdge.right
                ? iconSize / 8
                : iconSize,
      ),
      bottomLeft: Radius.circular(
        _currentEdge == ScreenEdge.left
            ? 0.0
            : _currentEdge == ScreenEdge.right
                ? iconSize / 8
                : iconSize,
      ),
      topRight: Radius.circular(
        _currentEdge == ScreenEdge.right
            ? 0.0
            : _currentEdge == ScreenEdge.left
                ? iconSize / 8
                : iconSize,
      ),
      bottomRight: Radius.circular(
        _currentEdge == ScreenEdge.right
            ? 0.0
            : _currentEdge == ScreenEdge.left
                ? iconSize / 8
                : iconSize,
      ),
    );
  }

  EdgeInsets _calculateMargin() {
    return EdgeInsets.only(
      left: _currentEdge == ScreenEdge.right
          ? iconSize * 2 / 3
          : _currentEdge == ScreenEdge.left
              ? 0
              : iconSize / 5,
      top: _currentEdge == ScreenEdge.right || _currentEdge == ScreenEdge.left
          ? 0
          : iconSize / 5,
      right: _currentEdge == ScreenEdge.left
          ? iconSize * 2 / 3
          : _currentEdge == ScreenEdge.right
              ? 0
              : iconSize / 5,
      bottom:
          _currentEdge == ScreenEdge.right || _currentEdge == ScreenEdge.left
              ? 0
              : iconSize / 5,
    );
  }
}
