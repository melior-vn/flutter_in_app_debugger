class ConsoleModel {
  String deviceId;
  String content;

  ConsoleModel({
    required this.deviceId,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      "deviceId": deviceId,
      "content": content,
    };
  }
}
