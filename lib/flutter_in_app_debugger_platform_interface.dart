import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_in_app_debugger_method_channel.dart';

abstract class FlutterInAppDebuggerPlatform extends PlatformInterface {
  /// Constructs a FlutterInAppDebuggerPlatform.
  FlutterInAppDebuggerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterInAppDebuggerPlatform _instance = MethodChannelFlutterInAppDebugger();

  /// The default instance of [FlutterInAppDebuggerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterInAppDebugger].
  static FlutterInAppDebuggerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterInAppDebuggerPlatform] when
  /// they register themselves.
  static set instance(FlutterInAppDebuggerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
