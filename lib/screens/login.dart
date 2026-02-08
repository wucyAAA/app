import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../api/login_api.dart';
import '../services/app_state.dart';
import '../router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await LoginApi.login(
        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result.success && result.user != null && result.token != null) {
        // 登录成功，更新全局状态
        await context.read<AppState>().login(result.token!, result.user!);

        if (mounted) {
          context.go(AppRoutes.news);
        }
      } else if (result.verifyCode != null) {
        // 需要验证
        setState(() {
          _errorMessage = '需要验证 (Code: ${result.verifyCode}) - 暂未支持';
        });
      } else {
        // 登录失败
        setState(() {
          _errorMessage = result.message ?? '登录失败';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '发生错误: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 头部 Logo 与 欢迎语

              Row(
                children: [
                  Image.asset(
                    'assets/favicon.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '幻云',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              Text(
                '欢迎回来',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '登录以继续使用您的账号',
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // 表单区域

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 用户名输入框

                    _buildNativeTextField(
                      context,
                      controller: _usernameController,
                      label: '用户名',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),

                    // 密码输入框

                    _buildNativeTextField(
                      context,
                      controller: _passwordController,
                      label: '密码',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      isObscure: _obscurePassword,
                      isDark: isDark,
                      onTogglePassword: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      onSubmitted: (_) => _handleLogin(),
                    ),

                    // 错误提示

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(Icons.error_rounded,
                              color: colorScheme.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const SizedBox(height: 24),

                    const SizedBox(height: 32),

                    // 登录按钮

                    FilledButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),

                        elevation: 0, // 扁平化设计

                        backgroundColor: colorScheme.primary,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Text(
                              '立即登录',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 封装更具 App 质感的输入框组件

  Widget _buildNativeTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    required bool isDark,
    VoidCallback? onTogglePassword,
    Function(String)? onSubmitted,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F7F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isObscure,
            textInputAction:
                isPassword ? TextInputAction.done : TextInputAction.next,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: '请输入$label',
              hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入$label';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }
}
