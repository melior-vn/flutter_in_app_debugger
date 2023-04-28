import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_in_app_debugger/flutter_in_app_debugger_method_channel.dart';

void main() {
  MethodChannelFlutterInAppDebugger platform = MethodChannelFlutterInAppDebugger();
  const MethodChannel channel = MethodChannel('flutter_in_app_debugger');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
