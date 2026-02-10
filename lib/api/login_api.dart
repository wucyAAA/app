import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/http_service.dart';
import '../services/app_state.dart';

/// 登录 API 响应
class LoginResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  final int? verifyCode;

  LoginResult({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.verifyCode,
  });
}

/// 登录相关 API
class LoginApi {
  /// 登录
  static Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final deviceId = await _getDeviceId();
      final encryptedPassword = _encryptPassword(password);

      // 动态判断平台 source (仅支持 'ios' 和 'android')
      final source = (!kIsWeb && Platform.isIOS) ? 'ios' : 'android';

      final response = await http.post(
        'login',
        data: {
          'username': username,
          'password': encryptedPassword,
          'ssid': deviceId,
          'source': source,
        },
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        // 检查业务状态码
        if (body['code'] == 200) {
          final data = body['data'];

          if (data is Map<String, dynamic>) {
            final verifyCode = data['code'];

            if (verifyCode == 0 || verifyCode == 2) {
              // 登录成功
              final user = User(
                id: data['user_id'].toString(),
                name: data['username'] ?? '',
                email: '',
                avatar: data['avatar'],
              );

              return LoginResult(
                success: true,
                user: user,
                token: data['token'],
              );
            } else {
              // 需要验证
              return LoginResult(
                success: false,
                message: '需要验证',
                verifyCode: verifyCode,
              );
            }
          } else {
            // data 不是 Map，可能是错误信息字符串
            return LoginResult(
              success: false,
              message: data.toString(),
            );
          }
        } else {
          // 业务错误
          return LoginResult(
            success: false,
            message: body['message'] ?? '登录失败 (${body['code']})',
          );
        }
      } else {
        return LoginResult(
          success: false,
          message: response.message ?? '登录失败',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }

  /// 获取设备唯一标识（机器码）
  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');

    if (deviceId == null || deviceId.isEmpty) {
      final deviceInfo = DeviceInfoPlugin();

      try {
        if (kIsWeb) {
          // Web 平台
          final webInfo = await deviceInfo.webBrowserInfo;
          deviceId = webInfo.userAgent ?? 'web_unknown';
          // 生成 MD5 作为唯一标识
          deviceId = md5.convert(utf8.encode(deviceId)).toString();
        } else if (Platform.isIOS) {
          // iOS 平台 - 使用 identifierForVendor
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        } else if (Platform.isAndroid) {
          // Android 平台 - 使用 androidId
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isMacOS) {
          // macOS 平台
          final macInfo = await deviceInfo.macOsInfo;
          deviceId = macInfo.systemGUID ?? '';
        } else if (Platform.isWindows) {
          // Windows 平台
          final windowsInfo = await deviceInfo.windowsInfo;
          deviceId = windowsInfo.deviceId;
        } else if (Platform.isLinux) {
          // Linux 平台
          final linuxInfo = await deviceInfo.linuxInfo;
          deviceId = linuxInfo.machineId ?? '';
        }
      } catch (e) {
        debugPrint('获取设备ID失败: $e');
      }

      // 如果获取失败，生成一个随机ID
      if (deviceId == null || deviceId.isEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        deviceId = md5.convert(utf8.encode(timestamp)).toString();
      }

      await prefs.setString('device_id', deviceId);
    }

    return deviceId;
  }

  /// 密码加密
  static String _encryptPassword(String password) {
    const salt = 'j3ZXHFo0ZEKy';
    // 第一次 MD5
    var bytes = utf8.encode(password);
    var digest = md5.convert(bytes);
    var firstMd5 = digest.toString();

    // 加盐后第二次 MD5
    var secondBytes = utf8.encode(salt + firstMd5);
    var secondDigest = md5.convert(secondBytes);
    return secondDigest.toString().toLowerCase();
  }
}
