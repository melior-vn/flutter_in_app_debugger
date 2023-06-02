import 'package:dio/dio.dart';

import '../api/device.dart';
import '../dio_exception.dart';
import '../models/models.dart';

class DeviceRepository {
  static final DeviceRepository _service = DeviceRepository._internal();

  DeviceRepository._internal();

  factory DeviceRepository() => _service;

  Future<bool> connectDevice(DeviceModel device) async {
    try {
      await DeviceApi().connectDevice(device);
      return true;
    } on DioError catch (err) {
      final errorMessage = DioException.fromDioError(err).toString();
      throw errorMessage;
    }
  }
}
