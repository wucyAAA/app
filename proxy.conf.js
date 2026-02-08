const PROXY_CONFIG = {
  "/api": {
    "target": "https://hy.yunmagic.com",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "debug"
  }
};

module.exports = PROXY_CONFIG;
