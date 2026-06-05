# 当前任务：Phase 1 MVP

> 开发顺序：后端 TDD → 前端同步 | 已完成模块详情见 **completed.md**

## 模块状态

| 模块 | 状态 | 测试数 |
|------|------|--------|
| BE-INFRA | ✅ | — |
| BE-AUTH  | ✅ | 37 |
| BE-USER  | ✅ | 17 |
| BE-CARD  | ✅ | 28 |
| BE-SYNC  | ✅ | 3  |
| BE-FRIEND | ✅ | 6 |
| BE-SHARE | ✅ | 20 |
| FE-INFRA | ✅ | — |
| FE-AUTH  | ✅ | — |
| FE-USER  | ✅ | — |
| FE-CARD  | 🔲 下一个 | — |
| FE-FRIEND | 🔲 下一个 | — |
| FE-SHARE  | 🔒 等待 FE-CARD + FE-FRIEND | — |

> BE-USER 测试数从 15 → 17（补充 `testDeleteAccountCascadesCardShares` + `testDeleteAccountCascadesFriendships`）

---

## 待解锁前端模块

| 模块 | 依赖 | 状态 |
|------|------|------|
| FE-CARD（卡片列表/添加/详情） | FE-AUTH ✅ + BE-CARD ✅ + BE-SHARE ✅ | **可开始** |
| FE-FRIEND（好友管理页面） | FE-AUTH ✅ + BE-FRIEND ✅ + BE-SHARE ✅ | **可开始** |
| FE-OFFLINE（离线缓存 + 增量同步） | FE-CARD + BE-SYNC ✅ | 等待 FE-CARD |
| FE-SHARE（共享管理） | FE-CARD + FE-FRIEND + BE-SHARE ✅ | 等待 FE-CARD + FE-FRIEND |

---

## Phase 1 完成标准

- [x] 所有后端集成测试通过（134 tests, 1 skipped）
- [x] 每个端点至少有 Happy Path + 401 + 403 测试
- [ ] OpenAPI 文档可访问（`/api/docs`）
- [x] 速率限制配置完毕（注册/登录/好友请求）
- [x] Docker Compose 启动后一键可运行测试
