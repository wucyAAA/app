import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'app_state.dart';
import '../utils/toast_utils.dart';

class HttpService {
  static HttpService? _instance;
  late Dio _dio;

  // 代理配置
  static String? _proxyHost;
  static int? _proxyPort;

  // 单例模式
  static HttpService get instance {
    _instance ??= HttpService._internal();
    return _instance!;
  }

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      // API 基础地址
      baseUrl: 'https://hy.yunmagic.com/api/v1/',
      // 连接超时
      connectTimeout: const Duration(seconds: 10),
      // 接收超时
      receiveTimeout: const Duration(seconds: 15),
      // 发送超时
      sendTimeout: const Duration(seconds: 10),
      // 默认请求头
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 配置代理（仅在调试模式下且非Web环境）
    if (kDebugMode && !kIsWeb) {
      _setupProxy();
    }

    // 添加拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));

    // 调试模式下打印日志
    // if (kDebugMode) {
    //   _dio.interceptors.add(LogInterceptor(
    //     requestBody: true,
    //     responseBody: true,
    //   ));
    // }
  }

  // 设置代理
  void _setupProxy() {
    if (_proxyHost == null || _proxyPort == null) return;

    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();

      client.findProxy = (uri) => 'PROXY $_proxyHost:$_proxyPort';
      // 忽略证书验证（仅开发环境）
      client.badCertificateCallback = (cert, host, port) => true;
      debugPrint('HTTP Proxy: $_proxyHost:$_proxyPort');

      return client;
    };
  }

  /// 配置代理地址
  /// 示例: setProxy('127.0.0.1', 7890)
  static void setProxy(String host, int port) {
    _proxyHost = host;
    _proxyPort = port;
    // 如果实例已存在，重新配置（非Web环境）
    if (_instance != null && kDebugMode && !kIsWeb) {
      _instance!._setupProxy();
    }
  }

  /// 清除代理
  static void clearProxy() {
    _proxyHost = null;
    _proxyPort = null;
    if (_instance != null && kDebugMode && !kIsWeb) {
      _instance!._setupProxy();
    }
  }

  // 设置 baseUrl
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  // 设置 Token
  void setToken(String token) {
    _dio.options.headers['Token'] = token;
  }

  // 清除 Token
  void clearToken() {
    _dio.options.headers.remove('Token');
  }

  // 请求拦截器
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 自动从全局状态读取 token
    final token = AppState.instance.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Token'] = token;
    }

    if (kDebugMode) {
      debugPrint('------------------------------------------------');
      debugPrint('Request: [${options.method}] ${options.uri}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('Params: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('Body: ${options.data}');
      }
      debugPrint('------------------------------------------------');
    }
    handler.next(options);
  }

  // 响应拦截器
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('Response: [${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  // 错误拦截器
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    // 检查 401 未授权
    if (error.response?.statusCode == 401) {
      ToastUtils.showWarning('登录已过期，请重新登录');
      AppState.instance.logout();
    }

    // 统一错误处理
    String message = _getErrorMessage(error);
    debugPrint('HTTP Error: $message');
    handler.next(error);
  }

  // 获取错误信息
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '请求超时';
      case DioExceptionType.receiveTimeout:
        return '响应超时';
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode);
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接失败';
      default:
        return '网络异常';
    }
  }

  // 处理状态码
  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求资源不存在';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      default:
        return '请求失败 ($statusCode)';
    }
  }

  // GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // 上传文件
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required String filePath,
    String fileKey = 'file',
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath),
        if (extraData != null) ...extraData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.error(_getErrorMessage(e), e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}

// 统一响应封装
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.isSuccess,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(isSuccess: true, data: data);
  }

  factory ApiResponse.error(String message, [int? statusCode]) {
    return ApiResponse(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

// 全局快捷访问
HttpService get http => HttpService.instance;
