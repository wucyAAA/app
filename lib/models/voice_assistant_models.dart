import 'package:flutter/material.dart';
import '../api/voice_api.dart';

// 任务状态枚举
enum TaskStatus { generated, confirmed, executing, completed, failed }

// 任务参数模型
class TaskParam {
  final String key;
  String value;
  final List<String>? options;

  TaskParam({
    required this.key,
    required this.value,
    this.options,
  });

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'options': options,
      };

  factory TaskParam.fromJson(Map<String, dynamic> json) {
    return TaskParam(
      key: json['key'],
      value: json['value'],
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

// 任务数据模型
class Task {
  final String id; // 本地唯一ID
  final String taskId; // 服务端返回的 batch task_id
  final String type;
  String description;
  final List<TaskParam> parameters;
  TaskStatus status;
  VoiceFunction rawFunction; // 原始数据，用于执行时回传
  bool isExpanded;

  Task({
    required this.id,
    required this.taskId,
    required this.type,
    required this.description,
    required this.parameters,
    required this.status,
    required this.rawFunction,
    this.isExpanded = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'type': type,
        'description': description,
        'parameters': parameters.map((e) => e.toJson()).toList(),
        'status': status.index,
        'rawFunction': rawFunction.toJson(),
        'isExpanded': isExpanded,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      taskId: json['taskId'],
      type: json['type'],
      description: json['description'],
      parameters: (json['parameters'] as List)
          .map((e) => TaskParam.fromJson(e))
          .toList(),
      status: TaskStatus.values[json['status']],
      rawFunction: VoiceFunction.fromJson(json['rawFunction']),
      isExpanded: json['isExpanded'],
    );
  }
}

// 会话数据模型
class VoiceSession {
  final String id;
  final String text; // 语音转文字结果
  final List<Task> tasks; // 解析出的任务列表
  final DateTime timestamp;

  VoiceSession({
    required this.id,
    required this.text,
    required this.tasks,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
      };

  factory VoiceSession.fromJson(Map<String, dynamic> json) {
    return VoiceSession(
      id: json['id'],
      text: json['text'],
      tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
