import 'dart:convert';
import '../services/http_service.dart';
import '../services/app_state.dart';

// 数据模型

class VoiceArgument {
  dynamic value; // Mutable for editing
  final double confidence;
  final dynamic confirmValue;
  final List<String>? options;
  final String originalTextSnippet;

  VoiceArgument({
    required this.value,
    this.confidence = 0.0,
    this.confirmValue,
    this.options,
    this.originalTextSnippet = '',
  });

  factory VoiceArgument.fromJson(Map<String, dynamic> json) {
    return VoiceArgument(
      value: json['value'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      confirmValue: json['confirm_value'],
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
      originalTextSnippet: json['original_text_snippet'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      'confirm_value': confirmValue,
      'options': options ?? [],
      'original_text_snippet': originalTextSnippet,
    };
  }
}

class VoiceFunction {
  final String name;
  final String functionName;
  final double confidence;
  final String originalTextSnippet;
  final Map<String, VoiceArgument> arguments;

  VoiceFunction({
    required this.name,
    this.functionName = '',
    this.confidence = 0.0,
    this.originalTextSnippet = '',
    required this.arguments,
  });

  factory VoiceFunction.fromJson(Map<String, dynamic> json) {
    final argsMap = <String, VoiceArgument>{};
    if (json['arguments'] != null) {
      (json['arguments'] as Map<String, dynamic>).forEach((key, value) {
        argsMap[key] = VoiceArgument.fromJson(value);
      });
    }
    return VoiceFunction(
      name: json['name'] ?? '',
      functionName: json['function_name'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      originalTextSnippet: json['original_text_snippet'] ?? '',
      arguments: argsMap,
    );
  }

  Map<String, dynamic> toJson() {
    final argsJson = <String, dynamic>{};
    arguments.forEach((key, value) {
      argsJson[key] = value.toJson();
    });
    return {
      'name': name,
      'function_name': functionName,
      'confidence': confidence,
      'original_text_snippet': originalTextSnippet,
      'arguments': argsJson,
    };
  }
}

class VoiceTaskResult {
  final String taskId;
  final String audioText;
  final List<VoiceFunction> functions;

  VoiceTaskResult({
    required this.taskId,
    required this.audioText,
    required this.functions,
  });

  factory VoiceTaskResult.fromJson(Map<String, dynamic> json) {
    var funcList = <VoiceFunction>[];
    if (json['functions'] != null) {
      funcList = (json['functions'] as List)
          .map((e) => VoiceFunction.fromJson(e))
          .toList();
    }
    return VoiceTaskResult(
      taskId: json['task_id'] ?? '',
      audioText: json['audio_text'] ?? '',
      functions: funcList,
    );
  }
}

class CommandExecutionResult {
  final String name;
  final bool success;
  final String? reason;

  CommandExecutionResult({
    required this.name,
    required this.success,
    this.reason,
  });

  factory CommandExecutionResult.fromJson(Map<String, dynamic> json) {
    return CommandExecutionResult(
      name: json['name'] ?? '',
      success: json['success'] ?? false,
      reason: json['reason'],
    );
  }
}

// API

class VoiceApi {
  // Scenario A: Voice to Command
  static Future<ApiResponse<VoiceTaskResult>> sendVoice({
    required String audioBase64,
    bool useAsr = false,
  }) async {
    try {
      final response = await http.post(
        'laboratory/command/send',
        data: {
          'audio_base64': audioBase64,
          'use_asr': useAsr,
        },
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        if (body['code'] == 200 && body['data'] != null) {
          // 实际数据在 data.data 中
          final innerData = body['data']['data'];
          if (innerData != null) {
            return ApiResponse.success(VoiceTaskResult.fromJson(innerData));
          }
          return ApiResponse.error('返回数据格式错误');
        } else {
          return ApiResponse.error(
            body['message'] ?? body['msg'] ?? '解析语音失败',
            body['code'],
          );
        }
      } else {
        return ApiResponse.error(response.message ?? '网络请求失败');
      }
    } catch (e) {
      return ApiResponse.error('请求异常: $e');
    }
  }

  // Scenario B: Execute Command
  static Future<ApiResponse<List<CommandExecutionResult>>> executeCommand({
    required String taskId,
    required List<VoiceFunction> commands,
  }) async {
    try {
      // 从全局缓存读取 user_id
      final userId = AppState.instance.user?.id ?? '';

      final requestData = {
        'task_id': taskId,
        'user_id': userId,
        'command_data': commands.map((e) => e.toJson()).toList(),
      };
      // 显式编码为 JSON 字符串，确保格式正确
      final jsonBody = jsonEncode(requestData);

      final response = await http.post(
        'laboratory/command/send',
        data: jsonBody,
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        if (body['code'] == 200 && body['data'] != null) {
          final dataInner = body['data']['data'];
          if (dataInner is List) {
            final list = dataInner
                .map((e) => CommandExecutionResult.fromJson(e))
                .toList();
            return ApiResponse.success(list);
          }
          return ApiResponse.success([]);
        } else {
          return ApiResponse.error(
            body['msg'] ?? '执行指令失败',
            body['code'],
          );
        }
      } else {
        return ApiResponse.error(response.message ?? '网络请求失败');
      }
    } catch (e) {
      return ApiResponse.error('请求异常: $e');
    }
  }
}
