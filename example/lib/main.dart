import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/home/overlay_view.dart';
import 'package:flutter_in_app_debugger/interceptors/melior_dio_interceptor.dart';

// ..interceptors.add(CustomInterceptors()),
// if (KShipUrl.currentEnv == ENVIRONMENT.DEBUG)
//   FlutterInAppDebuggerView()

void main() {
  FlutterInAppDebuggerView.listen(() => runApp(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    MeliorDioInterceptors().fakeData(
      duration: const Duration(seconds: 1),
      numberOfRepetions: 5,
      fakeDataType: FakeDataType.randomResponse,
    );
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print('fake exception');
      Future.delayed(const Duration(seconds: 3))
          .then((value) => throw Exception('fake exception'));
      print('fake exception');
    });
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
            Positioned(
              width: 100,
              height: 100,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('text'),
              ),
            ),
            FlutterInAppDebuggerView()
          ],
        ),
      ),
    );
  }
}
