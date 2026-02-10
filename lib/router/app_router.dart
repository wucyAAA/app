import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/news_feed_screen.dart';
import '../screens/comments_screen.dart';
import '../screens/push_library_screen.dart';
import '../screens/assistant_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login.dart';
import '../screens/webview_screen.dart';
import '../screens/mid_page_screen.dart';
import '../services/app_state.dart';
import 'main_shell.dart';

// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String news = '/news';
  static const String comments = '/comments';
  static const String pushLibrary = '/push-library';
  static const String assistant = '/assistant';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String webview = '/webview';
  static const String midpage = '/midpage';
  static const String settings = '/settings';
}

// 路由配置
class AppRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.news,
    debugLogDiagnostics: true,
    refreshListenable: AppState.instance,

    // 路由重定向（登录检查等）
    redirect: (context, state) {
      final isLoggedIn = AppState.instance.isLoggedIn;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      // 如果需要登录验证，取消下面的注释
      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }
      if (isLoggedIn && isLoginRoute) {
        return AppRoutes.news;
      }

      return null;
    },

    // 路由定义
    routes: [
      // 主页面（带底部导航栏）
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.news,
            name: 'news',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NewsFeedScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.comments,
            name: 'comments',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CommentsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.pushLibrary,
            name: 'pushLibrary',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PushLibraryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.assistant,
            name: 'assistant',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VoiceAssistantScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // 独立页面（不带底部导航栏）
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.webview,
        name: 'webview',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final uri = state.uri;
          final url = uri.queryParameters['url'] ?? '';
          final title = uri.queryParameters['title'];
          return WebViewScreen(url: url, title: title);
        },
      ),

      GoRoute(
        path: AppRoutes.midpage,
        name: 'midpage',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final uri = state.uri;
          final url = uri.queryParameters['url'] ?? '';
          final title = uri.queryParameters['title'];
          final recordId = uri.queryParameters['recordId'];
          return MidPageScreen(url: url, title: title, recordId: recordId);
        },
      ),
      // GoRoute(
      //   path: AppRoutes.settings,
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),
    ],

    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '页面不存在',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.uri.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.news),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
