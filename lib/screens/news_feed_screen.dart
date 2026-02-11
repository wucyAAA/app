import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import '../api/news_api.dart';
import '../router/app_router.dart';
import '../utils/toast_utils.dart';

import '../services/app_state.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<NewsItem> _newsList = [];
  List<NewsItem> _pendingNews = []; // 暂存的新闻，不直接显示
  Timer? _pollTimer;
  StreamSubscription? _tabTapSubscription;

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialNews();
    
    // 监听 Tab 点击事件，实现双击回顶
    _tabTapSubscription = AppState.instance.onTabTap.listen((index) {
      if (index == 0 && mounted) {
        // 如果有暂存消息，先显示暂存消息
        if (_pendingNews.isNotEmpty) {
          _showPendingNews();
        } else {
          // 否则直接滚动到顶部
          _refreshController.position?.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabTapSubscription?.cancel();
    _stopPolling();
    _refreshController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_newsList.isEmpty) return;
      await _checkNewItems();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// 静默检查更新
  Future<void> _checkNewItems() async {
    try {
      // 获取当前列表（包含暂存区）的最大 ID
      int maxId = 0;
      if (_pendingNews.isNotEmpty) {
        maxId = _pendingNews.map((e) => e.id).reduce((a, b) => a > b ? a : b);
      } else if (_newsList.isNotEmpty) {
        maxId = _newsList.map((e) => e.id).reduce((a, b) => a > b ? a : b);
      } else {
        return;
      }

      final result = await NewsApi.refresh(maxId: maxId, count: 20);
      if (mounted && result.success && result.items.isNotEmpty) {
        setState(() {
          // 去重并添加到暂存区
          final existingIds = _newsList.map((e) => e.id).toSet();
          existingIds.addAll(_pendingNews.map((e) => e.id));
          
          final newItems =
              result.items.where((e) => !existingIds.contains(e.id)).toList();
          
          if (newItems.isNotEmpty) {
             _pendingNews = [...newItems, ..._pendingNews];
          }
        });
      }
    } catch (_) {
      // 静默失败忽略
    }
  }

  /// 显示暂存的新闻（点击提示条触发）
  void _showPendingNews() {
    if (_pendingNews.isEmpty) return;

    setState(() {
      _newsList = [..._pendingNews, ..._newsList];
      _pendingNews = [];
    });
    
    // 滚动到顶部
    _refreshController.position?.jumpTo(0);
  }

  /// 首次加载新闻
  Future<void> _loadInitialNews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await NewsApi.loadInitial(count: 20);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.success) {
            _newsList = result.items;
            _startPolling(); // 加载成功后开启轮询
          } else {
            _hasError = true;
            _errorMessage = result.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    // 如果有暂存数据，直接合并显示，不再请求网络（或者合并后再请求也可以，视需求而定）
    // 这里采用：先合并暂存，再尝试请求更新的
    if (_pendingNews.isNotEmpty) {
      setState(() {
        _newsList = [..._pendingNews, ..._newsList];
        _pendingNews = [];
      });
    }

    if (_newsList.isEmpty) {
      await _loadInitialNews();
      _refreshController.refreshCompleted();
      return;
    }

    try {
      final maxId = _newsList.map((e) => e.id).reduce((a, b) => a > b ? a : b);
      final result = await NewsApi.refresh(maxId: maxId, count: 20);

      if (mounted) {
        if (result.success) {
          setState(() {
            final existingIds = _newsList.map((e) => e.id).toSet();
            final newItems =
                result.items.where((e) => !existingIds.contains(e.id)).toList();
            _newsList = [...newItems, ..._newsList];
          });
          _refreshController.resetNoData();
          _refreshController.refreshCompleted();
        } else {
          _refreshController.refreshFailed();
        }
      }
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  /// 上拉加载更多
  Future<void> _onLoading() async {
    if (_newsList.isEmpty) {
      _refreshController.loadComplete();
      return;
    }

    try {
      final minId = _newsList.map((e) => e.id).reduce((a, b) => a < b ? a : b);
      final result = await NewsApi.loadMore(minId: minId, count: 20);

      if (mounted) {
        if (result.success) {
          if (result.items.isEmpty) {
            _refreshController.loadNoData();
          } else {
            setState(() {
              // 去重并添加到底部
              final existingIds = _newsList.map((e) => e.id).toSet();
              final newItems =
                  result.items.where((e) => !existingIds.contains(e.id)).toList();
              // 创建新列表，确保 Flutter 检测到变化
              _newsList = [..._newsList, ...newItems];
            });
            _refreshController.loadComplete();
          }
        } else {
          _refreshController.loadFailed();
        }
      }
    } catch (e) {
      _refreshController.loadFailed();
    }
  }

  void _copyToClipboard(String text) {
    // 移除 HTML 标签
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
    Clipboard.setData(ClipboardData(text: cleanText));
    ToastUtils.showSuccess('已复制到剪贴板');
  }

  Future<void> _pushNews(NewsItem news) async {
    final result = await NewsApi.pushNews(id: news.id);

    if (!mounted) return;

    final msg = result.message ?? (result.success ? '推送成功' : '推送失败');
    if (result.success) {
      ToastUtils.showSuccess(msg);
    } else {
      ToastUtils.showError(msg);
    }
  }

  Future<void> _openUrl(String url, {String? title, String? recordId, bool isMidPage = false}) async {
    final path = isMidPage ? AppRoutes.midpage : AppRoutes.webview;
    context.push(
      Uri(
        path: path,
        queryParameters: {
          'url': url,
          if (title != null) 'title': title,
          if (recordId != null) 'recordId': recordId,
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: _buildBody(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(_errorMessage ?? '加载失败', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialNews,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final footerTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey;

    return Stack(
      children: [
        SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: ClassicHeader(
            refreshingText: '正在刷新...',
            completeText: '刷新完成',
            idleText: '下拉刷新',
            releaseText: '释放刷新',
            textStyle: TextStyle(color: footerTextColor),
            iconPos: IconPosition.left,
            failedIcon: Icon(Icons.error, color: footerTextColor),
            completeIcon: Icon(Icons.done, color: footerTextColor),
            idleIcon: Icon(Icons.arrow_downward, color: footerTextColor),
            releaseIcon: Icon(Icons.refresh, color: footerTextColor),
          ),
          footer: CustomFooter(
            builder: (context, mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text('上拉加载更多',
                    style: TextStyle(color: footerTextColor));
              } else if (mode == LoadStatus.loading) {
                body = const CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text('加载失败，点击重试',
                    style: TextStyle(color: footerTextColor));
              } else if (mode == LoadStatus.canLoading) {
                body = Text('释放加载更多',
                    style: TextStyle(color: footerTextColor));
              } else {
                body = Text('没有更多数据了',
                    style: TextStyle(color: footerTextColor));
              }
              return SizedBox(
                height: 55,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _newsList.isEmpty ? 1 : _newsList.length,
            // 设置预估高度，优化滚动性能
            itemExtent: null,
            cacheExtent: 500, // 缓存区域
            itemBuilder: (context, index) {
              if (_newsList.isEmpty) {
                return SizedBox(
                  height: 300,
                  child: Center(child: Text('暂无新闻', style: TextStyle(color: theme.textTheme.bodyMedium?.color))),
                );
              }
              final news = _newsList[index];
              return Column(
                children: [
                  _buildNewsItem(news, theme),
                  if (index < _newsList.length - 1)
                     Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFE5E5E5)),
                    ),
                ],
              );
            },
          ),
        ),
        // 悬浮提示条 (Twitter 风格)
        Positioned(
          top: 16,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _pendingNews.isNotEmpty
                  ? GestureDetector(
                      onTap: _showPendingNews,
                      child: Container(
                        key: const ValueKey('new_items_bubble'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '有 ${_pendingNews.length} 条新快讯，点击查看',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsItem(NewsItem news, ThemeData theme) {
    return RepaintBoundary(
      child: Slidable(
        key: ValueKey(news.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => _copyToClipboard(news.titleRaw),
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              icon: Icons.copy_rounded,
              label: '复制',
            ),
            SlidableAction(
              onPressed: (_) => _pushNews(news),
              backgroundColor: const Color(0xFF5856D6),
              foregroundColor: Colors.white,
              icon: Icons.send_rounded,
              label: '推送',
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          color: theme.cardTheme.color,
          child: InkWell(
            onTap: news.link != null 
              ? () {
                  if (news.isMidPageType) {
                    _openUrl(
                      news.midPageLink, 
                      title: news.titleRaw, 
                      recordId: news.midPageRecordId,
                      isMidPage: true,
                    );
                  } else {
                    _openUrl(news.link!, title: news.titleRaw);
                  }
                } 
              : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetaInfo(news, theme),
                  const SizedBox(height: 4),
                  Html(
                    data: news.title,
                    style: {
                      "body": Style(
                        fontSize: FontSize(15),
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: news.link != null 
                            ? (theme.brightness == Brightness.dark ? const Color(0xFF60A5FA) : Colors.black) 
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w400,
                        lineHeight: const LineHeight(1.33),
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaInfo(NewsItem news, ThemeData theme) {
    final metaColor = theme.textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
    return Row(
      children: [
         Icon(
          Icons.access_time_rounded,
          size: 14,
          color: metaColor,
        ),
        const SizedBox(width: 6),
        Text(
          news.formattedTime,
          style: TextStyle(
            fontSize: 12,
            color: metaColor,
          ),
        ),
        _buildDot(theme),
        Flexible(
          child: Text(
            news.site,
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.titleMedium?.color ?? const Color(0xFF111827),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (news.path.isNotEmpty) ...[
          _buildDot(theme),
          Flexible(
            child: Text(
              news.path,
              style: TextStyle(
                fontSize: 12,
                color: metaColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDot(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }
}