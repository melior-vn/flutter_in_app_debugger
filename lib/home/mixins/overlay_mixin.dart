import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_in_app_debugger/shared/animations/linear_moving_animation.dart';

import '../home_view.dart';

class FlutterInAppDebuggerOverlayMixin {
  late OverlayEntry _overlayEntry;

  late double _settingIconSize;

  late AnimationController _movingAnimationController;

  late Animation<Offset> _movingAnimation;

  late BuildContext _context;
  // Current offset
  Offset? _inAppIconOffset;
  // Normalize the position of current offset
  Offset? _normalizedInAppIconOffset;
  // Last offset for calculate end point
  final _historyInAppIconOffset = <Offset>[];

  // End point when end drag offset
  Offset? _endPointInAppIconOffset;

  void initFlutterInAppOverlay(
    BuildContext context, {
    required double iconSize,
    required TickerProvider vsync,
  }) {
    _context = context;
    _settingIconSize = iconSize;
    _movingAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(
        milliseconds: 500,
      ),
    );

    _movingAnimationController.addListener(() {
      Overlay.of(context)?.setState(() {
        _inAppIconOffset = _movingAnimation.value;
        _normalizedInAppIconOffset = _getNormalizedInAppIconOffset(
          _movingAnimation.value,
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
          iconSize: _settingIconSize,
        );
      });
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _createOverLay(
        context,
        movingAnimationController: _movingAnimationController,
        iconSize: iconSize,
      );
    });
  }

  void disposeFlutterInAppOverlay() {
    _movingAnimationController.dispose();
  }

  void _createOverLay(
    BuildContext context, {
    double iconSize = 40.0,
    required AnimationController movingAnimationController,
  }) async {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    _setInAppIconOffset(
      Offset(
        viewInsert.left,
        viewInsert.top,
      ),
      maxHeight: MediaQuery.of(context).size.height,
      maxWidth: MediaQuery.of(context).size.width,
      iconSize: iconSize,
    );
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _normalizedInAppIconOffset?.dy,
        left: _normalizedInAppIconOffset?.dx,
        child: GestureDetector(
          onTap: () => _onPressed(),
          onPanUpdate: (details) {
            movingAnimationController.stop();
            _setInAppIconOffset(
              Offset(
                (_inAppIconOffset?.dx ?? 0) + details.delta.dx,
                (_inAppIconOffset?.dy ?? 0) + details.delta.dy,
              ),
              maxHeight: MediaQuery.of(context).size.height,
              maxWidth: MediaQuery.of(context).size.width,
              iconSize: iconSize,
            );
            _endPointInAppIconOffset = _calculateInAppIconEndpoint(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            );
            overlayState?.setState(() {});
          },
          onPanEnd: (details) {
            _runMovingAnimation(
              startOffset: _inAppIconOffset!,
              endOffset: _endPointInAppIconOffset!,
              pixelsPerSecond: details.velocity.pixelsPerSecond,
              movingAnimationController: movingAnimationController,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height,
            );
            _historyInAppIconOffset.clear();
          },
          child: Container(
            width: iconSize,
            height: iconSize,
            color: Colors.orange,
          ),
        ),
      ),
    );

    _addOverlay(context);
  }

  void _addOverlay(BuildContext context) {
    Overlay.of(context)?.insert(_overlayEntry);
  }

  void _onPressed() async {
    _removeOverlay();

    await Navigator.push(
      _context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
    print('add over lay');
    _addOverlay(_context);
  }

  void _removeOverlay() {
    _overlayEntry.remove();
  }

  Offset _getNormalizedInAppIconOffset(
    Offset inAppIconOffset, {
    required double maxWidth,
    required double maxHeight,
    required double iconSize,
  }) {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    final validatedOffset = _validateOffset(
      newOffset: inAppIconOffset,
      minWidth: viewInsert.right,
      minHeight: viewInsert.top,
      maxWidth: maxWidth - viewInsert.right,
      maxHeight: maxHeight - viewInsert.bottom,
    );
    return Offset(
      min(
        validatedOffset.dx,
        maxWidth - iconSize - viewInsert.right,
      ),
      min(
        validatedOffset.dy,
        maxHeight - iconSize - viewInsert.bottom,
      ),
    );
  }

  Offset _validateOffset({
    required Offset newOffset,
    double minWidth = 0,
    required double maxWidth,
    double minHeight = 0,
    required double maxHeight,
  }) {
    return Offset(
      max(minWidth, min(maxWidth, newOffset.dx)),
      max(minHeight, min(maxHeight, newOffset.dy)),
    );
  }

  void _runMovingAnimation({
    required Offset startOffset,
    required Offset endOffset,
    required Offset pixelsPerSecond,
    required AnimationController movingAnimationController,
    required double maxWidth,
    required double maxHeight,
  }) {
    _movingAnimation = movingAnimationController.drive(
      Tween<Offset>(
        begin: startOffset,
        end: endOffset,
      ),
    );

    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / maxWidth;
    final unitsPerSecondY = pixelsPerSecond.dy / maxHeight;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, unitVelocity);

    movingAnimationController.animateWith(simulation);
  }

  Offset? _calculateInAppIconEndpoint({
    required double maxWidth,
    required double maxHeight,
  }) {
    late Offset lastInAppIconPoint;

    if (_historyInAppIconOffset.length < 12) {
      lastInAppIconPoint = _historyInAppIconOffset.first;
    } else {
      lastInAppIconPoint =
          _historyInAppIconOffset[_historyInAppIconOffset.length - 12];
    }

    return calculateIntersectionPointOnScreenEdge(
      startPoint: lastInAppIconPoint,
      endPoint: _inAppIconOffset!,
      width: maxWidth,
      height: maxHeight,
    );
  }

  // Set both _inAppIconOffset and _lastInAppIconOffset
  // If offset < 0 => update => 0;
  void _setInAppIconOffset(
    Offset newOffset, {
    required double maxWidth,
    required double maxHeight,
    required double iconSize,
  }) {
    final validatedOffset = _validateOffset(
      newOffset: newOffset,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
    );
    _historyInAppIconOffset.add(validatedOffset);
    _inAppIconOffset = validatedOffset;
    _normalizedInAppIconOffset = _getNormalizedInAppIconOffset(
      newOffset,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      iconSize: iconSize,
    );
  }
}
