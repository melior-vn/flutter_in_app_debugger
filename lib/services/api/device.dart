import 'package:dio/dio.dart';

import '../api_provider.dart';
import '../models/models.dart';

class DeviceApi {
  static final DeviceApi _service = DeviceApi._internal();

  DeviceApi._internal();

  factory DeviceApi() => _service;

  Future<Response> connectDevice(DeviceModel device) async {
    final response = await ApiProvider().put(
      "/devices",
      data: device.toJson(),
    );
    return response;
  }  
}