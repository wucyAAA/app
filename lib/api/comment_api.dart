import '../services/http_service.dart';

/// 股票数据模型
class Stock {
  final String code;
  final String name;
  final String change;
  final String open;
  final String close;

  Stock({
    required this.code,
    required this.name,
    required this.change,
    this.open = '',
    this.close = '',
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      change: json['change'] ?? '',
      open: json['open'] ?? '',
      close: json['close'] ?? '',
    );
  }
}

/// 用户类型枚举
enum UserType { seller, retail, suspectedSeller, unknown }

/// 评论/研报数据模型
class CommentItem {
  final int id;
  final String time;
  final int source;
  final int sourceId;
  final int seedId;
  final String type;
  final String contentType;
  final String title;
  final String content;
  final String organization;
  final String author;
  final String status;
  final String rawType;
  final bool isPrivate;
  final bool isHot;
  final bool isOptimistic;
  final String? code;
  final String owner;
  final List<Stock> stocks;
  final bool hasDup;
  final String detailWithStyle;
  final String url;
  final String fileName;
  final int tag;
  final String raw;
  final String text;
  final bool push;
  final bool click;
  final bool dup;
  final bool zsxq;
  final List<String> keywords;
  final List<String> tags;
  final String abstract_;
  final String industry;

  CommentItem({
    required this.id,
    required this.time,
    required this.source,
    required this.sourceId,
    required this.seedId,
    required this.type,
    required this.contentType,
    required this.title,
    required this.content,
    required this.organization,
    required this.author,
    required this.status,
    required this.rawType,
    required this.isPrivate,
    required this.isHot,
    required this.isOptimistic,
    this.code,
    required this.owner,
    required this.stocks,
    required this.hasDup,
    required this.detailWithStyle,
    required this.url,
    required this.fileName,
    required this.tag,
    required this.raw,
    required this.text,
    required this.push,
    required this.click,
    required this.dup,
    required this.zsxq,
    required this.keywords,
    required this.tags,
    required this.abstract_,
    required this.industry,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    // 解析股票列表
    List<Stock> stockList = [];
    if (json['stock'] != null && json['stock'] is List) {
      stockList = (json['stock'] as List)
          .map((e) => Stock.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // 解析关键词列表
    List<String> keywordList = [];
    if (json['keywords'] != null && json['keywords'] is List) {
      keywordList = (json['keywords'] as List).map((e) => e.toString()).toList();
    }

    // 解析标签列表
    List<String> tagList = [];
    if (json['tags'] != null && json['tags'] is List) {
      tagList = (json['tags'] as List).map((e) {
        if (e is Map) {
          return e['name']?.toString() ?? '';
        }
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
    }

    return CommentItem(
      id: json['id'] ?? 0,
      time: json['time'] ?? '',
      source: json['source'] ?? 0,
      sourceId: json['source_id'] ?? 0,
      seedId: json['seed_id'] ?? 0,
      type: json['type'] ?? '',
      contentType: json['content_type'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      organization: json['organization'] ?? '',
      author: json['author'] ?? '',
      status: json['status'] ?? '',
      rawType: json['raw_type'] ?? '',
      isPrivate: json['is_private'] ?? false,
      isHot: json['is_hot'] ?? false,
      isOptimistic: json['is_optimistic'] ?? false,
      code: json['code'],
      owner: json['owner'] ?? '',
      stocks: stockList,
      hasDup: json['has_dup'] ?? false,
      detailWithStyle: json['detail_with_style'] ?? '',
      url: json['url'] ?? '',
      fileName: json['file_name'] ?? '',
      tag: json['tag'] ?? 0,
      raw: json['raw'] ?? '',
      text: json['text'] ?? '',
      push: json['push'] ?? false,
      click: json['click'] ?? false,
      dup: json['dup'] ?? false,
      zsxq: json['zsxq'] ?? false,
      keywords: keywordList,
      tags: tagList,
      abstract_: json['abstract'] ?? '',
      industry: json['industry'] ?? '',
    );
  }

  /// 是否有图片
  bool get hasImage => rawType == 'image';

  /// 是否有视频
  bool get hasVideo {
    // 检查 rawType
    if (rawType == 'video') return true;
    // 检查内容中是否包含 video 标签
    if (content.contains('<video') || detailWithStyle.contains('<video')) return true;
    // 检查 URL 是否为视频文件
    if (url.isNotEmpty) {
      final lowerUrl = url.toLowerCase();
      if (lowerUrl.endsWith('.mp4') ||
          lowerUrl.endsWith('.webm') ||
          lowerUrl.endsWith('.mov') ||
          lowerUrl.endsWith('.m3u8')) {
        return true;
      }
    }
    return false;
  }

  /// 获取列表显示内容（去除HTML标签和换行）
  String get listDisplayContent {
    String text = detailWithStyle;
    // 去除整个 video 标签块（包括内容）
    text = text.replaceAll(RegExp(r'<video[^>]*>[\s\S]*?</video>', caseSensitive: false), '');
    // 去除整个 audio 标签块
    text = text.replaceAll(RegExp(r'<audio[^>]*>[\s\S]*?</audio>', caseSensitive: false), '');
    // 去除HTML标签
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // 去除HTML注释
    text = text.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
    // 去除换行符
    text = text.replaceAll(RegExp(r'[\r\n]+'), ' ');
    // 去除多余空格
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// 获取用户类型
  UserType get userType {
    if (tags.contains('卖方')) return UserType.seller;
    if (tags.contains('散户')) return UserType.retail;
    if (tags.contains('疑似卖方')) return UserType.suspectedSeller;
    return UserType.unknown;
  }

  /// 用户类型标签
  String get userTypeLabel {
    switch (userType) {
      case UserType.seller:
        return '卖方';
      case UserType.retail:
        return '散户';
      case UserType.suspectedSeller:
        return '疑似卖方';
      case UserType.unknown:
        return '';
    }
  }

  /// 获取显示标题（优先用 title，否则用 raw）
  String get displayTitle {
    if (title.isNotEmpty) return title;
    if (raw.isNotEmpty) return raw;
    return content.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 获取格式化时间
  String get formattedTime {
    if (time.isEmpty) return '';

    try {
      final dateTime = DateTime.parse(time);
      final now = DateTime.now();

      final isToday = dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;

      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute:$second';

      if (isToday) {
        return timeStr;
      } else {
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        return '$month-$day $timeStr';
      }
    } catch (e) {
      return time;
    }
  }
}

/// 评论列表响应
class CommentListResult {
  final bool success;
  final String? message;
  final List<CommentItem> items;
  final int total;
  final int cacheId;

  CommentListResult({
    required this.success,
    this.message,
    this.items = const [],
    this.total = 0,
    this.cacheId = 0,
  });
}

class CommentOperationResult {
  final bool success;
  final String? message;

  CommentOperationResult({required this.success, this.message});
}

/// 评论/研报相关 API
class CommentApi {
  /// 推送评论/研报
  static Future<CommentOperationResult> pushComment({required int id}) async {
    // 暂时屏蔽实际请求，如需开启请移除下面返回
    // return CommentOperationResult(
    //   success: false,
    //   message: '暂时屏蔽',
    // );
    
    try {
      final response = await http.post(
        'news/push', // 假设使用相同的推送接口
        data: {
          'id': id,
          'type': 'research', // 类型设为 research
        },
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        return CommentOperationResult(
          success: body['code'] == 200,
          message: body['message'] ?? (body['code'] == 200 ? '推送成功' : '推送失败'),
        );
      } else {
        return CommentOperationResult(
          success: false,
          message: response.message ?? '网络请求失败',
        );
      }
    } catch (e) {
      return CommentOperationResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }

  /// 获取评论/研报列表
  ///
  /// [pageSize] - 每页数量
  /// [pageNum] - 页码，从1开始
  /// [source] - 数据来源，默认 "new"
  /// [embeddingLimit] - 嵌入相似度阈值
  /// [begin] - 开始时间（毫秒时间戳），可选
  /// [end] - 结束时间（毫秒时间戳），可选
  /// [tags] - 标签过滤，多个标签用逗号分隔
  static Future<CommentListResult> getList({
    int pageSize = 20,
    int pageNum = 1,
    String source = 'new',
    double embeddingLimit = 0.03,
    int? begin,
    int? end,
    String? tags,
    String? keyword,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'page_size': pageSize,
        'page_num': pageNum,
        'source': source,
        'embedding_limit': embeddingLimit,
      };

      // 可选参数
      if (begin != null) params['begin'] = begin;
      if (end != null) params['end'] = end;
      if (tags != null && tags.isNotEmpty) params['tags'] = tags;
      if (keyword != null && keyword.isNotEmpty) params['keyword'] = keyword;

      final response = await http.get('research/new/list', params: params);

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        if (body['code'] == 200) {
          final data = body['data'];
          if (data != null && data['data'] != null) {
            final List<dynamic> list = data['data'];
            final items = list.map((e) => CommentItem.fromJson(e)).toList();
            return CommentListResult(
              success: true,
              items: items,
              total: data['total'] ?? 0,
              cacheId: data['cache_id'] ?? 0,
            );
          }
          return CommentListResult(success: true, items: []);
        } else {
          return CommentListResult(
            success: false,
            message: body['message'] ?? '获取数据失败',
          );
        }
      } else {
        return CommentListResult(
          success: false,
          message: response.message ?? '网络请求失败',
        );
      }
    } catch (e) {
      return CommentListResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }

  /// 首次加载
  static Future<CommentListResult> loadInitial({
    int pageSize = 20,
    String? tags,
  }) {
    return getList(pageSize: pageSize, pageNum: 1, tags: tags);
  }

  /// 加载更多（下一页）
  static Future<CommentListResult> loadMore({
    required int pageNum,
    int pageSize = 20,
    String? tags,
  }) {
    return getList(pageSize: pageSize, pageNum: pageNum, tags: tags);
  }
}
