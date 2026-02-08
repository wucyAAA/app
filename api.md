# API 接口文档

## 目录

- [1. 登录接口](#1-登录接口)
- [2. 用户信息接口](#2-用户信息接口)

---

# 1. 登录接口

## 接口信息

| 项目 | 说明 |
|------|------|
| **URL** | `/v1/login` |
| **Method** | `POST` |
| **Content-Type** | `application/json` |

---

## 请求参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `username` | string | 是 | 用户名 |
| `password` | string | 是 | 加密后的密码 |
| `ssid` | string | 是 | 会话标识，从 localStorage 获取或随机生成 |

### 密码加密规则

```
md5('j3ZXHFo0ZEKy' + md5(原始密码)).toLowerCase()
```

### 请求示例

```json
{
  "username": "huanyun",
  "password": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
  "ssid": "abc123xyz789"
}
```

---

## 响应参数

### 通用响应结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `code` | number | 业务状态码 |
| `message` | string | 响应消息 |
| `data` | object/string | 响应数据 |

### 成功时 data 字段

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `user_id` | string | 用户 ID |
| `username` | string | 用户名 |
| `real_name` | string | 真实姓名 |
| `avatar` | string | 头像 URL（可为空） |
| `token` | string | JWT 认证令牌 |
| `code` | number | 登录验证状态码 |

### data.code 验证状态码说明

| 值 | 说明 | 前端行为 |
|----|------|----------|
| `0` | 登录成功，无需额外验证 | 跳转至 `/loading` |
| `1` | 需要验证（类型1） | 跳转至 `/verify?code=1` |
| `2` | 需要验证（类型2） | 跳转至 `/verify?code=2` |

---

## 响应示例

### 成功响应

```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "user_id": "3",
    "username": "huanyun",
    "real_name": "开发",
    "avatar": "",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "code": 0
  }
}
```

### 失败响应

```json
{
  "code": 20006,
  "message": "用户名或密码错误",
  "data": "用户名或密码错误"
}
```

---

## 业务状态码

| code | 说明 |
|------|------|
| `200` | 请求成功 |
| `20006` | 用户名或密码错误 |

---

## 密码加密示例

```javascript
import md5 from 'md5'

const encryptPassword = (password) => {
  const salt = 'j3ZXHFo0ZEKy'
  return md5(salt + md5(password)).toLowerCase()
}

// 使用示例
const encrypted = encryptPassword('123456')
```

---

# 2. 用户信息接口

## 接口信息

| 项目 | 说明 |
|------|------|
| **URL** | `/api/v1/user/info` |
| **Method** | `GET` |
| **Content-Type** | `application/json` |
| **认证方式** | Token（Header 或其他方式携带） |

---

## 请求参数

无需请求参数（通过 Token 识别用户）

---

## 响应参数

### 通用响应结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `code` | number | 业务状态码 |
| `message` | string | 响应消息 |
| `data` | object | 用户信息数据 |

### data 字段详情

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `user_id` | string | 用户 ID |
| `real_name` | string | 真实姓名/昵称 |
| `token` | string | JWT 认证令牌 |
| `role` | string | 主要角色（可为空） |
| `roles` | array | 用户权限列表 |
| `type` | string | 用户类型，如 `"user"` |
| `memo` | string | 备注信息（可为空） |

### roles 数组元素结构

| 参数名 | 类型 | 说明 |
|--------|------|------|
| `rolename` | string | 权限名称（中文） |
| `value` | string | 权限标识（英文） |

---

## 响应示例

### 成功响应

```json
{
  "code": 200,
  "message": "ok",
  "data": {
    "user_id": "3",
    "real_name": "开发",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "role": "",
    "roles": [
      {
        "rolename": "权限管理",
        "value": "permission_management"
      },
      {
        "rolename": "个人中心",
        "value": "application"
      }
    ],
    "type": "user",
    "memo": ""
  }
}
```

---

## 业务状态码

| code | 说明 |
|------|------|
| `200` | 请求成功 |