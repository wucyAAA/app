import '../services/http_service.dart';

/// 新闻数据模型
class NewsItem {
  final int id;
  final String title;
  final String titleRaw;
  final String titleTime;
  final String? link;
  final String site;
  final String path;
  final int time;
  final bool mark;
  final int star;
  final int classId;
  final String? content;
  final String? author;
  final NewsTag? tag;

  NewsItem({
    required this.id,
    required this.title,
    required this.titleRaw,
    required this.titleTime,
    this.link,
    required this.site,
    required this.path,
    required this.time,
    required this.mark,
    required this.star,
    required this.classId,
    this.content,
    this.author,
    this.tag,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      titleRaw: json['title_raw'] ?? json['title'] ?? '',
      titleTime: json['title_time'] ?? '',
      link: json['link'],
      site: json['site'] ?? '',
      path: json['path'] ?? '',
      time: json['time'] ?? 0,
      mark: json['mark'] ?? false,
      star: json['star'] ?? 0,
      classId: json['class_id'] ?? 0,
      content: json['content'],
      author: json['author'],
      tag: json['tag'] != null ? NewsTag.fromJson(json['tag']) : null,
    );
  }

  /// 获取格式化的时间
  /// 当天只显示时:分:秒，非当天显示日期+时分秒
  String get formattedTime {
    if (time == 0) return '';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    final now = DateTime.now();

    // 判断是否是当天
    final isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    // 格式化时分秒
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute:$second';

    if (isToday) {
      // 当天只显示时间
      return timeStr;
    } else {
      // 非当天显示日期+时间
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      return '$month-$day $timeStr';
    }
  }
}

/// 新闻标签
class NewsTag {
  final String tag;
  final int rate;

  NewsTag({required this.tag, required this.rate});

  factory NewsTag.fromJson(Map<String, dynamic> json) {
    return NewsTag(
      tag: json['tag'] ?? '',
      rate: json['rate'] ?? 0,
    );
  }
}

/// 新闻列表响应
class NewsListResult {
  final bool success;
  final String? message;
  final List<NewsItem> items;

  NewsListResult({
    required this.success,
    this.message,
    this.items = const [],
  });
}

/// 加载方向
enum LoadDirection {
  up, // 上拉加载（更早的新闻）
  down, // 下拉加载（更新的新闻）
}

class NewsOperationResult {
  final bool success;
  final String? message;

  NewsOperationResult({required this.success, this.message});
}

/// 新闻相关 API
class NewsApi {
  /// 推送新闻
  static Future<NewsOperationResult> pushNews({required int id}) async {
    return NewsOperationResult(
      success: false,
      message: '暂时屏蔽',
    );
    try {
      final response = await http.post(
        'news/push',
        data: {
          'id': id,
          'type': 'news',
        },
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;
        return NewsOperationResult(
          success: body['code'] == 200,
          message: body['message'] ?? (body['code'] == 200 ? '推送成功' : '推送失败'),
        );
      } else {
        return NewsOperationResult(
          success: false,
          message: response.message ?? '网络请求失败',
        );
      }
    } catch (e) {
      return NewsOperationResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }

  /// 获取新闻列表
  ///
  /// [n] - 返回数据条数
  /// [offset] - 偏移基准 ID（首次加载可传 0）
  /// [direction] - 加载方向
  /// [leek] - 业务控制参数，默认 false
  static Future<NewsListResult> getNewsList({
    int n = 20,
    int offset = 0,
    LoadDirection direction = LoadDirection.down,
    bool leek = false,
  }) async {
    try {
      final response = await http.get(
        'news/roll',
        params: {
          'n': n,
          'offset': offset,
          'direction': direction == LoadDirection.up ? 'up' : 'down',
          'leek': leek,
        },
      );

      if (response.isSuccess && response.data != null) {
        final body = response.data as Map<String, dynamic>;

        if (body['code'] == 200) {
          final data = body['data'];
          if (data != null && data['data'] != null) {
            final List<dynamic> list = data['data'];
            final items = list.map((e) => NewsItem.fromJson(e)).toList();
            return NewsListResult(success: true, items: items);
          }
          return NewsListResult(success: true, items: []);
        } else {
          return NewsListResult(
            success: false,
            message: body['message'] ?? '获取新闻失败',
          );
        }
      } else {
        return NewsListResult(
          success: false,
          message: response.message ?? '网络请求失败',
        );
      }
    } catch (e) {
      return NewsListResult(
        success: false,
        message: '发生错误: $e',
      );
    }
  }

  /// 首次加载新闻
  static Future<NewsListResult> loadInitial({int count = 20}) {
    return getNewsList(n: count, offset: 0, direction: LoadDirection.down);
  }

  /// 加载更多（向下滚动，获取更早的新闻）
  static Future<NewsListResult> loadMore({required int minId, int count = 20}) {
    return getNewsList(n: count, offset: minId, direction: LoadDirection.down);
  }

  /// 刷新（下拉，获取最新的新闻）
  static Future<NewsListResult> refresh({required int maxId, int count = 20}) {
    return getNewsList(n: count, offset: maxId, direction: LoadDirection.up);
  }
}
