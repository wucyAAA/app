import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/comment_api.dart';
import '../router/app_router.dart';
import '../utils/toast_utils.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_thumbnail_widget.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  // Data state
  List<CommentItem> _comments = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _pageNum = 1;
  int _total = 0;
  String? _errorMessage;

  // Refresh controller
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String selectedTimeRange = '全部'; // Default to "All"
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedGroups = [];
  List<String> selectedUserTypes = [];

  bool get _hasActiveFilters {
    return selectedTimeRange != '全部' ||
        startDate != null ||
        endDate != null ||
        selectedUserTypes.isNotEmpty ||
        selectedGroups.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 根据时间范围获取开始和结束时间戳
  Map<String, int?> _getTimeRange() {
    int? begin;
    int? end;

    if (startDate != null || endDate != null) {
      // 使用自定义日期
      if (startDate != null) {
        begin = DateTime(startDate!.year, startDate!.month, startDate!.day)
            .millisecondsSinceEpoch;
      }
      if (endDate != null) {
        end = DateTime(
                endDate!.year, endDate!.month, endDate!.day, 23, 59, 59, 999)
            .millisecondsSinceEpoch;
      }
    } else if (selectedTimeRange.isNotEmpty && selectedTimeRange != '全部') {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
          .millisecondsSinceEpoch;

      switch (selectedTimeRange) {
        case '今天':
          begin = todayStart.millisecondsSinceEpoch;
          break;
        case '近3天':
          begin = todayStart
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch;
          break;
        case '最近7天':
          begin = todayStart
              .subtract(const Duration(days: 6))
              .millisecondsSinceEpoch;
          break;
        case '最近30天':
          begin = todayStart
              .subtract(const Duration(days: 29))
              .millisecondsSinceEpoch;
          break;
        case '最近3个月':
          begin = todayStart
              .subtract(const Duration(days: 89))
              .millisecondsSinceEpoch;
          break;
      }
    }

    return {'begin': begin, 'end': end};
  }

  /// 获取标签参数
  String? _getTagsParam() {
    if (selectedUserTypes.isEmpty) return null;
    return selectedUserTypes.join(',');
  }

  /// 加载数据
  Future<void> _loadData({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _pageNum = 1;
      });
    }

    final timeRange = _getTimeRange();
    final tags = _getTagsParam();

    final result = await CommentApi.getList(
      pageNum: _pageNum,
      pageSize: 20,
      begin: timeRange['begin'],
      end: timeRange['end'],
      tags: tags,
      keyword: _searchController.text.trim(),
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        if (isRefresh) {
          _comments = result.items;
        } else {
          _comments.addAll(result.items);
        }
        _total = result.total;
        _hasMore = _comments.length < _total;
        _isLoading = false;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message ?? '加载失败';
      });
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    _pageNum = 1;
    final timeRange = _getTimeRange();
    final tags = _getTagsParam();

    final result = await CommentApi.getList(
      pageNum: 1,
      pageSize: 20,
      begin: timeRange['begin'],
      end: timeRange['end'],
      tags: tags,
      keyword: _searchController.text.trim(),
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _comments = result.items;
        _total = result.total;
        _hasMore = _comments.length < _total;
        _errorMessage = null;
      });
      _refreshController.resetNoData();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  /// 上拉加载更多
  Future<void> _onLoadMore() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }

    _pageNum++;
    final timeRange = _getTimeRange();
    final tags = _getTagsParam();

    final result = await CommentApi.getList(
      pageNum: _pageNum,
      pageSize: 20,
      begin: timeRange['begin'],
      end: timeRange['end'],
      tags: tags,
      keyword: _searchController.text.trim(),
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _comments.addAll(result.items);
        _hasMore = _comments.length < _total;
      });
      if (_hasMore) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } else {
      _pageNum--;
      _refreshController.loadFailed();
    }
  }

  Future<void> _pushComment(CommentItem comment) async {
    final result = await CommentApi.pushComment(id: comment.id);

    if (!mounted) return;

    final msg = result.message ?? (result.success ? '推送成功' : '推送失败');
    if (result.success) {
      ToastUtils.showSuccess(msg);
    } else {
      ToastUtils.showError(msg);
    }
  }

  void _showCommentDetail(CommentItem comment) {
    if (comment.isMidPageType) {
      context.push(
        Uri(
          path: AppRoutes.midpage,
          queryParameters: {
            'url': comment.midPageLink,
            'title': comment.title,
            'recordId': comment.midPageRecordId,
          },
        ).toString(),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentDetailModal(
        comment: comment,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        initialTimeRange: selectedTimeRange,
        initialStartDate: startDate,
        initialEndDate: endDate,
        initialGroups: selectedGroups,
        initialUserTypes: selectedUserTypes,
        onConfirm: (timeRange, start, end, groups, userTypes) {
          setState(() {
            selectedTimeRange = timeRange;
            startDate = start;
            endDate = end;
            selectedGroups = groups;
            selectedUserTypes = userTypes;
          });
          Navigator.pop(context);
          // 筛选条件改变后重新加载数据
          _loadData();
        },
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    httpHeaders: {
                      'Referer': Uri.parse(imageUrl).origin,
                      'User-Agent':
                          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                    },
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CupertinoActivityIndicator(radius: 16),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 430),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(theme, isDark),
              // Comments List
              Expanded(
                child: _buildCommentsList(theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(
              color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA),
              width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: '搜索短评...',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodySmall?.color ??
                            const Color(0xFF8E8E93),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color ??
                            const Color(0xFF8E8E93),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _loadData();
                              },
                              child: Icon(
                                LucideIcons.xCircle,
                                size: 16,
                                color: theme.textTheme.bodySmall?.color ??
                                    const Color(0xFF8E8E93),
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: (value) {
                      setState(() {}); // 更新清除按钮状态
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _loadData,
                child: const Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF007AFF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 16,
                color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _showFilterModal,
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  size: 20,
                  color: _hasActiveFilters
                      ? const Color(0xFF007AFF) // Active color
                      : (theme.textTheme.bodyMedium?.color ??
                          const Color(0xFF4B5563)), // Inactive color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadData,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '重试',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 48,
              color: theme.textTheme.bodySmall?.color ?? Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color ?? Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final footerTextColor =
        theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93);

    return SmartRefresher(
      controller: _refreshController,
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
            body = Text('上拉加载更多', style: TextStyle(color: footerTextColor));
          } else if (mode == LoadStatus.loading) {
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text('加载失败，点击重试', style: TextStyle(color: footerTextColor));
          } else if (mode == LoadStatus.canLoading) {
            body = Text('释放加载更多', style: TextStyle(color: footerTextColor));
          } else {
            body = Text('没有更多数据了', style: TextStyle(color: footerTextColor));
          }
          return SizedBox(
            height: 55,
            child: Center(child: body),
          );
        },
      ),
      onRefresh: _onRefresh,
      onLoading: _onLoadMore,
      child: ListView.separated(
        itemCount: _comments.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
              height: 1,
              color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA)),
        ),
        itemBuilder: (context, index) {
          final comment = _comments[index];
          return _buildCommentItem(comment, theme, isDark);
        },
      ),
    );
  }

    Widget _buildCommentItem(CommentItem comment, ThemeData theme, bool isDark) {
      return RepaintBoundary(
        child: Slidable(
          key: ValueKey(comment.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                onPressed: (_) => _pushComment(comment),
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
            child: GestureDetector(
              onTap: () => _showCommentDetail(comment),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time, Group, Sender, UserType
                    _buildMetaInfo(comment, theme, isDark),
                    const SizedBox(height: 8),
                    // Title/Content - 列表不换行，去除HTML标签
                    Text(
                      comment.listDisplayContent,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.47,
                        color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (comment.hasImage && !comment.hasVideo) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _showImagePreview(context, comment.url),
                        child: Container(
                          width: 128,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: comment.url.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: comment.url,
                                    httpHeaders: {
                                      'Referer': Uri.parse(comment.url).origin,
                                      'User-Agent':
                                          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                                    },
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E5EA),
                                      child: const Center(
                                          child: CupertinoActivityIndicator()),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Center(
                                      child: Icon(
                                        LucideIcons.image,
                                        size: 32,
                                        color:
                                            theme.textTheme.bodySmall?.color ??
                                                const Color(0xFF8E8E93),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    LucideIcons.image,
                                    size: 32,
                                    color: theme.textTheme.bodySmall?.color ??
                                        const Color(0xFF8E8E93),
                                  ),
                                ),
                        ),
                      ),
                    ],
                    if (comment.hasVideo && comment.url.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      VideoThumbnailWidget(
                        videoUrl: comment.url,
                        width: 160,
                        height: 90,
                        onTap: () => _showCommentDetail(comment),
                      ),
                    ],
                    // Stocks and Keywords
                    if (comment.stocks.isNotEmpty ||
                        comment.keywords.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...comment.stocks
                              .map((stock) => _buildStockTag(stock, isDark)),
                          ...comment.keywords.map(
                              (keyword) => _buildKeywordTag(keyword, isDark)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  Widget _buildMetaInfo(CommentItem comment, ThemeData theme, bool isDark) {
    final metaColor =
        theme.textTheme.bodySmall?.color ?? const Color(0xFF6B7280);
    return Wrap(
      spacing: 0,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: metaColor,
        ),
        const SizedBox(width: 6),
        Text(
          comment.formattedTime,
          style: TextStyle(
            fontSize: 12,
            color: metaColor,
          ),
        ),
        _buildDot(theme),
        Text(
          comment.organization,
          style: TextStyle(
            fontSize: 12,
            color:
                theme.textTheme.titleMedium?.color ?? const Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildDot(theme),
        Text(
          comment.author,
          style: TextStyle(
            fontSize: 12,
            color: metaColor,
          ),
        ),
        if (comment.tags.isNotEmpty) ...[
          const SizedBox(width: 8),
          ...comment.tags.map((tag) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _buildUserTag(tag, isDark),
              )),
        ],
      ],
    );
  }

  Widget _buildDot(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildUserTag(String tag, bool isDark) {
    Color bgColor;
    Color textColor;

    if (tag.contains('卖方')) {
      bgColor = isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED);
      textColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
    } else if (tag.contains('疑似卖方')) {
      bgColor = isDark ? const Color(0xFF422006) : const Color(0xFFFEFCE8);
      textColor = isDark ? const Color(0xFFFACC15) : const Color(0xFFA16207);
    } else if (tag.contains('散户')) {
      bgColor = isDark ? const Color(0xFF3B0764) : const Color(0xFFFAF5FF);
      textColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
    } else {
      bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7);
      textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStockTag(Stock stock, bool isDark) {
    final displayChange = stock.displayChange;
    final isPositive = stock.isPositive;
    final isNegative = stock.isNegative;

    Color bgColor;
    Color textColor;

    if (isPositive) {
      bgColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
      textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    } else if (isNegative) {
      bgColor = isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4);
      textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    } else {
      bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7);
      textColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF3C3C43);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${stock.name} $displayChange',
        style: TextStyle(
          fontSize: 11,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildKeywordTag(String keyword, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$keyword',
        style: TextStyle(
          fontSize: 11,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }
}

// Comment Detail Modal
class CommentDetailModal extends StatelessWidget {
  final CommentItem comment;
  final VoidCallback onClose;

  const CommentDetailModal({
    super.key,
    required this.comment,
    required this.onClose,
  });

  void _showImagePreview(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    httpHeaders: {
                      'Referer': Uri.parse(imageUrl).origin,
                      'User-Agent':
                          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                    },
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CupertinoActivityIndicator(radius: 16),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onClose,
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () {}, // 阻止点击弹窗内容时触发关闭

            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          theme.dividerTheme.color ?? const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  // Header

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '短评详情',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF374151)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              LucideIcons.x,
                              size: 20,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Divider(height: 1, color: theme.dividerTheme.color),

                  // Content

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Meta info
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 0,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: theme.textTheme.bodySmall?.color ??
                                      const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  comment.formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color ??
                                        const Color(0xFF8E8E93),
                                  ),
                                ),
                                _buildDot(theme),
                                Text(
                                  comment.organization,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.titleMedium?.color ??
                                        const Color(0xFF111827),
                                  ),
                                ),
                                _buildDot(theme),
                                Text(
                                  comment.author,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color ??
                                        const Color(0xFF6B7280),
                                  ),
                                ),
                                if (comment.tags.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  ...comment.tags.map((tag) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: _buildUserTag(tag, isDark),
                                      )),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Content - 详情使用Html渲染
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  minWidth: double.infinity),
                              child: Html(
                                data: comment.detailWithStyle
                                    .replaceAll('\n', '<br/>'),
                                shrinkWrap: true,
                                onLinkTap: (url, attributes, element) {
                                  if (url != null && url.isNotEmpty) {
                                    context.push(
                                      Uri(
                                        path: AppRoutes.webview,
                                        queryParameters: {
                                          'url': url,
                                          'title': '详情'
                                        },
                                      ).toString(),
                                    );
                                  }
                                },
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    lineHeight: LineHeight(1.6),
                                    color: theme.textTheme.bodyLarge?.color ??
                                        Colors.black,
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  "p": Style(
                                    margin: Margins.symmetric(vertical: 8),
                                  ),
                                  "div": Style(
                                    margin: Margins.zero,
                                  ),
                                },
                                extensions: [
                                  TagExtension(
                                    tagsToExtend: {"img"},
                                    builder: (extensionContext) {
                                      final src = extensionContext
                                          .element?.attributes['src'];

                                      if (src == null || src.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return GestureDetector(
                                        onTap: () =>
                                            _showImagePreview(context, src),
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: src,
                                              httpHeaders: {
                                                'Referer':
                                                    Uri.parse(src).origin,
                                                'User-Agent':
                                                    'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                                              },
                                              fit: BoxFit.fitWidth,
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 200,
                                                color: isDark
                                                    ? const Color(0xFF374151)
                                                    : const Color(0xFFF2F2F7),
                                                child: const Center(
                                                  child:
                                                      CupertinoActivityIndicator(),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 200,
                                                color: isDark
                                                    ? const Color(0xFF374151)
                                                    : const Color(0xFFF2F2F7),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  LucideIcons.imageOff,
                                                  color: theme.textTheme
                                                          .bodySmall?.color ??
                                                      const Color(0xFF8E8E93),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  TagExtension(
                                    tagsToExtend: {"video"},
                                    builder: (extensionContext) {
                                      String? videoSrc = extensionContext
                                          .element?.attributes['src'];
                                      if (videoSrc == null ||
                                          videoSrc.isEmpty) {
                                        // 遍历子元素查找 source 标签
                                        final children =
                                            extensionContext.element?.children;
                                        if (children != null) {
                                          for (final child in children) {
                                            if (child.localName == 'source') {
                                              videoSrc =
                                                  child.attributes['src'];
                                              if (videoSrc != null &&
                                                  videoSrc.isNotEmpty) break;
                                            }
                                          }
                                        }
                                      }

                                      if (videoSrc != null &&
                                          videoSrc.isNotEmpty) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          child: VideoPlayerWidget(
                                              videoUrl: videoSrc),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (comment.stocks.isNotEmpty ||
                              comment.keywords.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                      height: 1,
                                      color: theme.dividerTheme.color),
                                  const SizedBox(height: 20),
                                  Text(
                                    '相关标签',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          theme.textTheme.bodyMedium?.color ??
                                              const Color(0xFF8E8E93),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ...comment.stocks.map((stock) =>
                                          _buildStockChip(stock, isDark)),
                                      ...comment.keywords.map((kw) =>
                                          _buildKeywordChip(kw, isDark)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserTag(String tag, bool isDark) {
    Color bgColor;
    Color textColor;

    if (tag.contains('卖方')) {
      bgColor = isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED);
      textColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C);
    } else if (tag.contains('疑似卖方')) {
      bgColor = isDark ? const Color(0xFF422006) : const Color(0xFFFEFCE8);
      textColor = isDark ? const Color(0xFFFACC15) : const Color(0xFFA16207);
    } else if (tag.contains('散户')) {
      bgColor = isDark ? const Color(0xFF3B0764) : const Color(0xFFFAF5FF);
      textColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
    } else {
      bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7);
      textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF8E8E93);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStockChip(Stock stock, bool isDark) {
    final displayChange = stock.displayChange;
    final isPositive = stock.isPositive;
    final isNegative = stock.isNegative;

    Color bgColor;
    Color textColor;

    if (isPositive) {
      bgColor = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2);
      textColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    } else if (isNegative) {
      bgColor = isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4);
      textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    } else {
      bgColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7);
      textColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF3C3C43);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${stock.name} $displayChange',
        style: TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildKeywordChip(String keyword, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '#$keyword',
        style: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildDot(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
        shape: BoxShape.circle,
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final String initialTimeRange;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<String> initialGroups;
  final List<String> initialUserTypes;
  final Function(String, DateTime?, DateTime?, List<String>, List<String>)
      onConfirm;

  const FilterModal({
    super.key,
    required this.initialTimeRange,
    this.initialStartDate,
    this.initialEndDate,
    required this.initialGroups,
    required this.initialUserTypes,
    required this.onConfirm,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late String selectedTimeRange;
  DateTime? startDate;
  DateTime? endDate;
  late List<String> selectedGroups;
  late List<String> selectedUserTypes;

  final List<String> timeRanges = ['今天', '近3天', '最近7天', '最近30天', '最近3个月'];

  final List<String> userTypeOptions = ['卖方', '散户', '疑似卖方'];

  @override
  void initState() {
    super.initState();
    selectedTimeRange = widget.initialTimeRange;
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedGroups = List.from(widget.initialGroups);
    selectedUserTypes = List.from(widget.initialUserTypes);
  }

  void _toggleUserType(String type) {
    setState(() {
      if (selectedUserTypes.contains(type)) {
        selectedUserTypes.remove(type);
      } else {
        selectedUserTypes.add(type);
      }
    });
  }

  void _handleReset() {
    setState(() {
      selectedTimeRange = '全部';
      startDate = null;
      endDate = null;
      selectedGroups = [];
      selectedUserTypes = [];
    });
    // 重置后自动触发数据更新
    widget.onConfirm(
      '全部',
      null,
      null,
      [],
      [],
    );
  }

  void _selectDate(BuildContext context, bool isStart) {
    DateTime tempDate =
        isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Toolbar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.dividerTheme.color ??
                              const Color(0xFFE5E5EA))),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color ??
                              const Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isStart) {
                            startDate = tempDate;
                            selectedTimeRange = '';
                          } else {
                            endDate = tempDate;
                            selectedTimeRange = '';
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '完成',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Picker
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: theme.brightness,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 20,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    maximumDate: DateTime.now(),
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '短评筛选',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.x,
                          size: 20,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerTheme.color),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Time Range
                    Text(
                      '发布时间',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeRanges.map((range) {
                        final isSelected = selectedTimeRange == range;
                        return _buildFilterChip(
                          label: range,
                          isSelected: isSelected,
                          theme: theme,
                          isDark: isDark,
                          onTap: () {
                            setState(() {
                              selectedTimeRange = range;
                              startDate = null;
                              endDate = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: _buildDateInput(
                              startDate != null
                                  ? "${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}"
                                  : '起始时间',
                              isActive: startDate != null,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-',
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color ??
                                      const Color(0xFF9CA3AF))),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: _buildDateInput(
                              endDate != null
                                  ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                                  : '终止时间',
                              isActive: endDate != null,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // User Types
                    Text(
                      '用户类型',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userTypeOptions.map((type) {
                        final isSelected = selectedUserTypes.contains(type);
                        return _buildFilterChip(
                          label: type,
                          isSelected: isSelected,
                          theme: theme,
                          isDark: isDark,
                          onTap: () => _toggleUserType(type),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: theme.dividerTheme.color ??
                              const Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleReset,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '重置',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color ??
                                  const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onConfirm(
                          selectedTimeRange,
                          startDate,
                          endDate,
                          selectedGroups,
                          selectedUserTypes,
                        ),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF007AFF), Color(0xFF0063CC)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '确认',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    final bgColor = isSelected
        ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
        : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB));
    final borderColor = isSelected
        ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE))
        : Colors.transparent;
    final textColor = isSelected
        ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB))
        : (theme.textTheme.bodyMedium?.color ?? const Color(0xFF374151));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 40 - 16) / 3,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDateInput(String text,
      {bool isActive = false, required ThemeData theme, required bool isDark}) {
    final bgColor = isActive
        ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
        : (isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB));
    final borderColor = isActive
        ? (isDark ? const Color(0xFF3B82F6) : const Color(0xFFBFDBFE))
        : (theme.dividerTheme.color ?? const Color(0xFFE5E7EB));
    final textColor = isActive
        ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB))
        : (theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF));

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
    );
  }
}

// Main entry point for testing
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comments App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
      ],
      locale: const Locale('zh', 'CN'),
      home: const CommentsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
