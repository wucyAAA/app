import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/voice_assistant_models.dart';

class AssistantSearchScreen extends StatefulWidget {
  final List<VoiceSession> historySessions;

  const AssistantSearchScreen({
    super.key,
    required this.historySessions,
  });

  @override
  State<AssistantSearchScreen> createState() => _AssistantSearchScreenState();
}

class _AssistantSearchScreenState extends State<AssistantSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VoiceSession> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchResults = widget.historySessions;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = widget.historySessions;
      } else {
        _searchResults = widget.historySessions.where((session) {
          if (session.text.toLowerCase().contains(query)) return true;
          for (var task in session.tasks) {
            if (task.type.toLowerCase().contains(query)) return true;
            if (task.description.toLowerCase().contains(query)) return true;
            for (var param in task.parameters) {
              if (param.value.toLowerCase().contains(query)) return true;
            }
          }
          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: theme.textTheme.bodyLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索历史对话...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
          ),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          textInputAction: TextInputAction.search,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(LucideIcons.x, color: theme.textTheme.bodyLarge?.color),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: widget.historySessions.isEmpty
          ? Center(
              child: Text(
                '暂无历史记录',
                style: TextStyle(color: theme.textTheme.bodySmall?.color),
              ),
            )
          : _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.search,
                        size: 48,
                        color: theme.dividerColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '未找到相关记录',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final session = _searchResults[index];
                    return ListTile(
                      title: Text(
                        session.text.isEmpty ? '无标题会话' : session.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(session.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      trailing: Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      onTap: () {
                        Navigator.of(context).pop(session);
                      },
                    );
                  },
                ),
    );
  }
}