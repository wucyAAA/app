import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 用户模型
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final List<String> roles; // Added roles

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> roleList = [];
    if (json['roles'] != null && json['roles'] is List) {
      roleList = (json['roles'] as List).map((e) {
        if (e is Map) return e['value']?.toString() ?? '';
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
    }

    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      roles: roleList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'roles': roles,
    };
  }

  /// 是否有截图(中间页)权限
  bool get hasScreenshotPermission => roles.contains('screenshot');
}

// 全局应用状态
class AppState extends ChangeNotifier {
  // 单例
  static AppState? _instance;
  static AppState get instance {
    _instance ??= AppState._internal();
    return _instance!;
  }

  AppState._internal();

  // ==================== 状态属性 ====================

  // 用户相关
  User? _user;
  String? _token;
  bool _isLoggedIn = false;

  // 主题相关
  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.light;

  // 应用设置
  bool _notificationsEnabled = true;
  String _language = 'zh_CN';

  // 加载状态
  bool _isLoading = false;

  // Tab 点击事件流
  final _tabTapController = StreamController<int>.broadcast();

  // ==================== Getters ====================

  User? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;
  bool get isLoading => _isLoading;
  
  Stream<int> get onTabTap => _tabTapController.stream;

  // ==================== 初始化 ====================

  /// 从本地存储加载状态
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 尝试从本地加载 Token
    final savedToken = prefs.getString('token');
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _isLoggedIn = true;
    }

    // 加载用户信息
    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    if (userId != null && userName != null && userEmail != null) {
      _user = User(
        id: userId,
        name: userName,
        email: userEmail,
        avatar: prefs.getString('user_avatar'),
      );
    }

    // 加载主题设置
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // 加载其他设置
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _language = prefs.getString('language') ?? 'zh_CN';

    notifyListeners();
  }

  // ==================== 事件通知 ====================

  /// 通知 Tab 点击
  void notifyTabTap(int index) {
    _tabTapController.add(index);
  }

  // ==================== 用户相关方法 ====================

  /// 登录
  Future<void> login(String token, User user) async {
    _token = token;
    _user = user;
    _isLoggedIn = true;

    // 保存到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.avatar != null) {
      await prefs.setString('user_avatar', user.avatar!);
    }

    notifyListeners();
  }

  /// 退出登录
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isLoggedIn = false;

    // 清除本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_avatar');

    notifyListeners();
  }

  /// 更新用户信息
  Future<void> updateUser(User user) async {
    _user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.avatar != null) {
      await prefs.setString('user_avatar', user.avatar!);
    }

    notifyListeners();
  }

  // ==================== 主题相关方法 ====================

  /// 切换深色模式
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);

    notifyListeners();
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);

    notifyListeners();
  }

  // ==================== 设置相关方法 ====================

  /// 设置通知开关
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    notifyListeners();
  }

  /// 设置语言
  Future<void> setLanguage(String lang) async {
    _language = lang;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);

    notifyListeners();
  }

  // ==================== 加载状态 ====================

  /// 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ==================== 清除所有数据 ====================

  /// 清除所有本地数据
  Future<void> clearAll() async {
    _user = null;
    _token = null;
    _isLoggedIn = false;
    _isDarkMode = false;
    _themeMode = ThemeMode.light;
    _notificationsEnabled = true;
    _language = 'zh_CN';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}

// 全局快捷访问（需要在 Provider 外部使用时）
AppState get appState => AppState.instance;
