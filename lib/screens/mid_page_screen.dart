import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/news_api.dart';
import '../utils/toast_utils.dart';
// import '../services/app_state.dart'; // Removing app_state dependency for now as UserInfo logic is simplified for conversion

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

  Future<String> _decryptImg(String url) async {
    // TODO: Implement actual decryption logic from utils/util.js
    // For now return as is.
    return url;
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('详情'),
        actions: [
          if (_isBloomberg)
            TextButton(
              onPressed: _reportErr,
              child: const Text('报错', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Watermarks
          const Positioned.fill(child: WatermarkWidget(text: '内部资料', color: Color(0x1A1890FF))),
          const Positioned.fill(child: WatermarkWidget(text: '请勿外传', color: Color(0x1A1890FF), offset: 50)),

          // Content
          if (_spinning)
            _buildLoading()
          else
            _buildContent(theme),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 20),
          const Text('L o a d i n g . . .'),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text('原文链接：'),
                GestureDetector(
                  onTap: () => _launchUrl(widget.url),
                  child: Text(
                    '点击跳转',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.url,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_showBloomberg) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: _imageUrls[index],
            placeholder: (context, url) => const SizedBox(
              height: 200, 
              child: Center(child: CupertinoActivityIndicator())
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_twitterData!['type'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _twitterData!['type'],
                          width: 40,
                          height: 40,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.person, size: 40),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _twitterData!['author'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@${_twitterData!['author_id'] ?? ''}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_twitterData!['title'] != null)
                  Text(_twitterData!['title'], style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (_twitterData!['content'] != null)
                  Text(_twitterData!['content']),
                const SizedBox(height: 10),
                if (_twitterData!['link'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _twitterData!['link'],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                if (_twitterData!['content_time'] != null)
                  Text(
                    _twitterData!['content_time'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _launchUrl(widget.url),
                  child: Text(
                    '原文链接：${widget.url}',
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if ((_showReuter || _showCaixin || _showJnz || _showBloombergMobile) && _htmlContent != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: _htmlContent!.replaceAll('\n', '<br/>'),
          style: {
            "body": Style(
              fontSize: FontSize(18),
              fontFamily: 'sans-serif',
              lineHeight: LineHeight(1.6),
            ),
            // "p": Style(
            //   textIndent: _showCaixin ? const TextIndent(2, TextIndentUnit.em) : null,
            // ),
            ".content": Style(
              backgroundColor: _showCaixin ? const Color(0xFFEAF0F2) : null,
              border: _showCaixin ? Border.all(color: const Color(0xFF95B2C0)) : null,
              padding: _showCaixin ? HtmlPaddings.all(15) : null,
            ),
            ".article-title": Style(
              color: Colors.red,
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5))),
            ),
          },
          onLinkTap: (url, attributes, element) {
            if (url != null) _launchUrl(url);
          },
        ),
      );
    }

    return const Center(child: Text('暂无内容'));
  }
}

class WatermarkWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double offset;

  const WatermarkWidget({
    super.key,
    required this.text,
    required this.color,
    this.offset = 0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _WatermarkPainter(
          text: text,
          color: color,
          offset: offset,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String text;
  final Color color;
  final double offset;

  _WatermarkPainter({required this.text, required this.color, this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: FontWeight.normal,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    const double stepX = 200;
    const double stepY = 200;
    
    canvas.save();
    canvas.rotate(-math.pi / 12); 

    // Draw pattern
    for (double y = -size.height; y < size.height * 2; y += stepY) {
      for (double x = -size.width; x < size.width * 2; x += stepX) {
        textPainter.paint(canvas, Offset(x + (y % (stepY * 2) == 0 ? 0 : stepX / 2), y + offset));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
