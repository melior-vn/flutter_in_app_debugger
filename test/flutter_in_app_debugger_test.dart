import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_in_app_debugger/flutter_in_app_debugger.dart';
import 'package:flutter_in_app_debugger/flutter_in_app_debugger_platform_interface.dart';
import 'package:flutter_in_app_debugger/flutter_in_app_debugger_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterInAppDebuggerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterInAppDebuggerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterInAppDebuggerPlatform initialPlatform = FlutterInAppDebuggerPlatform.instance;

  test('$MethodChannelFlutterInAppDebugger is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterInAppDebugger>());
  });

  test('getPlatformVersion', () async {
    FlutterInAppDebugger flutterInAppDebuggerPlugin = FlutterInAppDebugger();
    MockFlutterInAppDebuggerPlatform fakePlatform = MockFlutterInAppDebuggerPlatform();
    FlutterInAppDebuggerPlatform.instance = fakePlatform;

    expect(await flutterInAppDebuggerPlugin.getPlatformVersion(), '42');
  });
}
