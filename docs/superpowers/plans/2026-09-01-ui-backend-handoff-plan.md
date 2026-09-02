# StudyLoop UI 前后端交接与接口对齐实施计划 (Implementation Plan)

## 一、实施目标

基于 `docs/superpowers/specs/2026-09-01-ui-backend-handoff-spec.md`：
1. 建立标准的 4 层架构：UI (Pure) ↔ Controller / ViewState (Presentation) ↔ Repository / Domain ↔ Local Data (Drift / Purchases / Platform).
2. 将参考图中的 3 个柯基形象提取为 3x 高清透明 PNG，完整接入 Welcome、Home、Focus 等界面并注册到 `pubspec.yaml`。
3. 彻底重构 ViewState 与 Controller，消灭 UI 层的内聚业务计算（包括 Insights 的 7/30/90天过滤和图表统计、Home 层的阻力逻辑和 Timer 启动调用）。
4. 确保全部 38 项自动化测试 100% 绿色通过，且代码静态分析 0 警告。
5. 生成最终的交接文档 `UI_BACKEND_HANDOFF.md`。

---

## 二、实施分步计划

### Step 1: 资产注册与柯基形象贴图就绪
- [ ] 在 `pubspec.yaml` 中添加 `assets/images/` 资产目录。
- [ ] 验证 `assets/images/corgi_welcome.png`、`corgi_resting.png`、`corgi_focus.png` 存在并正常被 Flutter 打包。
- [ ] 升级 `lib/design_system/components/corgi_companion.dart` 与 `lib/presentation/widgets/companion_card.dart`，支持加载图片形象贴图。

### Step 2: 领域与仓库抽象层扩展 (`lib/domain/` & `lib/data/`)
- [ ] 定义通用领域异常体系：`sealed class AppFailure` (DatabaseFailure, BillingUnavailableFailure, UnknownFailure)。
- [ ] 定义结果类：`StartFocusResult`, `FinishSessionResult`。
- [ ] 抽象 `FocusSessionRepository`：
  - `startSession(SessionDraft draft)`
  - `pauseSession()`
  - `resumeSession()`
  - `finishSession()`
- [ ] 抽象 `TaskBreakdownRepository`：
  - `getMinimumAction(BarrierType barrier, String? taskText, TaskType? type)`
- [ ] 抽象 `InsightsRepository`（及 `DriftInsightsRepository`）：
  - 将所有在 `insights_screen.dart` 内的日期过滤、百分比统计、图表点位生成（`ChartPoint`）、最佳时段推导全部下沉至 `DriftInsightsRepository`。

### Step 3: 状态与 ViewModel 层规范化 (`lib/features/` or `lib/presentation/view_models/`)
- [ ] 创建 `WelcomeViewState` 与 `WelcomeController`。
- [ ] 创建 `HomeViewState`、`BarrierViewData`、`MinimumActionViewData` 与 `HomeController`。
- [ ] 创建 `FocusViewState` 与 `FocusController`。
- [ ] 创建 `InsightsViewState` 与 `InsightsController`。
- [ ] 创建 `PaywallViewState`、`ProductViewData` 与 `PaywallController`。
- [ ] 创建 `HistoryViewState`、`StudyHistoryItemViewData` 与 `HistoryController`。

### Step 4: 页面层纯表现重构 (Presentation Layer Refactoring)
- [ ] `welcome_screen.dart`: 使用 `corgi_welcome.png` 贴图，消费 `WelcomeViewState`，通过 `WelcomeController` 处理事件。
- [ ] `entry_screen.dart`: 使用 `corgi_resting.png` 贴图，消费 `HomeViewState`，去除所有 `_getGreeting` 及按钮内业务分支，全部委托 `HomeController`。
- [ ] `focus_screen.dart`: 使用 `corgi_focus.png` 贴图，消费 `FocusViewState`，倒计时与状态完全驱动自 `FocusController`。
- [ ] `insights_screen.dart`: 移除所有在 `build()` 中的循环统计、过滤与硬编码比例，直接绑定 `InsightsViewState` 中的 `points`、`bestDuration`、`bestTime`、`taskDistribution`。
- [ ] `paywall_screen.dart`: 接入 `PaywallViewState`。
- [ ] `history_screen.dart`: 接入 `HistoryViewState`。

### Step 5: 自动化测试与静态检查
- [ ] 运行 `flutter analyze`，确保 0 issues。
- [ ] 运行 `flutter test`，确保原有 38 项测试及新增架构测试全部通过。

### Step 6: 真机安装验证与交付文档
- [ ] 构建 debug APK 并安装到连接的 Vivo 手机。
- [ ] 抓取真机截图，确认形象贴图与界面数据正常工作。
- [ ] 编写并生成根目录下的正式交接文档 `UI_BACKEND_HANDOFF.md`。

---

## 三、验证方案

- **自动化验证**：
  ```bash
  flutter analyze
  flutter test
  ```
- **真机实测**：
  ```bash
  adb install -r build/app/outputs/flutter-apk/app-debug.apk
  adb shell am start -n com.zzy.studyloop/.MainActivity
  adb exec-out screencap -p > outputs/handoff_verification.png
  ```
