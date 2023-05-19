import 'dart:async';
import 'dart:developer' as DartDev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_in_app_debugger/console/models/log_event.dart';
import 'package:flutter_in_app_debugger/networks/models/models.dart';
import 'package:flutter_in_app_debugger/networks/views/network_view.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _movingAnimationController;
  late Animation<Offset> _movingAnimation;
  late OverlayEntry _overlayEntry;
  final _settingIconSize = 40.0;
  // Current offset
  Offset? _inAppIconOffset;
  // Last offset for calculate end point
  Offset? _lastInAppIconOffset;
  // Set both _inAppIconOffset and _lastInAppIconOffset
  void _setInAppIconOffset(Offset newOffset) {
    _lastInAppIconOffset = _inAppIconOffset ?? newOffset;
    _inAppIconOffset = newOffset;
    if (mounted) {
      _endPointInAppIconOffset = _calculateEndPointInAppIconOffset(
        _inAppIconOffset!,
        _lastInAppIconOffset!,
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      );
    }
  }

  // End point when end drag offset
  Offset? _endPointInAppIconOffset;

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
    _movingAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _initOverLay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
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
      viewInsert.left + 46,
      viewInsert.top +
          46 +
          MediaQuery.of(context).viewPadding.top +
          MediaQuery.of(context).viewInsets.top,
    ));
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _settingIconSize,
        height: _settingIconSize,
        top: _inAppIconOffset?.dy,
        left: _inAppIconOffset?.dx,
        child: GestureDetector(
          onPanUpdate: (details) {
            _setInAppIconOffset(Offset(
              (_inAppIconOffset?.dx ?? 0) + details.delta.dx,
              (_inAppIconOffset?.dy ?? 0) + details.delta.dy,
            ));
            overlayState?.setState(() {});
          },
          onPanEnd: (details) {
            setState(() {
              _horizontalVelocity =
                  details.velocity.pixelsPerSecond.dx.abs().floorToDouble();
              _verticalVelocity =
                  details.velocity.pixelsPerSecond.dy.abs().floorToDouble();
            });
          },
          child: FloatingActionButton(
            onPressed: _onPressed,
            backgroundColor: Colors.grey,
            mini: true,
            child: const Icon(
              Icons.settings,
            ),
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

  Offset? _calculateEndPointInAppIconOffset(
    Offset inAppIconOffset,
    Offset lastInAppIconOffset,
    double width,
    double height,
  ) {
    // 1. vector pháp tuyến
    // 1.1. (a, b) = (x1 - x2, y1 - y2)

    // 2. phương trình đường thẳng
    // 2.1. a*(x - x1) + b*(y - y1) = 0
    // 2.2. => a*x + b*y - (a*x1 + b*y1) = 0
    // 2.3. => y = ((a*x1 + b*y1) - a*x) / b
    // 2.4.   x = ((a*x1 + b*y1) - b*y) / a

    // 3. 4 điểm cắt tương ứng 4 đường của cạnh màn hình
    // 3.1. case x = 0
    // 3.2. case y = 0
    // 3.3. case x = width
    // 3.4. case y = height
    // NOTE*: Cần check song song
    final normalVector = Offset(
      inAppIconOffset.dx - lastInAppIconOffset.dx,
      inAppIconOffset.dy - inAppIconOffset.dy,
    );
  }
}
