import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../api/push_api.dart';

class PushLibraryScreen extends StatefulWidget {
  const PushLibraryScreen({super.key});

  @override
  State<PushLibraryScreen> createState() => _PushLibraryScreenState();
}

class _PushLibraryScreenState extends State<PushLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  // Data state
  List<PushRecord> _records = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _pageNum = 1;
  int _total = 0;
  String? _errorMessage;

  // Filter state
  DateTime? startDate;
  DateTime? endDate;
  String? selectedType;
  bool omitSurvey = true;

  bool get _hasActiveFilters {
    return selectedType != null || !omitSurvey || _searchController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day);
    endDate = startDate!.add(const Duration(days: 1));
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = true}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _pageNum = 1;
      });
    }

    int? beginTime;
    int? endTime;
    if (startDate != null) beginTime = startDate!.millisecondsSinceEpoch;
    if (endDate != null) endTime = endDate!.millisecondsSinceEpoch;

    final result = await PushApi.getList(
      pageNum: _pageNum,
      pageSize: 20,
      keyword: _searchController.text.trim(),
      beginTime: beginTime,
      endTime: endTime,
      type: selectedType,
      omitSurvey: omitSurvey,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        if (isRefresh) {
          _records = result.items;
        } else {
          _records.addAll(result.items);
        }
        _total = result.total;
        _hasMore = _records.length < _total;
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

  Future<void> _onRefresh() async {
    _pageNum = 1;
    int? beginTime;
    int? endTime;
    if (startDate != null) beginTime = startDate!.millisecondsSinceEpoch;
    if (endDate != null) endTime = endDate!.millisecondsSinceEpoch;

    final result = await PushApi.getList(
      pageNum: 1,
      pageSize: 20,
      keyword: _searchController.text.trim(),
      beginTime: beginTime,
      endTime: endTime,
      type: selectedType,
      omitSurvey: omitSurvey,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _records = result.items;
        _total = result.total;
        _hasMore = _records.length < _total;
        _errorMessage = null;
      });
      _refreshController.resetNoData();
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  Future<void> _onLoadMore() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }

    _pageNum++;
    int? beginTime;
    int? endTime;
    if (startDate != null) beginTime = startDate!.millisecondsSinceEpoch;
    if (endDate != null) endTime = endDate!.millisecondsSinceEpoch;

    final result = await PushApi.getList(
      pageNum: _pageNum,
      pageSize: 20,
      keyword: _searchController.text.trim(),
      beginTime: beginTime,
      endTime: endTime,
      type: selectedType,
      omitSurvey: omitSurvey,
    );

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _records.addAll(result.items);
        _hasMore = _records.length < _total;
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

  void _showDetail(PushRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PushDetailModal(
        record: record,
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
        initialStartDate: startDate,
        initialEndDate: endDate,
        initialType: selectedType,
        initialOmitSurvey: omitSurvey,
        onConfirm: (start, end, type, omit) {
          setState(() {
            startDate = start;
            endDate = end;
            selectedType = type;
            omitSurvey = omit;
          });
          Navigator.pop(context);
          _loadData(); // 重新加载数据
        },
      ),
    );
  }

  Color _getTypeBadgeBgColor(String type, bool isDark) {
    switch (type) {
      case 'user':
        return isDark ? const Color(0xFF172554) : const Color(0xFFEFF6FF);
      case 'system':
        return isDark ? const Color(0xFF052E16) : const Color(0xFFF0FDF4);
      case 'product':
        return isDark ? const Color(0xFF431407) : const Color(0xFFFFF7ED);
      case 'highly_recommend':
        return isDark ? const Color(0xFF3B0764) : const Color(0xFFFAF5FF);
      case 'ai_recommend':
        return isDark ? const Color(0xFF2E1065) : const Color(0xFFF5F3FF); // Violet
      default:
        return isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7);
    }
  }

  Color _getTypeBadgeTextColor(String type, bool isDark) {
    switch (type) {
      case 'user':
        return isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
      case 'system':
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
      case 'product':
        return isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C);
      case 'highly_recommend':
        return isDark ? const Color(0xFFC084FC) : const Color(0xFF7C3AED);
      case 'ai_recommend':
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
      default:
        return isDark ? const Color(0xFFD1D5DB) : const Color(0xFF3C3C43);
    }
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
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(theme, isDark),
              Expanded(
                child: _buildRecordsList(theme, isDark),
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
          bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA), width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _loadData(),
                    decoration: InputDecoration(
                      hintText: '搜索推送...', 
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
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
                                color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
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
                      setState(() {});
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
                      ? const Color(0xFF007AFF)
                      : (theme.textTheme.bodyMedium?.color ?? const Color(0xFF4B5563)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(ThemeData theme, bool isDark) {
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
              color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _loadData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.inbox,
              size: 48,
              color: theme.textTheme.bodySmall?.color ?? const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    final footerTextColor = theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93);

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
        itemCount: _records.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA)),
        ),
        itemBuilder: (context, index) {
          final record = _records[index];
          return _buildRecordItem(record, theme, isDark);
        },
      ),
    );
  }

  /// 去除HTML标签
  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Widget _buildRecordItem(PushRecord record, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetail(record),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.cardTheme.color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：site 和 path
            Row(
              children: [
                Text(
                  record.site,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.titleMedium?.color ?? const Color(0xFF1C1C1E),
                  ),
                ),
                if (record.path.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color ?? const Color(0xFFD1D1D6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.path,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // 内容：去除HTML标签
            Text(
              '${record.from}：${_stripHtml(record.content)}',
              style: TextStyle(
                fontSize: 15,
                height: 1.47,
                color: theme.textTheme.bodyLarge?.color ?? const Color(0xFF1C1C1E),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 时间：带上年月日
            Row(
              children: [
                if (record.sourceTime.isNotEmpty) ...[
                  Text(
                    '发布 ${record.sourceTime}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color ?? const Color(0xFFD1D1D6),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  '推送 ${record.time}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String? initialType;
  final bool initialOmitSurvey;
  final Function(DateTime?, DateTime?, String?, bool) onConfirm;

  const FilterModal({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    this.initialType,
    required this.initialOmitSurvey,
    required this.onConfirm,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedType;
  late bool omitSurvey;

  final Map<String, String> typeOptions = {
    'user': '用户',
    'auto_recommend': '自动新闻',
    'product': '产品价格',
    'system': '系统',
    'highly_recommend': '强推',
    'ai_recommend': 'AI推送',
  };

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    selectedType = widget.initialType;
    omitSurvey = widget.initialOmitSurvey;
  }

  void _selectType(String key) {
    setState(() {
      if (selectedType == key) {
        selectedType = null; // 取消选择
      } else {
        selectedType = key; // 单选
      }
    });
  }

  void _handleReset() {
    final now = DateTime.now();
    setState(() {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = startDate!.add(const Duration(days: 1));
      selectedType = null;
      omitSurvey = true;
    });
    // 重置后自动触发数据更新
    widget.onConfirm(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
      null,
      true,
    );
  }

  void _selectDate(BuildContext context, bool isStart) {
    DateTime tempDate =
        isStart ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now());
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA))),
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
                          color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isStart) {
                            startDate = tempDate;
                          } else {
                            endDate = tempDate;
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '推送筛选',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.titleMedium?.color ?? const Color(0xFF111827),
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
                          color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFF3F4F6)),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      '推送时间范围',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleMedium?.color ?? const Color(0xFF111827),
                      ),
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
                                  : '开始日期',
                              isActive: startDate != null,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('-',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF9CA3AF))),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: _buildDateInput(
                              endDate != null
                                  ? "${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}"
                                  : '结束日期',
                              isActive: endDate != null,
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '消息类型',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleMedium?.color ?? const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: typeOptions.entries.map((entry) {
                        final isSelected = selectedType == entry.key;
                        return _buildFilterChip(
                          label: entry.value,
                          isSelected: isSelected,
                          theme: theme,
                          isDark: isDark,
                          onTap: () => _selectType(entry.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '隐藏调研纪要',
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color ?? const Color(0xFF374151),
                          ),
                        ),
                        CupertinoSwitch(
                          value: omitSurvey,
                          activeColor: const Color(0xFF007AFF),
                          onChanged: (bool value) {
                            setState(() {
                              omitSurvey = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.dividerTheme.color ?? const Color(0xFFF3F4F6))),
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
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '重置',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color ?? const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onConfirm(
                          startDate,
                          endDate,
                          selectedType,
                          omitSurvey,
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

  Widget _buildDateInput(String text, {
    bool isActive = false,
    required ThemeData theme,
    required bool isDark,
  }) {
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

class PushDetailModal extends StatelessWidget {
  final PushRecord record;
  final VoidCallback onClose;

  const PushDetailModal({
    super.key,
    required this.record,
    required this.onClose,
  });

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
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '推送详情',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleMedium?.color ?? Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              LucideIcons.x,
                              size: 20,
                              color: theme.textTheme.bodyMedium?.color ?? const Color(0xFF8E8E93),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: theme.dividerTheme.color ?? const Color(0xFFE5E5EA)),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  record.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                                  ),
                                ),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFFD1D1D6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  record.site,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                                  ),
                                ),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: theme.textTheme.bodySmall?.color ?? const Color(0xFFD1D1D6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  record.from,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF007AFF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 内容显示
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(minWidth: double.infinity),
                              child: Html(
                                data: "<div><p>${((record.link.isNotEmpty && !record.link.startsWith('http')) ? record.link : record.content).replaceAll('\n', '<br/>')}</p></div>",
                                shrinkWrap: true,
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(16),
                                    lineHeight: LineHeight(1.6),
                                    color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  "p": Style(
                                    margin: Margins.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  "div": Style(
                                    margin: Margins.symmetric(horizontal: 16),
                                  ),
                                },
                              ),
                            ),
                          ),
                          // 如果 external == 'image'，展示图片（图片地址在 link 字段）
                          if (record.external == 'image' && record.link.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  record.link,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF2F2F7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        LucideIcons.image,
                                        size: 48,
                                        color: theme.textTheme.bodySmall?.color ?? const Color(0xFF8E8E93),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          // 如果不是图片类型且有原文链接，显示链接
                          if (record.external != 'image' &&
                              record.link.isNotEmpty &&
                              record.link.startsWith('http')) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                    minWidth: double.infinity),
                                child: Html(
                                  data:
                                      "<div><p><a href='${record.link}'>原文链接</a></p></div>",
                                  shrinkWrap: true,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(16),
                                      lineHeight: LineHeight(1.6),
                                      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    "p": Style(
                                      margin: Margins.symmetric(
                                          horizontal: 16, vertical: 8),
                                    ),
                                  },
                                ),
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
}