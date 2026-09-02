# StudyLoop UI 前后端交接与接口对齐规范 (Specification)

## 一、概述与背景

当前 StudyLoop 已完成基于 4 屏样机（Welcome、Home、Focus、Insights）的设计系统与视觉重构，并验证了真机运行与 38 项自动化测试。
为了实现正式企业级项目交付标准，消除 UI 与底层数据强耦合、Widget 内编写业务逻辑、Repository 缺乏统一封装、Drift 数据直入 UI 等问题，特制定本规范。

本规范确立严谨的 4 层分层架构：
```
[UI Layer (Pure Presentation / Widgets)]
       ↕ (ViewState DTO & Controller Callbacks)
[State Layer (Riverpod Controllers / Notifiers / ViewModels)]
       ↕ (Domain Models & UseCases & Results)
[Domain / Repository Layer (Abstract Repositories & Engine Services)]
       ↕ (Data Models / DTOs / SDK Calls)
[Data Layer (Drift SQLite / Purchases Flutter / Platform Channels)]
```

---

## 二、当前 UI / 业务交接问题报告（Phase 2 Audit）

| 序号 | 问题类别 | 涉及文件 | 具体问题表现 | 风险与危害 |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **Widget 内聚业务计算** | `lib/presentation/screens/insights_screen.dart` | 在 `build()` 方法内直接对全部历史记录进行日期过滤（7/30/90天）、字符串比对（`r.taskText.contains('复习')`）、计算百分比与环形分布图数据，并硬编码默认比例（45%, 30%, 15%, 10%）。 | 视图层与统计分析引擎强耦合，修改 UI 容易改坏统计；更换图表库无法复用计算；无单元测试保护。 |
| 2 | **直接依赖底层领域草稿** | `lib/presentation/screens/entry_screen.dart` | UI 直接读写 `SessionDraft` 领域实体；PrimaryButton 的 `onPressed` 内部直接判断 `draft.barrier == StudyBarrier.tiredness && draft.isSevere`、`draft.card == null` 等条件，并手动触发 `timerProvider.notifier.start(draft)`。 | 状态散落在各个按钮回调中，页面缺少集中单一状态真值源；若状态流转变更，需要在多个 Widget 中同步修改。 |
| 3 | **数据库与持久层直接操作** | `lib/presentation/screens/history_screen.dart`, `reflection_screen.dart` | `HistoryScreen` 中直接调用 `databaseProvider.deleteRecord(id)`；`reflection_screen.dart` 调用顶层函数 `commitReflection`，内部直接操作 `databaseProvider.commit(record)`。 | UI 绕过了 Repository 与业务审计层；无法进行统一的错误捕获与空状态/乐观更新管理。 |
| 4 | **RevenueCat SDK / 状态直连** | `lib/presentation/screens/paywall_screen.dart`, `settings_screen.dart` | UI 直接访问 `notifier.message` 并在 Widget 内部根据 `PurchaseResult` 分支处理，缺乏规范的 `PaywallViewState`（无加载态、商品列表结构化、网络不可用友好退避）。 | 支付逻辑一旦变更或无网络时，UI 可能出现白屏、死锁或未定义异常。 |
| 5 | **临时 Mock 与生产逻辑混杂** | `entry_screen.dart`, `insights_screen.dart` | 多个界面出现三元表达式兜底字符串（如 `draft.taskText.isNotEmpty ? draft.taskText : '复习线性代数：向量空间的定义'`），且无统一 Mock 接口标准。 | 数据真实性难以区分；正式上线后可能意外展示测试硬编码文案。 |
| 6 | **缺少统一 AsyncViewState** | 全局大部分 Screen | 缺乏标准的 Loading、Error、Empty、Success 四态封装，大量使用 `value ?? []` 或空保护，破坏了用户在网络延迟或空数据时的容错体验。 | 用户在冷启动或清空数据时可能看到闪烁或残缺布局。 |

---

## 三、4 层架构与职责划分标准

### 1. UI Layer（表现层）
- **职责**：
  - 仅消费所属界面的 `ViewState`（纯数据对象，已完成国际化字符串拼接与格式化）。
  - 响应用户点击，调用对应 `Controller` 暴露的高阶语义方法（例如 `controller.selectBarrier(type)`，`controller.startFocus(actionId)`）。
  - 纯净渲染 Loading / Empty / Error / Success 状态。
- **严禁**：
  - 严禁在 Widget 内做日期运算、百分比统计、正则匹配。
  - 严禁直接访问 `AppDatabase`、Drift DAO、`Purchases` SDK。
  - 严禁在底层组件内部直接 `ref.watch` 整个全局状态。

### 2. State Layer（状态与控制器层）
- **职责**：
  - 每个核心 Feature 拥有独立的 `ViewModel` 和 `Notifier` / `Controller`。
  - 负责将 Repository 返回的 Domain Model 转换为 UI 直接可消费的 `ViewState`。
  - 负责处理异步加载、错误捕获并映射为人类友好的错误提示。

### 3. Domain / Repository Layer（领域与仓库抽象层）
- **职责**：
  - 纯 Dart 代码，不依赖 Flutter `BuildContext` 或 Widget 体系。
  - 抽象接口：
    - `TaskBreakdownRepository`: 负责阻力诊断与微任务拆解。
    - `FocusSessionRepository`: 负责专注会话创建、暂停/恢复真实时间计算、非惩罚性完成归档。
    - `InsightsRepository`: 负责聚合计算专注时长、时间段分布、任务类型、确定性规则说明。
    - `EntitlementRepository`: 负责处理 Pro 权限、购买、恢复购买（已抽象 Fake / RevenueCat 双实现）。
  - 领域错误系统：`AppFailure`、`DatabaseFailure`、`BillingUnavailableFailure` 等。

### 4. Data Layer（数据与平台实现层）
- **职责**：
  - `DriftAppDatabase`: 实现 SQLite 的持久化存储，屏蔽 SQL 细节。
  - `RevenueCatEntitlementRepository`: 封装 `purchases_flutter` SDK。
  - `ImePlatformChannel`: 处理 Android 原生软键盘唤起。

---

## 四、界面级 ViewState 与控制器接口设计

### 1. Welcome 界面
```dart
class WelcomeViewState {
  const WelcomeViewState({required this.isChinese, required this.corgiAsset});
  final bool isChinese;
  final String corgiAsset; // 'assets/images/corgi_welcome.png'
}

abstract interface class WelcomeController {
  void toggleLanguage();
  void startJourney();
}
```

### 2. Home / Entry 界面
```dart
enum BarrierType {
  dontKnowWhereToStart,
  tooManyTasks,
  phoneDistraction,
  lowEnergy,
  overPreparing,
}

class BarrierViewData {
  const BarrierViewData({
    required this.type,
    required this.title,
    required this.icon,
    required this.selected,
  });
  final BarrierType type;
  final String title;
  final IconData icon;
  final bool selected;
}

class MinimumActionViewData {
  const MinimumActionViewData({
    required this.id,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    required this.difficultyLabel,
    required this.canStart,
  });
  final String id;
  final String title;
  final String description;
  final int estimatedMinutes;
  final String difficultyLabel;
  final bool canStart;
}

class HomeViewState {
  const HomeViewState({
    required this.greeting,
    required this.barriers,
    this.selectedBarrier,
    this.suggestedAction,
    required this.companionState,
    this.isLoading = false,
    this.errorMessage,
  });
  final String greeting;
  final List<BarrierViewData> barriers;
  final BarrierType? selectedBarrier;
  final MinimumActionViewData? suggestedAction;
  final DogState companionState;
  final bool isLoading;
  final String? errorMessage;
}

abstract interface class HomeController {
  void selectBarrier(BarrierType type);
  Future<StartFocusResult> startFocus();
  void openSettings();
  void openChat();
}
```

### 3. Focus 界面
```dart
enum FocusStatus { running, paused, completed }

class FocusViewState {
  const FocusViewState({
    required this.sessionId,
    required this.taskTitle,
    required this.actionInstruction,
    required this.plannedMinutes,
    required this.elapsedSeconds,
    required this.remainingSeconds,
    required this.formattedRemaining,
    required this.progress,
    required this.status,
    required this.companionState,
    required this.corgiAsset,
    required this.isPaused,
    required this.canFinish,
  });
  final String sessionId;
  final String taskTitle;
  final String actionInstruction;
  final int plannedMinutes;
  final int elapsedSeconds;
  final int remainingSeconds;
  final String formattedRemaining;
  final double progress;
  final FocusStatus status;
  final DogState companionState;
  final String corgiAsset; // 'assets/images/corgi_focus.png'
  final bool isPaused;
  final bool canFinish;
}

abstract interface class FocusController {
  void pause();
  void resume();
  Future<FinishSessionResult> finishSession();
}
```

### 4. Insights 界面
```dart
enum InsightRange { week, month, threeMonths, all }

class ChartPoint {
  const ChartPoint({required this.dateLabel, required this.value, required this.isHighlight});
  final String dateLabel;
  final double value;
  final bool isHighlight;
}

class FocusDurationInsight {
  const FocusDurationInsight({
    required this.totalHours,
    required this.changePercent,
    required this.points,
  });
  final double totalHours;
  final double? changePercent; // +18.0
  final List<ChartPoint> points;
}

class BestDurationInsight {
  const BestDurationInsight({required this.durationLabel, required this.description});
  final String durationLabel; // '45–60 min'
  final String description;
}

class BestTimeInsight {
  const BestTimeInsight({
    required this.timeWindowLabel, // '9:00 - 11:00 AM'
    required this.efficiencyBonus, // 0.17
    required this.sampleCount,
  });
  final String timeWindowLabel;
  final double efficiencyBonus;
  final int sampleCount;
}

class TaskCategoryDistribution {
  const TaskCategoryDistribution({
    required this.categoryName,
    required this.percentage,
    required this.colorHex,
  });
  final String categoryName;
  final double percentage; // 0.45
  final int colorHex;
}

class TaskDistributionInsight {
  const TaskDistributionInsight({required this.categories});
  final List<TaskCategoryDistribution> categories;
}

class InsightExplanation {
  const InsightExplanation({
    required this.title,
    required this.description,
    required this.sampleSize,
    required this.ruleDescription,
  });
  final String title;
  final String description;
  final int sampleSize;
  final String ruleDescription;
}

class InsightsViewState {
  const InsightsViewState({
    required this.selectedRange,
    required this.focusDuration,
    this.bestDuration,
    this.bestTime,
    required this.taskDistribution,
    required this.hasEnoughData,
    required this.isPro,
    this.isLoading = false,
    this.errorMessage,
    this.explanation,
  });
  final InsightRange selectedRange;
  final FocusDurationInsight focusDuration;
  final BestDurationInsight? bestDuration;
  final BestTimeInsight? bestTime;
  final TaskDistributionInsight taskDistribution;
  final bool hasEnoughData;
  final bool isPro;
  final bool isLoading;
  final String? errorMessage;
  final InsightExplanation? explanation;
}
```

---

## 五、UI ↔ Domain ↔ Database 完整字段映射表

| UI 展现字段 (ViewData) | Domain Model (`models.dart`) | Drift Database Column (`StudyRecords`) | 数据类型 | 允许为空 (Null Rule) | 校验 / 规范 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `sessionId` | `StudyRecord.id` | `id` | String (UUIDv4) | **NOT NULL** | 唯一主键 |
| `taskTitle` | `SessionDraft.taskText` / `StudyRecord.taskText` | `task_text` | String | **NOT NULL** | 最少 1 字符 |
| `barrierType` | `SessionDraft.barrier` / `StudyRecord.barrier` | `barrier` | Enum / String | **NOT NULL** | 映射 `StudyBarrier` |
| `taskType` | `SessionDraft.taskType` / `StudyRecord.taskType` | `task_type` | Enum / String | **NOT NULL** | 映射 `TaskType` |
| `examSubtype` | `SessionDraft.examSubtype` | `exam_subtype` | Enum / String | NULLABLE | 仅在 examRevision 下有值 |
| `plannedMinutes` | `plannedSeconds ~/ 60` | `planned_seconds` | Int (秒) | **NOT NULL** | > 0，默认 900 (15m) |
| `actualMinutes` | `actualSeconds ~/ 60` | `actual_seconds` | Int (秒) | **NOT NULL** | >= 0，真实前台累积秒数 |
| `focusStatus` | `outcome` | `outcome` | Enum / String | **NOT NULL** | completed / interrupted |
| `difficultyRating` | `difficulty` | `difficulty` | Int (1–5) | **NOT NULL** | 1 (极简) ~ 5 (极难) |
| `focusRating` | `focus` | `focus` | Int (1–5) | **NOT NULL** | 1 (涣散) ~ 5 (深度专注) |
| `moodChange` | `moodChange` | `mood_change` | Enum / String | **NOT NULL** | moreAtEase/unchanged/worse |
| `actionInstruction`| `StartCard.action` | N/A (动态拆解) | String | **NOT NULL** | 最小启动行动 |
| `dateLabel` | `startedAt` (经过 DateFormat) | `started_at` | DateTime | **NOT NULL** | ISO8601 毫秒级时间戳 |

---

## 六、图片形象贴图与资产对齐方案

依据用户要求“1、柯基用图片中的形象贴图”，将参考图中的 3 个柯基形象提取为 3x 高清透明 PNG 资产，并完全替换现有的简单矢量插画：
1. **Screen 1 (Welcome Screen)**:
   - 资产路径：`assets/images/corgi_welcome.png`
   - 形象特征：佩戴深绿领巾（带白色无限符号 `∞`）的坐姿柯基
2. **Screen 2 (Home Screen)**:
   - 资产路径：`assets/images/corgi_resting.png`
   - 形象特征：趴在绿色圆形软垫上的悠闲柯基伙伴
3. **Screen 3 (Focus Screen)**:
   - 资产路径：`assets/images/corgi_focus.png`
   - 形象特征：佩戴绿色降噪耳机、使用印有无限标志的笔记本电脑、旁边有一盆小绿植的专注柯基
4. **统一形象组件封装**：
   - 统一由 `CorgiCompanionWidget` 驱动，支持传入 `state` 或显式指定高清 PNG 资产，自动带有自适应大小与平滑过渡。
