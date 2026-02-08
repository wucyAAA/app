# 推送列表接口 API 文档

## 基本信息

| 项目 | 说明 |
|------|------|
| 接口地址 | `/api/v1/push/list` |
| 请求方式 | GET |
| 接口描述 | 获取推送消息列表，支持分页、关键词搜索、时间范围筛选、类型筛选等功能 |

---

## 请求参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| page_num | integer | 是 | 页码，从1开始 |
| page_size | integer | 是 | 每页数量 |
| keyword | string | 否 | 搜索关键词（需URL编码） |
| begin_time | integer | 否 | 开始时间，13位毫秒级时间戳,默认当天0点 | 
| end_time | integer | 否 | 结束时间，13位毫秒级时间戳,默认第二天0点 |
| type | string | 否 | 推送类型，可选值见下表 |
| omit_survey | boolean | 否 | 是否隐藏调研纪要，`true`/`false` |

### type 可选值

| 值 | 说明 |
|----|------|
| (空) | 全部 |
| user | 用户 |
| auto_recommend | 自动新闻 |
| product | 产品价格 |
| system | 系统 |
| highly_recommend | 强推 |
| ai_recommend | AI推送 |

---

## 响应参数

| 参数名 | 类型 | 说明 |
|--------|------|------|
| code | integer | 状态码，200表示成功 |
| message | string | 响应消息 |
| data | object | 响应数据 |
| data.total | integer | 总记录数 |
| data.data | array | 推送记录列表 |

### data.data 数组元素结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| id | integer | 推送记录ID |
| time | string | 推送时间 |
| from | string | 推送人/来源 |
| site | string | 站点名称 |
| path | string | 栏目路径 |
| external | string | 扩展标识 |
| content | string | 推送内容标题 |
| type | string | 推送类型 |
| link | string | 原文链接或详情内容 |
| seed_id | integer | 种子ID |
| rule_id | integer | 规则ID |
| source_time | string | 原文发布时间 |
| data_id | integer | 数据ID |
| raw | string | 原始标题 |
| source | string | 来源标识 |

---

## 请求示例
```
GET /api/v1/push/list?page_size=50&page_num=1&keyword=测试&begin_time=1770134400000&end_time=1770220800000&type=user&omit_survey=true
```

---

## 响应示例
```json
{
    "code": 200,
    "message": "ok",
    "data": {
        "data": [
            {
                "id": 9791513,
                "time": "2026-02-04 16:58:43",
                "from": "罗韩",
                "site": "新浪网",
                "path": "新浪夜间24小时滚动",
                "external": "roll",
                "content": "广东：拓展无人驾驶公共交通运营区域，扩大智能网联汽车道路测试与示范应用范围",
                "type": "recommend",
                "link": "广东省印发加快数字社会高质量建设实施意见。鼓励旅游景区和旅游服务企业升级智慧旅游服务，运用数智技术提升旅游服务水平。拓展无人驾驶公共交通运营区域，扩大智能网联汽车道路测试与示范应用范围，鼓励导航、网约车、智慧停车等数字交通服务平台提供智慧融合交通服务。",
                "seed_id": 8331,
                "rule_id": 0,
                "source_time": "2026-02-04 16:25:13",
                "data_id": 29267365,
                "raw": "广东：拓展无人驾驶公共交通运营区域，扩大智能网联汽车道路测试与示范应用范围",
                "source": "release"
            },
            {
                "id": 9791195,
                "time": "2026-02-04 16:37:47",
                "from": "罗韩",
                "site": "证券时报网",
                "path": "人民财讯",
                "external": "",
                "content": "千里科技：子公司千里智驾已正式提交L3级智能驾驶测试牌照申请",
                "type": "recommend",
                "link": "https://www.stcn.com/article/detail/3629467.html",
                "seed_id": 790,
                "rule_id": 0,
                "source_time": "2026-02-04 15:40:18",
                "data_id": 29265492,
                "raw": "千里科技：子公司千里智驾已正式提交L3级智能驾驶测试牌照申请",
                "source": "release"
            }
        ],
        "total": 2
    }
}
```