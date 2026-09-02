# StudyLoop AI Workflow Integration Spec (AI 学习工作流融合设计规范)

- **Date**: 2026-09-02
- **Author**: Senior AI Application & Flutter Architect
- **Status**: SPEC APPROVED FOR IMPLEMENTATION

---

## 1. 核心定位与原则 (Core Philosophy & Boundary)

### 1.1 定位 (Positioning)
**AI 是 StudyLoop 既有工作流中的增强层（Enhancement Layer），而不是独立平行的另一套工作流。**
严禁将 StudyLoop 改造成通用 AI Chat App。AI 的角色是「柯基学习伴侣的大脑」，负责在用户卡住的每一个具体节点提供理解、陪伴、阻力推测与可执行行动建议。

核心工作原则：
> **AI Suggests, StudyLoop Decides, User Confirms.**
> (AI 负责理解与建议，Domain 负责事实与规则，用户拥有最终决定权。)

### 1.2 权限矩阵 (Permission Matrix)

| 领域 / 资源 | AI 可读 (READ) | AI 可建议 (PROPOSE) | AI 禁止写入 (FORBIDDEN WRITE) |
| :--- | :--- | :--- | :--- |
| **StudySession / 学习记录** | 裁剪后的学习状态、当前任务、已专注时长 | 无 | ❌ 严禁直接 INSERT / UPDATE / DELETE Session |
| **Timer / 倒计时** | 是否正在计时、已过秒数 | 建议时长（如 10 分钟） | ❌ 严禁直接启动、暂停、跳过、停止计时器 |
| **Reflection / 反思评分** | 用户主动输入的复盘文本 | 暖心陪伴反馈 | ❌ 严禁擅自为用户制造难度/专注/心情评分 |
| **Insights / 规律洞察** | 本地聚合统计的确定性结果 | 自然语言解读与实用习惯建议 | ❌ 严禁直接读取原始数据库、伪造不存在的学习规律 |
| **RevenueCat / Pro 订阅** | ❌ 严禁读取订阅详细信息与密钥 | 无 | ❌ 严禁修改 entitlement、触发购买或越权 |
| **SQLite 数据库** | ❌ 严禁直接访问底层 Drift 实体与数据库表 | 无 | ❌ 严禁执行任何 SQL 语句 |

---

## 2. 融合到 5 个核心工作流表面 (Surface Integration)

AI 必须无缝融入 StudyLoop 原生学习路径：
`打开 App -> 阻力与自由表达 -> 极小行动拆解 -> 专注学习 -> 复盘反思 -> 历史与洞察`

```text
                               ┌────────────────────────────────┐
                               │  AI Companion Enhancement      │
                               │  (DeepSeek-V3 / Local Fallback)│
                               └──────────────┬─────────────────┘
                                              │
 1. Home Surface                              ▼
 [卡住了？和柯基说一句] ─────────► [推测 Barrier + 建议极小行动] ──► 用户确认 ──► 注入现有 Session
                                              │
 2. Task Screen                               ▼
 [模糊任务: "复习高数"] ────────► ["让柯基帮我再缩小一点"] ─────► 用户采纳 ──► 写入任务/设置时长
                                              │
 3. Focus Screen                              ▼
 [专注中想放弃 / 焦虑] ────────► [小型 "陪我一下" 抽屉] ────────► 1~2句安抚 ──► 用户自行决定坚持或保存休息
                                              │
 4. Reflection Screen                         ▼
 [完成反思] ───────────────────► ["和柯基说说刚才怎么样"] ──────► 暖心复盘 ──► 绝不伪造评分(跳过仍为null)
                                              │
 5. Insights Screen                           ▼
 [本地确定性规律计算] ─────────► ["让柯基解释这个规律"] ────────► 通俗解读 ──► 给出科学学习建议
```

### 2.1 表面 1：Home (首页)
- **入口**：柯基卡片提示「卡住了吗？和我说一句」或自由输入阻力描述。
- **职责**：自然语言解析模糊阻力，映射到 5 种合法 `StudyBarrier`，并提供 `ProposedAction`（极小起步）。
- **用户控制**：展示「就从这一步开始」与「换一个建议」，点击后调用既有 `homeController` 启动。

### 2.2 表面 2：Task Screen (起步卡 / 任务编辑)
- **入口**：在任务输入框下方提供「让柯基帮我再缩小一点 (AI 极小切入点拆解)」。
- **职责**：针对用户填写的宏大任务（如「写完毕设第四章」），生成 5~15 分钟立即可上手的 Micro-Action（如「只列出第四章的3个小标题提纲」）。
- **用户控制**：点击「采用这个极小行动」自动更新任务名称与预计时长，用户随时可手动修改。

### 2.3 表面 3：Focus Screen (专注中)
- **入口**：轻量级「陪我一下」微型按钮/浮窗。
- **职责**：专注过程极其克制，1~2 句话温暖回应（如「已经在往前走了，如果真的疲惫，随时可以保存现在的进度休息」）。
- **边界**：绝不打扰计时，绝不自动结束或延长 Timer。

### 2.4 表面 4：Reflection Screen (反思复盘)
- **入口**：反思页面「和柯基说说刚才怎么样」。
- **职责**：轻量复盘，肯定用户的努力，帮助用户整理心情。
- **边界**：绝不代替用户选择 1~5 星评分；用户跳过反思时，严格记录 `null`，保持数据真实性。

### 2.5 表面 5：Insights Screen (规律洞察)
- **入口**：在统计指标卡片（如「最佳专注时段」、「最常完成的任务」）上提供「让柯基解释这个规律」。
- **职责**：将本地计算完成的结构化数据（如「完成 8 次，上午专注度平均高出 30%」）转化为有温度的人性化学习建议。
- **边界**：不得凭空捏造 Context 中未包含的历史规律。

---

## 3. 架构与数据模型 (Domain Models & Protocol)

### 3.1 表面枚举与意图枚举
```dart
enum CompanionSurface {
  home,
  taskBreakdown,
  focus,
  reflection,
  insights,
}

enum CompanionIntent {
  support,
  proposeAction,
  explainInsight,
  clarifyBarrier,
}

enum AIRequestStatus {
  idle,
  sending,
  success,
  failed,
  fallback,
}
```

### 3.2 上下文清洗与最小化 (`AIContextSanitizer`)
- **禁止项**：绝不包含 SQLite 数据库连接、未聚合的历史表、用户真实姓名/邮箱、RevenueCat 订阅详情、硬件识别码。
- **允许项**：
  - `surface`：当前页面；
  - `barrier`：当前选中的阻力枚举；
  - `taskType`：当前任务类型；
  - `currentTaskTitle`：裁剪至 100 字符以内的任务文本；
  - `companionState`：当前柯基动画状态；
  - `isFocusing`：是否正在专注；
  - `currentFocusDuration`：当前已专注秒数；
  - `recentLearning`：本地 7 天聚合统计（总次数、完成次数、平均分钟、主攻类型）；
  - `deterministicInsightText`：本地已计算完成的洞察文本；
  - `actualDurationMinutes`：本次实际学习分钟数。

### 3.3 严格校验机制 (`Schema Validation`)
- `suggestedMinutes` 钳制在 `[5, 60]` 区间；
- `suggestedBarrier` 必须映射到系统现有的 5 种 `StudyBarrier`，未知字段置为 `null`；
- `suggestedTaskType` 必须映射到系统现有的 `TaskType`，未知字段置为 `null`；
- JSON 解析自动去除 Markdown 围栏代码块。

### 3.4 降级防线 (`Local Fallback Engine`)
当满足以下任意条件时，毫秒级平滑降级至 `LocalCompanionEngine`（基于本地确定性规则库）：
1. 未配置 DeepSeek API Key；
2. 离线无网络；
3. 网络请求超时（> 10 秒）；
4. HTTP 4xx/5xx 或额度超限；
5. 返回非法 JSON 或解析异常。
**StudyLoop 在无网络、无 Key 下必须保证 100% 全流程可用。**
