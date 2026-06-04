# CardPocket API 参考文档

> 基于 SPEC.md v1.2 | 后端：Symfony 7 + API Platform 4 | 基础路径：`/api`

---

## 通用规则

- **Content-Type**：`application/json`（请求和响应均为 JSON）
- **认证**：`Authorization: Bearer <access_token>`（除注册/登录/邮箱验证/重发验证邮件外所有端点）
- **OpenAPI 文档**：`GET /api/docs`（API Platform 自动生成）
- **UUID**：所有资源主键均为 UUID v4

---

## 错误响应格式

```json
{
  "type": "https://tools.ietf.org/html/rfc2616#section-10",
  "title": "Unauthorized",
  "status": 401,
  "detail": "JWT Token not found"
}
```

常见 HTTP 状态码：

| 状态码 | 含义 |
|--------|------|
| 200 | 成功（GET/PATCH） |
| 201 | 创建成功（POST） |
| 204 | 删除成功（DELETE） |
| 400 | 请求参数错误 |
| 401 | 未认证或 Token 过期 |
| 403 | 权限不足（Voter 拒绝） |
| 404 | 资源不存在 |
| 422 | 验证失败（字段约束不满足） |
| 429 | 速率限制触发 |

---

## 认证模块

### POST /api/auth/register
注册新用户，发送验证邮件，返回受限状态的用户信息。

**请求体**
```json
{
  "email": "user@example.com",
  "password": "strongPassword123",
  "userName": "john_doe",
  "gdprConsent": true
}
```

**响应 201**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "userName": "john_doe",
  "emailVerified": false,
  "createdAt": "2026-06-01T10:00:00Z"
}
```

**限制**：5 次/小时/IP

---

### POST /api/auth/verify-email
验证邮箱，解锁完整功能。Token 通过邮件链接中的查询参数传入。

**请求体**
```json
{
  "token": "email-verify-token-string"
}
```

**响应 200**
```json
{
  "message": "Email verified successfully"
}
```

**注意**：Token 24 小时有效，一次性使用。

---

### POST /api/auth/login
登录，返回 Access Token + Refresh Token。

**请求体**
```json
{
  "email": "user@example.com",
  "password": "strongPassword123"
}
```

**响应 200**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "abc123...",
  "token_type": "Bearer",
  "expires_in": 900
}
```

**限制**：10 次/分钟/IP

---

### POST /api/auth/refresh
用 Refresh Token 获取新的 Access Token（Rotation 策略：旧 Refresh Token 作废）。

**请求体**
```json
{
  "refresh_token": "abc123..."
}
```

**响应 200**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "new-refresh-token...",
  "expires_in": 900
}
```

---

### POST /api/auth/logout
使当前 Refresh Token 失效。

**请求体**
```json
{
  "refresh_token": "abc123..."
}
```

**响应 204**（无响应体）

---

### POST /api/auth/resend-verification
重新发送邮箱验证邮件。无论邮箱是否存在或已验证，始终返回 200（不泄露账户信息）。

**请求体**
```json
{
  "email": "user@example.com"
}
```

**响应 200**（无响应体）

**行为规则**：
- 未验证用户：创建新 `EmailVerificationToken`（24 小时有效）并发送验证邮件
- 已验证用户 / 不存在的邮箱 / 软删除用户：直接返回 200，不发邮件

**限制**：3 次/小时/邮箱

---

### POST /api/auth/push-token
*(Phase 2)* 注册或更新设备推送 Token。

**请求体**
```json
{
  "token": "ExponentPushToken[xxx]",
  "platform": "IOS"
}
```

platform 枚举值：`IOS` | `ANDROID` | `WEB`

**响应 201/200**（新建/更新）

---

## 用户模块

### GET /api/users/search
精确搜索用户（用于添加好友）。返回结果不暴露 email。

**查询参数**：`?q=<userName 或 email 精确值>`

**响应 200**
```json
[
  {
    "id": "uuid",
    "userName": "john_doe"
  }
]
```

若无匹配：返回空数组 `[]`（不返回 404，防止用户枚举探测）

**限制**：需已验证邮箱的用户才能调用

---

### GET /api/users/me
获取当前登录用户信息。

**响应 200**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "userName": "john_doe",
  "emailVerified": true,
  "createdAt": "2026-06-01T10:00:00Z"
}
```

---

### PATCH /api/users/me
更新当前用户信息（userName 或 password，二者均为可选）。

**请求体**（仅需传要修改的字段）
```json
{
  "userName": "new_username",
  "currentPassword": "oldPass",
  "newPassword": "newPass123"
}
```

修改密码时 `currentPassword` 必填。

**响应 200**（返回更新后的用户信息）

---

### DELETE /api/users/me
GDPR 删除账户，级联删除所有数据（不可逆）。

**响应 204**

级联删除顺序：
1. 软删除 User（deletedAt = now()）
2. 删除所有 owned Cards → 级联删除其 CardShare
3. 删除所有 viewer CardShare
4. 删除所有 Friendship（含关联 CardShare 级联）
5. 删除所有 PushToken（Phase 2）

---

### GET /api/users/me/data-export
*(Phase 3)* GDPR 数据导出，返回该用户所有个人数据的 JSON。

**响应 200**（JSON 文件）

---

## 好友模块

### GET /api/friendships
获取好友列表（仅 ACCEPTED 状态）。

**响应 200**
```json
[
  {
    "id": "uuid",
    "friend": {
      "id": "uuid",
      "userName": "jane_doe"
    },
    "createdAt": "2026-06-01T10:00:00Z"
  }
]
```

---

### GET /api/friendships/requests
获取我收到的待处理好友请求（PENDING）。

**响应 200**
```json
[
  {
    "id": "uuid",
    "requester": {
      "id": "uuid",
      "userName": "john_doe"
    },
    "createdAt": "2026-06-01T10:00:00Z"
  }
]
```

---

### POST /api/friendships
发送好友请求。

**请求体**
```json
{
  "addresseeId": "target-user-uuid"
}
```

**响应 201**
```json
{
  "id": "uuid",
  "status": "PENDING",
  "createdAt": "2026-06-01T10:00:00Z"
}
```

**错误**：
- 422：目标用户不存在 / 已是好友 / 已有 PENDING 请求
- 403：当前用户邮箱未验证

**限制**：20 次/天/用户

---

### PATCH /api/friendships/{id}/accept
接受好友请求（仅 Addressee 可操作）。

**响应 200**
```json
{
  "id": "uuid",
  "status": "ACCEPTED"
}
```

---

### DELETE /api/friendships/{id}
拒绝好友请求（PENDING）或解除好友关系（ACCEPTED）。

**响应 204**

**副作用**：若解除 ACCEPTED 好友，自动级联删除双方之间的所有 CardShare 记录。

---

## 卡片模块

### GET /api/cards
获取当前用户的所有卡片（自己创建 + 共享给我的）。支持增量同步。

**查询参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| `updatedAfter` | ISO 8601 | 增量同步：返回该时间后变化的卡片 |
| `archived` | boolean | Phase 2：过滤归档状态 |
| `q` | string | Phase 2：全文搜索 |
| `page` | integer | 分页页码（默认 1） |
| `itemsPerPage` | integer | 每页数量（默认 20，最大 50） |

**标准响应 200**（无 updatedAfter 时）
```json
{
  "member": [
    {
      "id": "uuid",
      "name": "Costco 会员卡",
      "barcodeType": "QR_CODE",
      "barcodeContent": "1234567890",
      "color": null,
      "gradient": null,
      "icon": null,
      "expiresAt": null,
      "archivedAt": null,
      "owner": {
        "id": "uuid",
        "userName": "john_doe"
      },
      "viewerNickname": null,
      "isOwner": true,
      "createdAt": "2026-06-01T10:00:00Z",
      "updatedAt": "2026-06-01T10:00:00Z"
    }
  ],
  "totalItems": 1
}
```

**增量同步响应 200**（携带 updatedAfter 时）
```json
{
  "updated": [
    {
      "id": "uuid",
      "name": "Costco 会员卡",
      "barcodeType": "QR_CODE",
      "barcodeContent": "1234567890",
      "viewerNickname": null,
      "isOwner": true,
      "updatedAt": "2026-06-01T10:00:00Z"
    }
  ],
  "deleted": ["uuid-of-deleted-card", "uuid-of-revoked-share"]
}
```

`deleted` 数组包含：已删除的 Card ID + 对当前用户撤销共享的 CardShare 对应的 Card ID。

---

### POST /api/cards
创建卡片。

**请求体**
```json
{
  "name": "Costco 会员卡",
  "barcodeType": "QR_CODE",
  "barcodeContent": "1234567890"
}
```

barcodeType 枚举值：`QR_CODE` | `CODE_128` | `EAN_13` | `CODE_39` | `PDF_417` | `AZTEC` | `EAN_8` | `UPC_A` | `DATA_MATRIX`

**响应 201**（返回完整 Card 对象）

**限制**：每用户最多 200 张（软限制，超出返回 422）

---

### GET /api/cards/{id}
获取单张卡片详情（Owner 或 Viewer 均可）。

**响应 200**（同 GET /api/cards 中的单条格式）

---

### PATCH /api/cards/{id}
更新卡片元数据（仅 Owner）。`barcodeType` 和 `barcodeContent` 字段即使传入也会被忽略。

**MVP 可修改字段**
```json
{
  "name": "新名称"
}
```

**Phase 2 追加可修改字段**
```json
{
  "icon": "🛒",
  "color": "#FF5733",
  "gradient": { "from": "#FF5733", "to": "#C70039", "direction": "horizontal" },
  "expiresAt": "2027-01-01T00:00:00Z",
  "archivedAt": null
}
```

**响应 200**

---

### DELETE /api/cards/{id}
删除卡片（仅 Owner）。级联删除所有 CardShare。

**响应 204**

---

## 共享管理模块

### GET /api/cards/{id}/shares
获取该卡片的共享成员列表（仅 Owner）。

**响应 200**
```json
[
  {
    "id": "card-share-uuid",
    "viewer": {
      "id": "uuid",
      "userName": "jane_doe"
    },
    "viewerNickname": null,
    "createdAt": "2026-06-01T10:00:00Z"
  }
]
```

---

### POST /api/cards/{id}/shares
添加共享成员（仅 Owner）。双方必须已是好友。

**请求体**
```json
{
  "viewerId": "target-user-uuid"
}
```

**响应 201**
```json
{
  "id": "card-share-uuid",
  "card": { "id": "card-uuid" },
  "viewer": { "id": "uuid", "userName": "jane_doe" },
  "viewerNickname": null,
  "createdAt": "2026-06-01T10:00:00Z"
}
```

**错误**：
- 403：双方不是好友
- 422：已共享给该用户

---

### PATCH /api/card-shares/{id}
Viewer 更新自己的私有昵称（仅 Viewer 本人可操作）。

**请求体**
```json
{
  "viewerNickname": "家庭超市卡"
}
```

传 `null` 可清除昵称。

**响应 200**

---

### DELETE /api/card-shares/{id}
移除共享（Owner 移除某 Viewer，或 Viewer 主动退出）。

**响应 204**

---

## 速率限制汇总

| 端点 | 限制维度 | 上限 |
|------|----------|------|
| POST /api/auth/register | IP | 5 次/小时 |
| POST /api/auth/login | IP | 10 次/分钟 |
| POST /api/auth/resend-verification | 邮箱 | 3 次/小时 |
| POST /api/friendships | 用户 | 20 次/天 |
| 所有其他认证 API | 用户 | 120 次/分钟 |
