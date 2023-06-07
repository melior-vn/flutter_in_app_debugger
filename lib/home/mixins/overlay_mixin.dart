import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/svg.dart';
import '../../shared/math/linear_moving.dart';

import '../home_view.dart';

enum ScreenEdge { left, right, top, bottom }

class FlutterInAppDebuggerOverlayMixin {
  late OverlayEntry _overlayEntry;

  late double _settingIconSize;

  late AnimationController _movingAnimationController;

  late Animation<Offset> _movingAnimation;

  late BuildContext _context;
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
      builder: (context) => AnimatedPositioned(
        duration: const Duration(milliseconds: 50),
        top: _normalizedInAppIconOffset?.dy,
        left: _normalizedInAppIconOffset?.dx,
        child: GestureDetector(
          onTap: () => _onPressed(),
          onPanUpdate: (details) {
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
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: _currentEdge == ScreenEdge.right
                    ? iconSize * 2 / 3
                    : _currentEdge == ScreenEdge.left
                        ? 0
                        : iconSize / 5,
                top: _currentEdge == ScreenEdge.right ||
                        _currentEdge == ScreenEdge.left
                    ? 0
                    : iconSize / 5,
                right: _currentEdge == ScreenEdge.left
                    ? iconSize * 2 / 3
                    : _currentEdge == ScreenEdge.right
                        ? 0
                        : iconSize / 5,
                bottom: _currentEdge == ScreenEdge.right ||
                        _currentEdge == ScreenEdge.left
                    ? 0
                    : iconSize / 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
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
                ),
                color: Colors.black.withOpacity(
                  0.6,
                ),
              ),
              padding: EdgeInsets.only(
                left: _currentEdge == ScreenEdge.left ||
                        _currentEdge == ScreenEdge.right
                    ? iconSize / 20
                    : iconSize / 60,
                right: iconSize / 20,
                top: iconSize / 14,
                bottom: iconSize / 14,
              ),
              child: SvgPicture.asset(
                'assets/flutter_logo.svg',
                package: 'flutter_in_app_debugger',
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
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

class InAppIconEndpoint {
  final Offset endpoint;
  final ScreenEdge? screenEdge;

  InAppIconEndpoint({
    required this.endpoint,
    this.screenEdge,
  });
}
