import 'dart:async';
import 'dart:developer' as DartDev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  late AnimationController _animationController;
  late Animation<double> _animation;
  late OverlayEntry _overlayEntry;
  final _settingIconSize = 40.0;
  Offset? _settingOffset;
  final _requests = <NetworkEvent>[];
  final _requestsStream = StreamController<NetworkEvent>.broadcast();
  final _logs = <LogEvent>[];
  final _logsStream = StreamController<LogEvent>.broadcast();

  List<NetworkEvent> get requests => _requests;
  void removeAllRequests() => _requests.removeWhere((element) => true);

  StreamController<NetworkEvent> get requestsStream => _requestsStream;

  List<LogEvent> get logs => _logs;
  void removeAllLogs() => _logs.removeWhere((element) => true);
  StreamController<LogEvent> get logsStream => _logsStream;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.2,
          1.0,
          curve: Curves.ease,
        )));

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _showOverLay();
    });
  }

  @override
  void dispose() {
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
    Map<String, dynamic>? data,
    required InterceptorType type,
  }) {
    final networkEvent = NetworkEvent(
      type: type,
      request: NetworkRequest(
        baseUrl: baseUrl,
        path: path,
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

  void _showOverLay() async {
    final viewInsert = MediaQuery.of(context).padding;
    _settingOffset = Offset(
      viewInsert.left + 46,
      viewInsert.top +
          46 +
          MediaQuery.of(context).viewPadding.top +
          MediaQuery.of(context).viewInsets.top,
    );
    final overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _settingIconSize,
        height: _settingIconSize,
        top: _settingOffset?.dy,
        left: _settingOffset?.dx,
        child: ScaleTransition(
          scale: _animation,
          child: GestureDetector(
            onPanUpdate: (details) {
              _settingOffset = Offset(
                (_settingOffset?.dx ?? 0) + details.delta.dx,
                (_settingOffset?.dy ?? 0) + details.delta.dy,
              );
              overlayState?.setState(() {});
            },
            child: FloatingActionButton(
              onPressed: () async {
                _overlayEntry.remove();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeView(),
                  ),
                );
                await _animationController.forward();
                overlayState?.insert(_overlayEntry);
              },
              backgroundColor: Colors.grey,
              mini: true,
              child: const Icon(
                Icons.settings,
              ),
            ),
          ),
        ),
      ),
    );
    _animationController.addListener(() {
      overlayState?.setState(() {});
    });
    await _animationController.forward();
    overlayState?.insert(_overlayEntry);

    // await Future.delayed(const Duration(seconds: 5))
    //     .whenComplete(() => animationController!.reverse())
    //     .whenComplete(() => overlayEntry!.remove());
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
