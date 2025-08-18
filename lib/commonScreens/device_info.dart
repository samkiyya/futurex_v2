// device_info.dart
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceData() async {
    Map<String, dynamic> deviceData = {};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.windows =>
            _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          _ => <String, dynamic> {
              'Error:': 'Platform not supported'
            },
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic> {'Error:': 'Failed to get platform version.'};
    }

    return deviceData;
  }

  String detectDeviceType(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      final double screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth > 600) {
        return 'Tablet';
      } else {
        return 'Mobile';
      }
    } else {
      return 'Computer';
    }
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic> {
      'board': build.board,
      'brand': build.brand,
      'device': build.device,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic> {
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic> {
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'platform': data.platform,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic> {
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic> {
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
    };
  }
}
