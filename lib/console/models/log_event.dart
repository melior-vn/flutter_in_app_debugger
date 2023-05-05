enum LogEventType { log, error }

class LogEvent {
  LogEvent({
    required this.message,
    this.stackTrace,
    this.type = LogEventType.log,
  }) : time = DateTime.now();
  final LogEventType type;
  final String message;
  final String? stackTrace;
  final DateTime time;
}
