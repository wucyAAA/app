import '../services/http_service.dart';

class PushRecord {
  final int id;
  final String time;
  final String from;
  final String site;
  final String path;
  final String external;
  final String content;
  final String type;
  final String link;
  final String url; // Added url field
  final int seedId;
  final int ruleId;
  final String sourceTime;
  final int? dataId; // Already in constructor but maybe missing in field list? No, it was there.
  final String raw;
  final String source;

  PushRecord({
    required this.id,
    required this.time,
    required this.from,
    required this.site,
    required this.path,
    required this.external,
    required this.content,
    required this.type,
    required this.link,
    required this.url,
    required this.seedId,
    required this.ruleId,
    required this.sourceTime,
    this.dataId, // Make optional to match factory
    required this.raw,
    required this.source,
  });

  factory PushRecord.fromJson(Map<String, dynamic> json) {
    return PushRecord(
      id: json['id'] ?? 0,
      time: json['time'] ?? '',
      from: json['from'] ?? '',
      site: json['site'] ?? '',
      path: json['path'] ?? '',
      external: json['external'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      link: json['link'] ?? '',
      url: json['url'] ?? '', // Parse url
      seedId: json['seed_id'] ?? 0,
      ruleId: json['rule_id'] ?? 0,
      sourceTime: json['source_time'] ?? '',
      dataId: json['data_id'],
      raw: json['raw'] ?? '',
      source: json['source'] ?? '',
    );
  }

  /// 是否有图片
  bool get hasImage => external == 'image' && url.isNotEmpty;

  /// 是否是支持中间页跳转的类型
  bool get isMidPageType {
    const supported = [
      'bloomberg',
      'bloomberg_test',
      'reuters',
      'twitter',
      'caixin',
      'jnz',
      'zsxq',
      'product',
      'pzb',
      'acecamp'
    ];
    return supported.contains(external);
  }

  /// 获取跳转用的 record_id (优先使用 data_id)
  String get midPageRecordId => (dataId ?? id).toString();

  /// 获取跳转用的链接
  String get midPageLink {
    if (link.isEmpty) return '';
    if (external == 'jnz') {
      return Uri.encodeComponent(link);
    }
    return link;
  }

  // 获取类型显示标签
  String get typeLabel {
    switch (type) {
      case 'user':
        return '用户';
      case 'auto_recommend':
        return '自动新闻';
      case 'product':
        return '产品价格';
      case 'system':
        return '系统';
      case 'highly_recommend':
        return '强推';
      case 'ai_recommend':
        return 'AI推送';
      default:
        return '其他';
    }
  }
}

class PushListResult {
  final bool success;
  final String? message;
  final List<PushRecord> items;
  final int total;

  PushListResult({
    required this.success,
    this.message,
    this.items = const [],
    this.total = 0,
  });
}

class PushApi {
  /// 获取推送列表
  static Future<PushListResult> getList({
    int pageNum = 1,
    int pageSize = 20,
    String? keyword,
    int? beginTime,
    int? endTime,
    String? type,
    bool? omitSurvey,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page_num': pageNum,
        'page_size': pageSize,
      };

      if (keyword != null && keyword.isNotEmpty) {
        params['keyword'] = keyword;
      }
      if (beginTime != null) {
        params['begin_time'] = beginTime;
      }
      if (endTime != null) {
        params['end_time'] = endTime;
      }
      if (type != null && type.isNotEmpty) {
        params['type'] = type;
      }
      if (omitSurvey != null) {
        params['omit_survey'] = omitSurvey;
      }

      final response = await http.get('push/list', params: params);

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        if (body['code'] == 200) {
          final data = body['data'];
          if (data != null && data['data'] != null) {
            final List<dynamic> list = data['data'];
            final items = list.map((e) => PushRecord.fromJson(e)).toList();
            return PushListResult(
              success: true,
              items: items,
              total: data['total'] ?? 0,
            );
          }
          return PushListResult(success: true, items: []);
        } else {
          return PushListResult(
            success: false,
            message: body['message'] ?? '获取数据失败',
          );
        }
      } else {
        return PushListResult(
          success: false,
          message: response.message ?? '网络请求失败',
        );
      }
    } catch (e) {
      return PushListResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }
}