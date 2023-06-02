class DeviceModel {
  String deviceId;
  String deviceName;
  bool isOnline;

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceId": deviceId,
      "deviceName": deviceName,
      "isOnline": isOnline,
    };
  }
}
