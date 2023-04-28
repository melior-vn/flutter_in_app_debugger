import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_in_app_debugger_platform_interface.dart';

/// An implementation of [FlutterInAppDebuggerPlatform] that uses method channels.
class MethodChannelFlutterInAppDebugger extends FlutterInAppDebuggerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_in_app_debugger');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
