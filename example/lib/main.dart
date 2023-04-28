import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/home/overlay_view.dart';

// ..interceptors.add(CustomInterceptors()),
// if (KShipUrl.currentEnv == ENVIRONMENT.DEBUG)
//   FlutterInAppDebuggerView()

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Center(
              child: Text('Running on: something\n'),
            ),
            FlutterInAppDebuggerView()
          ],
        ),
      ),
    );
  }
}
