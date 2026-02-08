# API 文档

## 获取研报/资讯列表

### 请求信息

**请求地址**

```
GET https://hy.yunmagic.com/api/v1/research/new/list
```

---

### 请求参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| page_size | int | 是 | 每页返回数量 | 20 |
| page_num | int | 是 | 页码，从1开始 | 1 |
| source | string | 是 | 数据来源 | new |
| embedding_limit | float | 否 | 嵌入相似度阈值 | 0.03 |
| begin | long | 否 | 开始时间（毫秒时间戳） | 1770048000000 |
| end | long | 否 | 结束时间（毫秒时间戳） | 1770220799999 |
| tags | string | 否 | 标签过滤，多个标签用逗号分隔（URL编码） | 散户,卖方,疑似卖方 |

---

### 响应参数

#### 顶层结构

| 字段 | 类型 | 说明 |
|------|------|------|
| code | int | 状态码，200表示成功 |
| message | string | 状态信息 |
| data | object | 响应数据 |

#### data 对象

| 字段 | 类型 | 说明 |
|------|------|------|
| data | array | 资讯/研报列表 |
| cache_id | int | 缓存ID |
| rule | string | 规则标识 |
| total | int | 总记录数 |

#### data.data 数组项

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 记录ID |
| time | string | 发布时间（格式：YYYY-MM-DD HH:mm:ss） |
| source | int | 来源类型 |
| source_id | int | 来源ID |
| seed_id | int | 种子ID |
| type | string | 类型，如 "research" |
| content_type | string | 内容类型，如 "meeting"、"card" |
| title | string | 标题 |
| content | string | 内容（可能包含HTML） |
| organization | string | 来源组织/群组名称 |
| author | string | 作者 |
| status | string | 状态，如 "normal" |
| creator | int | 创建者ID |
| raw_type | string | 原始类型，如 "image"、"card" |
| is_private | boolean | 是否私有 |
| is_hot | boolean | 是否热门 |
| is_optimistic | boolean | 是否乐观/看好 |
| code | string/null | 股票代码（可为空） |
| owner | string | 所有者 |
| recent_performance | string | 近期表现 |
| stock | array | 关联股票列表 |
| has_dup | boolean | 是否有重复 |
| detail_with_style | string | 带样式的详情内容 |
| url | string | 链接地址 |
| file_name | string | 文件名 |
| tag | int | 标签ID |
| raw | string | 原始文本内容 |
| text | string | 解析后的文本内容 |
| push | boolean | 是否推送 |
| click | boolean | 是否点击 |
| dup | boolean | 是否重复 |
| zsxq | boolean | 是否来自知识星球 |
| keywords | array | 关键词列表 |
| tags | array | 标签列表 |
| remark | array | 备注 |
| external | string | 外部信息 |
| category_report | string | 分类报告 |
| extra | string | 额外信息 |
| abstract | string | 摘要 |
| acquire | string | 获取信息 |
| industry | string | 行业 |
| report | string | 报告内容 |
| event | string | 事件 |
| structure | string | 结构信息 |

#### stock 数组项

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 股票代码 |
| name | string | 股票名称 |
| change | string | 涨跌幅 |
| open | string | 开盘价 |
| close | string | 收盘价 |

---

### 响应示例

```json
{
    "code": 200,
    "message": "ok",
    "data": {
        "data": [
            {
                "id": 6517293,
                "time": "2026-02-04 15:43:05",
                "source": 1,
                "source_id": 4484932,
                "seed_id": 11036,
                "type": "research",
                "content_type": "meeting",
                "title": "",
                "content": "微信图片 <img src=\"https://upload.yunmagic.com/research/图片xxx.png\"/>",
                "organization": "🔥逻辑前线",
                "author": "局外人",
                "status": "normal",
                "creator": 0,
                "raw_type": "image",
                "is_private": false,
                "is_hot": false,
                "is_optimistic": false,
                "code": null,
                "owner": "",
                "recent_performance": "",
                "stock": [
                    {
                        "code": "301396",
                        "name": "宏景科技",
                        "change": "",
                        "open": "",
                        "close": ""
                    }
                ],
                "has_dup": false,
                "detail_with_style": "微信图片 <img src=\"https://upload.yunmagic.com/research/图片xxx.png\"/>",
                "url": "https://upload.yunmagic.com/research/图片xxx.png",
                "file_name": "",
                "tag": 1,
                "raw": "微信图片",
                "text": "",
                "push": false,
                "click": false,
                "dup": false,
                "zsxq": false,
                "keywords": [],
                "tags": [
                    {
                        "name": "卖方",
                        "type": 3,
                        "report": false
                    }
                ],
                "remark": [],
                "external": "",
                "category_report": "",
                "extra": "",
                "abstract": "",
                "acquire": "",
                "industry": "",
                "report": "",
                "event": "",
                "structure": ""
            }
        ],
        "cache_id": 0,
        "rule": "nrsc",
        "total": 3451
    }
}
```

---

### 请求示例

```bash
curl -X GET "https://hy.yunmagic.com/api/v1/research/new/list?page_size=20&page_num=1&source=new&embedding_limit=0.03&begin=1770048000000&end=1770220799999&tags=%E6%95%A3%E6%88%B7,%E5%8D%96%E6%96%B9,%E7%96%91%E4%BC%BC%E5%8D%96%E6%96%B9"
```

---

### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 请求成功 |

---

### 备注

- `begin` 和 `end` 参数使用毫秒级时间戳
- `tags` 参数需要进行 URL 编码
- 返回的 `content` 字段可能包含 HTML 标签，如 `<img>` 和 `<a>`