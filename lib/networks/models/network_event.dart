import 'package:flutter/material.dart';

import 'models.dart';

class NetworkEvent<R, T> {
  NetworkEvent({
    required this.request,
    NetworkResponse<T>? response,
    NetworkError<T>? error,
  })  : requestTime = DateTime.now(),
        _response = response,
        _error = error,
        _responseTime =
            response != null || error != null ? DateTime.now() : null;

  final NetworkRequest<R> request;
  final DateTime requestTime;
  DateTime? _responseTime;
  DateTime? get responseTime => _responseTime;

  NetworkResponse<T>? _response;
  NetworkResponse<T>? get response => _response;
  set setResponse(NetworkResponse<T> response) {
    _response = response;
    _responseTime = DateTime.now();
  }

  NetworkError<T>? _error;
  NetworkError<T>? get error => _error;
  set setError(NetworkError<T> error) {
    _error = error;
    _responseTime = DateTime.now();
  }

  NetworkRequestStatus get status {
    var status = NetworkRequestStatus.running;
    if (response != null) {
      status = NetworkRequestStatus.done;
    } else if (error != null) {
      status = NetworkRequestStatus.failed;
    }
    return status;
  }

  String get statusText {
    switch (status) {
      case NetworkRequestStatus.running:
        return 'Running';
      case NetworkRequestStatus.done:
        if (response?.statusCode == 200) {
          return response?.statusCode.toString() ?? 'Done';
        } else {
          return 'Falied ${response?.statusCode}';
        }

      case NetworkRequestStatus.failed:
        return 'Error';
    }
  }

  Color get statusTextColor {
    switch (status) {
      case NetworkRequestStatus.running:
        return Colors.yellow.shade900;
      case NetworkRequestStatus.done:
        if (response?.statusCode == 200) {
          return Colors.green;
        } else {
          return Colors.orange;
        }
      case NetworkRequestStatus.failed:
        return Colors.red;
    }
  }
}
