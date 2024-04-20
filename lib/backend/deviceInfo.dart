// ignore_for_file: file_names

import 'package:device_info/device_info.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:device_marketing_names/device_marketing_names.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final DeviceMarketingNames _deviceMarketing = DeviceMarketingNames();

  Future<String> getIpAddress() async {
    final url = Uri.parse('http://ipconfig.io/ip');

    final response = await http.get(url);
    final status = response.statusCode;
    if (status != 200) throw Exception('http.get error: statusCode= $status');

    return response.body;
  }

  Future<String> getDeviceName() async {
    String deviceName = await _deviceMarketing.getNames();

    return deviceName;
  }

  Future<String> getDeviceModel() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    String deviceModel = androidInfo.model;

    return deviceModel;
  }

  Future<String> getDeviceHost() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    String deviceHost = androidInfo.host;

    return deviceHost;
  }

  Future<String> getDeviceID() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    String deviceID = androidInfo.id;

    return deviceID;
  }

  Future<String> getIsPhysical() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    String physical = androidInfo.isPhysicalDevice.toString();

    return physical;
  }

  Future<Map<String, String>> getAndroidInfo() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
    String? deviceName = _deviceMarketing.deviceNames;

    Map<String, String> data = <String, String>{}
      ..addAll({"devicename": deviceName!})
      ..addAll({"devicemodel": androidInfo.model})
      ..addAll({"devicehost": androidInfo.host})
      ..addAll({"deviceid": androidInfo.id})
      ..addAll({"isphysical": androidInfo.isPhysicalDevice.toString()});

    return data;
  }
}
