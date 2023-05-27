import 'dart:async';
import 'dart:developer' as DartDev;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_in_app_debugger/console/models/log_event.dart';
import 'package:flutter_in_app_debugger/networks/models/models.dart';
import 'package:flutter_in_app_debugger/networks/views/network_view.dart';
import 'package:flutter_in_app_debugger/shared/animations/linear_moving_animation.dart';

import 'home_view.dart';

class FlutterInAppDebuggerView extends StatefulWidget {
  FlutterInAppDebuggerView() : super(key: FlutterInAppDebuggerView.globalKey);

  static GlobalKey<_FlutterInAppDebuggerViewState> globalKey = GlobalKey();

  static Future listen(void Function() body) async {
    return runZoned(
      body,
      zoneSpecification: ZoneSpecification(
        print: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          String line,
        ) {
          FlutterInAppDebuggerView.globalKey.currentState?.addLog(
            message: line,
          );
          parent.print(zone, line);
        },
        handleUncaughtError: (
          Zone self,
          ZoneDelegate parent,
          Zone zone,
          Object error,
          StackTrace stackTrace,
        ) {
          FlutterInAppDebuggerView.globalKey.currentState?.addLog(
            message: error.toString(),
            stacktrace: stackTrace.toString(),
          );

          parent.handleUncaughtError(zone, error, stackTrace);
        },
      ),
    );
  }

  @override
  State<FlutterInAppDebuggerView> createState() =>
      _FlutterInAppDebuggerViewState();
}

class _FlutterInAppDebuggerViewState extends State<FlutterInAppDebuggerView>
    with TickerProviderStateMixin, LinearMovingAnimationMixin {
  late AnimationController _movingAnimationController;
  late Animation<Offset> _movingAnimation;
  late OverlayEntry _overlayEntry;
  late double _settingIconSize;

  // Current offset
  Offset? _inAppIconOffset;
  // Normalize the position of current offset
  Offset? _normalizedInAppIconOffset;
  // Last offset for calculate end point
  final _historyInAppIconOffset = <Offset>[];
  // Set both _inAppIconOffset and _lastInAppIconOffset
  // If offset < 0 => update => 0;
  void _setInAppIconOffset(Offset newOffset) {
    final validatedOffset = _validateOffset(newOffset);
    _historyInAppIconOffset.add(validatedOffset);
    _inAppIconOffset = validatedOffset;
    _normalizedInAppIconOffset = _getNormalizedInAppIconOffset(newOffset);
  }

  Offset? _calculateInAppIconEndpoint() {
    late Offset _lastInAppIconPoint;

    if (_historyInAppIconOffset.length < 12) {
      _lastInAppIconPoint = _historyInAppIconOffset.first;
    } else {
      _lastInAppIconPoint =
          _historyInAppIconOffset[_historyInAppIconOffset.length - 12];
    }
    _startPointOffset = _lastInAppIconPoint;

    return calculateIntersectionPointOnScreenEdge(
      startPoint: _lastInAppIconPoint,
      endPoint: _inAppIconOffset!,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
    );
  }

  void _runMovingAnimation(
    Offset startOffset,
    Offset endOffset,
    Offset pixelsPerSecond,
    Size size,
  ) {
    _movingAnimation = _movingAnimationController.drive(
      Tween<Offset>(
        begin: startOffset,
        end: endOffset,
      ),
    );

    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;

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

    _movingAnimationController.animateWith(simulation);
  }

  // End point when end drag offset
  Offset? _endPointInAppIconOffset;
  Offset? _startPointOffset;

  final _requests = <NetworkEvent>[];
  final _requestsStream = StreamController<NetworkEvent>.broadcast();
  final _logs = <LogEvent>[];
  final _logsStream = StreamController<LogEvent>.broadcast();

  var _verticalVelocity = 0.0;
  var _horizontalVelocity = 0.0;

  List<NetworkEvent> get requests => _requests;
  void removeAllRequests() => _requests.removeWhere((element) => true);

  StreamController<NetworkEvent> get requestsStream => _requestsStream;

  List<LogEvent> get logs => _logs;
  void removeAllLogs() => _logs.removeWhere((element) => true);
  StreamController<LogEvent> get logsStream => _logsStream;

  @override
  void initState() {
    super.initState();
    _movingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );

    _movingAnimationController.addListener(() {
      Overlay.of(context).setState(() {
        _inAppIconOffset = _movingAnimation.value;
        _normalizedInAppIconOffset =
            _getNormalizedInAppIconOffset(_movingAnimation.value);
      });
    });

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _initOverLay();
    });
  }

  @override
  void didChangeDependencies() {
    _settingIconSize = max(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height) *
        0.08;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrants) {
      return Stack(children: [
        const SizedBox.shrink(),
        if (_endPointInAppIconOffset != null)
          Positioned(
            top: min(
                _endPointInAppIconOffset!.dy - 50, constrants.maxHeight - 50),
            left: min(
                _endPointInAppIconOffset!.dx - 50, constrants.maxWidth - 50),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.green,
            ),
          ),
        if (_startPointOffset != null)
          Positioned(
            top: min(_startPointOffset!.dy - 20, constrants.maxHeight - 20),
            left: min(_startPointOffset!.dx - 20, constrants.maxWidth - 50),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.red,
            ),
          ),
        if (_inAppIconOffset != null)
          Positioned(
            top: min(_inAppIconOffset!.dy - 20, constrants.maxHeight - 20),
            left: min(_inAppIconOffset!.dx - 20, constrants.maxWidth - 50),
            child: Container(
              width: 40,
              height: 40,
              color: Colors.black,
            ),
          )
      ]);
    });
  }

  @override
  void dispose() {
    _movingAnimationController.dispose();
    _requestsStream.close();
    super.dispose();
  }

  LogEvent addLog({required String message, String? stacktrace}) {
    final logEvent = LogEvent(
        message: message,
        stackTrace: stacktrace,
        type: stacktrace != null ? LogEventType.error : LogEventType.log);
    _logs.insert(0, logEvent);
    _logsStream.add(logEvent);
    return logEvent;
  }

  NetworkEvent addNetworkRequest({
    required dynamic request,
    required String baseUrl,
    required String path,
    required String method,
    required Uri uri,
    Map<String, dynamic>? data,
    required InterceptorType type,
  }) {
    final networkEvent = NetworkEvent(
      type: type,
      request: NetworkRequest(
        baseUrl: baseUrl,
        path: path,
        uri: uri,
        method: method,
        requestObject: request,
        requestData: data,
      ),
    );

    _requests.insert(0, networkEvent);
    _requestsStream.add(networkEvent);
    return networkEvent;
  }

  NetworkEvent? addNetworkResponse({
    required dynamic response,
    required int statusCode,
    Map<String, dynamic>? responseData,
  }) {
    final networkEventIndex = _requests.indexWhere((element) =>
        element.request.requestObject.hashCode ==
        response.requestOptions.hashCode);
    if (networkEventIndex != -1) {
      _requests[networkEventIndex].setResponse = NetworkResponse(
        response: response,
        statusCode: statusCode,
        responseData: responseData,
      );
      _requestsStream.add(_requests[networkEventIndex]);
      return _requests[networkEventIndex];
    } else {
      debugPrint('[Flutter In-app Debugger] not found request');
      return null;
    }
  }

  NetworkEvent? addNetworkError({required DioError dioError}) {
    final networkEventIndex = _requests.indexWhere((element) =>
        element.request.requestObject.hashCode ==
        dioError.requestOptions.hashCode);
    if (networkEventIndex != -1) {
      final networkEvent = _requests[networkEventIndex];
      networkEvent.setError = NetworkError(error: dioError);
      _requestsStream.add(networkEvent);
      return networkEvent;
    } else {
      debugPrint('[Flutter In-app Debugger] not found request');
      return null;
    }
  }

  void _initOverLay() async {
    final viewInsert = MediaQuery.of(context).padding;
    _setInAppIconOffset(Offset(
      viewInsert.left,
      viewInsert.top +
          MediaQuery.of(context).viewPadding.top +
          MediaQuery.of(context).viewInsets.top,
    ));
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _normalizedInAppIconOffset?.dy,
        left: _normalizedInAppIconOffset?.dx,
        child: GestureDetector(
          onPanUpdate: (details) {
            _movingAnimationController.stop();
            _setInAppIconOffset(Offset(
              (_inAppIconOffset?.dx ?? 0) + details.delta.dx,
              (_inAppIconOffset?.dy ?? 0) + details.delta.dy,
            ));
            _endPointInAppIconOffset = _calculateInAppIconEndpoint();
            overlayState?.setState(() {});
            setState(() {});
          },
          onPanEnd: (details) {
            _horizontalVelocity =
                details.velocity.pixelsPerSecond.dx.abs().floorToDouble();
            _verticalVelocity =
                details.velocity.pixelsPerSecond.dy.abs().floorToDouble();
            _runMovingAnimation(
              _inAppIconOffset!,
              _endPointInAppIconOffset!,
              details.velocity.pixelsPerSecond,
              Size(
                _settingIconSize,
                _settingIconSize,
              ),
            );
            _historyInAppIconOffset.clear();
          },
          // child: FloatingActionButton(
          //   onPressed: _onPressed,
          //   backgroundColor: Colors.grey,
          //   mini: true,
          //   child: const Icon(
          //     Icons.settings,
          //   ),
          // ),
          child: Container(
            width: _settingIconSize,
            height: _settingIconSize,
            color: Colors.orange,
          ),
        ),
      ),
    );

    _addOverlay();
  }

  void _onPressed() async {
    _removeOverlay();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeView(),
      ),
    );
    _addOverlay();
  }

  void _addOverlay() {
    Overlay.of(context)?.insert(_overlayEntry);
  }

  void _removeOverlay() {
    _overlayEntry.remove();
  }

  Offset _getNormalizedInAppIconOffset(Offset inAppIconOffset) {
    final validatedOffset = _validateOffset(inAppIconOffset);
    return Offset(
      min(
        validatedOffset.dx,
        MediaQuery.of(context).size.width - _settingIconSize,
      ),
      min(
        validatedOffset.dy,
        MediaQuery.of(context).size.height - _settingIconSize,
      ),
    );
  }

  Offset _validateOffset(Offset newOffset) {
    final maxWidth = MediaQuery.of(context).size.width;
    final maxHeight = MediaQuery.of(context).size.height;
    return Offset(max(0, min(maxWidth, newOffset.dx)),
        max(0, min(maxHeight, newOffset.dy)));
  }
}
