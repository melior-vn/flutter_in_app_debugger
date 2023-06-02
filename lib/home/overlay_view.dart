import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/console/models/log_event.dart';
import 'package:flutter_in_app_debugger/networks/models/models.dart';
import 'package:flutter_in_app_debugger/services/models/console.dart';
import 'package:flutter_in_app_debugger/services/models/device.dart';
import 'package:flutter_in_app_debugger/services/models/network.dart';
import 'package:flutter_in_app_debugger/services/repositories/console.dart';
import 'package:flutter_in_app_debugger/services/repositories/device.dart';
import 'package:flutter_in_app_debugger/services/repositories/network.dart';
import 'package:flutter_in_app_debugger/shared/animations/linear_moving_animation.dart';

import 'mixins/overlay_mixin.dart';

class FlutterInAppDebuggerView extends StatefulWidget {
  final bool hasRemoteServer;
  final String? hostRemoteServer;

  FlutterInAppDebuggerView({
    this.hasRemoteServer = false,
    this.hostRemoteServer,
  }) : super(key: FlutterInAppDebuggerView.globalKey);

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

  String? deviceId;

  List<NetworkEvent> get requests => _requests;
  void removeAllRequests() => _requests.removeWhere((element) => true);

  StreamController<NetworkEvent> get requestsStream => _requestsStream;

  List<LogEvent> get logs => _logs;
  void removeAllLogs() => _logs.removeWhere((element) => true);
  StreamController<LogEvent> get logsStream => _logsStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      initFlutterInAppOverlay(
        context,
        iconSize: max(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.08,
        vsync: this,
      );
      _connectDevice(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrants) {
      return Stack(
        children: const [
          SizedBox.shrink(),
        ],
      );
    });
  }

  @override
  void dispose() {
    disposeFlutterInAppOverlay();
    _requestsStream.close();
    _connectDevice(false);
    super.dispose();
  }

  LogEvent addLog({required String message, String? stacktrace}) {
    final logEvent = LogEvent(
        message: message,
        stackTrace: stacktrace,
        type: stacktrace != null ? LogEventType.error : LogEventType.log);
    _logs.insert(0, logEvent);
    _logsStream.add(logEvent);
    _createConsole(logEvent);
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
      _createNetwork(_requests[networkEventIndex]);
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
      _createNetwork(networkEvent);
      return networkEvent;
    } else {
      debugPrint('[Flutter In-app Debugger] not found request');
      return null;
    }
  }

  Future<void> _connectDevice(bool isOnline) async {
    if(!widget.hasRemoteServer) return;
    final deviceInfo = await _getDeviceInfo();
    DeviceModel device = DeviceModel(
      deviceId: deviceInfo?[0] ?? "",
      deviceName: deviceInfo?[1] ?? "",
      isOnline: isOnline,
    );

    await DeviceRepository().connectDevice(device);
  }

  Future<void> _createConsole(LogEvent logEvent) async {
    if(!widget.hasRemoteServer) return;
    var _deviceId = deviceId;
    if (_deviceId == null) {
      final deviceInfo = await _getDeviceInfo();
      _deviceId = deviceInfo?[0];
    }

    final content = "${logEvent.message}\n${logEvent.stackTrace ?? ""}";

    ConsoleModel console = ConsoleModel(
      deviceId: _deviceId ?? "",
      content: content,
    );

    await ConsoleRepository().createConsole(console);
  }

  Future<void> _createNetwork(NetworkEvent networkEvent) async {
    if(!widget.hasRemoteServer) return;
    var _deviceId = deviceId;
    if (_deviceId == null) {
      final deviceInfo = await _getDeviceInfo();
      _deviceId = deviceInfo?[0];
    }

    int statusCode = 0;
    String responseData = "";

    switch (networkEvent.status) {
      case NetworkRequestStatus.done:
        statusCode = networkEvent.response?.statusCode ?? 200;
        responseData = jsonEncode(networkEvent.response?.responseData);
        break;
      case NetworkRequestStatus.failed:
        if (networkEvent.error != null && networkEvent.error!.error is DioError) {
          var error = networkEvent.error!.error as DioError;
          statusCode = error.response?.statusCode ?? 999;
          responseData = jsonEncode(error.response?.data);
        } else {
          return;
        }
        break;
      default:
        return;
    }

    NetworkModel network = NetworkModel(
        deviceId: _deviceId ?? "",
        method: networkEvent.request.method,
        path: networkEvent.request.path,
        statusCode: statusCode,
        request: jsonEncode(networkEvent.request.requestData),
        response: responseData);

    await NetworkRepository().createNetwork(network);
  }

  Future<List<String?>?> _getDeviceInfo() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosDeviceInfo = await deviceInfo.iosInfo;
      final deviceId = iosDeviceInfo.identifierForVendor;
      final deviceName = iosDeviceInfo.name;
      this.deviceId = deviceId;
      return [deviceId, deviceName];
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await deviceInfo.androidInfo;
      final deviceId = androidDeviceInfo.androidId;
      final deviceName = androidDeviceInfo.model;
      this.deviceId = deviceId;
      return [deviceId, deviceName];
    }
    return null;
  }

  String? getHostRemoteServer() {
    return widget.hostRemoteServer;
  }

  bool hasRemoteServer() {
    return widget.hasRemoteServer;
  }
}
