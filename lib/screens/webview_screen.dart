import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isError = false;
  String _pageTitle = '';
  bool _isSupported = true;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title ?? '详情';

    // 检查平台是否支持 WebView (仅 Android 和 iOS 支持官方 webview_flutter)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      _isSupported = true;
      _initWebView();
    } else {
      _isSupported = false;
      _isLoading = false;
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _isError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Try to get title if not provided
              if (widget.title == null) {
                _controller?.getTitle().then((title) {
                  if (title != null && title.isNotEmpty && mounted) {
                    setState(() {
                      _pageTitle = title;
                    });
                  }
                });
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _isError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            final scheme = uri.scheme.toLowerCase();

            // 允许标准 Web 协议和资源协议
            if (scheme == 'http' ||
                scheme == 'https' ||
                scheme == 'about' ||
                scheme == 'data' ||
                scheme == 'blob') {
              return NavigationDecision.navigate;
            }

            // 其他协议（如 mailto, tel, 唤起 App 等）尝试使用系统方式打开
            _launchExternalUrl(uri);
            return NavigationDecision.prevent;
          },
        ),
      );

    final validUri = _getValidUri(widget.url);
    _controller!.loadRequest(
      validUri,
      headers: {
        // 许多网站有防盗链机制，检查 Referer。
        // 将 Referer 设置为目标网站自身的 Origin，可以模拟站内跳转，绕过大部分防盗链。
        'Referer': validUri.origin,
      },
    );
  }

  Uri _getValidUri(String url) {
    Uri uri = Uri.parse(url);
    if (!uri.hasScheme) {
      // 如果没有协议头，默认添加 https
      uri = Uri.parse('https://$url');
    }
    return uri;
  }

  Future<void> _launchExternalUrl(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (!_isSupported) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.computer, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Windows 暂不支持内置浏览器',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '请在 iOS/Android 模拟器或真机上运行',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _launchInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('在外部浏览器打开'),
            ),
          ],
        ),
      );
    } else if (_isError) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '加载失败',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _controller?.reload();
              },
              child: const Text('点击重试'),
            ),
          ],
        ),
      );
    } else {
      body = WebViewWidget(controller: _controller!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? const Color(0xFFE5E5EA), width: 0.5)),
        bottom: (_isLoading && _isSupported)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2.0),
                child: LinearProgressIndicator(minHeight: 2.0),
              )
            : null,
      ),
      body: SafeArea(child: body),
    );
  }
}
