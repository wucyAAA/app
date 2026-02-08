import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/app_state.dart';
import '../router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void handleLogout() {
    // 处理退出登录逻辑
    context.read<AppState>().logout();
    // 使用 GoRouter 跳转到登录页
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final user = appState.user;
    final isLoggedIn = appState.isLoggedIn;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // 头部用户信息卡片
          _buildHeader(theme, user, isLoggedIn),
          // 内容区域
          Expanded(
            child: _buildContent(appState, theme, isLoggedIn),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, User? user, bool isLoggedIn) {
    final userName = isLoggedIn ? (user?.name ?? '用户') : '访客';
    final userEmail = isLoggedIn ? (user?.email ?? '') : '点击登录';
    final avatarText = userName.isNotEmpty ? userName.substring(0, 1) : 'G';
    final avatarUrl = user?.avatar;

    return Container(
      color: theme.cardTheme.color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Row(
            children: [
              // 头像
              GestureDetector(
                onTap: () {
                  if (!isLoggedIn) {
                    context.go(AppRoutes.login);
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: avatarUrl == null || avatarUrl.isEmpty
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          )
                        : null,
                    image: avatarUrl != null && avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Center(
                          child: Text(
                            avatarText,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isLoggedIn) {
                      context.go(AppRoutes.login);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 右箭头
              if (isLoggedIn)
                GestureDetector(
                  onTap: () {
                    // 处理点击进入详情
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppState appState, ThemeData theme, bool isLoggedIn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 夜间模式
          _buildDarkModeCard(appState, theme),
          const SizedBox(height: 12),

          // 关于
          _buildSettingCard(
            theme: theme,
            items: [
              _SettingItem(
                icon: LucideIcons.info,
                iconBgColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF1F2937)
                    : const Color(0xFFF2F2F7),
                iconColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
                title: '关于幻云APP',
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 退出登录
          if (isLoggedIn) _buildLogoutCard(theme),
        ],
      ),
    );
  }

  Widget _buildDarkModeCard(AppState appState, ThemeData theme) {
    final isDarkMode = appState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF312E81)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  isDarkMode ? LucideIcons.moon : LucideIcons.sun,
                  size: 16,
                  color: isDarkMode
                      ? const Color(0xFF818CF8)
                      : const Color(0xFFD97706),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '夜间模式',
                style: theme.textTheme.bodyLarge,
              ),
            ),
            // 切换开关
            GestureDetector(
              onTap: () {
                appState.toggleDarkMode();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 51,
                height: 31,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDarkMode
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFD1D5DB),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment:
                      isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
      {required List<_SettingItem> items, required ThemeData theme}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: theme.brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: items.map((item) => _buildSettingRow(item, theme)).toList(),
      ),
    );
  }

  Widget _buildSettingRow(_SettingItem item, ThemeData theme) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: item.showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.dividerTheme.color ?? const Color(0xFFF2F2F7),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 16,
                  color: item.iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            if (item.trailing != null) ...[
              item.trailing!,
              const SizedBox(width: 8),
            ],
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutCard(ThemeData theme) {
    return GestureDetector(
      onTap: handleLogout,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: theme.brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                LucideIcons.logOut,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              SizedBox(width: 8),
              Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 设置项数据类
class _SettingItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool showDivider;

  _SettingItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
    this.showDivider = false,
  });
}
