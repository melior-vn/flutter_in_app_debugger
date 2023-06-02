import 'package:dio/dio.dart';

import '../api_provider.dart';
import '../models/models.dart';

class ConsoleApi {
  static final ConsoleApi _service = ConsoleApi._internal();

  ConsoleApi._internal();

  factory ConsoleApi() => _service;

  Future<Response> createConsole(ConsoleModel console) async {
    final response = await ApiProvider().post(
      "/consoles",
      data: console.toJson(),
    );
    return response;
  }  
}