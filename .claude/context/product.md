# CardPocket — 产品上下文（给 Claude 读）

> 这份文件帮助 Claude 快速理解产品背景，在提供帮助时不偏离产品设计。

---

## 这是什么

CardPocket 是一个**数字卡包应用**（mobile-first）。用户把实体卡片（会员卡、门票、优惠券）的条码扫描/输入进来，以后直接拿手机展示条码，不用带实体卡。核心场景：家人共用一张超市会员卡（一个人存，全家都能用）。

**重要**：这是一个**公开社区应用**，任何人都可以注册使用，非商业化，主要用户在欧洲（GDPR 适用）。

---

## 核心实体

| 实体 | 描述 |
|------|------|
| User | 注册用户，有 userName（显示名）和 email（登录用，不对外暴露） |
| Card | 一张数字化的实体卡，包含条码字符串和条码类型。属于一个 Owner |
| CardShare | 共享关系：Owner 把某张 Card 共享给某个 Viewer（好友）|
| Friendship | 好友关系，双向，有 PENDING/ACCEPTED 两个状态 |
| PushToken | Phase 2：设备推送 Token（Expo Push Token）|

---

## 关键业务规则（每次帮助时必须遵守）

1. **条码不可修改**：Card 的 barcodeType 和 barcodeContent 创建后不能改，PATCH 请求中静默忽略这两个字段。

2. **共享必须先加好友**：POST /api/cards/{id}/shares 必须验证双方存在 ACCEPTED 的 Friendship，否则 403。

3. **解除好友 → 级联删除 CardShare**：这个级联在应用层实现（不是数据库 FK），需要主动查询并删除。

4. **Viewer 昵称隔离**：CardShare.viewerNickname 只有 Viewer 自己可见，Owner 的 GET 响应不包含此字段。

5. **邮箱验证门控**：emailVerifiedAt 为 null 的用户不能创建 Card 和发送好友请求（返回 403）。

6. **增量同步的 deleted 字段**：GET /api/cards?updatedAfter= 的 deleted 数组包含已删除的 Card UUID 和对当前用户撤销的 CardShare 对应的 Card UUID（两种情况都让前端删本地缓存）。

7. **用户搜索不泄露 email**：搜索结果只返回 id + userName，即使搜索词是 email。

8. **卡片数量上限**：每用户最多 200 张 owned Card。

---

## 两个角色的区别

| 操作 | Owner | Viewer |
|------|-------|--------|
| 查看/展示条码 | ✅ | ✅ |
| 设置私有昵称（viewerNickname） | ❌ | ✅（仅自己可见）|
| 编辑卡片名称 | ✅ | ❌ |
| 删除卡片 | ✅ | ❌ |
| 管理共享成员 | ✅ | ❌ |
| 退出共享 | ❌ | ✅ |

---

## 不存在的功能（不要建议/实现）

- ❌ 标签/分类系统（用搜索代替）
- ❌ 卡片备注（notes 字段不存在）
- ❌ OAuth 登录（只有 email+password）
- ❌ 实时同步（进入前台时拉取，不做 WebSocket）
- ❌ 卡片转让给 Viewer（删账号时数据直接清除）
- ❌ 共享链接（必须是好友才能共享）
- ❌ Web 版（Phase 3 才有）

---

## 开发方法

- **后端**：TDD（先写 PHPUnit 测试，再实现）
- **前端**：同步后端（后端某模块通过测试后，前端才开始实现对应 UI）
- **数据库**：生产和开发/测试环境都用 PostgreSQL（不用 SQLite）

---

## 技术栈速查

| 端 | 栈 |
|----|-----|
| 原生 App | Expo (React Native) + TypeScript |
| 后端 | Symfony 7 + API Platform 4 + PHP 8.2 |
| 数据库 | PostgreSQL 16 |
| 认证 | LexikJWT（Access 15min + Refresh 30天 Rotation）|
| 本地存储 | expo-secure-store（AES-256）|
| 邮件 | Symfony Mailer（建议用 Resend SMTP）|
| 推送（Phase 2）| Expo Push API |

---

## 当前阶段

**Phase 1（MVP）** — 正在开发中。

后端开发顺序：认证 → 用户 → 卡片 CRUD → 增量同步 → 好友 → 共享。  
前端跟随后端每个模块完成后实现。

具体任务见 `.claude/tasks/current.md`。
