import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../shared/math/linear_moving.dart';

import '../enums.dart';
import '../home_view.dart';
import '../models/in_app_icon_endpoint.dart';
import '../views/in_app_debugger_icon.dart';

class FlutterInAppDebuggerOverlayMixin {
  late OverlayEntry _overlayEntry;

  late double _settingIconSize;

  final _showingFunctionsSize = 120.0;

  var _currentIconSize = 0.0;

  late AnimationController _movingAnimationController;

  late Animation<Offset> _movingAnimation;

  late AnimationController _sizeAnimationController;
  late Animation<double> _sizeAnimation;

  late BuildContext _context;

  bool _isShowingFunctions = false;
  void setIsShowingFunctions(bool newValue) {
    _isShowingFunctions = newValue;
    Overlay.of(_context)?.setState(() {});
  }

  // Current offset
  Offset? _inAppIconOffset;
  ScreenEdge? _currentEdge;

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
    _currentIconSize = iconSize;
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

    _sizeAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(
        milliseconds: 100,
      ),
    );

    _createChangingSizeAnimation(
      animationController: _sizeAnimationController,
      startSize: _settingIconSize,
      endSize: _showingFunctionsSize,
    );

    _sizeAnimationController.addListener(() {
      Overlay.of(context)?.setState(() {
        _currentIconSize = _sizeAnimation.value;
        if (_normalizedInAppIconOffset != null) {
          _normalizedInAppIconOffset = _getNormalizedInAppIconOffset(
            _normalizedInAppIconOffset!,
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
            iconSize: _settingIconSize,
          );
        }
      });
      print(_currentIconSize);
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
    _sizeAnimationController.dispose();
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
      builder: (context) => AnimatedPositioned(
        duration: const Duration(milliseconds: 50),
        top: _normalizedInAppIconOffset?.dy,
        left: _normalizedInAppIconOffset?.dx,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _sizeAnimationController.stop();
            setIsShowingFunctions(!_isShowingFunctions);
            if (_isShowingFunctions) {
              _sizeAnimationController.forward();
            } else {
              _sizeAnimationController.reverse();
            }
          },
          onPanUpdate: (details) {
            if (!_isShowingFunctions) {
              movingAnimationController.stop();
              // _inAppIconOffset is native offset (0 -> max screen size),
              // If not _getNormalizedInAppIconOffset, the new offset (with delta)
              // maybe outsize screen
              // => delay position when on max width or height

              final newOffset = _getNormalizedInAppIconOffset(
                  Offset(
                    _inAppIconOffset!.dx + details.delta.dx,
                    _inAppIconOffset!.dy + details.delta.dy,
                  ),
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height,
                  iconSize: iconSize);

              _setInAppIconOffset(
                newOffset,
                maxHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width,
                iconSize: iconSize,
              );
              final data = _calculateInAppIconEndpoint(
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height,
              );
              _endPointInAppIconOffset = data.endpoint;
              _currentEdge = data.screenEdge;
              overlayState?.setState(() {});
            }
          },
          onPanEnd: (details) {
            if (!_isShowingFunctions) {
              _runMovingAnimation(
                startOffset: _inAppIconOffset!,
                endOffset: _endPointInAppIconOffset!,
                pixelsPerSecond: details.velocity.pixelsPerSecond,
                movingAnimationController: movingAnimationController,
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: MediaQuery.of(context).size.height,
              );
              _historyInAppIconOffset.clear();
            }
          },
          child: InAppDebuggerIcon(
            currentEdge: _currentEdge,
            iconSize: _currentIconSize,
            isShowingFunctions: _isShowingFunctions,
            setIsShowingFunctions: setIsShowingFunctions,
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
    _addOverlay(_context);
  }

  void _removeOverlay() {
    _overlayEntry.remove();
  }

  Offset _getNormalizedInAppIconOffset(
    Offset offset, {
    required double maxWidth,
    required double maxHeight,
    required double iconSize,
  }) {
    return Offset(
      max(
        _getNormalizedInAppIconOffsetMinWidth(),
        min(
          offset.dx,
          _getNormalizedInAppIconOffsetMaxWidth(
            iconSize: iconSize,
            maxWidth: maxWidth,
          ),
        ),
      ),
      max(
        _getNormalizedInAppIconOffsetMinHeight(),
        min(
          offset.dy,
          _getNormalizedInAppIconOffsetMaxHeight(
            iconSize: iconSize,
            maxHeight: maxHeight,
          ),
        ),
      ),
    );
  }

  double _getNormalizedInAppIconOffsetMaxWidth({
    required double maxWidth,
    required double iconSize,
  }) {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    return maxWidth - iconSize - viewInsert.right;
  }

  double _getNormalizedInAppIconOffsetMinWidth() {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    return viewInsert.left;
  }

  double _getNormalizedInAppIconOffsetMaxHeight({
    required double maxHeight,
    required double iconSize,
  }) {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    return maxHeight - iconSize - viewInsert.bottom;
  }

  double _getNormalizedInAppIconOffsetMinHeight() {
    final viewInsert = MediaQueryData.fromWindow(window).padding;
    return viewInsert.top;
  }

  void _createChangingSizeAnimation({
    required AnimationController animationController,
    required double startSize,
    required double endSize,
  }) {
    _sizeAnimation = animationController.drive(
      Tween<double>(
        begin: startSize,
        end: endSize,
      ),
    );
    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, 20);

    animationController.animateWith(simulation);
    animationController.stop();
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

  /// Calculate the end point after the user finishes interacting with the icon.
  /// There will be 2 cases to handle:
  /// - Moving case => calculate endpoint.
  /// - Case swipe to the edge to change to mini-shape => keep position.
  InAppIconEndpoint _calculateInAppIconEndpoint({
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

    ScreenEdge? currentEdge;

    final startPoint = lastInAppIconPoint;
    final endPoint = _inAppIconOffset!;
    final minNormalizedWidth = _getNormalizedInAppIconOffsetMinWidth();
    final minNormalizedHeight = _getNormalizedInAppIconOffsetMinHeight();
    final maxNormalizedWidth = _getNormalizedInAppIconOffsetMaxWidth(
      maxWidth: maxWidth,
      iconSize: _settingIconSize,
    );
    final maxNormalizedHeight = _getNormalizedInAppIconOffsetMaxHeight(
      maxHeight: maxHeight,
      iconSize: _settingIconSize,
    );

    const deltaPosition = 15;

    if (startPoint.dx == minNormalizedWidth &&
        endPoint.dx == minNormalizedWidth &&
        (startPoint.dy - endPoint.dy).abs() < deltaPosition) {
      currentEdge = ScreenEdge.left;
    } else if (startPoint.dx == maxNormalizedWidth &&
        endPoint.dx == maxNormalizedWidth &&
        (startPoint.dy - endPoint.dy).abs() < deltaPosition) {
      currentEdge = ScreenEdge.right;
    } else if (startPoint.dy == minNormalizedHeight &&
        endPoint.dy == minNormalizedHeight &&
        (startPoint.dx - endPoint.dx).abs() < deltaPosition) {
      currentEdge = ScreenEdge.top;
    } else if (startPoint.dy == maxNormalizedHeight &&
        endPoint.dy == maxNormalizedHeight &&
        (startPoint.dx - endPoint.dx).abs() < deltaPosition) {
      currentEdge = ScreenEdge.bottom;
    }
    print(currentEdge);
    if (currentEdge != null) {
      return InAppIconEndpoint(
        endpoint: _inAppIconOffset!,
        screenEdge: currentEdge,
      );
    }

    return InAppIconEndpoint(
      endpoint: calculateIntersectionPointOnScreenEdge(
            startPoint: lastInAppIconPoint,
            endPoint: _inAppIconOffset!,
            width: maxWidth,
            height: maxHeight,
          ) ??
          _inAppIconOffset!,
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
    final validatedOffset = _getNormalizedInAppIconOffset(
      newOffset,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      iconSize: _settingIconSize,
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
