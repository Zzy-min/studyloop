# STUDYLOOP_UI_ITERATION_REPORT

日期：2026-09-02
范围：第二轮 UI / 交互优化（柯基统一、一级 Tab、任务类型、本地陪伴聊天）
仓库：`C:\Users\Lenovo\Documents\Codex\2026-08-08\revenuecat-shipaton-2026-2026-10-01`

## 1. Corgi Asset Audit

### 原问题
Welcome / Home / Chat / Focus 混用几何 SVG 和插画 PNG。聊天头像与欢迎页不是同一只柯基。

### 修改方式
所有可见柯基改为 `CorgiPortrait`，按 `DogState` 选择同一套插画：

- waiting / prompting / completed → `assets/images/corgi_welcome.png`
- focusing → `assets/images/corgi_focus.png`
- resting / interrupted → `assets/images/corgi_resting.png`

渲染统一为 `BoxFit.contain` + `FilterQuality.high`。`CorgiCompanionWidget` 不再直接 `Image.asset` / `SvgPicture`。

### 替换资产
未新增角色。仍使用现有三张插画 PNG，不再在聊天/计时圈使用 `assets/dog_svg/*.svg`。

### 组件变化
- 新增/沿用 `lib/design_system/components/corgi_portrait.dart`
- `DogCompanion`、聊天头像、欢迎页、计时圈都走该组件
- Focus 暂停时显示 resting，完成时显示 completed

### 清晰度结果
原图约 240–300px，计时圈显示约 86×78dp，头像 36dp。

真机 vivo V2458A 已覆盖安装 debug APK：

- Welcome、Home、Chat 头像都是同一只坐姿插画柯基，绿围巾 + 无穷符号。
- Chat 不再使用几何 SVG。
- 已通过真实 5 分钟任务流启动 Focus；计时圈内显示同一套 focusing 柯基（耳机、电脑、绿围巾），倒计时从 `04:59` 正常运行。

## 2. Navigation Fix

### 原路由实现
四个一级页各自 `GoRoute` + `context.go()`，每页自带 `AppBottomNavigation`。

### 异常原因
`go()` 会整页 push-style 切换，并把 Tab 当成导航栈。

### 新方案
`StatefulShellRoute.indexedStack` + `MainShell`。Home / Records / Insights / Profile 作为四个 branch，BottomNav 只存在于 shell。`/task`、`/focus`、`/chat`、`/paywall` 等二级页仍用 root navigator。

### Back 行为
一级 Tab 用 `goBranch`，不再把 Tab 压进返回栈。系统 Back 不应逐个退 Tab。

任务编辑页和起步卡页已增加显式左上角返回按钮，兼容没有三键导航栏的手势导航手机；有导航栈时返回上一页，否则分别回首页或任务页。vivo V2458A 已验证任务页返回首页。

## 3. Task Type Redesign

### 旧 UI 问题
三个选项的下拉框，视觉粗糙，覆盖面不够。

### 新类型列表
考试复习、作业、编程练习、论文写作、阅读、背诵记忆、课程预习、项目任务、其他。

英文：Exam Review / Homework / Coding / Writing / Reading / Memorization / Preview / Project / Other。

存储名保持 `examRevision` / `programmingPractice` / `paperWriting`，避免旧记录损坏。未知名解析为 `other`。

### 交互方式
Material 3 `FilterChip` + icon + selected border/checkmark。考试复习才展开 subtype chips。

### 业务映射
`StartCardEngine` 为每个类型生成 4 级最小行动。coding / writing / reading 等不再只改图标。

## 4. Companion Upgrade

### 原回复机制
`CorgiChatEngine` 按关键词 if-else 抽一句，几乎不读学习状态。

### 新 Context
`CompanionContext` 读取 barrier、taskType、当前任务、companionState、当前/上次时长、最近样本数、是否提前结束。

### Rule Engine
`CompanionResponseEngine` 按 intent 选模板。Focus 中只给短句。提前结束说“实际做了 N 分钟会被记下来”，不说失败。

### Intent
pet / phone / lowEnergy / resistance / noStartingPoint / overwhelmed / breakdown / encourage / coding / writing / exam / completed / safety / unknown。

### Fallback
无法识别时询问：不知道从哪里开始、任务太多，还是今天有点累。

### Safety
危险信号停止激励学习，提示先照顾自己并联系紧急援助。不诊断、不治疗。

最近 5 条 templateId 不立即重复。聊天仍是辅助入口，首页 CTA 仍是开始专注。

## 5. Files Changed

- `lib/domain/models.dart`
- `lib/domain/start_card_engine.dart`
- `lib/domain/corgi_chat_engine.dart`
- `lib/domain/insight_engine.dart`
- `lib/data/database/app_database.dart`
- `lib/l10n/app_strings.dart`
- `lib/app.dart`
- `lib/presentation/widgets/main_shell.dart`（新增）
- `lib/presentation/widgets/task_type_selector.dart`（新增）
- `lib/presentation/screens/entry_screen.dart`
- `lib/presentation/screens/history_screen.dart`
- `lib/presentation/screens/insights_screen.dart`
- `lib/presentation/screens/settings_screen.dart`
- `lib/presentation/screens/task_screen.dart`
- `lib/presentation/screens/corgi_chat_screen.dart`
- `lib/presentation/view_models/focus_view_model.dart`
- `lib/design_system/components/corgi_companion.dart`
- `lib/design_system/components/corgi_portrait.dart`（沿用）
- `test/domain/start_card_engine_test.dart`
- `test/domain/corgi_chat_engine_test.dart`
- `test/presentation/tab_navigation_test.dart`（新增）
- `test/widget_test.dart`
- `test/presentation/chinese_localization_test.dart`
- `test/presentation/golden_path_test.dart`
- `test/presentation/view_models_test.dart`
- `lib/presentation/screens/start_card_screen.dart`（真机标签行溢出修复）

## 6. Tests

- `flutter analyze --no-pub`：No issues found
- `flutter test --no-pub`：**66 passed**
- `flutter build apk --debug --no-pub`：成功
- vivo V2458A 覆盖安装：成功；起步卡无 RenderFlex overflow，Focus focusing 柯基已验收

覆盖：

- 9 种 TaskType × 4 级起步卡
- 5 Barrier greeting
- Focus 短回复
- 提前结束不评判
- 无法识别 fallback
- 安全信号
- 模板去重
- 一级 Tab 切换
- 中英文任务流 / Golden Path

## 7. Remaining Issues

- 三张 PNG 仍非 2x/3x density 目录；大 hero 在高 DPI 上可能略软。
- 没有 360/390/412 golden 截图。
- 未加入生成式 AI。
- 发布签名、隐私政策、Reflection skip 真实性仍是产品审计 P0/P1，不在本轮范围。
