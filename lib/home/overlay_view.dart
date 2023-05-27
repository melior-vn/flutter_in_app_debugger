import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/console/models/log_event.dart';
import 'package:flutter_in_app_debugger/networks/models/models.dart';
import 'package:flutter_in_app_debugger/shared/animations/linear_moving_animation.dart';

import 'mixins/overlay_mixin.dart';

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
    with TickerProviderStateMixin, FlutterInAppDebuggerOverlayMixin {
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
  }

  @override
  void didChangeDependencies() {
    initFlutterInAppOverlay(
      context,
      iconSize: max(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height) *
          0.08,
      vsync: this,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrants) {
      return const Stack(children: [
        SizedBox.shrink(),
      ]);
    });
  }

  @override
  void dispose() {
    disposeFlutterInAppOverlay();
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
}
