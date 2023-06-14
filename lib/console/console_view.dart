import 'package:flutter/material.dart';
import 'package:flutter_in_app_debugger/configs/configs.dart';
import 'package:flutter_in_app_debugger/home/overlay_view.dart';
import 'package:intl/intl.dart';

class ConsoleView extends StatefulWidget {
  const ConsoleView({Key? key}) : super(key: key);

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Console Debugger',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              FlutterInAppDebuggerView.globalKey.currentState?.removeAllLogs();
              if (mounted) setState(() {});
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.black,
            ),
          )
        ],
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream:
            FlutterInAppDebuggerView.globalKey.currentState!.logsStream.stream,
        builder: (context, _) {
          final logs =
              FlutterInAppDebuggerView.globalKey.currentState?.logs ?? [];
          return ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0 || index == logs.length + 1) {
                return const SizedBox.shrink();
              } else {
                final log = FlutterInAppDebuggerView
                    .globalKey.currentState?.logs[index - 1];
                if (log != null) {
                  final formatedTime = DateFormat('HH:mm:ss').format(log.time);
                  return Padding(
                    padding: const EdgeInsets.all(DEFAULT_PADDING),
                    child: Text(
                      '$formatedTime : ${log.message}${log.stackTrace != null ? '\n${log.stackTrace}' : ''}',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }
            },
            separatorBuilder: (_, __) => Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey.withOpacity(0.1),
            ),
            itemCount: logs.length + 2,
          );
        },
      ),
    );
  }
}
