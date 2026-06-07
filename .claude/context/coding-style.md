# CardPocket — 编码规范

---

## 通用原则

- 代码是给人读的，命名要自解释
- 不写无谓注释（好的命名胜过注释）；只在非显而易见的"为什么"处写注释
- 不过度设计：三处类似代码才考虑抽象，不提前为假设的未来需求设计
- 每次提交前所有测试必须通过

---

## 后端（Symfony 7 + API Platform 4 + PHP）

### TDD 规则

- **Red → Green → Refactor**，不跳步骤
- 测试文件与功能同步提交，不事后补测试
- 集成测试使用真实 PostgreSQL（测试专用数据库），不 mock 数据库
- 每个 API 端点测试必须覆盖：正常路径、403（无权限）、404（不存在）
- 测试类命名：`{Feature}Test.php`，方法命名：`test{Action}{Condition}()`

```php
// 好：自解释的测试方法名
public function testCreateCardFailsWhenEmailNotVerified(): void {}
public function testDeleteFriendshipCascadesCardShares(): void {}

// 坏：
public function testCard(): void {}
public function test1(): void {}
```

### PHP 规范

- PHP 8.2+，严格类型：每个文件顶部 `declare(strict_types=1);`
- 使用 readonly 属性、枚举（PHP 8.1+ Enum）、命名参数
- 构造器属性提升（Constructor Promotion）

```php
// 好
class Card
{
    public function __construct(
        private readonly Uuid $id,
        private string $name,
        private readonly BarcodeType $barcodeType,
        private readonly string $barcodeContent,
    ) {}
}

// 坏
class Card
{
    private $id;
    private $name;
    public function __construct($id, $name) {
        $this->id = $id;
        $this->name = $name;
    }
}
```

### API Platform 4 规范

- **Resource DTO 独立于 Entity**：使用 `#[ApiResource]` 注解在独立的 DTO 类上，不注解 Entity
- **不使用 Serialization Groups**：每种视图/角色对应独立 Output DTO，每种写操作对应独立 Input DTO
- **不使用 `stateOptions(entityClass:...)`**：始终用自定义 State Provider/Processor，不依赖内置 Doctrine Provider
- **State Provider/Processor** 负责 DTO ↔ Entity 映射与业务逻辑，Entity 保持纯净
- **Voter 只负责授权**（能否访问该资源），不控制字段可见性；State Provider 判断角色并返回对应 Output DTO

**DTO 命名规范**：
- `{Resource}CreateInput`：POST 请求体
- `{Resource}UpdateInput`：PATCH 请求体
- `{Resource}Output`：单一视图的 GET 响应
- `{Resource}OwnerOutput` / `{Resource}ViewerOutput`：同一资源多角色的差异化视图

```php
// 好：独立 Output DTO，不同角色不同类，无 Serialization Groups
#[ApiResource(
    operations: [new Get(), new GetCollection()],
    provider: CardStateProvider::class,
)]
class CardOwnerOutput
{
    public string $id;
    public string $name;
    public string $barcodeType;
    public string $barcodeContent;
    // viewerNickname 不存在于此类
}

class CardViewerOutput
{
    public string $id;
    public string $name;
    public ?string $viewerNickname; // 仅 Viewer 可见
}

// State Provider 判断角色，返回对应 DTO；Voter 只判断能否访问
class CardStateProvider implements ProviderInterface
{
    public function provide(...): object|array|null
    {
        $this->security->denyAccessUnlessGranted('CARD_VIEW', $card); // Voter：能否访问

        return $card->getOwner() === $this->security->getUser()       // Provider：角色判断
            ? new CardOwnerOutput(...)
            : new CardViewerOutput(...);
    }
}
```

### 数据库规范

- 所有主键使用 UUID（Doctrine 的 UuidType）
- 软删除字段命名：`deletedAt: datetime|null`
- 时间字段统一使用 UTC，不存时区
- 数据库迁移使用 Doctrine Migrations，不手动修改 schema

### 错误处理

- 业务逻辑错误抛 `Symfony\Component\HttpKernel\Exception\*` 或自定义 Exception
- API Platform 会自动将 HttpException 转换为 JSON 响应
- 不用 try-catch 吞掉异常；让异常冒泡到全局处理器

---

## 前端（Expo React Native + TypeScript）

### TypeScript 规范

- `strict: true`（tsconfig.json）
- 不用 `any`；用 `unknown` + 类型守卫代替
- 类型从 Zod schema 派生（`z.infer<typeof Schema>`），不手写重复类型定义

### 文件组织

```
app/                  # Expo Router 路由文件（页面层，只做布局和调用 hooks）
src/components/       # 复用 UI 组件
src/hooks/            # 业务逻辑 Hook（use{Feature}.ts）
src/lib/api/client.ts # Axios 实例，不在其他地方 import axios
src/lib/api/endpoints/ # 每个资源一个文件（cards.ts / auth.ts / ...）
src/store/            # Zustand stores
src/schemas/          # Zod schemas
src/theme.ts          # 设计 Token（唯一样式常量来源）
```

- 组件里不直接调用 `axios`，只调用 `src/lib/api/endpoints/` 里的函数
- `queryFn` / `mutationFn` 只调用 endpoint 函数，不写请求逻辑

### 命名规范

- 组件文件：`PascalCase`（`BarcodeDisplay.tsx`）
- Hook：`camelCase` + `use` 前缀（`useCards.ts`）
- Zustand store：`camelCase` + `Store` 后缀（`authStore.ts`）
- 常量：`SCREAMING_SNAKE_CASE`（`MAX_CARDS_PER_USER = 200`）
- Zod schema：`PascalCase` + `Schema` 后缀（`LoginSchema`），派生类型去掉后缀（`type Login = z.infer<typeof LoginSchema>`）

### API 调用规范

```typescript
// src/lib/query/keys.ts — Query Key 常量
export const CARD_KEYS = {
  all: ['cards'] as const,
  list: () => [...CARD_KEYS.all, 'list'] as const,
  detail: (id: string) => [...CARD_KEYS.all, 'detail', id] as const,
};

// src/lib/api/endpoints/cards.ts — endpoint 函数
export async function fetchCards(): Promise<CardOwnerOutput[]> {
  const { data } = await apiClient.get('/api/cards');
  return CardOwnerOutputSchema.array().parse(data);
}

// src/hooks/useCards.ts — TanStack Query hook
export function useCards() {
  return useQuery({ queryKey: CARD_KEYS.list(), queryFn: fetchCards });
}
```

### Zustand Store 规范

```typescript
// src/store/authStore.ts
type AuthState = {
  user: UserProfile | null;
  accessToken: string | null;      // 内存只读，绝不持久化
  setUser: (user: UserProfile) => void;
  setAccessToken: (token: string | null) => void;
  clear: () => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  setUser: (user) => set({ user }),
  setAccessToken: (token) => set({ accessToken: token }),
  clear: () => set({ user: null, accessToken: null }),
}));

// 在拦截器等非 Hook 环境读取状态（不需要订阅）：
useAuthStore.getState().accessToken;
```

### 离线数据规范

- **卡片缓存**：expo-sqlite（`cards` 表），key 为 UUID
- **Refresh Token**：expo-secure-store，key 为固定字符串 `refresh_token`
- **lastSyncTimestamp**：expo-secure-store，key 为 `last_sync_ts`（ISO 8601 字符串）
- **Access Token**：Zustand 内存，App 重启后通过 `/refresh` 重新获取，**绝不写入任何持久化存储**
- 进入前台（`AppState` change to `'active'`）时触发同步，防抖 1 秒

### 条码渲染规范

```tsx
// BarcodeDisplay 组件内的分支逻辑
import QRCode from 'react-native-qrcode-svg';
import Barcode from '@kichiyaki/react-native-barcode-generator';

// QR_CODE 用 react-native-qrcode-svg
// 其余所有类型用 @kichiyaki/react-native-barcode-generator
export function BarcodeDisplay({ content, type }: BarcodeDisplayProps) {
  if (type === 'QR_CODE') {
    return <QRCode value={content} size={200} />;
  }
  return <Barcode value={content} format={type} width={2} height={80} />;
}
```

### 组件规范

- 优先使用函数组件 + Hook，不使用 class 组件
- Props 类型定义紧跟组件定义上方
- 条件渲染短时用三元，复杂时提取变量

```tsx
// 好
type BarcodeDisplayProps = {
  content: string;
  type: BarcodeType;
};

export function BarcodeDisplay({ content, type }: BarcodeDisplayProps) {
  if (type === 'QR_CODE') { ... }
  return <Barcode ... />;
}
```

### 表单规范

```typescript
// schemas/auth.ts
export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
export type Login = z.infer<typeof LoginSchema>;

// 页面中
const { control, handleSubmit } = useForm<Login>({
  resolver: zodResolver(LoginSchema),
});
```

- 对于单字段无验证需求的输入（如实时搜索框），可直接用 `useState`，不强制用 RHF

---

## Git 规范

### 分支命名

```
feat/backend-auth          # 后端功能
feat/frontend-card-list    # 前端功能
fix/friendship-cascade     # 问题修复
test/card-voter            # 补充测试
```

### Commit 消息格式

```
<type>(<scope>): <description>

type: feat | fix | test | refactor | docs | chore
scope: auth | card | friendship | share | user | infra

示例：
feat(auth): implement email verification flow
test(card): add incremental sync integration tests
fix(friendship): cascade delete CardShare on unfriend
```

### PR 规则

- 每个 PR 对应路线图中的一个模块（不要把多个模块混在一个 PR）
- PR 必须包含：对应的测试文件 + 通过 CI
- 后端 PR 合并前，前端不开始相关功能实现
