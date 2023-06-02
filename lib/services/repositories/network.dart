import 'package:dio/dio.dart';

import '../api/network.dart';
import '../dio_exception.dart';
import '../models/models.dart';

class NetworkRepository {
  static final NetworkRepository _service = NetworkRepository._internal();

  NetworkRepository._internal();

  factory NetworkRepository() => _service;

  Future<bool> createNetwork(NetworkModel network) async {
    try {
      await NetworkApi().createNetwork(network);
      return true;
    } on DioError catch (err) {
      final errorMessage = DioException.fromDioError(err).toString();
      throw errorMessage;
    }
  }
}