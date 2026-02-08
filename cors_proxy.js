// 本地代理服务器 - 解决 Flutter Web 跨域问题
// 使用方法: node cors_proxy.js

const http = require('http');
const https = require('https');
const url = require('url');

const PORT = 8010;
const TARGET_HOST = 'hy.yunmagic.com';

const server = http.createServer((req, res) => {
  // 设置 CORS 响应头
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Token, Authorization');

  // 处理预检请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  // 解析请求路径
  const parsedUrl = url.parse(req.url);

  // 转发请求到目标服务器
  const options = {
    hostname: TARGET_HOST,
    port: 443,
    path: parsedUrl.path,
    method: req.method,
    headers: {
      ...req.headers,
      host: TARGET_HOST,
    },
  };

  // 删除可能导致问题的头
  delete options.headers['origin'];
  delete options.headers['referer'];

  const proxyReq = https.request(options, (proxyRes) => {
    // 复制响应头
    Object.keys(proxyRes.headers).forEach((key) => {
      res.setHeader(key, proxyRes.headers[key]);
    });

    // 确保 CORS 头存在
    res.setHeader('Access-Control-Allow-Origin', '*');

    res.writeHead(proxyRes.statusCode);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Proxy error:', err);
    res.writeHead(500);
    res.end('Proxy error: ' + err.message);
  });

  req.pipe(proxyReq);
});

server.listen(PORT, () => {
  console.log(`CORS Proxy running at http://localhost:${PORT}`);
  console.log(`Forwarding requests to https://${TARGET_HOST}`);
  console.log('');
  console.log('在 Flutter 中使用:');
  console.log(`  http.setBaseUrl('http://localhost:${PORT}/api/v1/');`);
});
