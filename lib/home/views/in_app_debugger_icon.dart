import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/console/console_view.dart';
import 'package:flutter_in_app_debugger/networks/views/network_view.dart';
import 'package:flutter_svg/svg.dart';

import '../enums.dart';

class InAppDebuggerIcon extends StatelessWidget {
  const InAppDebuggerIcon({
    Key? key,
    required ScreenEdge? currentEdge,
    required this.iconSize,
    required this.isShowingFunctions,
    required this.setIsShowingFunctions,
    required this.showingFunctionsPadding,
    required this.addOverlay,
    required this.removeOverlay,
    required this.runMinimalInAppIconSizeAnimation,
  })  : _currentEdge = currentEdge,
        super(key: key);

  final ScreenEdge? _currentEdge;
  final double iconSize;
  final bool isShowingFunctions;
  final void Function(bool newValue) setIsShowingFunctions;
  final EdgeInsets showingFunctionsPadding;
  final void Function() removeOverlay;
  final void Function() addOverlay;
  final void Function() runMinimalInAppIconSizeAnimation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin:
            isShowingFunctions ? showingFunctionsPadding : _calculateMargin(),
        decoration: BoxDecoration(
          borderRadius: isShowingFunctions
              ? BorderRadius.circular(20)
              : _calculateBorderRadius(),
          color: Colors.black.withOpacity(
            0.6,
          ),
        ),
        padding: _calculatePadding(),
        child: isShowingFunctions
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FunctionIcon(
                    iconPath:
                        'assets/icons/network_manage_FILL0_wght400_GRAD0_opsz48.svg',
                    onTap: () => _hideAndShowInAppIcon(
                      function: Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NetworkView(),
                        ),
                      ),
                    ),
                  ),
                  FunctionIcon(
                    iconPath:
                        'assets/icons/terminal_FILL0_wght400_GRAD0_opsz48.svg',
                    onTap: () => _hideAndShowInAppIcon(
                      function: Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConsoleView(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SvgPicture.asset(
                'assets/logos/flutter_logo.svg',
                package: 'flutter_in_app_debugger',
                color: Colors.white,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  void _hideAndShowInAppIcon({required FutureOr function}) async {
    removeOverlay();
    runMinimalInAppIconSizeAnimation();
    await function;
    addOverlay();
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

class FunctionIcon extends StatelessWidget {
  const FunctionIcon({
    required this.iconPath,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SvgPicture.asset(
        iconPath,
        package: 'flutter_in_app_debugger',
        width: 30,
        height: 30,
        color: Colors.white,
      ),
    ));
  }
}
