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

## Git 规范

### 分支命名

```
feat/backend-auth          # 后端功能
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
