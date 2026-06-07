# 当前任务：Phase 1 MVP

> 开发顺序：后端 TDD → 前端同步 | 已完成模块详情见 **completed.md**
> 前端架构选型（2026-06-07 重新规划）：TanStack Query v5 + Zustand | Axios | RHF + Zod | expo-sqlite | StyleSheet + theme.ts | Jest + RNTL + MSW | react-native-qrcode-svg + jsbarcode + react-native-svg

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
| **FE-INFRA** | ✅ | 路由骨架、Axios 拦截器、Zustand、SecureStore、TanStack Query、MSW 配置全部完成 |
| FE-AUTH | ✅ | 登录/注册/会话恢复/Banner/登出，9 tests pass |
| FE-USER | ✅ | 设置页 + 修改用户名/密码 + 注销 |
| FE-CARD | ✅ | 9 tests pass |
| FE-OFFLINE | ⏳ 待开始 | 依赖 FE-CARD + BE-SYNC ✅ |
| FE-FRIEND | ⏳ 待开始 | 依赖 FE-INFRA + BE-FRIEND ✅ |
| FE-SHARE | ⏳ 待开始 | 依赖 FE-CARD + FE-FRIEND |

---

## 当前焦点：FE-OFFLINE / FE-FRIEND / FE-SHARE

> 前端已于 2026-06-07 完整重置（旧代码/依赖/缓存全部清除），从新架构重建。

### 已完成

- [x] 旧前端代码（`src/`）、缓存（`dist/`、`.expo/`）、依赖（`node_modules/`、`package-lock.json`）全部删除
- [x] `app.json` 更新（移除 `expo-barcode-scanner`，加入 `expo-camera` + 相机权限说明，名称改为 `CardPocket`）
- [x] `package.json` 更新为新依赖（axios、zustand、expo-sqlite、expo-camera、expo-brightness、react-native-qrcode-svg、jsbarcode、@react-native-community/netinfo、jest + RNTL + MSW 等）
- [x] 新目录骨架创建（`app/(auth)/`、`app/(app)/(tabs)/`、`src/components/`、`src/hooks/`、`src/lib/`、`src/store/`、`src/schemas/` 等）
- [x] `src/theme.ts`（颜色 / 字体 / 间距 / 圆角设计 Token）
- [x] `src/store/authStore.ts`（Zustand：user + accessToken 内存存储）

### ✅ FE-INFRA 全部完成（2026-06-07）

- [x] **FE-INFRA-01b**：`npm install`（react@19.2.7、@testing-library/react-native@^14.0.0、jsbarcode 等）
- [x] **FE-INFRA-04**：路由骨架（`app/_layout.tsx`、`(auth)/` 3 个页面、`(app)/_layout.tsx`、`(tabs)/` 3 个 tab 页）
- [x] **FE-INFRA-05**：`src/lib/api/client.ts`（Axios + 401 拦截 + 并发刷新去重）
- [x] **FE-INFRA-06**：`src/lib/api/endpoints/`（auth/cards/users/friends/shares 5 个文件）
- [x] **FE-INFRA-08**：`src/lib/storage/secureStore.ts`（Refresh Token + lastSync 封装）
- [x] **FE-INFRA-09**：`src/lib/storage/db.ts`（expo-sqlite v15 async API + cards 表）
- [x] **FE-INFRA-10**：`src/lib/query/QueryProvider.tsx` + `keys.ts`（TanStack Query v5）
- [x] **FE-INFRA-11**：`app/(app)/_layout.tsx` Auth Guard（`<Redirect href="/login" />`）
- [x] **FE-INFRA-12**：Jest + MSW 配置（rettime CJS stub + moduleNameMapper 解决 ESM 兼容性）
- [x] **FE-INFRA-13**：Zod schemas（`auth.ts` / `card.ts` / `friend.ts` / `cardShare.ts`）

---

## ✅ FE-AUTH 全部完成（2026-06-07）

- [x] **FE-AUTH-01**：`app/(auth)/login.tsx`（RHF + `LoginInputSchema` + `useLogin` hook）
- [x] **FE-AUTH-02**：`app/(auth)/register.tsx`（RHF + `RegisterInputSchema` + GDPR 勾选）
- [x] **FE-AUTH-03**：`app/(auth)/verify-email.tsx`（路由参数传 email + 重发验证邮件按钮）
- [x] **FE-AUTH-04**：`src/components/auth/EmailVerificationBanner.tsx`（未验证用户顶部 Banner，内置重发按钮）
- [x] **FE-AUTH-05**：`src/hooks/useLogout.ts`（`onSettled` 保证网络故障时也能退出）
- [x] **FE-AUTH-06**：`src/hooks/useSessionRestore.ts` + `src/lib/api/rawRefresh.ts`（冷启动会话恢复，`isRestoring` 防闪烁）
- [x] **FE-AUTH-07**：`__tests__/interceptor.test.ts`（9 tests：token 注入 / 401 刷新 / 并发 refresh 去重）

**MSW 配置扩展（伴随 FE-AUTH-07）**：
- `axios` moduleNameMapper → `dist/node/axios.cjs`（修复 react-native 条件下加载 browser 版问题）
- `@open-draft/deferred-promise` CJS stub（MSW 依赖，无 CJS 版本）
- `rettime` stub 补全 `emitAsPromise` + `hooks`
- 拦截器测试文件加 `@jest-environment node` 指令

---

## ✅ FE-USER 全部完成（2026-06-07）

- [x] **FE-USER-01**：`app/(app)/(tabs)/settings.tsx` 展示 `userName` / `email`（只读）
- [x] **FE-USER-02**：inline 修改用户名表单（RHF + `UpdateUsernameFormSchema` + 422 重名错误提示）
- [x] **FE-USER-03**：inline 修改密码表单（RHF + `ChangePasswordFormSchema`：当前密码 + 新密码 + 确认，400 错误提示）
- [x] **FE-USER-04**：注销账户二次确认 Modal（GDPR 数据清除说明 + `useDeleteAccount` → clear + redirect）

**新增文件**：`hooks/useUpdateUserName.ts` / `hooks/useChangePassword.ts` / `hooks/useDeleteAccount.ts`
**修改文件**：`schemas/auth.ts`（+2 form schemas）、`app/(app)/(tabs)/_layout.tsx`（+设置 Tab）

---

## ✅ FE-CARD 全部完成（2026-06-08）

- [x] **FE-CARD-01**：`src/components/cards/BarcodeDisplay.tsx`（QR_CODE → react-native-qrcode-svg；CODE_128/EAN_13/EAN_8/CODE_39/UPC_A → jsbarcode + @xmldom/xmldom 生成 SVG + SvgXml 渲染；PDF_417/AZTEC/DATA_MATRIX → 文字占位符）
- [x] **FE-CARD-02**：`app/(app)/(tabs)/index.tsx` 卡片列表（FlatList + 下拉刷新 + FAB 添加/扫码按钮 + 空状态）
- [x] **FE-CARD-03**：`app/(app)/cards/[id].tsx` 详情页（expo-brightness useFocusEffect 自动最大亮度 + 编辑 Modal + Alert 删除确认）
- [x] **FE-CARD-04**：`app/(app)/cards/add.tsx` 添加页（RHF + CardCreateInputSchema + 自定义 Modal 类型选择器 + BarcodeDisplay 实时预览 + 扫码预填支持）
- [x] **FE-CARD-05**：`app/(app)/cards/scan.tsx` 扫码页（useCameraPermissions + CameraView + expo-camera BarcodeType 映射 + router.replace 跳添加页）
- [x] **FE-CARD-06**：编辑卡片名称（详情页内联 Modal + useUpdateCard hook + RHF）
- [x] **FE-CARD-07**：删除卡片（Alert.alert 确认 + useDeleteCard hook + SQLite 同步删除）
- [x] **FE-CARD-08**：`__tests__/BarcodeDisplay.test.tsx`（9 种 barcodeType 渲染分支测试，9/9 通过）

**新增文件**：`src/lib/storage/cardMapper.ts`、`src/components/cards/BarcodeDisplay.tsx`、`src/components/cards/CardListItem.tsx`、`src/hooks/useSyncCards.ts`、`src/hooks/useCards.ts`、`src/hooks/useCreateCard.ts`、`src/hooks/useUpdateCard.ts`、`src/hooks/useDeleteCard.ts`、`app/(app)/cards/[id].tsx`、`app/(app)/cards/add.tsx`、`app/(app)/cards/scan.tsx`、`__tests__/BarcodeDisplay.test.tsx`

**修改文件**：`app/(app)/_layout.tsx`（Slot → Stack）、`app/(app)/(tabs)/index.tsx`（stub → 完整列表页）、`src/lib/storage/db.ts`（+`selectCardById`）

**关键技术点**：
- 同步策略：始终使用 `updatedAfter` 端点（首次用 epoch），避免处理分页响应格式
- RNTL v14 `render()` 是 async，必须 `await`；jest.mock 工厂禁用顶层 import 变量
- expo-camera `BarcodeScanningResult.type` 是 `string`，barcodeTypes 参数用 `CameraBarcodeType[]`

---

## Phase 1 完成标准

- [x] 所有后端集成测试通过（144 tests, 1 skipped）
- [x] 每个端点至少有 Happy Path + 401 + 403 测试
- [x] BE-BUGFIX Step 1~3 全部修复并补充测试
- [x] OpenAPI 文档可访问（`/api/docs`）
- [x] 速率限制配置完毕（注册 / 登录 / 好友请求）
- [x] Docker Compose 启动后一键可运行测试
- [x] 前端 FE-INFRA 完成（npm install + 路由骨架可启动）
- [x] 前端 FE-AUTH 完成（登录 / 注册 / 会话恢复）
- [x] 前端 FE-USER 完成（个人信息 / 修改 / 注销）
- [x] 前端 FE-CARD 完成（列表 / 添加 / 详情 / 扫码）
- [ ] 前端 FE-OFFLINE 完成（离线缓存 + 增量同步）
- [ ] 前端 FE-FRIEND 完成（好友管理）
- [ ] 前端 FE-SHARE 完成（共享管理）
