import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NetworkEvent {
  NetworkEvent({
    required this.request,
    this.response,
    this.error,
  });

  RequestOptions request;
  Response? response;
  DioError? error;

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
        return 'DioError';
    }
  }

  Color get statusTextColor {
    switch (status) {
      case NetworkRequestStatus.running:
        return Colors.yellow;
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

enum NetworkRequestStatus { running, done, failed }
