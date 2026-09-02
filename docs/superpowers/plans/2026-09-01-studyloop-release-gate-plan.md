# StudyLoop Release Gate Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 StudyLoop 从当前 NOT READY 推进到可本地验收、文案与权限一致、发布身份可接入的状态，但不做商店密钥签名和本轮真机购买。

**Architecture:** 保持现有分层：UI -> Riverpod ViewModel -> Domain/Repository -> Drift / RevenueCat。History 继续对所有用户开放；Pro 只锁长期 Insights。Timer 继续走时间差累计，并补齐 resumed/hidden 与恢复时重置 lastSavedAt。发布身份只改显示名，并预留 gitignore 的 keystore 接入。

**Tech Stack:** Flutter 3.44 / Dart 3.12、Riverpod、Drift/SQLite、go_router、purchases_flutter、Android `com.zzy.studyloop`

**Spec:** `STUDYLOOP_FULL_AUDIT.md`，叠加本轮已锁定决策：免费可看全部历史；显示名 + 签名配置，密钥仍由用户后续提供。

## Global Constraints

- 不删除功能、不删除测试、不改测试去迁就错误实现、不禁用 lint、不吞异常、不用假数据替代真实逻辑。
- 免费用户必须能完整走即时学习启动流程；RevenueCat 失败不得阻塞 Home / Focus / History。
- 用户提前结束不算失败；只保存实际前台专注时间。
- History 对 Free 和 Pro 都展示全部本地记录；Paywall 不得再承诺“解锁 7 天以上历史”。
- Pro 只解锁长期/跨维度 Insights（`InsightRange.threeMonths`、`InsightRange.all`，以及 `InsightEngine.proInsights`）。
- 正式签名密钥不得提交仓库；没有用户提供的 keystore 时，release 可继续用 debug 签名，但配置必须能在提供密钥后切换。
- 本轮不做 Dashboard 写入、沙盒购买或外部系统写入。
- 验证命令：`flutter analyze --no-pub`、`flutter test --no-pub`、必要时 `flutter build apk --release --no-pub`。

---

## 已锁定决策

1. **History 全部免费。** 不截断 7 天。改 Paywall / Insights CTA / 设置文案，使 Pro 只对应长期 Insights。
2. **发布身份做到显示名 + 签名接入点。** 启动器改为 `StudyLoop`；keystore 走 gitignore。真正商店签名等用户提供密钥后再做。

## 明确不做

- 商店正式签名与 Play 上传
- 本轮真机购买 / RevenueCat Dashboard 写入
- 重写架构、换状态管理、升级全部依赖
- 把 History 改成 Pro 功能
- 删除柯基聊天、演示数据或现有测试

---

## 文件边界

| 区域 | 主要文件 | 职责 |
| --- | --- | --- |
| 产品文案 | `lib/l10n/app_strings.dart`、`test/widget_test.dart`、`test/presentation/chinese_localization_test.dart` | Pro 只谈长期 Insights；Test Store 提示仅 debug |
| Insights 权限 | `lib/presentation/view_models/insights_view_model.dart`、`lib/presentation/screens/insights_screen.dart`、`lib/domain/insight_engine.dart` | Free 只看周/月；Pro 才看 3 月/全部和跨维度对比 |
| Timer 生命周期 | `lib/app.dart`、`lib/providers.dart`、`test/application/timer_notifier_test.dart` | hidden/resumed、恢复时不把离开时间算进去 |
| 首页空状态 | `lib/domain/task_breakdown_repository.dart`、`lib/presentation/screens/entry_screen.dart` | 无任务时不展示线性代数占位建议 |
| 发布身份 | `android/app/src/main/AndroidManifest.xml`、`android/app/build.gradle.kts`、`.gitignore`、`android/key.properties.example` | 显示名 StudyLoop；keystore 可选接入 |
| 验收 | `STUDYLOOP_FULL_AUDIT.md` | 记录本轮完成后的剩余风险，不把未跑的真机测试写成已通过 |

---

## Task 1: 把 Pro 从“完整历史”改成“长期 Insights”

**Files:**
- Modify: `lib/l10n/app_strings.dart`
- Modify: `lib/presentation/view_models/insights_view_model.dart`
- Modify: `lib/presentation/screens/insights_screen.dart`
- Modify: `test/widget_test.dart`
- Create: `test/presentation/insights_entitlement_test.dart`

- [ ] 改文案，使 Free/Pro 边界与决策一致：
  - `unlockProInsights`：中文 `解锁长期多维规律对比`，英文 `Unlock long-term pattern comparisons`
  - `paywallHeadline`：中文 `核心学习闭环和全部学习记录永久免费。\nPro 解锁 3 个月及以上的长期规律与跨维度对比。`，英文 `The full study loop and all local history stay free. Pro unlocks 3-month and all-time pattern comparisons.`
  - `paywallFeature2`：中文 `3 个月与全部范围的长期趋势`，英文 `Long-term trends across 3 months and all records`
  - `paywallFeature3` 保持任务类型/障碍交叉对比
- [ ] `InsightsController`：`InsightRange.threeMonths` / `InsightRange.all` 仅 `isPro == true` 时生效；Free 选择这两个范围时保持 `week` 或 `month`，并仍可打开 Paywall。
- [ ] Insights 页：Free 的 3月/全部分段显示锁，点击进 `/paywall`；有足够数据后，Pro 才渲染 `InsightEngine.proInsights` 列表。
- [ ] History 不改数据范围，继续 `recordsProvider` 全量展示。
- [ ] 测试：
  - 更新 `test/widget_test.dart` 中 `Unlock complete history and comparisons` 为新英文 CTA
  - 新增：Free 不能把 range 变成 `threeMonths`/`all`；Pro 可以；History 在 Free 下仍能读到 8 天前的记录
- [ ] 跑 `flutter test --no-pub test/widget_test.dart test/presentation/insights_entitlement_test.dart`

**Acceptance:** 免费用户能看全部 History；Paywall 不再承诺解锁历史；3月/全部 Insights 对 Free 锁定。

---

## Task 2: Test Store 文案仅 debug 显示

**Files:**
- Modify: `lib/presentation/screens/paywall_screen.dart`
- Modify: `test/presentation/chinese_localization_test.dart`

- [ ] Paywall 底部提示改为：
  - `EntitlementState.unknown` -> `paywallOfflineNotice`
  - `kDebugMode` -> `paywallTestStoreNotice`
  - 其他 release 状态不显示 Test Store 句子
- [ ] 保留现有字符串测试；再加一个 widget 测试或注释清楚：release 路径不应出现 `No real charge is made`
- [ ] 跑 `flutter test --no-pub test/presentation/chinese_localization_test.dart`

**Acceptance:** debug 仍能说明测试商店不扣费；release UI 不再承诺“不会产生真实扣款”。

---

## Task 3: Timer 生命周期与恢复

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/providers.dart`
- Modify: `test/application/timer_notifier_test.dart`

- [ ] `didChangeAppLifecycleState`：
  - `paused` / `inactive` / `hidden` -> `pauseForLifecycle()`
  - `resumed` -> 若存在未结束 snapshot 且 `running == false` 且 `needsRecovery == false`，调用 `continueSession()`；若 `needsRecovery == true`，不要自动 resume
- [ ] `TimerNotifier.restore()`：读到 snapshot 后把 `lastSavedAt` 设为现在再保存，避免把离开时间算进下一次 tick
- [ ] 测试：
  - restore 后立刻 tick，`accumulatedSeconds` 不变
  - finishEarly 后 resumed 不会把 timer 重新跑起来
- [ ] 跑 `flutter test --no-pub test/application/timer_notifier_test.dart`

**Acceptance:** 后台/恢复路径只累计前台时间；杀进程恢复不会把离开时间补进 actualSeconds。仍不把未跑的真机结果写成已验证。

---

## Task 4: 首页不再展示占位最小行动

**Files:**
- Modify: `lib/domain/task_breakdown_repository.dart`
- Modify: `lib/presentation/screens/entry_screen.dart`
- Modify: `test/presentation/view_models_test.dart`

- [ ] `getSuggestedAction`：`taskText.trim()` 为空时返回 `canStart: false`，title/description 用中性空状态，而不是线性代数第 2.1 节
- [ ] Entry 在 `canStart == false` 时显示“先写下任务”而不是假建议卡片内容
- [ ] 开始专注按钮：无 barrier 或无有效任务时保持 disabled；有 barrier 无任务时仍可走 `/task`
- [ ] 测试：初始 HomeViewState 的 suggestedAction 不是 Linear Algebra 占位文案
- [ ] 跑 `flutter test --no-pub test/presentation/view_models_test.dart test/widget_test.dart`

**Acceptance:** 冷启动首页不再假装已经为用户拆好了具体功课。

---

## Task 5: 启动器名称与签名接入

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `android/app/build.gradle.kts`
- Modify: `.gitignore`
- Create: `android/key.properties.example`

- [ ] `android:label` 改为 `StudyLoop`
- [ ] 删除 “Specify your own unique Application ID” TODO；`applicationId` 保持 `com.zzy.studyloop`
- [ ] `.gitignore` 增加 `android/key.properties`、`*.jks`、`*.keystore`
- [ ] `android/key.properties.example` 只含占位字段：`storeFile`、`storePassword`、`keyAlias`、`keyPassword`
- [ ] `build.gradle.kts`：若 `key.properties` 存在则使用它作为 release signingConfig，否则回退 debug 并保留注释说明这不是商店发布产物
- [ ] 不创建真实 keystore，不写入真实密码
- [ ] 跑 `flutter build apk --release --no-pub`

**Acceptance:** 安装后启动器显示 StudyLoop；无密钥时 release 仍能构建；密钥文件不会被 git 追踪。

---

## Task 6: 回归与审计收口

**Files:**
- Modify: `STUDYLOOP_FULL_AUDIT.md` 末尾追加“Plan Follow-up”一节，或保持原文并另写完成记录。优先更新原审计文档的 Remaining Risks / Release Recommendation，避免两份结论打架。

- [ ] `flutter analyze --no-pub`
- [ ] `flutter test --no-pub`
- [ ] `flutter build apk --release --no-pub`
- [ ] 更新审计结论：
  - History/Pro 文案不一致改为已修复
  - Test Store 文案泄漏改为已修复
  - 启动器名称改为已修复
  - 签名：配置已接入，商店签名仍待密钥
  - Timer 真机生命周期仍列为 Remaining Risk
- [ ] 发布建议改为 `READY WITH MINOR FIXES`，条件是上述命令通过，且明确剩余只是：正式 keystore、真机 Timer 脚本、integration_test

**Acceptance:** 本地门禁全绿；文档不再把已修问题当成 P0；未跑的真机项保持未验证。

---

## 验证矩阵

| 场景 | 期望 |
| --- | --- |
| 免费用户打开 History，有 8 天前记录 | 记录可见，不进 Paywall |
| 免费用户点 Insights 的 3月/全部 | 保持周/月，或进入 Paywall，不展示长期结论 |
| Pro 用户点 3月/全部 | 基于真实记录计算 |
| 空任务首页 | 无线性代数占位建议 |
| 切后台再回来 | 离开时间不计入；resume 后从累计秒继续 |
| 杀进程后冷启动点继续 | lastSavedAt 已重置，不会把离开时间补进 tick |
| debug Paywall | 可见 Test Store 不扣费说明 |
| release Paywall | 不可见 Test Store 不扣费说明 |
| 启动器 | 显示 `StudyLoop` |
| 无 key.properties 的 release 构建 | 成功，仍用 debug 签名并在 gradle 注释中标明 |

## 失败处理

- 测试因文案变更失败：先改产品字符串，再改测试断言，不要改回错误的“解锁历史”承诺。
- `key.properties` 缺失：必须能构建，不能让 CI/本地 release 失败。
- Timer 测试 flake：用 `clockProvider` 注入时间，不要用真实 `Timer.periodic` 等待。
- Insights 样本 < 3：继续只显示 empty state，禁止再引入占位图表。
