import 'package:dio/dio.dart';

import '../api/console.dart';
import '../dio_exception.dart';
import '../models/models.dart';

class ConsoleRepository {
  static final ConsoleRepository _service = ConsoleRepository._internal();

  ConsoleRepository._internal();

  factory ConsoleRepository() => _service;

  Future<bool> createConsole(ConsoleModel console) async {
    try {
      await ConsoleApi().createConsole(console);
      return true;
    } on DioError catch (err) {
      final errorMessage = DioException.fromDioError(err).toString();
      throw errorMessage;
    }
  }
}