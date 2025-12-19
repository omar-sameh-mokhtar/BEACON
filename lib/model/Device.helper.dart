import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceIdHelper {
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      return android.id;
    }
    return 'unknown-device';
  }
}
