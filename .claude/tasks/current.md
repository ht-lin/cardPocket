# 当前任务：Phase 1 MVP

> 开发顺序：后端 TDD | 已完成模块详情见 **completed.md**

## 模块状态

| 模块 | 状态 | 备注 |
|------|------|------|
| BE-INFRA | ✅ | — |
| BE-AUTH | ✅ | 37 tests |
| BE-USER | ✅ | 17 tests |
| BE-CARD | ✅ | 28 tests |
| BE-SYNC | ✅ | 3 tests |
| BE-FRIEND | ✅ | 6 tests |
| BE-SHARE | ✅ | 20 tests |
| BE-BUGFIX | ✅ | Step 1~3 全部完成 |

---

## Phase 1 完成标准

- [x] 所有后端集成测试通过（144 tests, 1 skipped）
- [x] 每个端点至少有 Happy Path + 401 + 403 测试
- [x] BE-BUGFIX Step 1~3 全部修复并补充测试
- [x] OpenAPI 文档可访问（`/api/docs`）
- [x] 速率限制配置完毕（注册 / 登录 / 好友请求）
- [x] Docker Compose 启动后一键可运行测试
