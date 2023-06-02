import 'package:dio/dio.dart';

class StatusCodeConstants {
  static const int BAD_REQUEST = 400;
  static const int UNAUTHORIZED = 401;
  static const int FORBIDDEN = 403;
  static const int NOT_FOUND = 404;
  static const int INTERNAL_SERVER_ERROR = 500;
  static const int BAD_GATEWAY = 502;
}

class DioException implements Exception {
  late String message;

  DioException.fromDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = 'Request to API server was cancelled';
        break;
      case DioErrorType.connectTimeout:
        message = 'Connection timeout with API server';
        break;
      case DioErrorType.receiveTimeout:
        message = 'Receive timeout in connection with API server';
        break;
      case DioErrorType.response:
        message = _handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioErrorType.sendTimeout:
        message = 'Send timeout in connection with API server';
        break;
      case DioErrorType.other:
        if (dioError.message.contains('SocketException')) {
          message = 'No Internet';
          break;
        }
        message = 'Unexpected error occurred';
        break;
      default:
        message = 'Something went wrong';
        break;
    }
  }

  String _handleError(int? statusCode, error) {
    switch (statusCode) {
      case StatusCodeConstants.BAD_REQUEST:
        return error['message'] ?? 'Bad request';
      case StatusCodeConstants.UNAUTHORIZED:
        return error['message'] ?? 'Unauthorized';
      case StatusCodeConstants.FORBIDDEN:
        return error['message'] ?? 'Forbidden';
      case StatusCodeConstants.NOT_FOUND:
        return error['message'] ?? 'Not Found';
      case StatusCodeConstants.INTERNAL_SERVER_ERROR:
        return 'Internal server error';
      case StatusCodeConstants.BAD_GATEWAY:
        return 'Bad gateway';
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message;
}