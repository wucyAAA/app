import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../api/news_api.dart';
import '../utils/toast_utils.dart';

class MidPageScreen extends StatefulWidget {
  final String url; // Original link (id in Vue)
  final String? title;
  final String? recordId;

  const MidPageScreen({
    super.key,
    required this.url,
    this.title,
    this.recordId,
  });

  @override
  State<MidPageScreen> createState() => _MidPageScreenState();
}

class _MidPageScreenState extends State<MidPageScreen> {
  bool _spinning = true;
  final List<String> _imageUrls = [];
  Map<String, dynamic>? _twitterData;
  String? _htmlContent;
  Timer? _timer;
  bool _isBloomberg = false;
  
  // Display flags
  bool _showTwitter = false;
  bool _showReuter = false;
  bool _showBloomberg = false; // Images
  bool _showCaixin = false;
  bool _showJnz = false;
  bool _showBloombergMobile = false;

  @override
  void initState() {
    super.initState();
    if (widget.url.contains('blinks.bloomberg')) {
      _isBloomberg = true;
    }
    _fetchData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (widget.url.isEmpty) {
      ToastUtils.showError('没有链接！');
      return;
    }

    // Polling logic
    if (_timer != null && _timer!.isActive) return;

    _doFetch();
  }

  Future<void> _doFetch() async {
    final result = await NewsApi.getMidPageData(
      link: widget.url,
      recordId: widget.recordId,
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      final data = result.data!;
      if (data.status == 'ok') {
        _timer?.cancel();
        _timer = null;
        
        setState(() {
          _spinning = false;
          _parseData(data);
        });
      } else {
        // Polling if status not ok
        _timer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
          _doFetch();
        });
      }
    } else {
      // Error handling
      ToastUtils.showError('获取失败');
    }
  }

  Future<void> _parseData(MidPageData data) async {
    final link = widget.url;

    if (link.contains('twitter.com')) {
      _showTwitter = true;
      if (data.contentData is Map) {
        _twitterData = Map<String, dynamic>.from(data.contentData);
      }
    } else if (link.contains('reuters')) {
      _showReuter = true;
      _htmlContent = data.html ?? (data.contentData is Map ? data.contentData['html'] : null);
    } else if (link.contains('blinks.bloomberg')) {
      _showBloomberg = true;
      for (var l in data.urls) {
        final parts = l.split('/');
        if (parts.isNotEmpty) {
          final imgName = parts.last;
          if (imgName.startsWith('jm')) {
            final decrypted = await _decryptImg(l);
            _imageUrls.add(decrypted);
          } else {
            _imageUrls.add(l);
          }
        }
      }
    } else if (link.contains('caixin') || link.contains('baiinfo')) {
      _showCaixin = true;
      _htmlContent = data.html ?? (data.contentData is Map ? data.contentData['html'] : null);
    } else if (link.contains('zzb.jddglobal')) {
      _showJnz = true;
      try {
        final d = data.contentData is String 
            ? jsonDecode(data.contentData) 
            : data.contentData;
        
        if (d != null && d['data'] != null) {
          final inner = d['data'];
          _htmlContent = '<h1>${inner['mainTitle']}</h1>${inner['content']}';
        }
      } catch (e) {
        debugPrint('JNZ parse error: $e');
      }
    } else if (link.contains('articles.zsxq.com')) {
      _showJnz = true;
      _htmlContent = data.html ?? (data.contentData is Map ? data.contentData['html'] : null);
    } else if (link.contains('api.zsxq.com/v2/files')) {
      _showJnz = true;
      final html = data.html ?? (data.contentData is Map ? data.contentData['html'] : '');
      final fileName = widget.title;
      if (html != null && html.toString().contains('upload')) {
        _htmlContent = '点击链接下载文件：<a href="$html">${fileName ?? '文件'}</a>';
      } else {
        _htmlContent = '星球源文件被删除或被修改！无法下载！';
      }
    } else if (link.contains('www.cls.cn') || link.contains('acecamp')) {
      _showJnz = true;
      _htmlContent = data.html ?? (data.contentData is Map ? data.contentData['html'] : null);
    } else {
      _showBloombergMobile = true;
      _htmlContent = data.html ?? (data.contentData is Map ? data.contentData['html'] : null);
    }
  }

  String _cleanReutersHtml(String html) {
    // Remove embedded <style> blocks — flutter_html doesn't handle them well
    html = html.replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false), '');
    // Remove inline style attributes that override mobile-friendly rendering
    html = html.replaceAll(RegExp(r'\s*style="[^"]*"', caseSensitive: false), '');
    // Remove base64 inline images (tiny icons that clutter the layout)
    html = html.replaceAll(RegExp(r'<img[^>]*src="data:image[^"]*"[^>]*/?>',caseSensitive: false), '');
    // Convert {{timestamp}} placeholders to readable date
    html = html.replaceAllMapped(RegExp(r'\{\{(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\.\d+\+\d+\}\}'), (m) {
      return '${m[1]}-${m[2]}-${m[3]} ${m[4]}:${m[5]}:${m[6]}';
    });
    // Collapse excessive <br/> sequences
    html = html.replaceAll(RegExp(r'(<br\s*/?>[\s]*){3,}', caseSensitive: false), '<br/><br/>');
    // Remove empty divs
    html = html.replaceAll(RegExp(r'<div[^>]*>\s*</div>', caseSensitive: false), '');
    return html;
  }

  Future<String> _decryptImg(String url) async {
    // TODO: Implement actual decryption logic from utils/util.js
    // For now return as is.
    return url;
  }

  String _safeOrigin(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme && uri.hasAuthority) return uri.origin;
    } catch (_) {}
    return '';
  }

  String _cleanUrl(dynamic val) {
    if (val == null) return '';
    String s = val.toString();
    if (s.startsWith('["') && s.endsWith('"]')) {
      return s.substring(2, s.length - 2);
    }
    return s;
  }

  Future<void> _reportErr() async {
    final success = await NewsApi.reportMidPageError(link: widget.url);
    if (success) {
      ToastUtils.showSuccess('上报成功');
      setState(() {
        _imageUrls.clear();
        _spinning = true;
      });
      _fetchData();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '详情',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isBloomberg)
            TextButton(
              onPressed: _reportErr,
              child: const Text('报错', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ),
          IconButton(
            icon: Icon(
              LucideIcons.externalLink,
              size: 20,
              color: theme.textTheme.bodyMedium?.color,
            ),
            onPressed: () => _launchUrl(widget.url),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: theme.dividerColor.withOpacity(0.2),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: _spinning
            ? _buildLoading(theme)
            : _buildContent(theme),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 14),
          const SizedBox(height: 16),
          Text(
            '正在加载...',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_showBloomberg) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: _imageUrls[index],
            httpHeaders: {
              'Referer': _safeOrigin(_imageUrls[index]),
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
            },
            placeholder: (context, url) => Container(
              height: 200, 
              color: theme.cardTheme.color,
              child: const Center(child: CupertinoActivityIndicator())
            ),
            errorWidget: (context, url, error) => const SizedBox(
              height: 200,
              child: Icon(Icons.error, color: Colors.grey),
            ),
            fit: BoxFit.contain,
          );
        },
      );
    }

    if (_showTwitter && _twitterData != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (_twitterData!['type'] != null)
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: CachedNetworkImageProvider(
                          _cleanUrl(_twitterData!['type']),
                          headers: {
                            'Referer': _safeOrigin(_cleanUrl(_twitterData!['type'])),
                            'User-Agent':
                                'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                          },
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _twitterData!['author'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@${_twitterData!['author_id'] ?? ''}',
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.twitter, color: Colors.blue[400], size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                if (_twitterData!['title'] != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: 8),
                     child: Text(
                       _twitterData!['title'],
                       style: const TextStyle(fontSize: 16, height: 1.5),
                     ),
                   ),
                if (_twitterData!['content'] != null)
                  Text(
                    _twitterData!['content'],
                    style: TextStyle(
                      fontSize: 15, 
                      height: 1.5,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                const SizedBox(height: 16),
                if (_twitterData!['link'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: _cleanUrl(_twitterData!['link']),
                      httpHeaders: {
                        'Referer': _safeOrigin(_cleanUrl(_twitterData!['link'])),
                        'User-Agent':
                            'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36',
                      },
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: CupertinoActivityIndicator())),
                      errorWidget: (context, url, error) =>
                          Container(height: 200, color: Colors.grey[100], child: const Icon(Icons.broken_image)),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_twitterData!['content_time'] != null)
                  Text(
                    _twitterData!['content_time'],
                    style: TextStyle(
                      color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showReuter && _htmlContent != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Html(
          data: _cleanReutersHtml(_htmlContent!),
          style: {
            "body": Style(
              fontSize: FontSize(16),
              fontFamily: 'system-ui, -apple-system, sans-serif',
              lineHeight: LineHeight(1.8),
              color: theme.textTheme.bodyLarge?.color,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "h1": Style(
              fontSize: FontSize(22),
              fontWeight: FontWeight.bold,
              lineHeight: LineHeight(1.4),
              margin: Margins.only(bottom: 16),
              color: theme.textTheme.titleLarge?.color,
            ),
            "h2": Style(
              fontSize: FontSize(18),
              fontWeight: FontWeight.w600,
              margin: Margins.only(top: 20, bottom: 12),
              color: theme.textTheme.titleMedium?.color,
            ),
            "p": Style(
              fontSize: FontSize(16),
              lineHeight: LineHeight(1.8),
              margin: Margins.only(bottom: 14),
            ),
            "a": Style(
              color: theme.primaryColor,
              textDecoration: TextDecoration.none,
            ),
            "li": Style(
              fontSize: FontSize(15),
              lineHeight: LineHeight(1.6),
              margin: Margins.only(bottom: 8),
            ),
            "ul": Style(
              margin: Margins.only(bottom: 16, left: 4),
              padding: HtmlPaddings.only(left: 12),
            ),
            ".newsHeaderH1": Style(
              fontSize: FontSize(22),
              fontWeight: FontWeight.bold,
              lineHeight: LineHeight(1.4),
              margin: Margins.only(bottom: 12),
            ),
            ".date": Style(
              fontSize: FontSize(13),
              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
              margin: Margins.only(bottom: 16),
            ),
            ".storyContent": Style(
              fontSize: FontSize(16),
              lineHeight: LineHeight(1.8),
              margin: Margins.only(top: 8),
            ),
            ".storyId": Style(
              display: Display.none,
            ),
            ".copyright": Style(
              fontSize: FontSize(11),
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey[400],
              margin: Margins.only(top: 24),
              padding: HtmlPaddings.only(top: 16),
              border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.3))),
            ),
            ".disclaimer": Style(
              fontSize: FontSize(11),
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5) ?? Colors.grey[400],
            ),
            "img": Style(
              margin: Margins.symmetric(vertical: 8),
            ),
          },
          onLinkTap: (url, attributes, element) {
            if (url != null) _launchUrl(url);
          },
        ),
      );
    }

    if ((_showCaixin || _showJnz || _showBloombergMobile) && _htmlContent != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Html(
          data: _htmlContent!,
          style: {
            "body": Style(
              fontSize: FontSize(17),
              fontFamily: 'system-ui, -apple-system, sans-serif',
              lineHeight: LineHeight(1.6),
              color: theme.textTheme.bodyLarge?.color,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            "h1": Style(
              fontSize: FontSize(22),
              fontWeight: FontWeight.bold,
              margin: Margins.only(bottom: 16),
            ),
            "h2": Style(
              fontSize: FontSize(20),
              fontWeight: FontWeight.w600,
              margin: Margins.only(top: 24, bottom: 12),
            ),
            "p": Style(
              margin: Margins.only(bottom: 16),
            ),
            "a": Style(
              color: theme.primaryColor,
              textDecoration: TextDecoration.none,
            ),
            ".content": Style(
              backgroundColor: _showCaixin ? theme.cardTheme.color : null,
              border: _showCaixin ? Border.all(color: theme.dividerColor) : null,
              padding: _showCaixin ? HtmlPaddings.all(16) : null,
            ),
            ".article-title": Style(
              color: theme.textTheme.titleLarge?.color,
              fontSize: FontSize(20),
              fontWeight: FontWeight.bold,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
              padding: HtmlPaddings.only(bottom: 12),
              margin: Margins.only(bottom: 20),
            ),
          },
          onLinkTap: (url, attributes, element) {
            if (url != null) _launchUrl(url);
          },
        ),
      );
    }

    return Center(
      child: Text(
        '暂无内容',
        style: TextStyle(color: theme.textTheme.bodySmall?.color),
      ),
    );
  }
}