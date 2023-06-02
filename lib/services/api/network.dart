import 'package:dio/dio.dart';

import '../api_provider.dart';
import '../models/models.dart';

class NetworkApi {
  static final NetworkApi _service = NetworkApi._internal();

  NetworkApi._internal();

  factory NetworkApi() => _service;

  Future<Response> createNetwork(NetworkModel network) async {
    final response = await ApiProvider().post(
      "/networks",
      data: network.toJson(),
    );
    return response;
  }  
}