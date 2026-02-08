# 新闻滚动加载 API

用于获取新闻列表，支持**上拉加载（向上翻页）**和**下拉加载（向下翻页）**。两个方向使用同一接口，仅参数不同，返回数据结构完全一致。

---

## 基本信息

* **请求方式**：`GET`
* **接口地址**：`/api/v1/news/roll`
* **数据格式**：`JSON`

---

## 请求参数

| 参数名       | 类型      | 必填 | 说明                         |
| --------- | ------- | -- | -------------------------- |
| n         | number  | 是  | 返回数据条数                     |
| offset    | number  | 是  | 偏移基准 ID（通常为当前列表最小或最大新闻 ID） |
| direction | string  | 是  | 加载方向：`up`（上拉） / `down`（下拉） |
| leek      | boolean | 否  | 业务控制参数，默认 `false`          |

---

## 请求示例

### 1️⃣ 上拉加载（获取更早的新闻）

```http
GET https://hy.yunmagic.com/api/v1/news/roll?n=22&offset=29239535&direction=up&leek=false
```

* `offset`：当前列表中**最小**的新闻 ID
* `direction=up`：向上加载（历史数据）

---

### 2️⃣ 下拉加载（获取更新的新闻）

```http
GET https://hy.yunmagic.com/api/v1/news/roll?n=40&offset=29239421&direction=down&leek=false
```

* `offset`：当前列表中**最大**的新闻 ID
* `direction=down`：向下加载（最新数据）

---

## 响应数据结构

```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "data": [
      {
        "id": 29239419,
        "title": "上期能源 调整原油等期货相关合约<span style=\"color:rgb(190, 97, 97);font-weight:bold\">涨</span>跌停板幅度和交易保证金比例",
        "title_time": "2026-02-03 18:49:15",
        "link": "https://36kr.com/newsflashes/3667456074507141",
        "content": "",
        "content_time": "",
        "object": "",
        "type": "news",
        "author": "",
        "author_id": "Z2hfMjA2YjdiOWE4ZDgx",
        "seed_id": 989,
        "spider_begin_at": "2026-02-03 18:49:31",
        "spider_end_at": "2026-02-03 18:49:31",
        "site": "36kr快讯",
        "path": "快讯",
        "source_link": "https://36kr.com/newsflashes/",
        "name": "",
        "code": "",
        "mark": false,
        "home": 1,
        "star": 5,
        "class_id": 7,
        "duplication_id": 0,
        "time": 1770115771471,
        "is_copy_clicked": false,
        "is_link_clicked": false,
        "is_recommend_clicked": false,
        "is_highly_recommend_clicked": false,
        "named_entity": "",
        "sentiment": "",
        "title_raw": "上期能源 调整原油等期货相关合约涨跌停板幅度和交易保证金比例",
        "content_raw": "",
        "external": "",
        "is_translate": false,
        "source": "",
        "detail": "",
        "tag": {
          "tag": "",
          "rate": 0
        }
      }
    ]
  }
}
```

---

## 字段说明（data.data[]）

| 字段名        | 类型      | 说明                   |
| ---------- | ------- | -------------------- |
| id         | number  | 新闻唯一 ID（用于分页 offset） |
| title      | string  | 新闻标题（可能包含 HTML）      |
| title_time | string  | 标题时间                 |
| link       | string  | 新闻原文链接               |
| site       | string  | 新闻来源站点               |
| path       | string  | 新闻分类路径               |
| time       | number  | 时间戳（毫秒）              |
| mark       | boolean | 是否标记                 |
| star       | number  | 重要级别                 |
| class_id   | number  | 分类 ID                |
| title_raw  | string  | 纯文本标题                |
| tag        | object  | 标签信息                 |

---

## 分页加载建议

* **首次加载**：

  * 不传 `offset` 或使用当前时间附近的基准值
* **上拉加载**：

  * 使用当前列表中最小 `id` 作为 `offset`
* **下拉加载**：

  * 使用当前列表中最大 `id` 作为 `offset`
* 建议前端对 `id` 做去重处理，避免重复数据

---

## 备注

* 上拉 / 下拉接口 **完全一致**，仅通过 `direction` 区分
* `title` 字段可能包含 HTML，请前端自行处理渲染或过滤
